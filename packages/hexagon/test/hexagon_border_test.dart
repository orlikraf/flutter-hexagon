import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';

void main() {
  const square = Rect.fromLTWH(0, 0, 200, 200);

  void expectRect(Rect actual, Rect expected) {
    expect(actual.left, closeTo(expected.left, 0.01));
    expect(actual.top, closeTo(expected.top, 0.01));
    expect(actual.right, closeTo(expected.right, 0.01));
    expect(actual.bottom, closeTo(expected.bottom, 0.01));
  }

  test('regular flat hexagon fits and centers in the rect', () {
    final path = const HexagonBorder().getOuterPath(square);
    const height = 200 * sqrt3 / 2;
    expectRect(
      path.getBounds(),
      const Rect.fromLTWH(0, (200 - height) / 2, 200, height),
    );
    expect(path.contains(const Offset(100, 100)), isTrue);
    expect(path.contains(const Offset(5, 20)), isFalse);
  });

  test('regular pointy hexagon fits and centers in the rect', () {
    final path = const HexagonBorder(type: HexagonType.pointy)
        .getOuterPath(const Rect.fromLTWH(0, 0, 200, 100));
    const width = 100 * sqrt3 / 2;
    expectRect(
      path.getBounds(),
      const Rect.fromLTWH((200 - width) / 2, 0, width, 100),
    );
  });

  test('eccentricity 1 stretches the hexagon to the rect', () {
    for (final type in HexagonType.values) {
      final path = HexagonBorder(type: type, eccentricity: 1)
          .getOuterPath(const Rect.fromLTWH(10, 20, 300, 50));
      expectRect(path.getBounds(), const Rect.fromLTWH(10, 20, 300, 50));
    }
  });

  test('rounded corners cut off the sharp corners', () {
    final sharp = const HexagonBorder().getOuterPath(square);
    final rounded = const HexagonBorder(cornerRadius: 20).getOuterPath(square);
    // Just inside the left corner of the sharp hexagon.
    const nearCorner = Offset(1, 100);
    expect(sharp.contains(nearCorner), isTrue);
    expect(rounded.contains(nearCorner), isFalse);
    // Edges away from the corners are unchanged.
    expect(rounded.contains(const Offset(100, 15)), isTrue);
    expect(rounded.contains(const Offset(100, 100)), isTrue);
    // A huge radius is clamped instead of producing a broken path.
    final huge = const HexagonBorder(cornerRadius: 1000).getOuterPath(square);
    expect(huge.getBounds().isFinite, isTrue);
    expect(huge.contains(const Offset(100, 100)), isTrue);
  });

  test('inner path is inset by the border width', () {
    const border = HexagonBorder(side: BorderSide(width: 10));
    final outer = border.getOuterPath(square).getBounds();
    final inner = border.getInnerPath(square).getBounds();
    // Flat side corners move inward by width / sin(60°).
    expect(inner.width, closeTo(outer.width - 2 * 10 / (sqrt3 / 2), 0.01));
    expect(inner.height, closeTo(outer.height - 20, 0.01));
    expect(border.dimensions, const EdgeInsets.all(10));
  });

  test('paints the outline and interior without errors', () {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const HexagonBorder(cornerRadius: 8, side: BorderSide(width: 2))
        .paint(canvas, square);
    const HexagonBorder().paintInterior(canvas, square, Paint());
    recorder.endRecording().dispose();
  });

  test('lerps between hexagon borders of the same type', () {
    const a = HexagonBorder(side: BorderSide(width: 0));
    const b = HexagonBorder(cornerRadius: 10, side: BorderSide(width: 4));
    final mid = ShapeBorder.lerp(a, b, 0.5)! as HexagonBorder;
    expect(mid.cornerRadius, 5);
    expect(mid.side.width, 2);
    expect(ShapeBorder.lerp(a, b, 0), a);
    expect(ShapeBorder.lerp(a, b, 1), b);
  });

  test('scale, copyWith and equality', () {
    const border = HexagonBorder(cornerRadius: 4, side: BorderSide(width: 2));
    final scaled = border.scale(2) as HexagonBorder;
    expect(scaled.cornerRadius, 8);
    expect(scaled.side.width, 4);
    expect(border.copyWith(type: HexagonType.pointy).type, HexagonType.pointy);
    expect(border.copyWith(), border);
    expect(border.hashCode, border.copyWith().hashCode);
    expect(border, isNot(const HexagonBorder()));
    expect(border.toString(), contains('flat'));
  });

  testWidgets('works as a Material shape', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: Material(
              shape: HexagonBorder(cornerRadius: 4),
              elevation: 4,
              color: Colors.amber,
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
