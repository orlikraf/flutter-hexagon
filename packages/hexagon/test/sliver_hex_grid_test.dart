import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';

SliverConstraints _constraints(Axis axis, double crossAxisExtent) =>
    SliverConstraints(
      axisDirection:
          axis == Axis.vertical ? AxisDirection.down : AxisDirection.right,
      growthDirection: GrowthDirection.forward,
      userScrollDirection: ScrollDirection.idle,
      scrollOffset: 0,
      precedingScrollExtent: 0,
      overlap: 0,
      remainingPaintExtent: 600,
      crossAxisExtent: crossAxisExtent,
      crossAxisDirection:
          axis == Axis.vertical ? AxisDirection.right : AxisDirection.down,
      viewportMainAxisExtent: 600,
      remainingCacheExtent: 600,
      cacheOrigin: 0,
    );

void main() {
  final configurations = [
    for (final axis in Axis.values)
      for (final type in HexagonType.values)
        for (final parity in OffsetParity.values)
          for (final count in [1, 2, 5]) (axis, type, parity, count),
  ];

  test('cells fill the cross axis without overlapping', () {
    for (final (axis, type, parity, count) in configurations) {
      final reason = '$axis $type $parity $count';
      for (final spacing in [0.0, 6.0]) {
        final layout = SliverHexGridDelegate.count(
          crossAxisCount: count,
          type: type,
          spacing: spacing,
          parity: parity,
        ).getLayout(_constraints(axis, 400));
        var minCross = double.infinity;
        var maxCross = double.negativeInfinity;
        for (var index = 0; index < 4 * count; index++) {
          final g = layout.getGeometryForChildIndex(index);
          minCross =
              minCross < g.crossAxisOffset ? minCross : g.crossAxisOffset;
          final end = g.crossAxisOffset + g.crossAxisExtent;
          maxCross = maxCross > end ? maxCross : end;
          expect(g.scrollOffset, greaterThanOrEqualTo(-1e-9), reason: reason);
        }
        expect(minCross, closeTo(0, 1e-6), reason: reason);
        expect(maxCross, closeTo(400, 1e-6), reason: reason);

        // Neighboring hexes are exactly one step apart; no two are closer.
        final centers = [
          for (var index = 0; index < 4 * count; index++)
            layout.layout.hexToPixel(layout.hexOf(index)),
        ];
        final step = sqrt3 * (layout.radius + spacing / sqrt3);
        for (var i = 0; i < centers.length; i++) {
          for (var j = i + 1; j < centers.length; j++) {
            expect(
              centers[i].distanceTo(centers[j]),
              greaterThan(step - 1e-6),
              reason: reason,
            );
          }
        }
        expect(
          {for (var i = 0; i < 4 * count; i++) layout.hexOf(i)}.length,
          4 * count,
          reason: reason,
        );
      }
    }
  });

  test('visible index range covers every visible cell', () {
    for (final (axis, type, parity, count) in configurations) {
      final reason = '$axis $type $parity $count';
      final layout = SliverHexGridDelegate.count(
        crossAxisCount: count,
        type: type,
        spacing: 3,
        parity: parity,
      ).getLayout(_constraints(axis, 300));
      const total = 400;
      final geometries = [
        for (var index = 0; index < total; index++)
          layout.getGeometryForChildIndex(index),
      ];
      final end = layout.computeMaxScrollOffset(total);
      for (var start = 0.0; start < end; start += 37) {
        final stop = start + 150;
        final first = layout.getMinChildIndexForScrollOffset(start);
        final last = layout.getMaxChildIndexForScrollOffset(stop);
        for (var index = 0; index < total; index++) {
          final g = geometries[index];
          final visible =
              g.trailingScrollOffset > start && g.scrollOffset < stop;
          if (visible) {
            expect(index, greaterThanOrEqualTo(first),
                reason: '$reason $start');
            expect(index, lessThanOrEqualTo(last), reason: '$reason $start');
          }
        }
      }
      for (final g in geometries) {
        expect(g.trailingScrollOffset, lessThanOrEqualTo(end + 1e-9));
      }
    }
  });

  test('extent picks as many hexagons as fit', () {
    final layout = const SliverHexGridDelegate.extent(maxCellExtent: 60)
        .getLayout(_constraints(Axis.vertical, 400));
    expect(layout.layout.cellWidth, lessThanOrEqualTo(60));
    final fewer = SliverHexGridDelegate.count(
      crossAxisCount: layout.crossAxisCount - 1,
    ).getLayout(_constraints(Axis.vertical, 400));
    expect(fewer.layout.cellWidth, greaterThan(60));
  });

  test('reversed cross axis mirrors the cells', () {
    const delegate = SliverHexGridDelegate.count(crossAxisCount: 4);
    final ltr = delegate.getLayout(_constraints(Axis.vertical, 400));
    final rtl = delegate.getLayout(
      _constraints(Axis.vertical, 400).copyWith(
        crossAxisDirection: AxisDirection.left,
      ),
    );
    for (var index = 0; index < 12; index++) {
      final a = ltr.getGeometryForChildIndex(index);
      final b = rtl.getGeometryForChildIndex(index);
      expect(
        b.crossAxisOffset,
        closeTo(400 - a.crossAxisOffset - a.crossAxisExtent, 1e-9),
      );
    }
  });

  testWidgets('builds lazily and scrolls', (tester) async {
    final built = <int>{};
    await tester.pumpWidget(
      MaterialApp(
        home: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
            SliverHexGrid.builder(
              gridDelegate: const SliverHexGridDelegate.count(
                crossAxisCount: 5,
                spacing: 4,
              ),
              itemCount: 10000,
              itemBuilder: (context, index) {
                built.add(index);
                return Hexagon(
                  type: HexagonType.pointy,
                  child: Text('$index'),
                );
              },
            ),
          ],
        ),
      ),
    );
    expect(find.text('0'), findsOneWidget);
    expect(built.length, lessThan(200));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsNothing);
    expect(built.length, lessThan(1000));
    expect(tester.takeException(), isNull);
  });

  testWidgets('taps reach the hexagon under the pointer', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: CustomScrollView(
          slivers: [
            SliverHexGrid.builder(
              gridDelegate: const SliverHexGridDelegate.count(
                crossAxisCount: 4,
              ),
              itemCount: 40,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => taps.add(index),
                child: ColoredBox(
                  key: ValueKey(index),
                  color: Colors.amber,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    // Item 4 starts the second row, shifted right by half a hexagon, so its
    // bounding box overlaps the bottom corners of items 0 and 1.
    final first = tester.getRect(find.byKey(const ValueKey(0)));
    final second = tester.getRect(find.byKey(const ValueKey(4)));
    expect(second.left, greaterThan(first.left));
    expect(second.top, lessThan(first.bottom));

    await tester.tapAt(first.center);
    await tester.tapAt(second.center);
    // Inside item 0's hexagon, in the region where item 4's bounding box
    // overlaps it.
    await tester.tapAt(Offset(first.center.dx + 2, second.top + 2));
    expect(taps, [0, 4, 0]);
  });

  testWidgets('scrolls horizontally', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            height: 200,
            child: CustomScrollView(
              scrollDirection: Axis.horizontal,
              slivers: [
                SliverHexGrid.list(
                  gridDelegate: const SliverHexGridDelegate.count(
                    crossAxisCount: 2,
                    type: HexagonType.flat,
                  ),
                  children: [
                    for (var i = 0; i < 30; i++)
                      Hexagon(key: ValueKey(i), child: Text('$i')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final a = tester.getRect(find.byKey(const ValueKey(0)));
    final b = tester.getRect(find.byKey(const ValueKey(1)));
    final c = tester.getRect(find.byKey(const ValueKey(2)));
    // Items fill a column top to bottom, then move right.
    expect(b.top, greaterThan(a.top));
    expect(c.left, greaterThan(a.left));
    expect(tester.takeException(), isNull);
  });
}
