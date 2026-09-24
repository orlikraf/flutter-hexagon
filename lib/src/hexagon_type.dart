// TODO(phase-2): rename to lowerCamelCase with deprecated aliases.
// ignore_for_file: constant_identifier_names

import 'dart:math';

///Enum for hexagon "orientation".
enum HexagonType { FLAT, POINTY }

extension HexagonTypeExtension on HexagonType {
  static final double _ratioPointy = sqrt(3) / 2;
  static final double _ratioFlat = 1 / _ratioPointy;

  /// Hexagon width to height ratio
  double get ratio {
    if (isFlat) return _ratioFlat;
    return _ratioPointy;
  }

  /// Returns true for POINTY;
  bool get isPointy => this == HexagonType.POINTY;

  /// Returns true for FLAT;
  bool get isFlat => this == HexagonType.FLAT;

  double flatFactor(bool inBounds) => (isFlat && !inBounds) ? 0.75 : 1;

  double pointyFactor(bool inBounds) => (isPointy && !inBounds) ? 0.75 : 1;
}
