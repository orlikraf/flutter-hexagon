import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';

void main() {
  testWidgets('every tab of the example renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(HexagonGrid), findsOneWidget);

    await tester.tap(find.text('V-Offset'));
    await tester.pumpAndSettle();
    expect(find.byType(HexagonOffsetGrid), findsOneWidget);

    await tester.tap(find.text('H-Offset'));
    await tester.pumpAndSettle();
    expect(find.byType(HexagonOffsetGrid), findsOneWidget);

    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();
    expect(find.byType(HexagonWidget), findsNWidgets(6));
  });
}
