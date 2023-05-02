import 'dart:math';

///Unified representation of cube and axial coordinates systems.
///
class Coordinates {
  ///Cube constructor
  const Coordinates.cube(this.x, this.y, this.z);

  ///Axial constructor
  Coordinates.axial(int q, int r)
      : this.x = q,
        this.y = (-q - r).toInt(),
        this.z = r;

  final int x, y, z;

  int get q => x;

  int get r => z;

  ///Distance measured in steps between tiles. A single step is only going over edge of neighbouring tiles.
  int distance(Coordinates other) {
    return max(
        (x - other.x).abs(), max((y - other.y).abs(), (z - other.z).abs()));
  }

  Coordinates operator +(Coordinates other) {
    return Coordinates.cube(x + other.x, y + other.y, z + other.z);
  }

  Coordinates operator -(Coordinates other) {
    return Coordinates.cube(x - other.x, y - other.y, z - other.z);
  }

  @override
  bool operator ==(Object other) =>
      other is Coordinates && other.x == x && other.y == y && other.z == z;

  @override
  int get hashCode => x ^ y ^ z;

  ///Constant value of space center
  static const Coordinates zero = Coordinates.cube(0, 0, 0);

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
