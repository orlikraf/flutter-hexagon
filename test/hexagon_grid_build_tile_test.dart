import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';

import 'test_utils.dart';

// Kept in its own file: before the fix this did not compile, because
// HexagonGrid.buildTile could not return null.
void main() {
  // Regression: the docs said buildTile may return null to fall back to
  // hexagonBuilder, but its type did not allow null.
  testWidgets('buildTile can return null to use hexagonBuilder', (
    tester,
  ) async {
    const template = Color(0xFF00FF00);
    const center = Color(0xFFFF0000);

    await tester.pumpWidget(
      boxed(
        const Size(400, 400),
        HexagonGrid.flat(
          depth: 1,
          hexagonBuilder: HexagonWidgetBuilder(color: template),
          buildTile: (coordinates) => coordinates == Coordinates.zero
              ? HexagonWidgetBuilder(color: center)
              : null,
        ),
      ),
    );

    final colors = tester
        .widgetList<HexagonWidget>(find.byType(HexagonWidget))
        .map((tile) => tile.color)
        .toList();
    expect(colors.where((color) => color == center), hasLength(1));
    expect(colors.where((color) => color == template), hasLength(6));
  });
}
