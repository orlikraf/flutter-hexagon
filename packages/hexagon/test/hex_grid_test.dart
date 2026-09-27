import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';

Widget _cell(BuildContext context, Hex hex) =>
    ColoredBox(key: ValueKey(hex), color: Colors.amber);

void main() {
  testWidgets('sizes itself from a fixed radius', (tester) async {
    await tester.pumpWidget(
      Center(
        child: HexGrid(
          radius: 20,
          cells: HexShape.hexagon(1),
          itemBuilder: _cell,
        ),
      ),
    );
    final size = tester.getSize(find.byType(HexGrid));
    expect(size.width, closeTo(100, 0.01));
    expect(size.height, closeTo(3 * 20 * sqrt3, 0.01));
    expect(
      tester.getCenter(find.byKey(const ValueKey(Hex.zero))),
      tester.getCenter(find.byType(HexGrid)),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey(Hex.zero))),
      Size(40, 20 * sqrt3),
    );
  });

  testWidgets('places neighbors one step apart', (tester) async {
    await tester.pumpWidget(
      Center(
        child: HexGrid(
          type: HexagonType.pointy,
          radius: 10,
          spacing: 2,
          cells: HexShape.hexagon(1),
          itemBuilder: _cell,
        ),
      ),
    );
    const layout = HexLayout.pointy(radius: 10, spacing: 2);
    final zero = tester.getCenter(find.byKey(const ValueKey(Hex.zero)));
    for (final hex in Hex.zero.neighbors) {
      final actual = tester.getCenter(find.byKey(ValueKey(hex))) - zero;
      final expected = layout.centerOf(hex) - layout.centerOf(Hex.zero);
      expect(actual.dx, closeTo(expected.dx, 1e-6));
      expect(actual.dy, closeTo(expected.dy, 1e-6));
    }
  });

  testWidgets('fits the constraints when no radius is given', (tester) async {
    await tester.pumpWidget(
      Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: HexGrid(cells: HexShape.hexagon(1), itemBuilder: _cell),
        ),
      ),
    );
    final radius = 300 / (2 * sqrt3 + sqrt3);
    expect(
      tester.getSize(find.byKey(const ValueKey(Hex.zero))).width,
      closeTo(2 * radius, 0.01),
    );
  });

  testWidgets('taps go to the hexagon under the pointer', (tester) async {
    final taps = <Hex>[];
    await tester.pumpWidget(
      Center(
        child: HexGrid(
          radius: 20,
          cells: HexShape.hexagon(1),
          itemBuilder: _cell,
          onHexTap: taps.add,
        ),
      ),
    );
    final center = tester.getCenter(find.byType(HexGrid));
    await tester.tapAt(center);
    // Inside Hex(0, 0), but also inside Hex(1, -1)'s bounding box, which is
    // hit-tested first.
    await tester.tapAt(center + const Offset(12, -5));
    await tester.tapAt(tester.getCenter(find.byKey(const ValueKey(Hex(1, 0)))));
    expect(taps, [Hex.zero, Hex.zero, const Hex(1, 0)]);
  });

  testWidgets('keeps cell state when cells are reordered', (tester) async {
    Widget grid(List<Hex> cells) => Center(
          child: HexGrid(
            radius: 20,
            cells: cells,
            itemBuilder: (context, hex) => _Counter(key: ValueKey(hex)),
          ),
        );
    await tester.pumpWidget(grid(HexShape.hexagon(1)));
    await tester.pumpWidget(grid(HexShape.hexagon(1).reversed.toList()));
    expect(find.byType(_Counter), findsNWidgets(7));
    expect(tester.takeException(), isNull);
  });
}

class _Counter extends StatefulWidget {
  const _Counter({super.key});

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
