import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';
import 'package:hexagon/src/hexagon_path_builder.dart';

void main() {
  testWidgets('HexagonWidget exists.', (WidgetTester tester) async {
    // Test code goes here.
    await tester.pumpWidget(Center(
      child: HexagonWidget(
        type: HexagonType.FLAT,
        height: 100,
      ),
    ));

    expect(find.byType(HexagonWidget), findsOneWidget);
  });

  testWidgets('HexagonGird', (WidgetTester tester) async {
    await tester.pumpWidget(HexagonGrid.flat(
      height: 660,
      width: 633,
      depth: 1,
    ));

    expect(find.byType(HexagonGrid), findsOneWidget);
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
  test("Coordinates distance", () {
    var zero = Coordinates.zero;
    var one = Coordinates.axial(1, 0);
    var two = Coordinates.axial(1, 3);

    expect(zero.distance(zero), 0);
    expect(zero.distance(one), 1);
    expect(zero.distance(two), 4);
    expect(one.distance(one), 0);
    expect(two.distance(zero), 4);
    expect(two.distance(one), 3);

    var four = Coordinates.axial(4, 0);
    var fourNe = Coordinates.axial(-4, 0);

    expect(four.distance(fourNe), 8);
  });
}
