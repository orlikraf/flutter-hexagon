import 'hex.dart';
import 'hex_layout.dart';
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

  /// A triangle with [size] cells along its base, pointing in [pointing].
  ///
  /// When the base runs along the hexagons' flat sides (pointy hexagons
  /// pointing [HexTrianglePointing.up] or [HexTrianglePointing.down], flat
  /// hexagons pointing [HexTrianglePointing.left] or
  /// [HexTrianglePointing.right]) the triangle is exact: every side has
  /// [size] cells and it holds `size · (size + 1) / 2` of them. In the other
  /// four combinations, such as flat hexagons pointing up, the base is a
  /// zigzag and the sides are stepped; the cells are those whose centers fall
  /// inside an equilateral triangle over the base. Odd sizes give symmetric
  /// stepped triangles.
  ///
  /// [pointing] defaults to [HexTrianglePointing.up], so the triangle rests
  /// on its base.
  ///
  /// By default [origin] is the first cell of the base: its leftmost cell,
  /// or its topmost cell when the triangle points left or right. With
  /// [centered] the triangle is instead centered on [origin] (on the nearest
  /// hex, when the exact center falls between hexes). With [hollow] only the
  /// cells on its edges are returned.
  static List<Hex> triangle(
    int size, {
    HexagonType type = HexagonType.flat,
    HexTrianglePointing pointing = HexTrianglePointing.up,
    Hex origin = Hex.zero,
    bool centered = false,
    bool hollow = false,
  }) {
    if (size < 0) {
      throw ArgumentError.value(size, 'size', 'must not be negative');
    }
    if (size == 0) {
      return [];
    }
    var cells = switch ((type, pointing)) {
      // Exact triangles. Flat pointing right and pointy pointing down share
      // their axial cells, as do flat pointing left and pointy pointing up.
      (HexagonType.flat, HexTrianglePointing.right) ||
      (HexagonType.pointy, HexTrianglePointing.down) =>
        [
          for (var q = 0; q < size; q++)
            for (var r = 0; r < size - q; r++) Hex(q, r),
        ],
      (HexagonType.flat, HexTrianglePointing.left) ||
      (HexagonType.pointy, HexTrianglePointing.up) =>
        [
          for (var q = 0; q < size; q++)
            for (var r = size - 1 - q; r < size; r++) Hex(q, r),
        ],
      // Stepped triangles, all derived from flat hexagons pointing up.
      // reflectQ flips flat layouts vertically; swapping q and r turns a
      // flat layout into a pointy one mirrored along the diagonal, so
      // "up" becomes "left"; reflectR flips pointy layouts horizontally.
      (HexagonType.flat, HexTrianglePointing.up) => _steppedFlatUp(size),
      (HexagonType.flat, HexTrianglePointing.down) => [
          for (final hex in _steppedFlatUp(size)) hex.reflectQ(),
        ],
      (HexagonType.pointy, HexTrianglePointing.left) => [
          for (final hex in _steppedFlatUp(size)) hex.reflectS(),
        ],
      (HexagonType.pointy, HexTrianglePointing.right) => [
          for (final hex in _steppedFlatUp(size)) hex.reflectS().reflectR(),
        ],
    };
    if (hollow) {
      cells = outline(cells);
    }
    if (centered) {
      return centerOn(cells, origin);
    }
    final shift = origin - _baseStart(cells, type, pointing);
    return [for (final hex in cells) hex + shift];
  }

  /// Flat hexagons forming a stepped triangle that points up: the cells
  /// whose centers lie inside an equilateral triangle standing on a zigzag
  /// base of [size] columns.
  static List<Hex> _steppedFlatUp(int size) {
    // With radius 1, columns are 1.5 apart and a column's cells are √3 apart:
    // x = 1.5 q, y = √3 (r + q / 2). The base spans the columns' centers plus
    // half a column on each side, so the end columns are included.
    const epsilon = 1e-9;
    const left = -0.75;
    final right = 1.5 * (size - 1) + 0.75;
    final height = (right - left) * sqrt3 / 2;
    return [
      for (var q = 0; q < size; q++)
        for (var r = (-height / sqrt3 - q / 2).floor();
            r <= (-q / 2).ceil();
            r++)
          if (_insideUpTriangle(
              1.5 * q, sqrt3 * (r + q / 2), left, right, epsilon))
            Hex(q, r),
    ];
  }

  static bool _insideUpTriangle(
    double x,
    double y,
    double left,
    double right,
    double epsilon,
  ) =>
      y <= epsilon &&
      y >= -sqrt3 * (x - left) - epsilon &&
      y >= -sqrt3 * (right - x) - epsilon;

  /// The first cell of the triangle's base: leftmost for triangles pointing
  /// up or down, topmost for triangles pointing left or right.
  static Hex _baseStart(
    List<Hex> cells,
    HexagonType type,
    HexTrianglePointing pointing,
  ) {
    final layout = HexLayout(type: type, radius: 1);
    // Sort key: the base is at the far end from the apex; ties break toward
    // the left or the top.
    (double, double) key(Hex hex) {
      final p = layout.hexToPixel(hex);
      return switch (pointing) {
        HexTrianglePointing.up => (-p.y, p.x),
        HexTrianglePointing.down => (p.y, p.x),
        HexTrianglePointing.left => (-p.x, p.y),
        HexTrianglePointing.right => (p.x, p.y),
      };
    }

    var best = cells.first;
    var bestKey = key(best);
    for (final hex in cells.skip(1)) {
      final k = key(hex);
      // Cells on the base share the first coordinate up to rounding.
      if (k.$1 < bestKey.$1 - 1e-6 ||
          (k.$1 <= bestKey.$1 + 1e-6 && k.$2 < bestKey.$2)) {
        best = hex;
        bestKey = k;
      }
    }
    return best;
  }

  /// The cells of [cells] on the edge of the shape: those with at least one
  /// neighbor outside it. Keeps the original order.
  ///
  /// Turns any shape into its outline, e.g. `outline(HexShape.hexagon(3))`
  /// is the ring of radius 3.
  static List<Hex> outline(Iterable<Hex> cells) {
    final set = cells.toSet();
    return [
      for (final hex in cells)
        if (hex.neighbors.any((neighbor) => !set.contains(neighbor))) hex,
    ];
  }

  /// [cells] moved so that their center lands on [center] (on the nearest
  /// hex, when the exact center falls between hexes). Keeps the order.
  ///
  /// Works with any shape, e.g. `centerOn(HexShape.rectangle(6, 4), hex)`.
  static List<Hex> centerOn(Iterable<Hex> cells, Hex center) {
    final list = cells.toList();
    if (list.isEmpty) {
      return list;
    }
    var q = 0;
    var r = 0;
    for (final hex in list) {
      q += hex.q;
      r += hex.r;
    }
    final middle = FractionalHex(q / list.length, r / list.length).round();
    final shift = center - middle;
    return [for (final hex in list) hex + shift];
  }
}

/// The direction a [HexShape.triangle] points on screen.
enum HexTrianglePointing {
  /// Apex at the top, resting on the base.
  up,

  /// Apex at the bottom.
  down,

  /// Apex on the left.
  left,

  /// Apex on the right.
  right,
}
