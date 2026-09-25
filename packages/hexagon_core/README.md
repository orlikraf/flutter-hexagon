# hexagon_core

Hexagonal grid math in pure Dart: coordinates, pixel layouts, map shapes,
pathfinding, movement range and field of view.

No Flutter dependency, so the same code runs in a Flutter app, a Flame game,
a command-line tool or a game server. For widgets, use
[`hexagon`](https://pub.dev/packages/hexagon), which re-exports this package.

The math follows Red Blob Games'
[Hexagonal Grids](https://www.redblobgames.com/grids/hexagons/) guide.

## Coordinates

`Hex` stores axial coordinates `(q, r)`; the third cube coordinate `s` is
derived.

```dart
const a = Hex(2, -1);
const b = Hex(-1, 3);

a.distanceTo(b);          // 4
a.neighbors;              // the 6 adjacent hexes
a + Hex.directions[0];    // one step in direction 0
a.rotateRight();          // 60° clockwise around the origin
a.rotateAround(b, 2);     // 120° clockwise around b
a.lineTo(b);              // hexes on a straight line, both ends included
a.ring(2);                // hexes exactly 2 steps away
a.spiral(2);              // a, then its rings 1 and 2
```

Convert to and from rectangular "column, row" systems:

```dart
final hex = Hex.fromOffset(3, 4, HexagonType.flat);            // odd-q
final (:column, :row) = hex.toOffset(HexagonType.flat);
Hex.fromOffset(3, 4, HexagonType.pointy, parity: OffsetParity.even);
Hex.fromDoubled(4, 2, HexagonType.pointy);
```

## Pixels

`HexLayout` maps hexes to pixel positions and back, for drawing and hit
testing:

```dart
const layout = HexLayout.pointy(radius: 24, spacing: 2);

layout.hexToPixel(const Hex(1, 2));             // center of the hex
layout.pixelToHex(const PixelPoint(130, 75));   // hex under a point
layout.corners(const Hex(1, 2));                // its 6 corners
layout.boundsOf(cells);                         // bounding box of a map
layout.hexesInRect(viewport);                   // hexes visible in a rect
```

## Maps

`HexShape` builds common map shapes, and `HexMap` stores a value per cell:

```dart
final board = HexShape.hexagon(4);                 // 61 hexes
final field = HexShape.rectangle(20, 12);          // offset rectangle
final terrain = HexMap<Terrain>.fromCells(field, generateTerrain);
terrain.neighborsOf(const Hex(3, 3));              // neighbors in the map
```

## Pathfinding and visibility

```dart
bool passable(Hex hex) => terrain[hex]?.walkable ?? false;
double? cost(Hex from, Hex to) => terrain[to]?.movementCost;

// Every hex reachable with 5 movement points, with its cost.
final range = unit.reachable(movement: 5, passable: passable, cost: cost);

// Cheapest path (A*), or null if there is none.
final path = unit.pathTo(target, passable: passable, cost: cost);

// Line of sight and field of view.
unit.canSee(target, blocksSight: (hex) => terrain[hex]!.isWall);
unit.fieldOfView(8, blocksSight: (hex) => terrain[hex]!.isWall);
```

Searches on an unbounded plane are limited by `movement` and `maxVisited`;
pass `passable` to keep them inside your map.

## Performance

`benchmark/hexagon_core_benchmark.dart` times the operations games call
every frame or turn on a 200 × 200 map. Run it with:

```sh
dart run benchmark/hexagon_core_benchmark.dart
```
