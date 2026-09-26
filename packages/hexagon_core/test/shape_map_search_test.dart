import 'package:hexagon_core/hexagon_core.dart';
import 'package:test/test.dart';

void main() {
  group('HexShape', () {
    test('hexagon', () {
      expect(HexShape.hexagon(0), [Hex.zero]);
      expect(HexShape.hexagon(3).length, 37);
      expect(
          HexShape.hexagon(1, center: const Hex(5, 5)).first, const Hex(5, 5));
    });

    test('rectangle matches offset coordinates', () {
      final cells = HexShape.rectangle(4, 3, type: HexagonType.pointy);
      expect(cells.length, 12);
      expect(cells.toSet().length, 12);
      final offsets = {
        for (final hex in cells) hex.toOffset(HexagonType.pointy),
      };
      for (var row = 0; row < 3; row++) {
        for (var column = 0; column < 4; column++) {
          expect(offsets, contains((column: column, row: row)));
        }
      }
    });

    test('parallelogram and triangle', () {
      expect(HexShape.parallelogram(3, 2).length, 6);
      expect(HexShape.triangle(4).length, 10);
      expect(HexShape.triangle(4, flipped: true).length, 10);
      expect(HexShape.triangle(4).toSet(),
          isNot(HexShape.triangle(4, flipped: true).toSet()));
    });
  });

  group('HexMap', () {
    test('stores values per hex', () {
      final map = HexMap<String>.fromCells(HexShape.hexagon(1), (h) => '$h');
      expect(map.length, 7);
      expect(map[Hex.zero], 'Hex(0, 0)');
      map[const Hex(9, 9)] = 'far';
      expect(map.containsKey(const Hex(9, 9)), isTrue);
      expect(map.remove(const Hex(9, 9)), 'far');
      expect(map.neighborsOf(Hex.zero).length, 6);
      expect(map.neighborsOf(const Hex(1, 0)).length, 3);
      expect(map.where((hex, value) => hex == Hex.zero), [Hex.zero]);
      expect(HexMap.of(map).length, 7);
    });
  });

  group('HexSearch', () {
    final walls = {const Hex(1, 0), const Hex(1, -1), const Hex(0, 1)};
    bool open(Hex hex) => hex.length <= 4 && !walls.contains(hex);

    test('reachable respects movement, walls and cost', () {
      final free = Hex.zero.reachable(movement: 2);
      expect(free.length, 19);
      expect(free[Hex.zero], 0);
      expect(free[const Hex(2, 0)], 2);

      final walled = Hex.zero.reachable(movement: 1, passable: open);
      expect(walled.keys.toSet(), {
        Hex.zero,
        const Hex(0, -1),
        const Hex(-1, 0),
        const Hex(-1, 1),
      });

      final expensive = Hex.zero.reachable(
        movement: 3,
        cost: (from, to) => to.q > 0 ? 3 : 1,
      );
      expect(expensive[const Hex(1, 0)], 3);
      expect(expensive.containsKey(const Hex(2, 0)), isFalse);

      final blocked = Hex.zero.reachable(movement: 5, cost: (a, b) => null);
      expect(blocked, {Hex.zero: 0.0});
    });

    test('pathTo finds a shortest path', () {
      expect(Hex.zero.pathTo(Hex.zero), [Hex.zero]);
      final direct = Hex.zero.pathTo(const Hex(3, -1))!;
      expect(direct.length, 4);
      expect(direct.first, Hex.zero);
      expect(direct.last, const Hex(3, -1));

      final around = Hex.zero.pathTo(const Hex(2, 0), passable: open)!;
      for (final hex in around) {
        expect(walls, isNot(contains(hex)));
      }
      for (var i = 1; i < around.length; i++) {
        expect(around[i - 1].distanceTo(around[i]), 1);
      }
      expect(around.length - 1, greaterThan(2));
    });

    test('pathTo prefers cheap terrain', () {
      final swamp = {const Hex(1, 0)};
      final path = Hex.zero.pathTo(
        const Hex(2, 0),
        cost: (from, to) => swamp.contains(to) ? 10 : 1,
      )!;
      expect(path, isNot(contains(const Hex(1, 0))));
      expect(path.length, 4);
    });

    test('pathTo returns null when unreachable', () {
      final enclosed = Hex.zero.neighbors.toSet();
      expect(
        Hex.zero.pathTo(
          const Hex(3, 0),
          passable: (h) => !enclosed.contains(h),
          maxVisited: 500,
        ),
        isNull,
      );
      expect(
        Hex.zero.pathTo(const Hex(3, 0), passable: (h) => h != const Hex(3, 0)),
        isNull,
      );
    });

    test('line of sight and field of view', () {
      bool blocks(Hex hex) => hex == const Hex(1, 0);
      expect(Hex.zero.canSee(const Hex(1, 0), blocksSight: blocks), isTrue);
      expect(Hex.zero.canSee(const Hex(3, 0), blocksSight: blocks), isFalse);
      expect(Hex.zero.canSee(const Hex(0, 3), blocksSight: blocks), isTrue);

      final view = Hex.zero.fieldOfView(3, blocksSight: blocks);
      expect(view, contains(Hex.zero));
      expect(view, contains(const Hex(1, 0)));
      expect(view, isNot(contains(const Hex(3, 0))));
      expect(view.length, lessThan(37));
    });
  });
}
