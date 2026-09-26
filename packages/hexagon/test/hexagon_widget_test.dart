import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';

Widget _app(Widget child, {ThemeData? theme}) =>
    MaterialApp(theme: theme, home: Center(child: child));

void main() {
  testWidgets('contain: width decides height for flat', (tester) async {
    await tester.pumpWidget(_app(const Hexagon(width: 200)));
    final size = tester.getSize(find.byType(Hexagon));
    expect(size.width, 200);
    expect(size.height, closeTo(200 / HexagonType.flat.ratio, 0.01));
  });

  testWidgets('contain: width decides height for pointy', (tester) async {
    await tester.pumpWidget(_app(const Hexagon.pointy(width: 100)));
    final size = tester.getSize(find.byType(Hexagon));
    expect(size.width, 100);
    expect(size.height, closeTo(100 / HexagonType.pointy.ratio, 0.01));
  });

  testWidgets('contain: fits the largest hexagon in loose constraints',
      (tester) async {
    await tester.pumpWidget(
      _app(
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300, maxHeight: 100),
          child: const Hexagon(),
        ),
      ),
    );
    final size = tester.getSize(find.byType(Hexagon));
    expect(size.height, 100);
    expect(size.width, closeTo(100 * HexagonType.flat.ratio, 0.01));
  });

  testWidgets('wrap: encloses the child', (tester) async {
    const childKey = Key('child');
    await tester.pumpWidget(
      _app(
        const Hexagon(
          fit: HexagonFit.wrap,
          child: SizedBox(key: childKey, width: 100, height: 100),
        ),
      ),
    );
    final radius = HexagonType.flat.radiusToEnclose(100, 100);
    final size = tester.getSize(find.byType(Hexagon));
    expect(size.width, closeTo(2 * radius, 0.01));
    expect(size.height, closeTo(sqrt3 * radius, 0.01));
    expect(
      tester.getCenter(find.byKey(childKey)),
      tester.getCenter(find.byType(Hexagon)),
    );
  });

  testWidgets('inscribed child area is the largest inner rectangle',
      (tester) async {
    const childKey = Key('child');
    await tester.pumpWidget(
      _app(const Hexagon(width: 200, child: SizedBox.expand(key: childKey))),
    );
    final size = tester.getSize(find.byKey(childKey));
    expect(size.width, closeTo(100, 0.01));
    expect(size.height, closeTo(100 * sqrt3, 0.01));
  });

  testWidgets('bounds child area fills the bounding box', (tester) async {
    const childKey = Key('child');
    await tester.pumpWidget(
      _app(
        const Hexagon(
          width: 200,
          childArea: HexagonChildArea.bounds,
          child: SizedBox(key: childKey),
        ),
      ),
    );
    expect(
      tester.getSize(find.byKey(childKey)),
      tester.getSize(find.byType(Hexagon)),
    );
  });

  testWidgets('only taps inside the hexagon count', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _app(Hexagon(width: 200, onTap: () => taps++)),
    );
    final rect = tester.getRect(find.byType(Hexagon));
    await tester.tapAt(rect.center);
    expect(taps, 1);
    await tester.tapAt(rect.topLeft + const Offset(4, 4));
    expect(taps, 1);
    await tester.tapAt(rect.bottomRight - const Offset(4, 4));
    expect(taps, 1);
  });

  testWidgets('long press and hover callbacks', (tester) async {
    var longPresses = 0;
    await tester.pumpWidget(
      _app(
        Hexagon(
          width: 200,
          onLongPress: () => longPresses++,
          onHover: (_) {},
        ),
      ),
    );
    await tester.longPress(find.byType(Hexagon));
    expect(longPresses, 1);
  });

  testWidgets('uses the theme extension for defaults', (tester) async {
    await tester.pumpWidget(
      _app(
        const Hexagon(width: 100),
        theme: ThemeData(
          extensions: const [
            HexagonThemeData(
              color: Colors.red,
              cornerRadius: 5,
              elevation: 3,
              side: BorderSide(width: 2),
            ),
          ],
        ),
      ),
    );
    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(Hexagon),
        matching: find.byType(Material),
      ),
    );
    expect(material.color, Colors.red);
    expect(material.elevation, 3);
    final shape = material.shape! as HexagonBorder;
    expect(shape.cornerRadius, 5);
    expect(shape.side.width, 2);
  });

  testWidgets('explicit values override the theme', (tester) async {
    await tester.pumpWidget(
      _app(
        const Hexagon(width: 100, color: Colors.blue, cornerRadius: 1),
        theme: ThemeData(
          extensions: const [
            HexagonThemeData(color: Colors.red, cornerRadius: 5),
          ],
        ),
      ),
    );
    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(Hexagon),
        matching: find.byType(Material),
      ),
    );
    expect(material.color, Colors.blue);
    expect((material.shape! as HexagonBorder).cornerRadius, 1);
  });

  testWidgets('falls back to wrap without bounded constraints', (tester) async {
    await tester.pumpWidget(
      _app(
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: UnconstrainedBox(
            child: Hexagon(child: SizedBox(width: 50, height: 50)),
          ),
        ),
      ),
    );
    final size = tester.getSize(find.byType(Hexagon));
    final radius = HexagonType.flat.radiusToEnclose(50, 50);
    expect(size.width, closeTo(2 * radius, 0.01));
  });

  test('HexagonThemeData copyWith and lerp', () {
    const a = HexagonThemeData(color: Colors.black, elevation: 0);
    const b = HexagonThemeData(color: Colors.white, elevation: 10);
    final mid = a.lerp(b, 0.5);
    expect(mid.elevation, 5);
    expect(a.lerp(null, 0.5), a);
    expect(a.copyWith(cornerRadius: 3).cornerRadius, 3);
    expect(a.copyWith(cornerRadius: 3).color, Colors.black);
    expect(a, const HexagonThemeData(color: Colors.black, elevation: 0));
  });
}
