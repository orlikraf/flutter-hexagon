import 'dart:math' as math;
import 'dart:ui';

import 'package:hexagon_core/hexagon_core.dart';

/// Converts between `hexagon_core` pixel types and Flutter's [Offset].
extension PixelPointOffset on PixelPoint {
  /// This point as an [Offset].
  Offset toOffset() => Offset(x, y);
}

/// Converts between `hexagon_core` pixel types and Flutter's [Rect].
extension PixelRectRect on PixelRect {
  /// This rectangle as a [Rect].
  Rect toRect() => Rect.fromLTRB(left, top, right, bottom);
}

/// Converts a Flutter [Offset] to a `hexagon_core` [PixelPoint].
extension OffsetPixelPoint on Offset {
  /// This offset as a [PixelPoint].
  PixelPoint toPixelPoint() => PixelPoint(dx, dy);
}

/// Converts a Flutter [Rect] to a `hexagon_core` [PixelRect].
extension RectPixelRect on Rect {
  /// This rectangle as a [PixelRect].
  PixelRect toPixelRect() => PixelRect.fromLTRB(left, top, right, bottom);
}

/// [HexLayout] methods that take and return Flutter types.
extension HexLayoutFlutter on HexLayout {
  /// Center of [hex] as an [Offset].
  Offset centerOf(Hex hex) => hexToPixel(hex).toOffset();

  /// Bounding box of [hex] as a [Rect].
  Rect rectOf(Hex hex) => cellBounds(hex).toRect();

  /// Bounding box of all [cells] as a [Rect].
  Rect rectOfAll(Iterable<Hex> cells) => boundsOf(cells).toRect();

  /// The hex whose center is nearest to [position].
  Hex hexAt(Offset position) => pixelToHex(position.toPixelPoint());

  /// Every hex whose bounding box overlaps [rect].
  Iterable<Hex> hexesIn(Rect rect) => hexesInRect(rect.toPixelRect());
}

/// Corners of a hexagon of [type] placed in [rect], clockwise on screen.
///
/// With [eccentricity] 0 the hexagon is regular and as large as fits in
/// [rect], centered. With 1 it is stretched to touch all four sides of
/// [rect]. Values in between interpolate.
List<Offset> hexagonCorners(
  Rect rect,
  HexagonType type, {
  double eccentricity = 0,
}) {
  final radius = type.radiusToFit(rect.width, rect.height);
  final width = lerpDouble(
    type.widthForRadius(radius),
    rect.width,
    eccentricity,
  )!;
  final height = lerpDouble(
    type.heightForRadius(radius),
    rect.height,
    eccentricity,
  )!;
  final c = rect.center;
  final hw = width / 2;
  final hh = height / 2;
  if (type.isFlat) {
    return [
      Offset(c.dx + hw, c.dy),
      Offset(c.dx + hw / 2, c.dy + hh),
      Offset(c.dx - hw / 2, c.dy + hh),
      Offset(c.dx - hw, c.dy),
      Offset(c.dx - hw / 2, c.dy - hh),
      Offset(c.dx + hw / 2, c.dy - hh),
    ];
  }
  return [
    Offset(c.dx, c.dy - hh),
    Offset(c.dx + hw, c.dy - hh / 2),
    Offset(c.dx + hw, c.dy + hh / 2),
    Offset(c.dx, c.dy + hh),
    Offset(c.dx - hw, c.dy + hh / 2),
    Offset(c.dx - hw, c.dy - hh / 2),
  ];
}

/// Moves every edge of the convex polygon [corners] outward by [distance]
/// (inward when negative).
List<Offset> offsetPolygon(List<Offset> corners, double distance) {
  if (distance == 0) {
    return corners;
  }
  final count = corners.length;
  return [
    for (var i = 0; i < count; i++)
      _offsetCorner(
        corners[(i - 1 + count) % count],
        corners[i],
        corners[(i + 1) % count],
        distance,
      ),
  ];
}

Offset _offsetCorner(Offset previous, Offset corner, Offset next, double d) {
  final toPrevious = previous - corner;
  final toNext = next - corner;
  if (toPrevious.distance == 0 || toNext.distance == 0) {
    return corner;
  }
  final a = toPrevious / toPrevious.distance;
  final b = toNext / toNext.distance;
  final bisector = -(a + b);
  if (bisector.distance == 0) {
    return corner;
  }
  final halfAngle = _angleBetween(a, b) / 2;
  return corner + bisector / bisector.distance * (d / math.sin(halfAngle));
}

double _angleBetween(Offset a, Offset b) {
  final cos = (a.dx * b.dx + a.dy * b.dy).clamp(-1.0, 1.0);
  return math.acos(cos);
}

/// A closed path through [corners], with corners rounded by [cornerRadius].
///
/// The rounding is a true circular arc of [cornerRadius], shrunk if a corner's
/// edges are too short for it.
Path roundedPolygonPath(List<Offset> corners, {double cornerRadius = 0}) {
  final path = Path();
  if (corners.isEmpty) {
    return path;
  }
  if (cornerRadius <= 0) {
    return path..addPolygon(corners, true);
  }
  final count = corners.length;
  for (var i = 0; i < count; i++) {
    final previous = corners[(i - 1 + count) % count];
    final corner = corners[i];
    final next = corners[(i + 1) % count];
    final toPrevious = previous - corner;
    final toNext = next - corner;
    final lengthPrevious = toPrevious.distance;
    final lengthNext = toNext.distance;
    if (lengthPrevious == 0 || lengthNext == 0) {
      if (i == 0) {
        path.moveTo(corner.dx, corner.dy);
      } else {
        path.lineTo(corner.dx, corner.dy);
      }
      continue;
    }
    final a = toPrevious / lengthPrevious;
    final b = toNext / lengthNext;
    final angle = _angleBetween(a, b);
    final tangent = math.min(
      cornerRadius / math.tan(angle / 2),
      math.min(lengthPrevious, lengthNext) / 2,
    );
    final start = corner + a * tangent;
    final end = corner + b * tangent;
    if (i == 0) {
      path.moveTo(start.dx, start.dy);
    } else {
      path.lineTo(start.dx, start.dy);
    }
    // A conic with weight sin(angle / 2) is an exact circular arc.
    path.conicTo(corner.dx, corner.dy, end.dx, end.dy, math.sin(angle / 2));
  }
  return path..close();
}
