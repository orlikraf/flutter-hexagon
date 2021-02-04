import 'dart:math';

///Unified representation of cube and axial coordinates systems.
///
class Coordinates {
  Coordinates.cube(this.x, this.y, this.z)
      : assert(x != null),
        assert(y != null),
        assert(z != null);

  Coordinates.axial(int q, int r)
      : assert(q != null),
        assert(r != null),
        this.x = q,
        this.y = (-q - r).toInt(),
        this.z = r;

  final int x, y, z;

  int get q => x;

  int get r => z;

  Coordinates operator +(Coordinates other) {
    return Coordinates.cube(x + other.x, y + other.y, z + other.z);
  }

  Coordinates operator -(Coordinates other) {
    return Coordinates.cube(x - other.x, y - other.y, z - other.z);
  }

  int distance(Coordinates other) {
    return max(
        (x - other.x).abs(), max((y - other.y).abs(), (z - other.z).abs()));
  }

  @override
  bool operator ==(Object other) =>
      other is Coordinates && other.x == x && other.y == y && other.z == z;

  @override
  int get hashCode => x ^ y ^ z;

  static Coordinates zero = Coordinates.cube(0, 0, 0);

  @override
  String toString() => 'Coordinates[cube: ($x, $y, $z), axial: ($q, $r)]';
}

class HexDirections {
  static Coordinates pointyRight = Coordinates.axial(1, 0);
  static Coordinates pointyLeft = Coordinates.axial(-1, 0);
  static Coordinates pointyTopRight = Coordinates.axial(1, -1);
  static Coordinates pointyTopLeft = Coordinates.axial(0, -1);
  static Coordinates pointyDownRight = Coordinates.axial(0, 1);
  static Coordinates pointyDownLeft = Coordinates.axial(-1, 1);

  static Coordinates flatTop = Coordinates.axial(0, -1);
  static Coordinates flatDown = Coordinates.axial(0, 1);
  static Coordinates flatRightTop = Coordinates.axial(1, -1);
  static Coordinates flatRightDown = Coordinates.axial(1, 0);
  static Coordinates flatLeftTop = Coordinates.axial(-1, 0);
  static Coordinates flatLeftDown = Coordinates.axial(-1, 1);
}

class Tile<T> {
  final Coordinates coordinates;
  final T item;

  Tile(this.coordinates, this.item);
}
