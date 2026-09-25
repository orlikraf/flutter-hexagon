// Tests of the deprecated pre-1.0 API, which must keep working until 2.0.0.
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';

void main() {
  testWidgets('HexagonWidget', (tester) async {
    await tester.pumpWidget(
      const Center(child: HexagonWidget(type: HexagonType.flat, height: 100)),
    );
    expect(find.byType(HexagonWidget), findsOneWidget);
  });

  testWidgets('HexagonGrid', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: HexagonGrid.flat(height: 660, width: 633, depth: 1),
      ),
    );
    expect(find.byType(HexagonWidget), findsNWidgets(7));
  });

  testWidgets('HexagonOffsetGrid', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HexagonOffsetGrid.oddPointy(
            columns: 3,
            rows: 2,
            buildTile: (col, row) => HexagonWidgetBuilder(color: Colors.red),
          ),
        ),
      ),
    );
    expect(find.byType(HexagonWidget), findsNWidgets(6));
  });

  test('HexagonPainter', () {
    final painter = HexagonPainter(HexagonPathBuilder(HexagonType.FLAT));
    expect(painter.hitTest(Offset.zero), false);
  });

  test('HexagonPathBuilder equality', () {
    final flat = HexagonPathBuilder(HexagonType.flat);
    final flat2 = HexagonPathBuilder(HexagonType.flat, inBounds: false);
    final pointy = HexagonPathBuilder(HexagonType.pointy, borderRadius: 2.0);
    final pointy2 = HexagonPathBuilder(HexagonType.POINTY, borderRadius: 2);
    expect(flat == flat, true);
    expect(flat != flat2, true);
    expect(flat != pointy, true);
    expect(pointy == pointy2, true);
  });

  test('HexagonTypeExtension factors', () {
    expect(HexagonType.flat.flatFactor(false), 0.75);
    expect(HexagonType.flat.flatFactor(true), 1);
    expect(HexagonType.pointy.pointyFactor(false), 0.75);
    expect(HexagonType.flat.ratio, closeTo(1.1547, 1e-4));
  });

  test('Coordinates distance', () {
    const zero = Coordinates.zero;
    final one = Coordinates.axial(1, 0);
    final two = Coordinates.axial(1, 3);
    expect(zero.distance(zero), 0);
    expect(zero.distance(one), 1);
    expect(zero.distance(two), 4);
    expect(two.distance(one), 3);
    expect(Coordinates.axial(4, 0).distance(Coordinates.axial(-4, 0)), 8);
  });
}
