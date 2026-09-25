import 'dart:math';

/// The orientation of a hexagon.
enum HexagonType {
  /// Flat top and bottom edges, with corners pointing left and right.
  flat,

  /// Corners pointing up and down, with flat left and right edges.
  pointy;

  /// Deprecated alias of [flat].
  @Deprecated('Use HexagonType.flat. Will be removed in 1.0.0.')
  // ignore: constant_identifier_names
  static const FLAT = flat;

  /// Deprecated alias of [pointy].
  @Deprecated('Use HexagonType.pointy. Will be removed in 1.0.0.')
  // ignore: constant_identifier_names
  static const POINTY = pointy;
}

/// Geometry of a [HexagonType].
extension HexagonTypeExtension on HexagonType {
  static final double _ratioPointy = sqrt(3) / 2;
  static final double _ratioFlat = 1 / _ratioPointy;

  /// Width divided by height of a regular hexagon of this type: 2/√3 for
  /// [HexagonType.flat] and √3/2 for [HexagonType.pointy].
  double get ratio => isFlat ? _ratioFlat : _ratioPointy;

  /// Whether this is [HexagonType.pointy].
  bool get isPointy => this == HexagonType.pointy;

  /// Whether this is [HexagonType.flat].
  bool get isFlat => this == HexagonType.flat;

  /// Horizontal scale of a flat hexagon's layout box when `inBounds` is
  /// false.
  @Deprecated('Internal layout detail. Will be removed in 1.0.0.')
  double flatFactor(bool inBounds) => (isFlat && !inBounds) ? 0.75 : 1;

  /// Vertical scale of a pointy hexagon's layout box when `inBounds` is
  /// false.
  @Deprecated('Internal layout detail. Will be removed in 1.0.0.')
  double pointyFactor(bool inBounds) => (isPointy && !inBounds) ? 0.75 : 1;
}
