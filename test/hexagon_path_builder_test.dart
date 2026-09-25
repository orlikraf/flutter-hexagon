import 'dart:math' as math;
import 'dart:ui';

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

void _expectWithin(Rect actual, Rect bounds) {
  final outer = bounds.inflate(_tolerance);
  expect(
    actual.left >= outer.left &&
        actual.top >= outer.top &&
        actual.right <= outer.right &&
        actual.bottom <= outer.bottom,
    isTrue,
    reason: '$actual is not within $bounds',
  );
}

/// Points along [path], [step] logical pixels apart.
Iterable<Offset> _samplePath(Path path, {double step = 1}) sync* {
  for (final metric in path.computeMetrics()) {
    for (var distance = 0.0; distance <= metric.length; distance += step) {
      yield metric.getTangentForOffset(distance)!.position;
    }
  }
}

void main() {
  group('HexagonPathBuilder geometry', () {
    test('flat hexagon fills its box', () {
      final size = Size(100, 50 * _sqrt3);
      final path = HexagonPathBuilder(HexagonType.flat).build(size);
      _expectRect(path.getBounds(), Offset.zero & size);
    });

    test('pointy hexagon fills its box', () {
      final size = Size(50 * _sqrt3, 100);
      final path = HexagonPathBuilder(HexagonType.pointy).build(size);
      _expectRect(path.getBounds(), Offset.zero & size);
    });

    test('flat hexagon out of bounds overflows left and right by 1/8', () {
      final size = Size(75, 50 * _sqrt3);
      final path = HexagonPathBuilder(
        HexagonType.flat,
        inBounds: false,
      ).build(size);
      _expectRect(path.getBounds(), Rect.fromLTRB(-12.5, 0, 87.5, 50 * _sqrt3));
    });

    test('pointy hexagon out of bounds overflows top and bottom by 1/8', () {
      final size = Size(50 * _sqrt3, 75);
      final path = HexagonPathBuilder(
        HexagonType.pointy,
        inBounds: false,
      ).build(size);
      _expectRect(path.getBounds(), Rect.fromLTRB(0, -12.5, 50 * _sqrt3, 87.5));
    });

    test('equality', () {
      expect(
        HexagonPathBuilder(HexagonType.flat),
        HexagonPathBuilder(HexagonType.flat, inBounds: true),
      );
      expect(
        HexagonPathBuilder(HexagonType.flat, borderRadius: 2).hashCode,
        HexagonPathBuilder(HexagonType.flat, borderRadius: 2.0).hashCode,
      );
    });
  });

  group('HexagonPathBuilder with a box of the wrong aspect ratio', () {
    // Regression: the hexagon was sized from one dimension only and painted
    // outside its box.
    test('flat hexagon fits a wide, short box and is centered', () {
      const size = Size(200, 50);
      final bounds = HexagonPathBuilder(
        HexagonType.flat,
      ).build(size).getBounds();
      _expectWithin(bounds, Offset.zero & size);
      expect(bounds.height, closeTo(50, _tolerance));
      expect(bounds.center.dx, closeTo(100, _tolerance));
      expect(bounds.center.dy, closeTo(25, _tolerance));
    });

    test('pointy hexagon fits a narrow, tall box and is centered', () {
      const size = Size(50, 200);
      final bounds = HexagonPathBuilder(
        HexagonType.pointy,
      ).build(size).getBounds();
      _expectWithin(bounds, Offset.zero & size);
      expect(bounds.width, closeTo(50, _tolerance));
      expect(bounds.center.dx, closeTo(25, _tolerance));
      expect(bounds.center.dy, closeTo(100, _tolerance));
    });
  });

  group('HexagonPathBuilder corner radius', () {
    // Regression: negative radii threw, although HexagonWidget documents
    // them as having no effect.
    test('negative radius is treated as no rounding', () {
      final size = Size(100, 50 * _sqrt3);
      final path = HexagonPathBuilder(
        HexagonType.flat,
        borderRadius: -5,
      ).build(size);
      _expectRect(path.getBounds(), Offset.zero & size);
    });

    // Regression: radii larger than the edge allows produced a
    // self-intersecting path far outside the hexagon.
    test('oversized radius stays inside the hexagon', () {
      final size = Size(100, 50 * _sqrt3);
      final path = HexagonPathBuilder(
        HexagonType.flat,
        borderRadius: 1000,
      ).build(size);
      _expectWithin(path.getBounds(), Offset.zero & size);
    });

    // Regression: corners were drawn with a cubic approximation that is
    // not circular (off by about 3% of the radius).
    test('rounded corners are circular arcs', () {
      final size = Size(1000, 500 * _sqrt3);
      final apothem = 250 * _sqrt3;
      // At the largest radius every corner arc meets its neighbours, so
      // the whole outline is a circle around the center.
      final path = HexagonPathBuilder(
        HexagonType.flat,
        borderRadius: apothem,
      ).build(size);
      final center = size.center(Offset.zero);

      for (final point in _samplePath(path)) {
        expect(
          (point - center).distance,
          closeTo(apothem, 1),
          reason: 'point $point is not on the circle',
        );
      }
    });
  });
}
