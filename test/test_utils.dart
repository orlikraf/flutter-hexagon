import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';

/// Gives the test a square surface large enough for every box size used in
/// the layout tests.
void useLargeSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Places [child] at the top-left corner in a box of exactly [size].
Widget boxed(Size size, Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Align(
    alignment: Alignment.topLeft,
    child: SizedBox(width: size.width, height: size.height, child: child),
  ),
);

/// Expects every [HexagonWidget] to be laid out within [bounds].
void expectTilesWithin(WidgetTester tester, Rect bounds) {
  const epsilon = 0.01;
  final tiles = find.byType(HexagonWidget);
  final count = tiles.evaluate().length;
  expect(count, greaterThan(0));
  for (var i = 0; i < count; i++) {
    final rect = tester.getRect(tiles.at(i));
    expect(
      rect.left >= bounds.left - epsilon &&
          rect.top >= bounds.top - epsilon &&
          rect.right <= bounds.right + epsilon &&
          rect.bottom <= bounds.bottom + epsilon,
      isTrue,
      reason: 'tile $i at $rect is outside $bounds',
    );
  }
}
