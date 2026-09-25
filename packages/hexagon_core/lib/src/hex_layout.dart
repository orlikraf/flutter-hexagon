import 'dart:math' as math;

import 'hex.dart';
import 'hexagon_type.dart';
import 'pixel.dart';

/// Maps hexes to pixel positions and back.
///
/// A layout is defined by the hexagon [type], the [radius] of each hexagon
/// (distance from its center to a corner), the [spacing] between neighboring
/// hexagons' edges, and the pixel position of `Hex(0, 0)`'s center
/// ([origin]).
///
/// The same layout object can drive painting, hit testing and game logic, so
/// a hex is always at the same place whichever of them asks.
final class HexLayout {
  /// Creates a layout.
  const HexLayout({
    this.type = HexagonType.flat,
    required this.radius,
    this.spacing = 0,
    this.origin = PixelPoint.zero,
  })  : assert(radius > 0, 'radius must be positive'),
        assert(spacing >= 0, 'spacing must not be negative');

  /// Creates a layout of flat hexagons.
  const HexLayout.flat({
    required double radius,
    double spacing = 0,
    PixelPoint origin = PixelPoint.zero,
  }) : this(
          type: HexagonType.flat,
          radius: radius,
          spacing: spacing,
          origin: origin,
        );

  /// Creates a layout of pointy hexagons.
  const HexLayout.pointy({
    required double radius,
    double spacing = 0,
    PixelPoint origin = PixelPoint.zero,
  }) : this(
          type: HexagonType.pointy,
          radius: radius,
          spacing: spacing,
          origin: origin,
        );

  /// Orientation of the hexagons.
  final HexagonType type;

  /// Distance from a hexagon's center to its corners, in pixels.
  final double radius;

  /// Gap between the edges of neighboring hexagons, in pixels.
  final double spacing;

  /// Pixel position of the center of `Hex(0, 0)`.
  final PixelPoint origin;

  /// Radius of the hexagons if they were packed without spacing, which is
  /// what determines how far apart their centers are.
  double get _step => radius + spacing / sqrt3;

  /// Width of one hexagon's bounding box.
  double get cellWidth => type.widthForRadius(radius);

  /// Height of one hexagon's bounding box.
  double get cellHeight => type.heightForRadius(radius);

  /// Horizontal distance between the centers of neighboring columns.
  double get horizontalStep => type.isFlat ? 1.5 * _step : sqrt3 * _step;

  /// Vertical distance between the centers of neighboring rows.
  double get verticalStep => type.isFlat ? sqrt3 * _step : 1.5 * _step;

  /// Pixel position of the center of [hex].
  PixelPoint hexToPixel(Hex hex) {
    final step = _step;
    if (type.isFlat) {
      return PixelPoint(
        origin.x + step * 1.5 * hex.q,
        origin.y + step * (sqrt3 / 2 * hex.q + sqrt3 * hex.r),
      );
    }
    return PixelPoint(
      origin.x + step * (sqrt3 * hex.q + sqrt3 / 2 * hex.r),
      origin.y + step * 1.5 * hex.r,
    );
  }

  /// Fractional hex coordinates of a pixel position.
  FractionalHex pixelToFractionalHex(PixelPoint point) {
    final step = _step;
    final x = (point.x - origin.x) / step;
    final y = (point.y - origin.y) / step;
    if (type.isFlat) {
      return FractionalHex(2 / 3 * x, -1 / 3 * x + sqrt3 / 3 * y);
    }
    return FractionalHex(sqrt3 / 3 * x - 1 / 3 * y, 2 / 3 * y);
  }

  /// The hex whose center is nearest to a pixel position.
  ///
  /// With [spacing], points in the gap between hexagons map to the nearest
  /// one.
  Hex pixelToHex(PixelPoint point) => pixelToFractionalHex(point).round();

