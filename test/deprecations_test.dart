// These tests use the deprecated names on purpose: they must keep working
// until 1.0.0.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';

void main() {
  test('uppercase enum names are aliases of the new values', () {
    expect(HexagonType.FLAT, same(HexagonType.flat));
    expect(HexagonType.POINTY, same(HexagonType.pointy));
    expect(GridType.EVEN, same(GridType.even));
    expect(GridType.ODD, same(GridType.odd));
  });

  test('old direction names are aliases of the new ones', () {
    expect(HexDirections.pointyDownRight, HexDirections.pointyBottomRight);
    expect(HexDirections.pointyDownLeft, HexDirections.pointyBottomLeft);
    expect(HexDirections.flatDown, HexDirections.flatBottom);
    expect(HexDirections.flatRightTop, HexDirections.flatTopRight);
    expect(HexDirections.flatRightDown, HexDirections.flatBottomRight);
    expect(HexDirections.flatLeftTop, HexDirections.flatTopLeft);
    expect(HexDirections.flatLeftDown, HexDirections.flatBottomLeft);
  });

  test('flatFactor and pointyFactor keep their values', () {
    expect(HexagonType.flat.flatFactor(false), 0.75);
    expect(HexagonType.flat.flatFactor(true), 1);
    expect(HexagonType.flat.pointyFactor(false), 1);
    expect(HexagonType.pointy.pointyFactor(false), 0.75);
    expect(HexagonType.pointy.pointyFactor(true), 1);
    expect(HexagonType.pointy.flatFactor(false), 1);
  });
}
