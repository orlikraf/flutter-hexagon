import 'dart:math';

import '../hexagon_type.dart';

/// The position of a tile in a hexagonal grid, in cube or axial
/// coordinates.
///
/// Cube coordinates `(x, y, z)` always satisfy `x + y + z == 0`. Axial
/// coordinates `(q, r)` describe the same tile without the redundant `y`:
/// `q == x` and `r == z`. See
/// [Hexagonal Grids](https://www.redblobgames.com/grids/hexagons/#coordinates)
/// on Red Blob Games.
///
/// ```dart
/// const tile = Coordinates.axial(1, 2);
/// assert(tile == Coordinates.cube(1, -3, 2));
/// final neighbour = tile + HexDirections.pointyRight;
/// ```
class Coordinates {
  /// Creates coordinates from cube components, which must sum to zero.
  const Coordinates.cube(this.x, this.y, this.z)
    : assert(x + y + z == 0, 'Cube coordinates must satisfy x + y + z == 0.');

  /// Creates coordinates from axial components.
  const Coordinates.axial(int q, int r) : x = q, y = -q - r, z = r;

  /// The cube x component. Equal to [q].
  final int x;

  /// The cube y component. Equal to `-q - r`.
  final int y;

  /// The cube z component. Equal to [r].
  final int z;

  /// The axial q (column) component.
  int get q => x;

  /// The axial r (row) component.
  int get r => z;

  /// The number of steps from this tile to [other], where each step crosses
  /// one edge into a neighbouring tile.
  int distance(Coordinates other) {
    return max(
      (x - other.x).abs(),
      max((y - other.y).abs(), (z - other.z).abs()),
    );
  }

  /// The tile reached by moving by [other], for example a [HexDirections]
  /// step.
  Coordinates operator +(Coordinates other) {
    return Coordinates.cube(x + other.x, y + other.y, z + other.z);
  }

  /// The offset from [other] to this tile.
  Coordinates operator -(Coordinates other) {
    return Coordinates.cube(x - other.x, y - other.y, z - other.z);
  }

  @override
  bool operator ==(Object other) =>
      other is Coordinates && other.x == x && other.y == y && other.z == z;

  @override
  int get hashCode => Object.hash(x, y, z);

  /// The center tile of a `HexagonGrid`.
  static const Coordinates zero = Coordinates.cube(0, 0, 0);

  @override
  String toString() => 'Coordinates[cube: ($x, $y, $z), axial: ($q, $r)]';
}

/// Steps to the six neighbours of a tile, as [Coordinates] to add to it.
///
/// Names describe where the neighbour appears on screen, for grids of
/// pointy or flat hexagons. [of] lists all six for a [HexagonType].
abstract final class HexDirections {
  /// The neighbour to the right, in a pointy grid.
  static const pointyRight = Coordinates.axial(1, 0);

  /// The neighbour to the upper right, in a pointy grid.
  static const pointyTopRight = Coordinates.axial(1, -1);

  /// The neighbour to the upper left, in a pointy grid.
  static const pointyTopLeft = Coordinates.axial(0, -1);

  /// The neighbour to the left, in a pointy grid.
  static const pointyLeft = Coordinates.axial(-1, 0);

  /// The neighbour to the lower left, in a pointy grid.
  static const pointyBottomLeft = Coordinates.axial(-1, 1);

  /// The neighbour to the lower right, in a pointy grid.
  static const pointyBottomRight = Coordinates.axial(0, 1);

  /// The neighbour above, in a flat grid.
  static const flatTop = Coordinates.axial(0, -1);

  /// The neighbour to the upper right, in a flat grid.
  static const flatTopRight = Coordinates.axial(1, -1);

  /// The neighbour to the lower right, in a flat grid.
  static const flatBottomRight = Coordinates.axial(1, 0);

  /// The neighbour below, in a flat grid.
  static const flatBottom = Coordinates.axial(0, 1);

  /// The neighbour to the lower left, in a flat grid.
  static const flatBottomLeft = Coordinates.axial(-1, 1);

  /// The neighbour to the upper left, in a flat grid.
  static const flatTopLeft = Coordinates.axial(-1, 0);

  /// The six directions for [type], clockwise on screen, starting with the
  /// neighbour to the right ([HexagonType.pointy]) or to the lower right
  /// ([HexagonType.flat]).
  static List<Coordinates> of(HexagonType type) =>
      type.isPointy ? _pointy : _flat;

  static const _pointy = [
    pointyRight,
    pointyBottomRight,
    pointyBottomLeft,
    pointyLeft,
    pointyTopLeft,
    pointyTopRight,
  ];

  static const _flat = [
    flatBottomRight,
    flatBottom,
    flatBottomLeft,
    flatTopLeft,
    flatTop,
    flatTopRight,
  ];

  /// Deprecated alias of [pointyBottomRight].
  @Deprecated('Use pointyBottomRight. Will be removed in 1.0.0.')
  static const pointyDownRight = pointyBottomRight;

  /// Deprecated alias of [pointyBottomLeft].
  @Deprecated('Use pointyBottomLeft. Will be removed in 1.0.0.')
  static const pointyDownLeft = pointyBottomLeft;

  /// Deprecated alias of [flatBottom].
  @Deprecated('Use flatBottom. Will be removed in 1.0.0.')
  static const flatDown = flatBottom;

  /// Deprecated alias of [flatTopRight].
  @Deprecated('Use flatTopRight. Will be removed in 1.0.0.')
  static const flatRightTop = flatTopRight;

  /// Deprecated alias of [flatBottomRight].
  @Deprecated('Use flatBottomRight. Will be removed in 1.0.0.')
  static const flatRightDown = flatBottomRight;

  /// Deprecated alias of [flatTopLeft].
  @Deprecated('Use flatTopLeft. Will be removed in 1.0.0.')
  static const flatLeftTop = flatTopLeft;

  /// Deprecated alias of [flatBottomLeft].
  @Deprecated('Use flatBottomLeft. Will be removed in 1.0.0.')
  static const flatLeftDown = flatBottomLeft;
}
