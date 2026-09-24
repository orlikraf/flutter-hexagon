import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';

const _tolerance = 1e-3;
final _sqrt3 = math.sqrt(3);

void _expectRect(Rect actual, Rect expected) {
  expect(actual.left, closeTo(expected.left, _tolerance), reason: 'left');
  expect(actual.top, closeTo(expected.top, _tolerance), reason: 'top');
  expect(actual.right, closeTo(expected.right, _tolerance), reason: 'right');
  expect(actual.bottom, closeTo(expected.bottom, _tolerance), reason: 'bottom');
}

void main() {
  group('HexagonBorder paths', () {
    test('outer path is the hexagon of HexagonPathBuilder, moved to rect', () {
      final rect = Rect.fromLTWH(10, 20, 100, 50 * _sqrt3);
      const border = HexagonBorder(type: HexagonType.flat);
      final expected = HexagonPathBuilder(
        HexagonType.flat,
      ).build(rect.size).shift(rect.topLeft).getBounds();

      _expectRect(border.getOuterPath(rect).getBounds(), expected);
      _expectRect(expected, rect);
    });

    test('inner path moves every edge in by the stroke width', () {
      final rect = Rect.fromLTWH(0, 0, 100, 50 * _sqrt3);
      const border = HexagonBorder(
        type: HexagonType.flat,
        side: BorderSide(width: 4),
      );
      final inner = border.getInnerPath(rect).getBounds();

      // A flat hexagon's height is edge to edge, so it shrinks by 2 × 4.
      expect(inner.height, closeTo(50 * _sqrt3 - 8, _tolerance));
      expect(inner.center.dx, closeTo(rect.center.dx, _tolerance));
      expect(inner.center.dy, closeTo(rect.center.dy, _tolerance));
      expect(border.dimensions, const EdgeInsets.all(4));
    });

    test('pointy border fits a pointy hexagon', () {
      final rect = Rect.fromLTWH(0, 0, 50 * _sqrt3, 100);
      const border = HexagonBorder(type: HexagonType.pointy);
      _expectRect(border.getOuterPath(rect).getBounds(), rect);
    });
  });

  group('HexagonBorder values', () {
    const border = HexagonBorder(
      type: HexagonType.pointy,
      cornerRadius: 4,
      side: BorderSide(width: 2),
    );

    test('scale', () {
      expect(
        border.scale(2),
        const HexagonBorder(
          type: HexagonType.pointy,
          cornerRadius: 8,
          side: BorderSide(width: 4),
        ),
      );
    });

    test('copyWith', () {
      expect(
        border.copyWith(type: HexagonType.flat, cornerRadius: 1),
        const HexagonBorder(
          type: HexagonType.flat,
          cornerRadius: 1,
          side: BorderSide(width: 2),
        ),
      );
      expect(border.copyWith(), border);
    });

    test('lerp between borders of the same type', () {
      const from = HexagonBorder(type: HexagonType.flat);
      const to = HexagonBorder(
        type: HexagonType.flat,
        cornerRadius: 10,
        side: BorderSide(width: 4),
      );
      final middle = ShapeBorder.lerp(from, to, 0.5)! as HexagonBorder;

      expect(middle.cornerRadius, 5);
      expect(middle.side.width, 2);
    });

    test('equality and hashCode', () {
      const same = HexagonBorder(
        type: HexagonType.pointy,
        cornerRadius: 4,
        side: BorderSide(width: 2),
      );
      expect(border, same);
      expect(border.hashCode, same.hashCode);
      expect(border, isNot(border.copyWith(cornerRadius: 5)));
    });
  });

  testWidgets('clipping to a HexagonBorder limits taps to the hexagon', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: Material(
            color: Colors.teal,
            shape: const HexagonBorder(
              type: HexagonType.flat,
              side: BorderSide(color: Colors.white, width: 3),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => taps++,
              child: const SizedBox(width: 200, height: 173),
            ),
          ),
        ),
      ),
    );
    final box = tester.getRect(find.byType(InkWell));

    await tester.tapAt(box.center);
    expect(taps, 1);

    // The corners of the box are outside a flat hexagon.
    await tester.tapAt(box.topLeft + const Offset(2, 2));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ShapeDecoration paints a HexagonBorder', (tester) async {
    await tester.pumpWidget(
      const Center(
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: Color(0xFF00FF00),
            shape: HexagonBorder(
              type: HexagonType.pointy,
              cornerRadius: 12,
              side: BorderSide(
                width: 3,
                strokeAlign: BorderSide.strokeAlignCenter,
              ),
            ),
          ),
          child: SizedBox(width: 100, height: 115),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
