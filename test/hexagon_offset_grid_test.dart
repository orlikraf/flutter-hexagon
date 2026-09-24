import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';

import 'test_utils.dart';

typedef _GridFactory =
    HexagonOffsetGrid Function({
      required int columns,
      required int rows,
      HexagonWidgetBuilder? hexagonBuilder,
    });

final _constructors = <String, _GridFactory>{
  'oddFlat': ({required columns, required rows, hexagonBuilder}) =>
      HexagonOffsetGrid.oddFlat(
        columns: columns,
        rows: rows,
        hexagonBuilder: hexagonBuilder,
      ),
  'evenFlat': ({required columns, required rows, hexagonBuilder}) =>
      HexagonOffsetGrid.evenFlat(
        columns: columns,
        rows: rows,
        hexagonBuilder: hexagonBuilder,
      ),
  'oddPointy': ({required columns, required rows, hexagonBuilder}) =>
      HexagonOffsetGrid.oddPointy(
        columns: columns,
        rows: rows,
        hexagonBuilder: hexagonBuilder,
      ),
  'evenPointy': ({required columns, required rows, hexagonBuilder}) =>
      HexagonOffsetGrid.evenPointy(
        columns: columns,
        rows: rows,
        hexagonBuilder: hexagonBuilder,
      ),
};

const _shapes = [(5, 10), (9, 4), (1, 3), (3, 1), (1, 1)];

const _boxes = [Size(400, 1000), Size(1000, 400), Size(300, 300), Size(800, 600)];

void main() {
  // Regression: the grid compared aspect ratios in mixed units (hexagon
  // widths against hexagon heights), so in some boxes it chose the wrong
  // dimension to fit and overflowed; e.g. a 5x10 flat grid in 400x1000
  // rendered 440 px wide.
  group('HexagonOffsetGrid fits its box', () {
    for (final MapEntry(key: name, value: grid) in _constructors.entries) {
      for (final (columns, rows) in _shapes) {
        for (final box in _boxes) {
          testWidgets('$name ${columns}x$rows in $box', (tester) async {
            useLargeSurface(tester);
            await tester.pumpWidget(
              boxed(box, grid(columns: columns, rows: rows)),
            );

            expect(tester.takeException(), isNull);
            expectTilesWithin(tester, Offset.zero & box);
            expect(
              find.byType(HexagonWidget),
              findsNWidgets(columns * rows),
            );
          });
        }
      }
    }
  });

  // Regression: only oddFlat rejected empty grids.
  test('every constructor rejects an empty grid', () {
    // Not const, so the asserts run when the test runs.
    var empty = 0;
    for (final MapEntry(key: name, value: grid) in _constructors.entries) {
      expect(
        () => grid(columns: empty, rows: 3),
        throwsAssertionError,
        reason: '$name with 0 columns',
      );
      expect(
        () => grid(columns: 3, rows: empty),
        throwsAssertionError,
        reason: '$name with 0 rows',
      );
    }
  });

  // Regression: a key on the shared template was copied onto every tile,
  // which failed with a confusing "Duplicate keys found" error.
  testWidgets('a keyed hexagonBuilder template is rejected clearly', (
    tester,
  ) async {
    await tester.pumpWidget(
      boxed(
        const Size(400, 400),
        HexagonOffsetGrid.oddPointy(
          columns: 3,
          rows: 3,
          hexagonBuilder: HexagonWidgetBuilder(key: const ValueKey('tile')),
        ),
      ),
    );

    final error = tester.takeException();
    expect(error, isA<AssertionError>());
    expect(error.toString(), contains('buildTile'));
  });

  testWidgets('per-tile keys from buildTile are allowed', (tester) async {
    await tester.pumpWidget(
      boxed(
        const Size(400, 400),
        HexagonOffsetGrid.oddPointy(
          columns: 3,
          rows: 3,
          buildTile: (col, row) =>
              HexagonWidgetBuilder(key: ValueKey((col, row))),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
