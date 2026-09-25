import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';

import 'test_utils.dart';

const _boxes = [
  Size(400, 1000),
  Size(1000, 400),
  Size(300, 300),
  Size(800, 115),
  Size(800, 600),
];

void main() {
  group('HexagonGrid fits its box', () {
    for (final type in HexagonType.values) {
      for (var depth = 0; depth <= 4; depth++) {
        for (final box in _boxes) {
          testWidgets('${type.name} depth $depth in $box', (tester) async {
            useLargeSurface(tester);
            await tester.pumpWidget(
              boxed(box, HexagonGrid(hexType: type, depth: depth)),
            );

            expect(tester.takeException(), isNull);
            expectTilesWithin(tester, Offset.zero & box);
            final tiles = 1 + 3 * depth * (depth + 1);
            expect(find.byType(HexagonWidget), findsNWidgets(tiles));
          });
        }
      }
    }
  });

  // Regression: an exact `==` on computed doubles picked the wrong
  // dimension for some heights, e.g. 115 at depth 3, and the grid rendered
  // 882 px tall in a 115 px box.
  testWidgets('flat depth 3 in an 800x115 box', (tester) async {
    await tester.pumpWidget(
      boxed(const Size(800, 115), const HexagonGrid.flat(depth: 3)),
    );

    expect(tester.takeException(), isNull);
    expectTilesWithin(tester, Offset.zero & const Size(800, 115));
  });

  // Regression: with an explicit width, padding was not subtracted, so the
  // tiles overflowed by the padding.
  testWidgets('explicit width with padding', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HexagonGrid.flat(
            width: 400,
            depth: 2,
            padding: EdgeInsets.all(20),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expectTilesWithin(
      tester,
      tester.getRect(find.byType(HexagonGrid)).deflate(20),
    );
  });

  // Regression: an explicit width larger than the parent allows was used
  // as-is, and the other dimension was treated as unbounded.
  testWidgets('explicit width larger than the parent', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: HexagonGrid.pointy(width: 1000, depth: 2)),
      ),
    );

    expect(tester.takeException(), isNull);
    expectTilesWithin(tester, Offset.zero & const Size(800, 600));
  });

  // Regression: a key on the shared template was copied onto every tile,
  // which failed with a confusing "Duplicate keys found" error.
  testWidgets('a keyed hexagonBuilder template is rejected clearly', (
    tester,
  ) async {
    await tester.pumpWidget(
      boxed(
        const Size(400, 400),
        HexagonGrid.flat(
          depth: 1,
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
        HexagonGrid.flat(
          depth: 1,
          buildTile: (coordinates) =>
              HexagonWidgetBuilder(key: ValueKey(coordinates)),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
