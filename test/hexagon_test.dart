import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';
import 'package:hexagon/src/hexagon_path_builder.dart';
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
    var hexagonPainter = HexagonPainter(HexagonPathBuilder(HexagonType.FLAT));

    expect(hexagonPainter.hitTest(Offset.zero), false);
  });
  test("HexagonPathBuilder test", () {
    var flat = HexagonPathBuilder(HexagonType.FLAT);
    var flat2 = HexagonPathBuilder(HexagonType.FLAT, inBounds: true);
    var pointy = HexagonPathBuilder(HexagonType.POINTY, borderRadius: 2.0);
    var pointy2 = HexagonPathBuilder(HexagonType.POINTY, borderRadius: 2);

    expect(flat == flat, true);
    expect(flat != flat2, true);
    expect(flat != pointy, true);
    expect(pointy == pointy2, true);
  });
}
