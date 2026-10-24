// TEMPORARY: renders each page of the example to build/screenshots/*.png so
// the pages can be looked at without a device. Run with
// `flutter test tool/screenshots_test.dart`.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';
import 'package:hexagon_example/main.dart';

Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) {
    return;
  }
  final dir = Directory('$root/bin/cache/artifacts/material_fonts');
  if (!dir.existsSync()) {
    return;
  }
  final roboto = FontLoader('Roboto');
  final icons = FontLoader('MaterialIcons');
  for (final file in dir.listSync().whereType<File>()) {
    final name = file.uri.pathSegments.last;
    final bytes = file.readAsBytesSync();
    final data = Future.value(
      bytes.buffer.asByteData(bytes.offsetInBytes, bytes.lengthInBytes),
    );
    if (name.startsWith('Roboto')) {
      roboto.addFont(data);
    } else if (name.startsWith('MaterialIcons')) {
      icons.addFont(data);
    }
  }
  await roboto.load();
  await icons.load();
}

Future<void> _shoot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  for (final element in find.byType(Image).evaluate()) {
    final image = (element.widget as Image).image;
    await tester.runAsync(() => precacheImage(image, element));
  }
  await tester.pumpAndSettle();
  final root = tester.element(find.byType(HexagonExampleApp));
  await tester.runAsync(() async {
    final image = await captureImage(root);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('build/screenshots/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('screenshots', (tester) async {
    await tester.runAsync(_loadFonts);
    tester.view.physicalSize = const Size(1100, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const HexagonExampleApp());
    await _shoot(tester, '1_widgets_top');
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await _shoot(tester, '2_widgets_bottom');

    await tester.tap(find.text('Grids').last);
    await _shoot(tester, '3_grids_hexagon');
    await tester.tap(find.text('triangle'));
    await tester.tap(find.text('pointy'));
    await _shoot(tester, '4_grids_triangle_pointy_up');
    await tester.tap(find.text('flat'));
    await tester.tap(find.text('hollow'));
    await _shoot(tester, '5_grids_triangle_flat_up_hollow');

    await tester.tap(find.text('Scrolling').last);
    await _shoot(tester, '6_scrolling');

    await tester.tap(find.text('Game map').last);
    await tester.pumpAndSettle();
    final unit = find.descendant(
      of: find.byType(HexGridView),
      matching: find.byType(Hexagon),
    );
    await tester.tap(unit.first);
    await _shoot(tester, '7_game_map_selected');
  });
}
