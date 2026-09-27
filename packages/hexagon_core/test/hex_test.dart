import 'package:hexagon_core/hexagon_core.dart';
import 'package:test/test.dart';

void main() {
  group('Hex', () {
    test('cube coordinate s keeps the sum at zero', () {
      const hex = Hex(3, -5);
      expect(hex.q + hex.r + hex.s, 0);
      expect(const Hex.cube(3, -5, 2), hex);
    });

    test('arithmetic', () {
      expect(const Hex(1, 2) + const Hex(3, -1), const Hex(4, 1));
      expect(const Hex(1, 2) - const Hex(3, -1), const Hex(-2, 3));
      expect(-const Hex(1, 2), const Hex(-1, -2));
      expect(const Hex(1, -2) * 3, const Hex(3, -6));
    });

    test('equality and hashing', () {
      final hexes = [const Hex(1, 2), Hex(1, 1 + 1), const Hex(2, 1)];
      expect(hexes.toSet().length, 2);
      expect(hexes[0].hashCode, hexes[1].hashCode);
      expect(const Hex(1, 2).toString(), 'Hex(1, 2)');
    });

    test('distance', () {
      expect(Hex.zero.distanceTo(Hex.zero), 0);
      expect(Hex.zero.distanceTo(const Hex(1, 0)), 1);
      expect(Hex.zero.distanceTo(const Hex(1, 3)), 4);
      expect(const Hex(1, 3).distanceTo(const Hex(1, 0)), 3);
      expect(const Hex(4, 0).distanceTo(const Hex(-4, 0)), 8);
      expect(const Hex(3, -7).length, 7);
    });

    test('neighbors are all one step away and distinct', () {
      const center = Hex(2, -3);
      final neighbors = center.neighbors;
      expect(neighbors.toSet().length, 6);
      for (final n in neighbors) {
        expect(center.distanceTo(n), 1);
      }
      expect(center.neighbor(0), center.neighbor(6));
      expect(center.neighbor(-1), center.neighbor(5));
    });

    test('diagonal neighbors are two steps away', () {
      for (final d in Hex.zero.diagonalNeighbors) {
        expect(Hex.zero.distanceTo(d), 2);
      }
    });

    test('directions go counterclockwise and rotations follow them', () {
      for (var i = 0; i < 6; i++) {
        expect(Hex.directions[i].rotateLeft(), Hex.directions[(i + 1) % 6]);
        expect(Hex.directions[i].rotateRight(), Hex.directions[(i + 5) % 6]);
      }
    });

    test('rotateAround', () {
      const center = Hex(1, 1);
      const hex = Hex(3, 0);
      expect(hex.rotateAround(center, 6), hex);
      expect(hex.rotateAround(center, 0), hex);
      expect(
          hex.rotateAround(center, 1), center + (hex - center).rotateRight());
      expect(
          hex.rotateAround(center, -1), center + (hex - center).rotateLeft());
      expect(hex.rotateAround(center, 3).distanceTo(center),
          hex.distanceTo(center));
    });

    test('reflections are involutions and keep distance', () {
      const hex = Hex(2, -5);
      expect(hex.reflectQ().reflectQ(), hex);
      expect(hex.reflectR().reflectR(), hex);
      expect(hex.reflectS().reflectS(), hex);
      expect(hex.reflectQ().q, hex.q);
      expect(hex.reflectR().r, hex.r);
      expect(hex.reflectS().s, hex.s);
      expect(hex.reflectQ().length, hex.length);
    });

    test('lineTo', () {
      expect(Hex.zero.lineTo(Hex.zero), [Hex.zero]);
      final line = Hex.zero.lineTo(const Hex(5, -2));
      expect(line.first, Hex.zero);
      expect(line.last, const Hex(5, -2));
      expect(line.length, 6);
      for (var i = 1; i < line.length; i++) {
        expect(line[i - 1].distanceTo(line[i]), 1);
      }
    });

    test('ring', () {
      expect(Hex.zero.ring(0), [Hex.zero]);
      for (var radius = 1; radius <= 4; radius++) {
        final ring = const Hex(2, 1).ring(radius);
        expect(ring.length, 6 * radius);
        expect(ring.toSet().length, 6 * radius);
        for (final hex in ring) {
          expect(hex.distanceTo(const Hex(2, 1)), radius);
        }
      }
    });

    test('spiral and range cover the same hexes', () {
      for (var radius = 0; radius <= 4; radius++) {
        final spiral = const Hex(-1, 2).spiral(radius);
        final range = const Hex(-1, 2).range(radius).toList();
        final count = 1 + 3 * radius * (radius + 1);
        expect(spiral.length, count);
        expect(range.length, count);
        expect(spiral.toSet(), range.toSet());
        expect(spiral.first, const Hex(-1, 2));
      }
    });

    test('offset coordinates round-trip', () {
      for (final type in HexagonType.values) {
        for (final parity in OffsetParity.values) {
          for (final hex in Hex.zero.range(5)) {
            final offset = hex.toOffset(type, parity: parity);
            expect(
              Hex.fromOffset(offset.column, offset.row, type, parity: parity),
              hex,
            );
          }
        }
      }
    });

    test('offset coordinates shift the right columns and rows', () {
      expect(Hex.fromOffset(1, 0, HexagonType.flat), const Hex(1, 0));
      expect(Hex.fromOffset(2, 0, HexagonType.flat), const Hex(2, -1));
      expect(
        Hex.fromOffset(1, 0, HexagonType.flat, parity: OffsetParity.even),
        const Hex(1, -1),
      );
      expect(Hex.fromOffset(0, 1, HexagonType.pointy), const Hex(0, 1));
      expect(Hex.fromOffset(0, 2, HexagonType.pointy), const Hex(-1, 2));
      expect(
          Hex.fromOffset(-3, -3, HexagonType.pointy)
              .toOffset(HexagonType.pointy),
          (column: -3, row: -3));
    });

    test('doubled coordinates round-trip', () {
      for (final type in HexagonType.values) {
        for (final hex in Hex.zero.range(5)) {
          final doubled = hex.toDoubled(type);
          expect((doubled.column + doubled.row).isEven, isTrue);
          expect(Hex.fromDoubled(doubled.column, doubled.row, type), hex);
        }
      }
    });
  });

  group('FractionalHex', () {
    test('round picks the containing hex', () {
      expect(const FractionalHex(0.1, 0.1).round(), Hex.zero);
      expect(const FractionalHex(0.9, -0.1).round(), const Hex(1, 0));
      expect(const FractionalHex(2.4, -1.3).round(), const Hex(2, -1));
      final rounded = const FractionalHex(0.5, 0.4).round();
      expect(rounded.q + rounded.r + rounded.s, 0);
    });

    test('lerp', () {
      expect(
        const FractionalHex(0, 0).lerp(const FractionalHex(2, -4), 0.5),
        const FractionalHex(1, -2),
      );
    });
  });

  group('HexagonType', () {
    test('ratios', () {
      expect(HexagonType.flat.ratio, closeTo(1.1547, 1e-4));
      expect(HexagonType.pointy.ratio, closeTo(0.8660, 1e-4));
      expect(HexagonType.flat.isFlat, isTrue);
      expect(HexagonType.pointy.isPointy, isTrue);
    });

    test('deprecated aliases', () {
      // ignore: deprecated_member_use_from_same_package
      expect(HexagonType.FLAT, HexagonType.flat);
      // ignore: deprecated_member_use_from_same_package
      expect(HexagonType.POINTY, HexagonType.pointy);
    });

    test('radiusToFit fits the box', () {
      for (final type in HexagonType.values) {
        final radius = type.radiusToFit(200, 100);
        expect(type.widthForRadius(radius), lessThanOrEqualTo(200 + 1e-9));
        expect(type.heightForRadius(radius), lessThanOrEqualTo(100 + 1e-9));
      }
    });

    test('radiusToEnclose puts the rectangle corners on or inside', () {
      for (final type in HexagonType.values) {
        for (final (w, h) in [(1.0, 1.0), (3.0, 1.0), (1.0, 3.0)]) {
          final radius = type.radiusToEnclose(w, h);
          final layout = HexLayout(type: type, radius: radius);
          final corner = PixelPoint(w / 2, h / 2);
          // The corner rounds to the center hex when it is inside it.
          expect(layout.pixelToHex(corner * 0.999), Hex.zero);
          // A square slightly smaller than the naive estimate would not fit.
          expect(radius, greaterThan(0));
        }
      }
      // Regression: a unit square needs R = 1/2 + 1/(2√3) ≈ 0.789 for flat.
      expect(HexagonType.flat.radiusToEnclose(1, 1), closeTo(0.7887, 1e-4));
    });

    test('inscribed rectangle', () {
      final flat = HexagonType.flat.inscribedRectForRadius(10);
      expect(flat.width, 10);
      expect(flat.height, closeTo(17.3205, 1e-4));
      final pointy = HexagonType.pointy.inscribedRectForRadius(10);
      expect(pointy.width, closeTo(17.3205, 1e-4));
      expect(pointy.height, 10);
    });
  });
}
