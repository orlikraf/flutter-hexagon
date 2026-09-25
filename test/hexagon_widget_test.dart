import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';

void main() {
  // Regression: the docs say values <= 0 have no effect, but a negative
  // radius threw an assertion.
  testWidgets('negative cornerRadius is ignored', (tester) async {
    await tester.pumpWidget(
      const Center(child: HexagonWidget.flat(width: 100, cornerRadius: -5)),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('hit testing follows the hexagon shape, also after a rebuild', (
    tester,
  ) async {
    var taps = 0;
    late StateSetter rebuild;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return GestureDetector(
                onTap: () => taps++,
                child: const HexagonWidget.flat(width: 100),
              );
            },
          ),
        ),
      ),
    );

    final tile = tester.getRect(find.byType(HexagonWidget));

    await tester.tap(find.byType(HexagonWidget));
    expect(taps, 1);

    // The top-left corner of the box is outside a flat hexagon.
    await tester.tapAt(tile.topLeft + const Offset(1, 1));
    expect(taps, 1);

    rebuild(() {});
    await tester.pump();

    await tester.tap(find.byType(HexagonWidget));
    expect(taps, 2);
  });

  group('clipping', () {
    Finder clipIn(Finder tile) =>
        find.descendant(of: tile, matching: find.byType(ClipPath));

    testWidgets('a hexagon without a child is not clipped', (tester) async {
      await tester.pumpWidget(
        const Center(child: HexagonWidget.flat(width: 100)),
      );
      expect(clipIn(find.byType(HexagonWidget)), findsNothing);
    });

    testWidgets('a child is clipped with clipBehavior', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: HexagonWidget.flat(
              width: 100,
              clipBehavior: Clip.hardEdge,
              child: Text('A'),
            ),
          ),
        ),
      );
      final clip = tester.widget<ClipPath>(clipIn(find.byType(HexagonWidget)));
      expect(clip.clipBehavior, Clip.hardEdge);
    });

    testWidgets('Clip.none keeps the child unclipped', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: HexagonWidget.pointy(
              width: 100,
              clipBehavior: Clip.none,
              child: Text('A'),
            ),
          ),
        ),
      );
      expect(clipIn(find.byType(HexagonWidget)), findsNothing);
      expect(find.text('A'), findsOneWidget);
    });

    test('HexagonWidgetBuilder passes clipBehavior on', () {
      final tile = HexagonWidgetBuilder(
        clipBehavior: Clip.none,
      ).build(type: HexagonType.flat, inBounds: true, width: 10);
      expect(tile.clipBehavior, Clip.none);
      expect(
        HexagonWidgetBuilder()
            .build(type: HexagonType.flat, inBounds: true, width: 10)
            .clipBehavior,
        Clip.antiAlias,
      );
    });
  });
}
