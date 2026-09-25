import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(TabBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('every page of the example renders', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(HexagonGrid), findsOneWidget);

    await _openTab(tester, 'Offset');
    expect(find.byType(HexagonOffsetGrid), findsOneWidget);
    await tester.tap(find.text('Pointy, horizontal'));
    await tester.pumpAndSettle();
    expect(find.byType(HexagonOffsetGrid), findsOneWidget);

    await _openTab(tester, 'Widgets');
    expect(find.byType(HexagonWidget), findsNWidgets(6));

    await _openTab(tester, 'Border');
    expect(find.text('Material + InkWell'), findsOneWidget);

    await _openTab(tester, 'Coordinates');
    expect(find.text('Tapped: 1, 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a tile on the coordinates page selects it', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await _openTab(tester, 'Coordinates');

    await tester.tap(find.text('-2,3'));
    await tester.pump();
    expect(find.text('Tapped: -2, 3'), findsOneWidget);

    await tester.tap(find.text('spiral(2)'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
