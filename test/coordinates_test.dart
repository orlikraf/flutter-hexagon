import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';

/// All tiles of a hexagon-shaped grid with the given [radius].
List<Coordinates> _hexagonOfRadius(int radius) => [
  for (var q = -radius; q <= radius; q++)
    for (
      var r = math.max(-radius, -q - radius);
      r <= math.min(radius, -q + radius);
      r++
    )
      Coordinates.axial(q, r),
];

void main() {
  group('Coordinates', () {
    test('axial and cube constructors describe the same tile', () {
      expect(Coordinates.axial(1, 2), Coordinates.cube(1, -3, 2));
      expect(
        Coordinates.axial(1, 2).hashCode,
        Coordinates.cube(1, -3, 2).hashCode,
      );
    });

    test('hashCode spreads the tiles of a grid across distinct values', () {
      final tiles = _hexagonOfRadius(10);
      expect(tiles, hasLength(331));

      final hashes = tiles.map((tile) => tile.hashCode).toSet();
      expect(hashes.length, greaterThan(tiles.length * 0.95));
    });

    test('cube components must sum to zero', () {
      // Not const, so the assert runs when the test runs.
      var one = 1;
      expect(() => Coordinates.cube(one, one, one), throwsAssertionError);
    });

    test('axial coordinates can be const', () {
      const tile = Coordinates.axial(2, -1);
      expect(tile, const Coordinates.cube(2, -1, -1));
    });

    test('mirrored tiles do not share a hash code', () {
      expect(
        Coordinates.cube(1, -1, 0).hashCode,
        isNot(Coordinates.cube(-1, 1, 0).hashCode),
      );
    });
  });
}
