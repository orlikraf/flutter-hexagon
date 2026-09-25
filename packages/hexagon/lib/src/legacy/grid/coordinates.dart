// Pre-1.0 API, kept for compatibility and deprecated. See MIGRATION.md.
// ignore_for_file: deprecated_member_use_from_same_package, public_member_api_docs, unnecessary_this, curly_braces_in_flow_control_structures, use_key_in_widget_constructors, use_super_parameters, prefer_const_constructors_in_immutables, constant_identifier_names, sort_child_properties_last, prefer_typing_uninitialized_variables, prefer_final_fields, unnecessary_null_comparison, sized_box_for_whitespace, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

///Unified representation of cube and axial coordinates systems.
///
@Deprecated('Use Hex. Will be removed in 2.0.0.')
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

@Deprecated('Use Hex.directions. Will be removed in 2.0.0.')
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
