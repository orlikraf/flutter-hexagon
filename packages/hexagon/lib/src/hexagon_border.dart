import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/painting.dart';
import 'package:hexagon_core/hexagon_core.dart';

import 'geometry.dart';

/// A hexagon-shaped border, usable anywhere Flutter accepts a [ShapeBorder].
///
/// ```dart
/// Material(shape: const HexagonBorder(), elevation: 4, child: ...)
/// Card(shape: const HexagonBorder(type: HexagonType.pointy), child: ...)
/// ElevatedButton(style: ElevatedButton.styleFrom(shape: const HexagonBorder()), ...)
/// DecoratedBox(decoration: const ShapeDecoration(shape: HexagonBorder(), color: ...))
/// ClipPath.shape(shape: const HexagonBorder(cornerRadius: 8), child: ...)
/// ```
///
/// By default the hexagon is regular and as large as fits in the box, centered
/// ([eccentricity] 0). Set [eccentricity] to 1 to stretch it to the box.
///
/// Borders of the same [type] animate smoothly between each other, including
/// [cornerRadius], [eccentricity] and [side].
class HexagonBorder extends OutlinedBorder {
  /// Creates a hexagon border.
  const HexagonBorder({
    this.type = HexagonType.flat,
    this.cornerRadius = 0,
    this.eccentricity = 0,
    super.side,
  })  : assert(cornerRadius >= 0),
        assert(eccentricity >= 0 && eccentricity <= 1);

  /// Orientation of the hexagon.
  final HexagonType type;

  /// Radius of the rounded corners, in logical pixels.
  final double cornerRadius;

  /// How much the hexagon is stretched to fill its box: 0 keeps it regular,
  /// 1 makes it touch all four sides.
  final double eccentricity;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.strokeInset);

  @override
  ShapeBorder scale(double t) => HexagonBorder(
        type: type,
        cornerRadius: cornerRadius * t,
        eccentricity: eccentricity,
        side: side.scale(t),
      );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is HexagonBorder && a.type == type) {
      return HexagonBorder(
        type: type,
        cornerRadius: math.max(0, lerpDouble(a.cornerRadius, cornerRadius, t)!),
        eccentricity:
            lerpDouble(a.eccentricity, eccentricity, t)!.clamp(0.0, 1.0),
        side: BorderSide.lerp(a.side, side, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is HexagonBorder && b.type == type) {
      return HexagonBorder(
        type: type,
        cornerRadius: math.max(0, lerpDouble(cornerRadius, b.cornerRadius, t)!),
        eccentricity:
            lerpDouble(eccentricity, b.eccentricity, t)!.clamp(0.0, 1.0),
        side: BorderSide.lerp(side, b.side, t),
      );
    }
    return super.lerpTo(b, t);
  }

  Path _path(Rect rect, double offset) {
    var corners = hexagonCorners(rect, type, eccentricity: eccentricity);
    if (offset != 0) {
      corners = offsetPolygon(corners, offset);
    }
    return roundedPolygonPath(
      corners,
      cornerRadius: cornerRadius > 0 ? math.max(0, cornerRadius + offset) : 0,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect, -side.strokeInset);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect, 0);

  @override
  bool get preferPaintInterior => true;

  @override
  void paintInterior(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    TextDirection? textDirection,
  }) {
    canvas.drawPath(getOuterPath(rect), paint);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) {
      return;
    }
    canvas.drawPath(_path(rect, side.strokeOffset / 2), side.toPaint());
  }

  @override
  HexagonBorder copyWith({
    BorderSide? side,
    HexagonType? type,
    double? cornerRadius,
    double? eccentricity,
  }) =>
      HexagonBorder(
        type: type ?? this.type,
        cornerRadius: cornerRadius ?? this.cornerRadius,
        eccentricity: eccentricity ?? this.eccentricity,
        side: side ?? this.side,
      );

  @override
  bool operator ==(Object other) =>
      other is HexagonBorder &&
      other.type == type &&
      other.cornerRadius == cornerRadius &&
      other.eccentricity == eccentricity &&
      other.side == side;

  @override
  int get hashCode => Object.hash(type, cornerRadius, eccentricity, side);

  @override
  String toString() =>
      'HexagonBorder(${type.name}, cornerRadius: $cornerRadius, '
      'eccentricity: $eccentricity, $side)';
}
