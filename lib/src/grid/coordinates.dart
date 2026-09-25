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
/// final area = tile.spiral(2); // this tile and two rings around it
/// ```
class Coordinates {
  /// Creates coordinates from cube components, which must sum to zero.
  const Coordinates.cube(this.x, this.y, this.z)
    : assert(x + y + z == 0, 'Cube coordinates must satisfy x + y + z == 0.');

  /// Creates coordinates from axial components.
  const Coordinates.axial(int q, int r) : x = q, y = -q - r, z = r;

  /// The tile containing the fractional axial position ([q], [r]), for
  /// example a point between tile centers.
  factory Coordinates.nearest(double q, double r) {
    final s = -q - r;
    var roundedQ = q.round();
    var roundedR = r.round();
    final roundedS = s.round();
    final errorQ = (roundedQ - q).abs();
    final errorR = (roundedR - r).abs();
    final errorS = (roundedS - s).abs();
    // Rounding each component separately can break q + r + s == 0; fix the
    // one that was rounded the furthest.
    if (errorQ > errorR && errorQ > errorS) {
      roundedQ = -roundedR - roundedS;
    } else if (errorR > errorS) {
      roundedR = -roundedQ - roundedS;
    }
    return Coordinates.axial(roundedQ, roundedR);
  }

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

  /// This offset repeated [factor] times, for example to step several tiles
  /// in one [HexDirections] direction.
  Coordinates operator *(int factor) {
    return Coordinates.cube(x * factor, y * factor, z * factor);
  }

  /// The six neighbouring tiles, clockwise on screen.
  ///
  /// The order matches [HexDirections.of] for both orientations: it starts
  /// with the neighbour to the right in a pointy grid, or to the lower
  /// right in a flat grid.
  List<Coordinates> get neighbors => [
    for (final direction in HexDirections._pointy) this + direction,
  ];

  /// The tiles exactly [radius] steps away, clockwise on screen.
  ///
  /// The ring starts [radius] steps toward [HexDirections.pointyTopLeft]
  /// (which is [HexDirections.flatTop] in a flat grid). A radius of 0 gives
  /// just this tile.
  List<Coordinates> ring(int radius) {
    assert(radius >= 0, 'radius must not be negative');
    if (radius == 0) return [this];
    final result = <Coordinates>[];
    var tile = this + HexDirections.pointyTopLeft * radius;
    for (final direction in HexDirections._pointy) {
      for (var step = 0; step < radius; step++) {
        result.add(tile);
        tile = tile + direction;
      }
    }
    return result;
  }

  /// All tiles at most [radius] steps away, ring by ring, starting with
  /// this tile: `1 + 3 * radius * (radius + 1)` tiles.
  List<Coordinates> spiral(int radius) => [
    for (var ringRadius = 0; ringRadius <= radius; ringRadius++)
      ...ring(ringRadius),
  ];

  /// This tile rotated around [Coordinates.zero] by [turns] sixths of a
  /// full turn: clockwise on screen, or counter-clockwise when negative.
  ///
  /// To rotate around another tile `center`, use
  /// `(tile - center).rotate(turns) + center`.
  Coordinates rotate(int turns) {
    var tile = this;
    for (var i = 0; i < turns % 6; i++) {
      tile = Coordinates.cube(-tile.z, -tile.x, -tile.y);
    }
    return tile;
  }

  /// The tiles on the straight line from this tile to [other], both
  /// included, each a neighbour of the next.
  List<Coordinates> lineTo(Coordinates other) {
    final steps = distance(other);
    if (steps == 0) return [this];
    // Nudge both ends off tile edges, so points exactly between two tiles
    // always round the same way.
    final startQ = q + 1e-6, startR = r + 2e-6;
    final endQ = other.q + 1e-6, endR = other.r + 2e-6;
    return [
      for (var step = 0; step <= steps; step++)
        Coordinates.nearest(
          startQ + (endQ - startQ) * step / steps,
          startR + (endR - startR) * step / steps,
        ),
    ];
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
