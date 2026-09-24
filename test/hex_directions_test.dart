import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';

import 'test_utils.dart';

void main() {
  group('HexDirections.of', () {
    for (final type in HexagonType.values) {
      test('${type.name}: six distinct neighbours that cancel out', () {
        final directions = HexDirections.of(type);
        expect(directions, hasLength(6));
        expect(directions.toSet(), hasLength(6));
        for (final direction in directions) {
          expect(Coordinates.zero.distance(direction), 1);
        }
        expect(
          directions.reduce((sum, direction) => sum + direction),
          Coordinates.zero,
        );
      });

      // The names describe where neighbours appear on screen, so check them
      // against a rendered grid.
      testWidgets('${type.name}: clockwise on screen around a tile', (
        tester,
      ) async {
        await tester.pumpWidget(
          boxed(
            const Size(600, 600),
            HexagonGrid(
              hexType: type,
              depth: 1,
              buildChild: (coordinates) =>
                  Text('${coordinates.q},${coordinates.r}'),
            ),
          ),
        );

        final center = tester.getCenter(find.text('0,0'));
        final start = type.isPointy ? 0 : 30;
        final directions = HexDirections.of(type);
        for (var i = 0; i < directions.length; i++) {
          final direction = directions[i];
          final offset =
              tester.getCenter(find.text('${direction.q},${direction.r}')) -
              center;
          final angle = offset.direction * 180 / math.pi;
          final expected = start + 60 * i;
          final difference = (angle - expected + 540) % 360 - 180;
          expect(
            difference.abs(),
            lessThan(1),
            reason: 'direction $i ($direction) is at $angle°, not $expected°',
          );
        }
      });
    }
  });

  test('named directions match their position in HexDirections.of', () {
    expect(HexDirections.of(HexagonType.pointy), [
      HexDirections.pointyRight,
      HexDirections.pointyBottomRight,
      HexDirections.pointyBottomLeft,
      HexDirections.pointyLeft,
      HexDirections.pointyTopLeft,
      HexDirections.pointyTopRight,
    ]);
    expect(HexDirections.of(HexagonType.flat), [
      HexDirections.flatBottomRight,
      HexDirections.flatBottom,
      HexDirections.flatBottomLeft,
      HexDirections.flatTopLeft,
      HexDirections.flatTop,
      HexDirections.flatTopRight,
    ]);
  });
}
