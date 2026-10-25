import 'package:hexagon_core/hexagon_core.dart';

/// Sizing factors used by the pre-1.0 widgets.
///
/// `ratio`, `isFlat` and `isPointy` are now members of [HexagonType] itself.
/// They are repeated here so that explicit `HexagonTypeExtension(type).ratio`
/// calls keep compiling.
@Deprecated('Used only by the pre-1.0 widgets. Will be removed in 2.0.0.')
extension HexagonTypeExtension on HexagonType {
  /// Width to height ratio of a regular hexagon of this type.
  double get ratio => isFlat ? 2 / sqrt3 : sqrt3 / 2;

  /// Whether this is [HexagonType.flat].
  bool get isFlat => this == HexagonType.flat;

  /// Whether this is [HexagonType.pointy].
  bool get isPointy => this == HexagonType.pointy;

  /// Width factor of a flat hexagon drawn out of bounds.
  double flatFactor(bool inBounds) => (isFlat && inBounds == false) ? 0.75 : 1;

  /// Height factor of a pointy hexagon drawn out of bounds.
  double pointyFactor(bool inBounds) =>
      (isPointy && inBounds == false) ? 0.75 : 1;
}
