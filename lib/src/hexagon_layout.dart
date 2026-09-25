import 'hexagon_type.dart';

/// Layout box scales shared by the widgets. Not exported.
///
/// With `inBounds` false, a hexagon's pointed ends may overflow its layout
/// box by an eighth of its size on each side, so neighbouring tiles in a
/// grid interlock. The box is then 3/4 of the hexagon along that axis.
extension HexagonLayout on HexagonType {
  /// Box width divided by hexagon width.
  double widthFactor(bool inBounds) => (isFlat && !inBounds) ? 0.75 : 1;

  /// Box height divided by hexagon height.
  double heightFactor(bool inBounds) => (isPointy && !inBounds) ? 0.75 : 1;
}
