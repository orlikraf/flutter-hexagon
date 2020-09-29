import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon_widget.dart';

void main() {
  testWidgets('HexagonWidget exists.', (WidgetTester tester) async {
    // Test code goes here.
    await tester.pumpWidget(HexagonWidget());

    expect(find.byType(HexagonWidget), findsOneWidget);
  });
}
