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
}
