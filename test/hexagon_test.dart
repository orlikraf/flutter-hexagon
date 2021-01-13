import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';
import 'package:hexagon/src/hexagon_type.dart';

void main() {
  testWidgets('HexagonWidget exists.', (WidgetTester tester) async {
    // Test code goes here.
    await tester.pumpWidget(HexagonWidget(
      type: HexagonType.FLAT,
      height: 100,
    ));

    expect(find.byType(HexagonWidget), findsOneWidget);
  });
  test("HexagonPainter test", () {
    var hexagonPainter = HexagonPainter(HexagonType.FLAT);

    expect(hexagonPainter.hitTest(Offset.zero), false);
  });
}
