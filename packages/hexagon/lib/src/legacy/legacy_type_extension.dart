import 'package:hexagon_core/hexagon_core.dart';

/// Sizing factors used by the pre-1.0 widgets.
///
/// `ratio`, `isFlat` and `isPointy` are now members of [HexagonType] itself.
@Deprecated('Used only by the pre-1.0 widgets. Will be removed in 2.0.0.')
extension HexagonTypeExtension on HexagonType {
  /// Width factor of a flat hexagon drawn out of bounds.
  double flatFactor(bool inBounds) => (isFlat && inBounds == false) ? 0.75 : 1;

  /// Height factor of a pointy hexagon drawn out of bounds.
  double pointyFactor(bool inBounds) =>
      (isPointy && inBounds == false) ? 0.75 : 1;
}
