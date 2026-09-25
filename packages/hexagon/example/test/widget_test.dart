import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';
import 'package:hexagon_example/main.dart';
import 'package:hexagon_example/map_page.dart';

void main() {
  testWidgets('every page of the gallery builds', (tester) async {
    await tester.pumpWidget(const HexagonExampleApp());
    await tester.pumpAndSettle();
    expect(find.byType(Hexagon), findsWidgets);

    await tester.tap(find.text('Grids').last);
    await tester.pumpAndSettle();
    expect(find.byType(HexGrid), findsOneWidget);

    await tester.tap(find.text('Game map').last);
    await tester.pumpAndSettle();
    expect(find.byType(HexGridView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('generated map has land and water', () {
    final map = generateMap(20, 15);
    expect(map.length, 300);
    expect(map.values, contains(Terrain.water));
    expect(map.values, contains(Terrain.grass));
  });
}
