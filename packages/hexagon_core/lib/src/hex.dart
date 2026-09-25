import 'hexagon_type.dart';

/// Which rows or columns of an offset grid are shifted by half a cell.
///
/// Flat hexagons are offset by columns, pointy hexagons by rows.
enum OffsetParity {
  /// Odd columns (flat) or odd rows (pointy) are shifted down or right.
  odd,

  /// Even columns (flat) or even rows (pointy) are shifted down or right.
  even;

  int get _sign => this == OffsetParity.even ? 1 : -1;
}

/// A hexagon cell addressed with axial coordinates ([q], [r]).
///
/// The third cube coordinate [s] is derived so that `q + r + s == 0`.
/// Axial coordinates make arithmetic simple: neighbors, distances, rotations
/// and lines are all cheap integer operations. Use [Hex.fromOffset] and
/// [toOffset] (or [Hex.fromDoubled] and [toDoubled]) to talk to rectangular
/// "column/row" systems.
///
/// Directions and rotations are described on screen, where y grows downward.
final class Hex {
  /// Creates a hex from axial coordinates.
  const Hex(this.q, this.r);

  /// Creates a hex from cube coordinates. [q] + [r] + [s] must be zero.
  const Hex.cube(this.q, this.r, int s) : assert(q + r + s == 0);

  /// Creates a hex from offset ("column, row") coordinates.
  ///
  /// Flat hexagons use columns shifted by half a cell ("q-offset"), pointy
  /// hexagons use rows shifted by half a cell ("r-offset"). [parity] chooses
  /// whether odd or even columns/rows are the shifted ones.
  factory Hex.fromOffset(
    int column,
    int row,
    HexagonType type, {
    OffsetParity parity = OffsetParity.odd,
  }) {
    if (type.isFlat) {
      return Hex(column, row - (column + parity._sign * (column & 1)) ~/ 2);
    }
    return Hex(column - (row + parity._sign * (row & 1)) ~/ 2, row);
  }

  /// Creates a hex from doubled coordinates.
  ///
  /// Flat hexagons use "doubled height" (rows step by two), pointy hexagons
  /// "doubled width" (columns step by two). `column + row` must be even.
  factory Hex.fromDoubled(int column, int row, HexagonType type) {
    assert((column + row).isEven, 'column + row must be even');
    if (type.isFlat) {
      return Hex(column, (row - column) ~/ 2);
    }
    return Hex((column - row) ~/ 2, row);
  }

  /// The hex at the origin.
  static const Hex zero = Hex(0, 0);

  /// The six neighbor offsets, in counterclockwise order on screen.
  ///
  /// Use with [neighbor]: `hex.neighbor(i) == hex + Hex.directions[i]`.
  static const List<Hex> directions = [
    Hex(1, 0),
    Hex(1, -1),
    Hex(0, -1),
    Hex(-1, 0),
    Hex(-1, 1),
    Hex(0, 1),
  ];

  /// The six diagonal offsets (hexes two steps away, between two neighbors),
  /// in counterclockwise order on screen.
  static const List<Hex> diagonals = [
    Hex(2, -1),
    Hex(1, -2),
    Hex(-1, -1),
    Hex(-2, 1),
    Hex(-1, 2),
    Hex(1, 1),
  ];

  /// Axial column coordinate.
  final int q;

  /// Axial row coordinate.
  final int r;

  /// Third cube coordinate, `-q - r`.
  int get s => -q - r;

  /// Component-wise sum.
  Hex operator +(Hex other) => Hex(q + other.q, r + other.r);

  /// Component-wise difference.
  Hex operator -(Hex other) => Hex(q - other.q, r - other.r);

  /// The hex mirrored through the origin.
  Hex operator -() => Hex(-q, -r);

  /// Scales the vector from the origin to this hex by [factor].
  Hex operator *(int factor) => Hex(q * factor, r * factor);

  /// Number of steps from the origin.
  int get length => (q.abs() + r.abs() + s.abs()) ~/ 2;

  /// Number of steps to [other], moving only between neighbors.
  int distanceTo(Hex other) => (this - other).length;

  /// The neighbor in [direction] (0–5, wrapping around), see [directions].
  Hex neighbor(int direction) => this + directions[direction % 6];

  /// The six neighbors, in the order of [directions].
  List<Hex> get neighbors =>
      [for (final direction in directions) this + direction];

  /// The six diagonal neighbors, in the order of [diagonals].
  List<Hex> get diagonalNeighbors =>
      [for (final diagonal in diagonals) this + diagonal];

  /// This hex rotated 60° counterclockwise (on screen) around the origin.
  Hex rotateLeft() => Hex(-s, -q);

  /// This hex rotated 60° clockwise (on screen) around the origin.
  Hex rotateRight() => Hex(-r, -s);

