# hexagon

[![pub package](https://img.shields.io/pub/v/hexagon.svg)](https://pub.dev/packages/hexagon)
[![CI](https://github.com/orlikraf/flutter-hexagon/actions/workflows/ci.yml/badge.svg)](https://github.com/orlikraf/flutter-hexagon/actions/workflows/ci.yml)

Hexagon-shaped widgets and hexagonal grids for Flutter. The geometry
follows the excellent
[hexagon guide on Red Blob Games](https://www.redblobgames.com/grids/hexagons/).

<img src="https://raw.githubusercontent.com/orlikraf/flutter-hexagon/main/example/hexagon_example_1.png" width="200"> <img src="https://raw.githubusercontent.com/orlikraf/flutter-hexagon/main/example/hexagon_example_2.png" width="200"> <img src="https://raw.githubusercontent.com/orlikraf/flutter-hexagon/main/example/hexagon_example_3.png" width="200"> <img src="https://raw.githubusercontent.com/orlikraf/flutter-hexagon/main/example/hexagon_example_4.png" width="200">

## Features

| | |
|---|---|
| `HexagonWidget` | A flat or pointy hexagon with color, elevation, rounded corners and a clipped child |
| `HexagonOffsetGrid` | A rectangular grid addressed by column and row |
| `HexagonGrid` | A hexagon-shaped grid addressed by cube / axial `Coordinates` |
| `Coordinates` | Distances, neighbours, rings, spirals, lines and rotation |
| `HexagonBorder` | The hexagon as a `ShapeBorder`, for `Material`, `Card`, `InkWell` and decorations |

## Installation

```yaml
dependencies:
  hexagon: ^0.3.0
```

```dart
import 'package:hexagon/hexagon.dart';
```

Requires Dart 3.8 / Flutter 3.32 or newer. Upgrading from 0.2? See the
[migration guide](doc/migration.md).

## A single hexagon

Give a `HexagonWidget` a width or a height; the other follows from the
hexagon's aspect ratio. If you give both, the largest hexagon that fits is
drawn, centered.

```dart
HexagonWidget.flat(
  width: 120,
  color: Colors.limeAccent,
  padding: 4,
  child: const Text('A flat tile'),
),
HexagonWidget.pointy(
  width: 120,
  color: Colors.red,
  elevation: 8,
  cornerRadius: 12,
  child: const Text('A pointy tile'),
),
```

The child is clipped to the hexagon; pass `clipBehavior: Clip.none` to let
it overflow.

## Which grid do I need?

| | `HexagonOffsetGrid` | `HexagonGrid` |
|---|---|---|
| Shape | Rectangle | Hexagon |
| Tiles addressed by | `(col, row)` | `Coordinates` (cube / axial) |
| Size | `columns` × `rows` | `depth` rings around a center tile |
| Good for | Boards, maps, menus laid out in rows | Game boards, radial layouts, anything using distances or neighbours |

Both grids fit themselves into the available space. Style every tile with a
`hexagonBuilder` template, or a single tile by returning a
`HexagonWidgetBuilder` from `buildTile` (return `null` to use the
template). `buildChild` sets a tile's content and overrides any child from
a builder.

### Offset grid

Every other column (flat tiles) or row (pointy tiles) is shifted by half a
tile. The constructor says which: `oddFlat`, `evenFlat`, `oddPointy` or
`evenPointy`, like the
[offset coordinates on Red Blob Games](https://www.redblobgames.com/grids/hexagons/#coordinates-offset).
At least one of the grid's constraints must be bounded.

```dart
HexagonOffsetGrid.oddPointy(
  columns: 5,
  rows: 10,
  buildTile: (col, row) => HexagonWidgetBuilder(
    color: row.isEven ? Colors.yellow : Colors.orangeAccent,
    elevation: 2,
  ),
  buildChild: (col, row) => Text('$col, $row'),
)
```

### Hexagon grid

`depth` rings of tiles surround the center tile, `Coordinates.zero`. Give
the grid bounded constraints, or a `width` or `height`.

```dart
InteractiveViewer(
  constrained: false,
  child: HexagonGrid.pointy(
    depth: 5,
    width: 1920,
    buildTile: (coordinates) => HexagonWidgetBuilder(
      padding: 2,
      cornerRadius: 8,
      color: coordinates == Coordinates.zero ? Colors.red : null,
    ),
    buildChild: (coordinates) => Text('${coordinates.q}, ${coordinates.r}'),
  ),
)
```

## Coordinates

`Coordinates` combines
[cube and axial coordinates](https://www.redblobgames.com/grids/hexagons/#coordinates-cube),
which describe the same tile:

```dart
const tile = Coordinates.axial(2, -1); // q, r
assert(tile == Coordinates.cube(2, -1, -1)); // x, y, z with x + y + z == 0

tile.distance(Coordinates.zero); // 2
tile + HexDirections.pointyRight; // the neighbour to the right
tile.neighbors; // all six, clockwise
tile.ring(2); // the 12 tiles exactly 2 steps away
tile.spiral(2); // the 19 tiles at most 2 steps away
tile.rotate(1); // a sixth of a turn clockwise around the center
tile.lineTo(Coordinates.zero); // a connected line of tiles
Coordinates.nearest(1.4, -0.2); // round a fractional position to a tile
```

`HexDirections` names each neighbour by where it appears on screen, e.g.
`pointyTopRight` or `flatBottom`. `HexDirections.of(type)` lists all six,
clockwise.

## The hexagon as a border

`HexagonBorder` puts the hexagon anywhere Flutter takes a `ShapeBorder`,
with an optional outline. Clipping to it also limits taps to the hexagon.

```dart
Material(
  color: Colors.teal,
  shape: const HexagonBorder(
    type: HexagonType.pointy,
    cornerRadius: 12,
    side: BorderSide(color: Colors.white, width: 3),
  ),
  clipBehavior: Clip.antiAlias,
  child: InkWell(
    onTap: () {},
    child: const SizedBox(width: 200, height: 200),
  ),
)
```

Borders of the same type animate smoothly, for example in an
`AnimatedContainer` with a `ShapeDecoration`.

## Example

The [example app](example/lib/main.dart) shows every feature, including an
interactive page for the `Coordinates` helpers.

## Contributing

CI checks formatting, analysis (with every public member documented) and
tests on the oldest supported and the latest stable Flutter. A benchmark of
large grids runs on every push. `docs/PLAN.md` in the repository has the
roadmap.
