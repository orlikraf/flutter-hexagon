import 'package:hexagon_core/hexagon_core.dart';
import 'package:test/test.dart';

void main() {
  final layouts = [
    const HexLayout.flat(radius: 10),
    const HexLayout.pointy(radius: 10),
    const HexLayout.flat(radius: 7, spacing: 3, origin: PixelPoint(40, -20)),
    const HexLayout.pointy(radius: 7, spacing: 3, origin: PixelPoint(-5, 12)),
  ];

  test('hexToPixel and pixelToHex round-trip', () {
    for (final layout in layouts) {
      for (final hex in Hex.zero.range(6)) {
        expect(layout.pixelToHex(layout.hexToPixel(hex)), hex);
      }
    }
  });

  test('points near corners map to the containing hex', () {
    for (final layout in layouts) {
      const hex = Hex(2, -1);
      final center = layout.hexToPixel(hex);
      for (final corner in layout.corners(hex)) {
        final inside = center + (corner - center) * 0.95;
        expect(layout.pixelToHex(inside), hex);
      }
    }
  });

  test('neighbor centers are one step apart', () {
    for (final layout in layouts) {
      final center = layout.hexToPixel(Hex.zero);
      final expected = sqrt3 * (layout.radius + layout.spacing / sqrt3);
      for (final n in Hex.zero.neighbors) {
        expect(
            layout.hexToPixel(n).distanceTo(center), closeTo(expected, 1e-9));
      }
    }
  });

  test('cell size and steps', () {
    const flat = HexLayout.flat(radius: 10);
    expect(flat.cellWidth, 20);
    expect(flat.cellHeight, closeTo(17.3205, 1e-4));
    expect(flat.horizontalStep, 15);
    expect(flat.verticalStep, closeTo(17.3205, 1e-4));
    const pointy = HexLayout.pointy(radius: 10);
    expect(pointy.cellWidth, closeTo(17.3205, 1e-4));
    expect(pointy.cellHeight, 20);
    expect(pointy.verticalStep, 15);
  });

  test('corners are radius away from the center', () {
    for (final layout in layouts) {
      final center = layout.hexToPixel(const Hex(1, 1));
      final corners = layout.corners(const Hex(1, 1));
      expect(corners.length, 6);
      for (final corner in corners) {
        expect(corner.distanceTo(center), closeTo(layout.radius, 1e-9));
      }
    }
  });

  test('boundsOf', () {
    const layout = HexLayout.flat(radius: 10);
    expect(layout.boundsOf(const []), PixelRect.zero);
    expect(layout.boundsOf([Hex.zero]), layout.cellBounds(Hex.zero));
    final bounds = layout.boundsOf(HexShape.hexagon(2));
    expect(bounds.width, closeTo(20 + 2 * 2 * 15, 1e-9));
  });

  test('hexesInRect finds exactly the hexes overlapping the rect', () {
    for (final layout in layouts) {
      const rect = PixelRect.fromLTRB(-33, -21, 58, 44);
      final found = layout.hexesInRect(rect).toSet();
      for (final hex in Hex.zero.range(12)) {
        final overlaps = layout.cellBounds(hex).overlaps(rect);
        if (overlaps) {
          expect(found, contains(hex), reason: '$layout $hex');
        }
      }
      for (final hex in found) {
        final bounds = layout.cellBounds(hex).inflate(1e-6);
        expect(bounds.overlaps(rect), isTrue, reason: '$layout $hex');
      }
    }
  });

  test('equality and copyWith', () {
    const layout = HexLayout.flat(radius: 10);
    expect(layout, const HexLayout(radius: 10));
    expect(layout.copyWith(radius: 5).radius, 5);
    expect(layout.copyWith(type: HexagonType.pointy).type, HexagonType.pointy);
  });
}