  /// This hex rotated around [center] by [steps] × 60°.
  ///
  /// Positive steps rotate clockwise on screen, negative counterclockwise.
  Hex rotateAround(Hex center, int steps) {
    var vector = this - center;
    final turns = steps % 6;
    for (var i = 0; i < turns; i++) {
      vector = vector.rotateRight();
    }
    return center + vector;
  }

  /// Reflection across the axis where `q` stays constant (swaps `r` and `s`).
  Hex reflectQ() => Hex(q, s);

  /// Reflection across the axis where `r` stays constant (swaps `q` and `s`).
  Hex reflectR() => Hex(s, r);

  /// Reflection across the axis where `s` stays constant (swaps `q` and `r`).
  Hex reflectS() => Hex(r, q);

  /// The hexes on a straight line from this hex to [other], both included.
  List<Hex> lineTo(Hex other) {
    final steps = distanceTo(other);
    if (steps == 0) {
      return [this];
    }
    // Nudging the start avoids ambiguous rounding on exact edges.
    final start = FractionalHex(q + 1e-6, r + 1e-6);
    final end = FractionalHex(other.q + 1e-6, other.r + 1e-6);
    return [
      for (var i = 0; i <= steps; i++) start.lerp(end, i / steps).round(),
    ];
  }

  /// The hexes exactly [radius] steps away, counterclockwise on screen.
  ///
  /// A radius of 0 returns just this hex.
  List<Hex> ring(int radius) {
    assert(radius >= 0, 'radius must not be negative');
    if (radius == 0) {
      return [this];
    }
    final result = <Hex>[];
    var hex = this + directions[4] * radius;
    for (var side = 0; side < 6; side++) {
      for (var step = 0; step < radius; step++) {
        result.add(hex);
        hex = hex.neighbor(side);
      }
    }
    return result;
  }

  /// This hex followed by its rings of radius 1 to [radius].
  ///
  /// Contains `1 + 3 · radius · (radius + 1)` hexes.
  List<Hex> spiral(int radius) => [
        for (var k = 0; k <= radius; k++) ...ring(k),
      ];

  /// All hexes at most [radius] steps away, ordered by `q` then `r`.
  Iterable<Hex> range(int radius) sync* {
    assert(radius >= 0, 'radius must not be negative');
    for (var dq = -radius; dq <= radius; dq++) {
      final low = dq < 0 ? -radius - dq : -radius;
      final high = dq < 0 ? radius : radius - dq;
      for (var dr = low; dr <= high; dr++) {
        yield Hex(q + dq, r + dr);
      }
    }
  }

  /// Offset ("column, row") coordinates of this hex, see [Hex.fromOffset].
  ({int column, int row}) toOffset(
    HexagonType type, {
    OffsetParity parity = OffsetParity.odd,
  }) {
    if (type.isFlat) {
      return (column: q, row: r + (q + parity._sign * (q & 1)) ~/ 2);
    }
    return (column: q + (r + parity._sign * (r & 1)) ~/ 2, row: r);
  }

  /// Doubled coordinates of this hex, see [Hex.fromDoubled].
  ({int column, int row}) toDoubled(HexagonType type) {
    if (type.isFlat) {
      return (column: q, row: 2 * r + q);
    }
    return (column: 2 * q + r, row: r);
  }

  @override
  bool operator ==(Object other) => other is Hex && other.q == q && other.r == r;

  @override
  int get hashCode => Object.hash(q, r);

  @override
  String toString() => 'Hex($q, $r)';
}

/// A position between hex centers, in fractional axial coordinates.
///
/// Produced by pixel-to-hex conversion and line interpolation; [round] gives
/// the hex that contains it.
final class FractionalHex {
  /// Creates a fractional hex from axial coordinates.
  const FractionalHex(this.q, this.r);

  /// Axial column coordinate.
  final double q;

  /// Axial row coordinate.
  final double r;

  /// Third cube coordinate, `-q - r`.
  double get s => -q - r;

  /// Linear interpolation between this position and [other].
  FractionalHex lerp(FractionalHex other, double t) =>
      FractionalHex(q + (other.q - q) * t, r + (other.r - r) * t);

  /// The hex containing this position.
  Hex round() {
    var rq = q.roundToDouble();
    var rr = r.roundToDouble();
    final rs = s.roundToDouble();
    final dq = (rq - q).abs();
    final dr = (rr - r).abs();
    final ds = (rs - s).abs();
    if (dq > dr && dq > ds) {
      rq = -rr - rs;
    } else if (dr > ds) {
      rr = -rq - rs;
    }
    return Hex(rq.toInt(), rr.toInt());
  }

  @override
  bool operator ==(Object other) =>
      other is FractionalHex && other.q == q && other.r == r;

  @override
  int get hashCode => Object.hash(q, r);

  @override
  String toString() => 'FractionalHex($q, $r)';
}
