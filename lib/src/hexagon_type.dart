import 'dart:math';

///Enum for hexagon "orientation".
enum HexagonType { FLAT, POINTY }

extension HexagonTypeExtension on HexagonType {
  static double _ratioPointy = (sqrt(3) / 2);
  static double _ratioFlat = 1 / _ratioPointy;

  /// Hexagon width to height ratio
  double get ratio {
    if (isFlat) return _ratioFlat;
    return _ratioPointy;
  }

  /// Returns true for POINTY;
  bool get isPointy => this == HexagonType.POINTY;

  /// Returns true for FLAT;
  bool get isFlat => this == HexagonType.FLAT;

  double flatFactor(bool inBounds) => (isFlat && inBounds == false) ? 0.75 : 1;

  double pointyFactor(bool inBounds) =>
      (isPointy && inBounds == false) ? 0.75 : 1;
}