  /// The six corners of [hex], clockwise on screen.
  ///
  /// Flat hexagons start with the right corner, pointy hexagons with the top
  /// one.
  List<PixelPoint> corners(Hex hex) {
    final center = hexToPixel(hex);
    final hw = cellWidth / 2;
    final hh = cellHeight / 2;
    if (type.isFlat) {
      return [
        PixelPoint(center.x + hw, center.y),
        PixelPoint(center.x + hw / 2, center.y + hh),
        PixelPoint(center.x - hw / 2, center.y + hh),
        PixelPoint(center.x - hw, center.y),
        PixelPoint(center.x - hw / 2, center.y - hh),
        PixelPoint(center.x + hw / 2, center.y - hh),
      ];
    }
    return [
      PixelPoint(center.x, center.y - hh),
      PixelPoint(center.x + hw, center.y - hh / 2),
      PixelPoint(center.x + hw, center.y + hh / 2),
      PixelPoint(center.x, center.y + hh),
      PixelPoint(center.x - hw, center.y + hh / 2),
      PixelPoint(center.x - hw, center.y - hh / 2),
    ];
  }

  /// Bounding box of [hex].
  PixelRect cellBounds(Hex hex) => PixelRect.fromCenter(
        center: hexToPixel(hex),
        width: cellWidth,
        height: cellHeight,
      );

  /// Bounding box of all [cells], or [PixelRect.zero] if there are none.
  PixelRect boundsOf(Iterable<Hex> cells) {
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;
    for (final hex in cells) {
      final center = hexToPixel(hex);
      minX = math.min(minX, center.x);
      minY = math.min(minY, center.y);
      maxX = math.max(maxX, center.x);
      maxY = math.max(maxY, center.y);
    }
    if (minX == double.infinity) {
      return PixelRect.zero;
    }
    final hw = cellWidth / 2;
    final hh = cellHeight / 2;
    return PixelRect.fromLTRB(minX - hw, minY - hh, maxX + hw, maxY + hh);
  }

  /// Every hex whose bounding box overlaps [rect].
  ///
  /// Use it to find the cells visible in a viewport without scanning a whole
  /// map. The number of hexes is proportional to the area of [rect].
  Iterable<Hex> hexesInRect(PixelRect rect) sync* {
    final step = _step;
    final hw = cellWidth / 2;
    final hh = cellHeight / 2;
    final left = rect.left - origin.x - hw;
    final right = rect.right - origin.x + hw;
    final top = rect.top - origin.y - hh;
    final bottom = rect.bottom - origin.y + hh;
    if (type.isFlat) {
      // x = 1.5·step·q, y = √3·step·(r + q/2)
      final firstQ = (left / (1.5 * step)).ceil();
      final lastQ = (right / (1.5 * step)).floor();
      final rowStep = sqrt3 * step;
      for (var q = firstQ; q <= lastQ; q++) {
        final firstR = (top / rowStep - q / 2).ceil();
        final lastR = (bottom / rowStep - q / 2).floor();
        for (var r = firstR; r <= lastR; r++) {
          yield Hex(q, r);
        }
      }
    } else {
      // x = √3·step·(q + r/2), y = 1.5·step·r
      final firstR = (top / (1.5 * step)).ceil();
      final lastR = (bottom / (1.5 * step)).floor();
      final columnStep = sqrt3 * step;
      for (var r = firstR; r <= lastR; r++) {
        final firstQ = (left / columnStep - r / 2).ceil();
        final lastQ = (right / columnStep - r / 2).floor();
        for (var q = firstQ; q <= lastQ; q++) {
          yield Hex(q, r);
        }
      }
    }
  }

  /// A copy of this layout with the given fields replaced.
  HexLayout copyWith({
    HexagonType? type,
    double? radius,
    double? spacing,
    PixelPoint? origin,
  }) =>
      HexLayout(
        type: type ?? this.type,
        radius: radius ?? this.radius,
        spacing: spacing ?? this.spacing,
        origin: origin ?? this.origin,
      );

  @override
  bool operator ==(Object other) =>
      other is HexLayout &&
      other.type == type &&
      other.radius == radius &&
      other.spacing == spacing &&
      other.origin == origin;

  @override
  int get hashCode => Object.hash(type, radius, spacing, origin);

  @override
  String toString() =>
      'HexLayout(type: ${type.name}, radius: $radius, spacing: $spacing, '
      'origin: $origin)';
}
