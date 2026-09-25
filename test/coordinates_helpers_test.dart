import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';

/// Whether each tile in [tiles] is a neighbour of the next.
bool _isConnected(List<Coordinates> tiles) {
  for (var i = 0; i + 1 < tiles.length; i++) {
    if (tiles[i].distance(tiles[i + 1]) != 1) return false;
  }
  return true;
}

void main() {
  const tile = Coordinates.axial(2, -1);

  test('multiplying repeats a step', () {
    expect(HexDirections.pointyRight * 3, const Coordinates.axial(3, 0));
    expect(tile * 0, Coordinates.zero);
  });

  test('neighbors are the six HexDirections steps, in order', () {
    for (final type in HexagonType.values) {
      expect(tile.neighbors, [
        for (final direction in HexDirections.of(type)) tile + direction,
      ]);
    }
    expect(tile.neighbors.every((n) => tile.distance(n) == 1), isTrue);
  });

  group('ring', () {
    test('radius 0 is the tile itself', () {
      expect(tile.ring(0), [tile]);
    });

    for (var radius = 1; radius <= 4; radius++) {
      test('radius $radius: 6 × radius tiles at that distance, in a loop', () {
        final ring = tile.ring(radius);
        expect(ring, hasLength(6 * radius));
        expect(ring.toSet(), hasLength(6 * radius));
        expect(ring.every((t) => tile.distance(t) == radius), isTrue);
        expect(_isConnected([...ring, ring.first]), isTrue);
      });
    }

    test('starts toward the top left and goes clockwise', () {
      final directions = HexDirections.of(HexagonType.pointy);
      expect(Coordinates.zero.ring(1), [
        ...directions.skip(4),
        ...directions.take(4),
      ]);
    });
  });

  test('spiral covers every tile within the radius once', () {
    final spiral = tile.spiral(3);
    expect(spiral, hasLength(1 + 3 * 3 * 4));
    expect(spiral.toSet(), hasLength(spiral.length));
    expect(spiral.first, tile);
    expect(spiral.every((t) => tile.distance(t) <= 3), isTrue);
  });

  group('rotate', () {
    test('one turn moves each direction to the next clockwise', () {
      final directions = HexDirections.of(HexagonType.pointy);
      for (var i = 0; i < 6; i++) {
        expect(directions[i].rotate(1), directions[(i + 1) % 6]);
      }
    });

    test('six turns, and turning back, restore the tile', () {
      expect(tile.rotate(6), tile);
      expect(tile.rotate(2).rotate(-2), tile);
      expect(tile.rotate(-1), tile.rotate(5));
    });

    test('keeps the distance from the center', () {
      for (var turns = 0; turns < 6; turns++) {
        expect(
          tile.rotate(turns).distance(Coordinates.zero),
          tile.distance(Coordinates.zero),
        );
      }
    });
  });

  test('nearest rounds fractional positions to a valid tile', () {
    expect(Coordinates.nearest(2, -1), const Coordinates.axial(2, -1));
    expect(Coordinates.nearest(0.9, 0.05), const Coordinates.axial(1, 0));
    expect(Coordinates.nearest(-1.1, 2.3), const Coordinates.axial(-1, 2));
  });

  group('lineTo', () {
    test('to itself is the tile', () {
      expect(tile.lineTo(tile), [tile]);
    });

    test('is connected, with one tile per step', () {
      for (final target in [
        const Coordinates.axial(3, -1),
        const Coordinates.axial(-2, 4),
        const Coordinates.axial(-5, -1),
      ]) {
        final line = tile.lineTo(target);
        expect(line.first, tile);
        expect(line.last, target);
        expect(line, hasLength(tile.distance(target) + 1));
        expect(_isConnected(line), isTrue, reason: 'line to $target');
      }
    });

    test('along a direction is that direction repeated', () {
      expect(Coordinates.zero.lineTo(HexDirections.flatBottom * 3), [
        for (var i = 0; i <= 3; i++) HexDirections.flatBottom * i,
      ]);
    });
  });
}
