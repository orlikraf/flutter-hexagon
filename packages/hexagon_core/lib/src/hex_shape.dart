import 'hex.dart';
import 'hexagon_type.dart';

/// Ready-made sets of hexes for common map and grid shapes.
abstract final class HexShape {
  /// A hexagon-shaped area: [center] and every hex within [radius] steps.
  ///
  /// Contains `1 + 3 · radius · (radius + 1)` hexes, in spiral order starting
  /// from [center].
  static List<Hex> hexagon(int radius, {Hex center = Hex.zero}) {
    assert(radius >= 0, 'radius must not be negative');
    return center.spiral(radius);
  }

  /// A rectangle of [columns] × [rows] cells in offset coordinates.
  ///
  /// Flat hexagons produce columns shifted by half a cell, pointy hexagons
  /// rows shifted by half a cell; [parity] chooses which ones. Cells are
  /// returned row by row, starting at ([firstColumn], [firstRow]).
  static List<Hex> rectangle(
    int columns,
    int rows, {
    HexagonType type = HexagonType.flat,
    OffsetParity parity = OffsetParity.odd,
    int firstColumn = 0,
    int firstRow = 0,
  }) {
    assert(columns >= 0 && rows >= 0, 'size must not be negative');
    return [
      for (var row = firstRow; row < firstRow + rows; row++)
        for (var column = firstColumn; column < firstColumn + columns; column++)
          Hex.fromOffset(column, row, type, parity: parity),
    ];
  }

  /// A parallelogram of [width] × [height] cells along the `q` and `r` axes,
  /// with [origin] at one corner.
  static List<Hex> parallelogram(
    int width,
    int height, {
    Hex origin = Hex.zero,
  }) {
    assert(width >= 0 && height >= 0, 'size must not be negative');
    return [
      for (var r = 0; r < height; r++)
        for (var q = 0; q < width; q++) Hex(origin.q + q, origin.r + r),
    ];
  }

  /// A triangle with [size] cells along each side and [origin] at one corner.
  ///
  /// [flipped] points the triangle the other way.
  static List<Hex> triangle(
    int size, {
    bool flipped = false,
    Hex origin = Hex.zero,
  }) {
    assert(size >= 0, 'size must not be negative');
    return [
      for (var q = 0; q < size; q++)
        if (flipped)
          for (var r = size - 1 - q; r < size; r++)
            Hex(origin.q + q, origin.r + r)
        else
          for (var r = 0; r < size - q; r++) Hex(origin.q + q, origin.r + r),
    ];
  }
}
