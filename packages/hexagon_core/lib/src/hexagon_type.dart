import 'dart:math' as math;

/// The square root of 3, used throughout hexagon geometry.
const double sqrt3 = 1.7320508075688772;

/// Orientation of a hexagon.
enum HexagonType {
  /// Flat top and bottom edges, corners pointing left and right.
  flat,

  /// Corners pointing up and down, flat left and right edges.
  pointy;

  /// Old name of [HexagonType.flat].
  @Deprecated('Use HexagonType.flat. Will be removed in 2.0.0.')
  // ignore: constant_identifier_names
  static const HexagonType FLAT = flat;

  /// Old name of [HexagonType.pointy].
  @Deprecated('Use HexagonType.pointy. Will be removed in 2.0.0.')
  // ignore: constant_identifier_names
  static const HexagonType POINTY = pointy;

  /// Whether this is [HexagonType.flat].
  bool get isFlat => this == HexagonType.flat;

  /// Whether this is [HexagonType.pointy].
  bool get isPointy => this == HexagonType.pointy;

  /// Width to height ratio of a regular hexagon of this type.
  ///
  /// `2 / √3` (≈ 1.155) for [flat] and `√3 / 2` (≈ 0.866) for [pointy].
  double get ratio => isFlat ? 2 / sqrt3 : sqrt3 / 2;

  /// Width of the bounding box of a regular hexagon with the given
  /// circumradius (distance from the center to a corner).
  double widthForRadius(double radius) => isFlat ? 2 * radius : sqrt3 * radius;

  /// Height of the bounding box of a regular hexagon with the given
  /// circumradius (distance from the center to a corner).
  double heightForRadius(double radius) =>
      isFlat ? sqrt3 * radius : 2 * radius;

  /// Circumradius of the largest regular hexagon that fits in a box of
  /// [width] × [height].
  double radiusToFit(double width, double height) => isFlat
      ? math.min(width / 2, height / sqrt3)
      : math.min(width / sqrt3, height / 2);

  /// Circumradius of the smallest regular hexagon that encloses a rectangle of
  /// [width] × [height] centered in it.
  double radiusToEnclose(double width, double height) => isFlat
      ? math.max(height / sqrt3, width / 2 + height / (2 * sqrt3))
      : math.max(width / sqrt3, height / 2 + width / (2 * sqrt3));

  /// Width and height of the largest-area axis-aligned rectangle inscribed in
  /// a regular hexagon with the given circumradius.
  ///
  /// For [flat] this is `radius × √3·radius`, for [pointy]
  /// `√3·radius × radius`.
  ({double width, double height}) inscribedRectForRadius(double radius) =>
      isFlat
          ? (width: radius, height: sqrt3 * radius)
          : (width: sqrt3 * radius, height: radius);
}
