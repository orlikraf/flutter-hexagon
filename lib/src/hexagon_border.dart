import 'dart:math';

import 'package:flutter/widgets.dart';

import 'geometry/hex_metrics.dart';
import 'hexagon_path_builder.dart';
import 'hexagon_type.dart';

/// A hexagon-shaped border, for anything that takes a [ShapeBorder].
///
/// The hexagon is the largest one that fits the rectangle, centered. Use it
/// with `Material`, `Card`, `InkWell.customBorder`, [ShapeDecoration] or
/// [ShapeBorderClipper], and set [side] to draw an outline:
///
/// ```dart
/// Material(
///   color: Colors.teal,
///   shape: const HexagonBorder(
///     type: HexagonType.pointy,
///     cornerRadius: 8,
///     side: BorderSide(color: Colors.white, width: 2),
///   ),
///   clipBehavior: Clip.antiAlias,
///   child: InkWell(onTap: () {}, child: const SizedBox(width: 120, height: 139)),
/// )
/// ```
///
/// Borders of the same [type] animate smoothly between corner radii and
/// sides.
class HexagonBorder extends OutlinedBorder {
  /// Creates a hexagon-shaped border.
  const HexagonBorder({
    required this.type,
    this.cornerRadius = 0.0,
    super.side,
  });

  /// The orientation of the hexagon.
  final HexagonType type;

  /// Radius of the rounded corners. Values <= 0 give sharp corners; values
  /// larger than the hexagon allows are clamped.
  final double cornerRadius;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.strokeInset);

  /// The largest hexagon that fits in [rect], with every edge moved [inset]
  /// toward the center (away from it when negative).
  Path _path(Rect rect, double inset) {
    final radius = HexMetrics.circumradius(type, rect.size, true);
    if (radius <= 0) return Path();
    // Moving each edge by `inset` changes the circumradius by
    // `inset * 2 / √3`, and the corner radius by `inset`.
    final scale = max(0.0, radius - inset * 2 / HexMetrics.sqrt3) / radius;
    final scaled = Rect.fromCenter(
      center: rect.center,
      width: rect.width * scale,
      height: rect.height * scale,
    );
    return HexagonPathBuilder(
      type,
      borderRadius: max(0.0, cornerRadius - inset),
    ).build(scaled.size).shift(scaled.topLeft);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect, 0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect, side.strokeInset);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;
    // The stroke is centered on its path, so offset the path to put the
    // stroke inside, centered on or outside the outline per strokeAlign.
    canvas.drawPath(
      _path(rect, side.strokeInset - side.width / 2),
      side.toPaint(),
    );
  }

  @override
  HexagonBorder scale(double t) => HexagonBorder(
    type: type,
    cornerRadius: cornerRadius * t,
    side: side.scale(t),
  );

  @override
  HexagonBorder copyWith({
    BorderSide? side,
    HexagonType? type,
    double? cornerRadius,
  }) => HexagonBorder(
    type: type ?? this.type,
    cornerRadius: cornerRadius ?? this.cornerRadius,
    side: side ?? this.side,
  );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is HexagonBorder && a.type == type) {
      return HexagonBorder(
        type: type,
        cornerRadius: a.cornerRadius + (cornerRadius - a.cornerRadius) * t,
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
        cornerRadius: cornerRadius + (b.cornerRadius - cornerRadius) * t,
        side: BorderSide.lerp(side, b.side, t),
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  bool operator ==(Object other) =>
      other is HexagonBorder &&
      other.type == type &&
      other.cornerRadius == cornerRadius &&
      other.side == side;

  @override
  int get hashCode => Object.hash(type, cornerRadius, side);

  @override
  String toString() =>
      'HexagonBorder(type: ${type.name}, cornerRadius: $cornerRadius, '
      'side: $side)';
}
