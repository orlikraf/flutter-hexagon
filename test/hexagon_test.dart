import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';
import 'package:hexagon/src/hexagon_path_builder.dart';

void main() {
  testWidgets('HexagonWidget exists.', (WidgetTester tester) async {
    // Test code goes here.
    await tester.pumpWidget(
      Center(child: HexagonWidget(type: HexagonType.FLAT, height: 100)),
    );

    expect(find.byType(HexagonWidget), findsOneWidget);
  });

  testWidgets('HexagonGird', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: HexagonGrid.flat(height: 200, width: 200, depth: 1),
          ),
        ),
      ),
    );

    expect(find.byType(HexagonGrid), findsOneWidget);
  });

  testWidgets('HexagonWidget with border', (WidgetTester tester) async {
    // Test creating a hexagon with a border
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: HexagonWidget(
              type: HexagonType.FLAT,
              height: 100,
              borderWidth: 3,
              borderColor: const Color(0xFF000000), // Black border
              color: const Color(0xFFFFFFFF), // White fill
            ),
          ),
        ),
      ),
    );

    expect(find.byType(HexagonWidget), findsOneWidget);

    // Verify that the hexagon widget was created
    final hexagonWidget = tester.widget<HexagonWidget>(
      find.byType(HexagonWidget),
    );
    expect(hexagonWidget.borderWidth, equals(3));
    expect(hexagonWidget.borderColor, equals(const Color(0xFF000000)));
    expect(hexagonWidget.color, equals(const Color(0xFFFFFFFF)));
    expect(hexagonWidget.type, equals(HexagonType.FLAT));
  });

  testWidgets('HexagonWidget.pointy with border', (WidgetTester tester) async {
    // Test creating a pointy hexagon with a border using named constructor
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: HexagonWidget.pointy(
              width: 120,
              borderWidth: 5,
              borderColor: const Color(0xFFFF0000), // Red border
              color: const Color(0xFF00FF00), // Green fill
            ),
          ),
        ),
      ),
    );

    expect(find.byType(HexagonWidget), findsOneWidget);

    // Verify properties of the pointy hexagon with border
    final hexagonWidget = tester.widget<HexagonWidget>(
      find.byType(HexagonWidget),
    );
    expect(hexagonWidget.borderWidth, equals(5));
    expect(hexagonWidget.borderColor, equals(const Color(0xFFFF0000)));
    expect(hexagonWidget.color, equals(const Color(0xFF00FF00)));
    expect(hexagonWidget.type, equals(HexagonType.POINTY));
    expect(hexagonWidget.width, equals(120));
  });

  test("HexagonPainter test", () {
    var hexagonPainter = HexagonPainter(HexagonPathBuilder(HexagonType.FLAT));

    expect(hexagonPainter.hitTest(Offset.zero), false);
  });
  test("HexagonPathBuilder test", () {
    var flat = HexagonPathBuilder(HexagonType.FLAT);
    var flat2 = HexagonPathBuilder(HexagonType.FLAT, inBounds: true);
    var flat3 = HexagonPathBuilder(HexagonType.FLAT, inBounds: false);
    var pointy = HexagonPathBuilder(HexagonType.POINTY, borderRadius: 2.0);
    var pointy2 = HexagonPathBuilder(HexagonType.POINTY, borderRadius: 2);

    expect(flat == flat2, true); // Same type, same default inBounds value
    expect(flat != flat3, true); // Same type, different inBounds value
    expect(flat != pointy, true); // Different type
    expect(pointy == pointy2, true); // Same type, same borderRadius values
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
