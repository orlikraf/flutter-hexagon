import 'package:hexagon_core/hexagon_core.dart';

void main() {
  // A hexagon-shaped map with a wall through the middle.
  final walls = {for (var r = -2; r <= 1; r++) Hex(0, r)};
  final map = HexMap<bool>.fromCells(
    HexShape.hexagon(3),
    (hex) => walls.contains(hex),
  );
  bool passable(Hex hex) => map[hex] == false;

  const start = Hex(-2, 1);
  const goal = Hex(2, -1);

  print('Distance: ${start.distanceTo(goal)}');
  print('Path: ${start.pathTo(goal, passable: passable)}');
  print(
      'Reachable in 2 moves: ${start.reachable(movement: 2, passable: passable).length} hexes');
  print('Can see the goal: ${start.canSee(goal, blocksSight: walls.contains)}');

  // Pixel positions for drawing or hit testing.
  const layout = HexLayout.pointy(radius: 24);
  print('Goal center: ${layout.hexToPixel(goal)}');
  print('Hex under (100, 40): ${layout.pixelToHex(const PixelPoint(100, 40))}');
}
