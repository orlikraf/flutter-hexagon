import 'dart:math';
import 'dart:ui';

import 'hexagon_layout.dart';
import 'hexagon_type.dart';

/// Builds the outline of a hexagon for a given size.
///
/// Used by `HexagonPainter` and `HexagonClipper`, and useful for custom
/// painting or clipping in the same shape as a `HexagonWidget`.
class HexagonPathBuilder {
  /// The orientation of the hexagon.
  final HexagonType type;

  /// Whether the hexagon must fit inside the size given to [build].
  ///
  /// When false, its pointed ends overflow by an eighth of the hexagon on
  /// each side, as tiles do in the grids.
  final bool inBounds;

  /// Radius of the rounded corners. Values <= 0 give sharp corners; values
  /// larger than the hexagon allows are clamped.
  final double borderRadius;

  /// Creates a path builder for hexagons of [type].
  HexagonPathBuilder(this.type, {this.inBounds = true, this.borderRadius = 0});

  /// Builds the largest hexagon path that fits in [size], centered.
  Path build(Size size) => _hexagonPath(size);

  Point<double> _flatHexagonCorner(Offset center, double size, int i) {
    var angleDeg = 60 * i;
    var angleRad = pi / 180 * angleDeg;
    return Point(
      center.dx + size * cos(angleRad),
      center.dy + size * sin(angleRad),
    );
  }

  Point<double> _pointyHexagonCorner(Offset center, double size, int i) {
    var angleDeg = 60 * i - 30;
    var angleRad = pi / 180 * angleDeg;
    return Point(
      center.dx + size * cos(angleRad),
      center.dy + size * sin(angleRad),
    );
  }

  /// Calculates hexagon corners for given size and center.
  List<Point<double>> _flatHexagonCornerList(Offset center, double size) =>
      List<Point<double>>.generate(
        6,
        (index) => _flatHexagonCorner(center, size, index),
        growable: false,
      );

  /// Calculates hexagon corners for given size and center.
  List<Point<double>> _pointyHexagonCornerList(Offset center, double size) =>
      List<Point<double>>.generate(
        6,
        (index) => _pointyHexagonCorner(center, size, index),
        growable: false,
      );

  /// The point [distance] away from [start] in the direction of [end].
  Point<double> _pointTowards(
    Point<double> start,
    Point<double> end,
    double distance,
  ) {
    final fraction = distance / start.distanceTo(end);
    return start + (end - start) * fraction;
  }

  /// Where the rounding of [corner] starts, on the edge from the previous
  /// corner.
  Point<double> _radiusStart(
    Point<double> corner,
    int index,
    List<Point<double>> cornerList,
    double radius,
  ) {
    var prevCorner = index > 0
        ? cornerList[index - 1]
        : cornerList[cornerList.length - 1];
    return _pointTowards(corner, prevCorner, radius * tan(pi / 6));
  }

  /// Where the rounding of [corner] ends, on the edge to the next corner.
  Point<double> _radiusEnd(
    Point<double> corner,
    int index,
    List<Point<double>> cornerList,
    double radius,
  ) {
    var nextCorner = index < cornerList.length - 1
        ? cornerList[index + 1]
        : cornerList[0];
    return _pointTowards(corner, nextCorner, radius * tan(pi / 6));
  }

  /// The circumradius of the largest hexagon that fits in [size].
  ///
  /// When [inBounds] is false, the pointed ends may overflow the box by an
  /// eighth of the hexagon on each side.
  double _circumradius(Size size) {
    if (type.isFlat) {
      return min(
        size.width / type.widthFactor(inBounds) / 2,
        size.height / sqrt(3),
      );
    }
    return min(
      size.height / type.heightFactor(inBounds) / 2,
      size.width / sqrt(3),
    );
  }

  /// Returns path in shape of hexagon.
  Path _hexagonPath(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final circumradius = _circumradius(size);

    final cornerList = type.isFlat
        ? _flatHexagonCornerList(center, circumradius)
        : _pointyHexagonCornerList(center, circumradius);

    // Beyond the apothem, neighbouring corner arcs would overlap and the
    // path would intersect itself. At the apothem the hexagon is a circle.
    final cornerRadius = min(
      max(borderRadius, 0.0),
      circumradius * sqrt(3) / 2,
    );

    final path = Path();
    if (cornerRadius > 0) {
      for (var index = 0; index < cornerList.length; index++) {
        final point = cornerList[index];
        final rStart = _radiusStart(point, index, cornerList, cornerRadius);
        final rEnd = _radiusEnd(point, index, cornerList, cornerRadius);
        if (index == 0) {
          path.moveTo(rStart.x, rStart.y);
        } else {
          path.lineTo(rStart.x, rStart.y);
        }
        path.arcToPoint(
          Offset(rEnd.x, rEnd.y),
          radius: Radius.circular(cornerRadius),
        );
      }
    } else {
      for (var index = 0; index < cornerList.length; index++) {
        final point = cornerList[index];
        if (index == 0) {
          path.moveTo(point.x, point.y);
        } else {
          path.lineTo(point.x, point.y);
        }
      }
    }

    return path..close();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HexagonPathBuilder &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          inBounds == other.inBounds &&
          borderRadius == other.borderRadius;

  @override
  int get hashCode => Object.hash(type, inBounds, borderRadius);
}
