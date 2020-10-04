enum HexagonType { FLAT, POINTY }

extension HexagonTypeExtension on HexagonType {
  double get ratio {
    if (isPointy) return 1.1547005;
    return 1 / 1.1547005;
  }

  bool get isPointy => this == HexagonType.POINTY;

  bool get isFlat => this == HexagonType.FLAT;

  double flatFactor(bool inBounds) => (isFlat && inBounds == false) ? 0.75 : 1;

  double pointyFactor(bool inBounds) =>
      (isPointy && inBounds == false) ? 0.75 : 1;
}
