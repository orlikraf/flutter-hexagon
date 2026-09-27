import 'dart:math' as math;

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

    test('parallelogram', () {
      expect(HexShape.parallelogram(3, 2).length, 6);
    });

    group('triangle', () {
      // Groups the cells' pixel centers into rows (pointy) or columns (flat)
      // and returns the cell count of each, ordered top to bottom or left to
      // right.
      List<int> lineLengths(List<Hex> cells, HexagonType type) {
        final layout = HexLayout(type: type, radius: 10);
        final counts = <int, int>{};
        for (final hex in cells) {
          final center = layout.hexToPixel(hex);
          final key = (type.isFlat ? center.x : center.y).round();
          counts[key] = (counts[key] ?? 0) + 1;
        }
        final keys = counts.keys.toList()..sort();
        return [for (final key in keys) counts[key]!];
      }

      final cases = {
        (HexagonType.pointy, HexTrianglePointing.up): [1, 2, 3, 4],
        (HexagonType.pointy, HexTrianglePointing.down): [4, 3, 2, 1],
        (HexagonType.flat, HexTrianglePointing.left): [1, 2, 3, 4],
        (HexagonType.flat, HexTrianglePointing.right): [4, 3, 2, 1],
      };

      test('points where asked', () {
        cases.forEach((key, expected) {
          final (type, pointing) = key;
          final cells = HexShape.triangle(4, type: type, pointing: pointing);
          expect(cells.length, 10, reason: '$key');
          expect(cells.toSet().length, 10, reason: '$key');
          expect(lineLengths(cells, type), expected, reason: '$key');
        });
      });

      test('stepped triangles point where asked', () {
        for (final (type, pointing) in [
          (HexagonType.flat, HexTrianglePointing.up),
          (HexagonType.flat, HexTrianglePointing.down),
          (HexagonType.pointy, HexTrianglePointing.left),
          (HexagonType.pointy, HexTrianglePointing.right),
        ]) {
          for (var size = 1; size <= 9; size++) {
            final cells =
                HexShape.triangle(size, type: type, pointing: pointing);
            final reason = '$type $pointing $size';
            final layout = HexLayout(type: type, radius: 10);
            final points = [for (final hex in cells) layout.hexToPixel(hex)];
            final vertical = pointing == HexTrianglePointing.up ||
                pointing == HexTrianglePointing.down;
            // Position along the base, and distance toward the apex.
            double along(PixelPoint p) => vertical ? p.x : p.y;
            double toward(PixelPoint p) => switch (pointing) {
                  HexTrianglePointing.up => -p.y,
                  HexTrianglePointing.down => p.y,
                  HexTrianglePointing.left => -p.x,
                  HexTrianglePointing.right => p.x,
                };

            expect(cells.toSet().length, cells.length, reason: reason);
            // The base spans `size` lines of cells.
            expect(
              points.map((p) => along(p).round()).toSet().length,
              size,
              reason: reason,
            );
            // A single cell at the apex.
            final apex = points.map(toward).reduce(math.max);
            expect(
              points.where((p) => toward(p) > apex - 1e-6).length,
              1,
              reason: reason,
            );
            // Grows with the size.
            if (size > 1) {
              expect(
                cells.length,
                greaterThan(
                  HexShape.triangle(size - 1, type: type, pointing: pointing)
                      .length,
                ),
                reason: reason,
              );
            }
            // Odd sizes are symmetric around the apex.
            if (size.isOdd) {
              final middle = (points.map(along).reduce(math.min) +
                      points.map(along).reduce(math.max)) /
                  2;
              final positions = {
                for (final p in points)
                  (along(p).round(), toward(p).round()),
              };
              final mirrored = {
                for (final p in points)
                  ((2 * middle - along(p)).round(), toward(p).round()),
              };
              expect(mirrored, positions, reason: reason);
            }
          }
        }
      });

      test('defaults to pointing up, resting on its base', () {
        expect(
          HexShape.triangle(3, type: HexagonType.pointy),
          HexShape.triangle(
            3,
            type: HexagonType.pointy,
            pointing: HexTrianglePointing.up,
          ),
        );
      });

      test('origin is the first cell of the base', () {
        const layout = HexLayout.pointy(radius: 10);
        final up = HexShape.triangle(4, type: HexagonType.pointy);
        final bottom =
            up.map((h) => layout.hexToPixel(h).y).reduce(math.max);
        final baseRow =
            up.where((h) => layout.hexToPixel(h).y == bottom).toList();
        expect(baseRow.length, 4);
        expect(baseRow, contains(Hex.zero));
        expect(
          baseRow.every(
            (h) => layout.hexToPixel(h).x >= layout.hexToPixel(Hex.zero).x,
          ),
          isTrue,
        );
        for (final pointing in HexTrianglePointing.values) {
          for (final type in HexagonType.values) {
            expect(
              HexShape.triangle(5, type: type, pointing: pointing),
              contains(Hex.zero),
              reason: '$type $pointing',
            );
          }
        }
        expect(() => HexShape.triangle(-1), throwsArgumentError);
        expect(HexShape.triangle(0), isEmpty);
      });

      test('origin, centered and hollow', () {
        const origin = Hex(5, -2);
        final moved = HexShape.triangle(4, origin: origin);
        expect(
          moved.toSet(),
          {for (final hex in HexShape.triangle(4)) hex + origin},
        );

        for (final size in [1, 2, 3, 4, 5, 6, 7]) {
          final centered =
              HexShape.triangle(size, origin: origin, centered: true);
          const layout = HexLayout.flat(radius: 10);
          var x = 0.0;
          var y = 0.0;
          for (final hex in centered) {
            x += layout.hexToPixel(hex).x;
            y += layout.hexToPixel(hex).y;
          }
          final middle = PixelPoint(x / centered.length, y / centered.length);
          // Within one hex of the requested center.
          expect(
            middle.distanceTo(layout.hexToPixel(origin)),
            lessThanOrEqualTo(layout.horizontalStep * 1.2),
            reason: 'size $size',
          );
        }

        const pointy = HexagonType.pointy;
        expect(HexShape.triangle(0, type: pointy, hollow: true), isEmpty);
        expect(HexShape.triangle(1, type: pointy, hollow: true).length, 1);
        for (final size in [2, 3, 4, 8]) {
          final hollow = HexShape.triangle(size, type: pointy, hollow: true);
          expect(hollow.length, 3 * (size - 1), reason: 'size $size');
          expect(
            HexShape.triangle(size, type: pointy).toSet().containsAll(hollow),
            isTrue,
          );
        }
        // Stepped triangles can be hollow too.
        final stepped = HexShape.triangle(7);
        final steppedHollow = HexShape.triangle(7, hollow: true);
        expect(steppedHollow.length, lessThan(stepped.length));
        expect(stepped.toSet().containsAll(steppedHollow), isTrue);
      });
    });

    test('outline and centerOn work on any shape', () {
      expect(HexShape.outline(HexShape.hexagon(3)).toSet(),
          Hex.zero.ring(3).toSet());
      expect(HexShape.outline(const []), isEmpty);
      expect(HexShape.outline(HexShape.rectangle(4, 3)).length, 10);

      final centered = HexShape.centerOn(HexShape.hexagon(2), const Hex(3, 3));
      expect(centered.first, const Hex(3, 3));
      expect(centered.length, 19);
      expect(HexShape.centerOn(const [], Hex.zero), isEmpty);
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
