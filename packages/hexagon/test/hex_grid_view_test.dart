import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';

void main() {
  const layout = HexLayout.flat(radius: 20);
  final small = HexShape.hexagon(3).toSet();

  Future<HexGridController> pumpView(
    WidgetTester tester, {
    required Set<Hex> cells,
    List<HexLayer> layers = const [HexPaintLayer.fill()],
    ValueChanged<Hex>? onHexTap,
    ValueChanged<Hex>? onHexLongPress,
    Hex? initialCenter,
  }) async {
    final controller = HexGridController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: HexGridView(
          layout: layout,
          cells: cells,
          layers: layers,
          controller: controller,
          onHexTap: onHexTap,
          onHexLongPress: onHexLongPress,
          initialCenter: initialCenter,
        ),
      ),
    );
    // The camera is centered after the first frame.
    await tester.pump();
    return controller;
  }

  testWidgets('starts centered on the map', (tester) async {
    final taps = <Hex>[];
    final controller =
        await pumpView(tester, cells: small, onHexTap: taps.add);
    expect(controller.hasView, isTrue);
    expect(controller.centerHex, Hex.zero);
    await tester.tapAt(const Offset(400, 300));
    expect(taps, [Hex.zero]);
  });

  testWidgets('starts at initialCenter', (tester) async {
    final controller = await pumpView(
      tester,
      cells: small,
      initialCenter: const Hex(2, -1),
    );
    expect(controller.centerHex, const Hex(2, -1));
  });

  testWidgets('taps outside the map are ignored', (tester) async {
    final taps = <Hex>[];
    await pumpView(tester, cells: small, onHexTap: taps.add);
    await tester.tapAt(const Offset(5, 5));
    expect(taps, isEmpty);
  });

  testWidgets('long press reports the hex', (tester) async {
    final presses = <Hex>[];
    await pumpView(tester, cells: small, onHexLongPress: presses.add);
    await tester.longPressAt(const Offset(400, 300));
    expect(presses, [Hex.zero]);
  });

  testWidgets('jumpTo and animateTo move the camera', (tester) async {
    final taps = <Hex>[];
    final controller =
        await pumpView(tester, cells: small, onHexTap: taps.add);

    controller.jumpTo(const Hex(2, 0));
    await tester.pump();
    expect(controller.centerHex, const Hex(2, 0));
    await tester.tapAt(const Offset(400, 300));
    expect(taps, [const Hex(2, 0)]);

    controller.jumpTo(const Hex(-1, 1), scale: 2);
    await tester.pump();
    expect(controller.scale, closeTo(2, 1e-9));
    expect(controller.centerHex, const Hex(-1, 1));

    final done = controller.animateTo(const Hex(-2, 0), scale: 1);
    await tester.pumpAndSettle();
    await done;
    expect(controller.centerHex, const Hex(-2, 0));
    expect(controller.scale, closeTo(1, 1e-9));
  });

  testWidgets('hexAtViewport converts viewport positions', (tester) async {
    final controller = await pumpView(tester, cells: small);
    expect(controller.hexAtViewport(const Offset(400, 300)), Hex.zero);
    expect(
      controller.hexAtViewport(const Offset(400, 300) + layout.centerOf(
            const Hex(1, 0),
          )),
      const Hex(1, 0),
    );
    expect(controller.hexAtViewport(const Offset(2, 2)), isNull);
  });

  testWidgets('only paints and builds visible cells', (tester) async {
    final painted = <Hex>{};
    final built = <Hex>{};
    final big = HexShape.rectangle(200, 200).toSet();
    await pumpView(
      tester,
      cells: big,
      layers: [
        HexPaintLayer(painter: (canvas, cell) => painted.add(cell.hex)),
        HexWidgetLayer(
          builder: (context, hex) {
            built.add(hex);
            return const SizedBox.expand();
          },
        ),
      ],
    );
    expect(painted, isNotEmpty);
    expect(built, isNotEmpty);
    // About 27 × 18 hexes fit in an 800 × 600 viewport.
    expect(painted.length, lessThan(2000));
    expect(built.length, lessThan(2000));
    expect(big.containsAll(painted), isTrue);
  });

  testWidgets('widget layers only cover their cells', (tester) async {
    final taps = <Hex>[];
    await pumpView(
      tester,
      cells: small,
      layers: [
        const HexPaintLayer.fill(color: Colors.green, strokeColor: Colors.black),
        HexWidgetLayer(
          cells: const [Hex.zero],
          builder: (context, hex) => GestureDetector(
            key: const Key('unit'),
            onTap: () => taps.add(hex),
          ),
        ),
      ],
    );
    expect(find.byKey(const Key('unit')), findsOneWidget);
    await tester.tapAt(const Offset(400, 300));
    expect(taps, [Hex.zero]);
  });

  testWidgets('reports hover changes', (tester) async {
    final hovered = <Hex?>[];
    final controller = HexGridController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: HexGridView(
          layout: layout,
          cells: small,
          controller: controller,
          onHexHover: hovered.add,
        ),
      ),
    );
    await tester.pump();
    final mouse = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: const Offset(400, 300));
    await mouse.moveTo(const Offset(401, 301));
    await tester.pump();
    expect(controller.hoveredHex, Hex.zero);
    await mouse.moveTo(const Offset(2, 2));
    await tester.pump();
    expect(controller.hoveredHex, isNull);
    expect(hovered, [Hex.zero, null]);
  });

  testWidgets('can switch controllers', (tester) async {
    final first = HexGridController();
    final second = HexGridController();
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    Widget view(HexGridController? controller) => MaterialApp(
          home: HexGridView(
            layout: layout,
            cells: small,
            controller: controller,
          ),
        );
    await tester.pumpWidget(view(null));
    await tester.pumpWidget(view(first));
    expect(first.hasView, isTrue);
    await tester.pumpWidget(view(second));
    expect(first.hasView, isFalse);
    expect(second.hasView, isTrue);
    await tester.pumpWidget(const SizedBox());
    expect(second.hasView, isFalse);
    expect(tester.takeException(), isNull);
  });
}
