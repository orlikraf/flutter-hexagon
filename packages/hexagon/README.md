# hexagon

[![pub package](https://img.shields.io/pub/v/hexagon.svg)](https://pub.dev/packages/hexagon)

Hexagons for Flutter apps and games: a hexagon widget and `ShapeBorder`,
hex grids, and a pannable, zoomable hex map with painted layers,
pathfinding and hit testing.

<img src="https://raw.githubusercontent.com/orlikraf/flutter-hexagon/main/packages/hexagon/example/hexagon_example_1.png" width="200"> <img src="https://raw.githubusercontent.com/orlikraf/flutter-hexagon/main/packages/hexagon/example/hexagon_example_2.png" width="200"> <img src="https://raw.githubusercontent.com/orlikraf/flutter-hexagon/main/packages/hexagon/example/hexagon_example_3.png" width="200"> <img src="https://raw.githubusercontent.com/orlikraf/flutter-hexagon/main/packages/hexagon/example/hexagon_example_4.png" width="200">

| You want… | Use |
|---|---|
| A hexagon-shaped button, card, avatar or tile | `Hexagon`, or `HexagonBorder` on any Material widget |
| A board or menu of up to a few hundred cells | `HexGrid` |
| A large map with pan, zoom, overlays and units | `HexGridView` |
| Coordinates, distances, pathfinding, field of view | `Hex`, `HexLayout`, `HexShape`, `HexMap` (from [`hexagon_core`](https://pub.dev/packages/hexagon_core), re-exported) |

```yaml
dependencies:
  hexagon: ^1.0.0
```

```dart
import 'package:hexagon/hexagon.dart';
```

Upgrading from 0.x? See [MIGRATION.md](MIGRATION.md).

## Hexagon

A hexagon-shaped surface. It picks its size during layout, like
`AspectRatio`, so give it a width, a height, or constraints:

```dart
Hexagon(
  width: 120,
  color: Colors.amber,
  elevation: 4,
  cornerRadius: 8,
  side: const BorderSide(color: Colors.brown, width: 2),
  onTap: () {},
  child: const Icon(Icons.hive),
)

Hexagon.pointy(height: 80, child: Text('Pointy'))
```

* **`fit`**: `HexagonFit.contain` (default) draws the largest hexagon that
  fits the constraints. `HexagonFit.wrap` sizes the hexagon around its child.
* **`childArea`**: `HexagonChildArea.inscribed` (default) lays the child out
  in the largest rectangle inside the hexagon, so text and icons stay
  visible. `HexagonChildArea.bounds` gives the child the whole bounding box,
  clipped to the hexagon, which suits images.
* Taps, long presses and hover only count **inside the outline**, so
  hexagons can overlap their bounding boxes.

Set defaults for every `Hexagon` with the theme extension:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: const [HexagonThemeData(cornerRadius: 6, elevation: 2)],
  ),
)
```

## HexagonBorder

A `ShapeBorder`, so it works wherever Flutter takes a shape:

```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(shape: const HexagonBorder(cornerRadius: 8)),
  onPressed: () {},
  child: const Text('Hex button'),
)

Card(shape: const HexagonBorder(type: HexagonType.pointy), child: ...)

Container(
  decoration: const ShapeDecoration(
    shape: HexagonBorder(side: BorderSide(width: 2)),
    color: Colors.teal,
  ),
)

ClipPath.shape(shape: const HexagonBorder(cornerRadius: 12), child: image)
```

The hexagon is regular and centered in its box; `eccentricity: 1` stretches
it to the box instead. Borders of the same type animate between each other,
for example in `AnimatedContainer` or `ShapeBorderTween`.

## HexGrid

One widget per cell, for any set of cells:

```dart
HexGrid(
  cells: HexShape.hexagon(3),          // or rectangle, parallelogram, triangle, any Iterable<Hex>
  type: HexagonType.pointy,
  spacing: 4,
  itemBuilder: (context, hex) => Hexagon(
    type: HexagonType.pointy,
    child: Text('${hex.q}, ${hex.r}'),
  ),
  onHexTap: (hex) => print('tapped $hex'),
)
```

Without a `radius`, the hexagons are sized so the grid fits its constraints.
Each cell gets exactly its hexagon's bounding box and only receives pointers
inside its hexagon.

## HexGridView

For maps with thousands of cells. It pans and zooms, paints only the cells
in the viewport, and stacks layers bottom to top:

```dart
final controller = HexGridController();

HexGridView(
  layout: const HexLayout.flat(radius: 24),
  cells: terrain.cells.toSet(),
  controller: controller,
  layers: [
    // Canvas layers: nothing is built per cell.
    HexPaintLayer.fill(colorOf: (hex) => terrain[hex]!.color),
    HexPaintLayer.fill(cells: reachable, color: Colors.white24),
    HexPaintLayer(
      cells: path,
      painter: (canvas, cell) =>
          canvas.drawCircle(cell.center, 5, Paint()..color = Colors.white),
    ),
    // Widgets for the few cells that need them.
    HexWidgetLayer(cells: units.keys, builder: (context, hex) => UnitToken(units[hex]!)),
  ],
  onHexTap: select,
  onHexHover: preview,
)

controller.animateTo(const Hex(10, -4), scale: 2);
controller.hexAtViewport(position);
```

`HexCell` gives painters the cell's center, bounding box and outline path.
Pass `repaint:` a `Listenable` (an animation, or a `ChangeNotifier` holding
game state) to repaint a layer without rebuilding.

## Grid math, pathfinding and field of view

Everything in [`hexagon_core`](https://pub.dev/packages/hexagon_core) is
re-exported. It has no Flutter dependency, so a game server can use it too.

```dart
const a = Hex(2, -1);
a.distanceTo(const Hex(-1, 3));          // 4
a.neighbors;
a.lineTo(const Hex(5, -3));
Hex.fromOffset(3, 4, HexagonType.flat);  // from column/row

const layout = HexLayout.pointy(radius: 24);
layout.centerOf(a);                      // Offset
layout.hexAt(details.localPosition);     // Hex under a pointer

final range = unit.reachable(movement: 5, passable: isLand, cost: moveCost);
final path = unit.pathTo(target, passable: isLand, cost: moveCost);
final visible = unit.fieldOfView(8, blocksSight: isWall);
```

## Example

The [example app](example/lib), also
[running in the browser](https://orlikraf.github.io/flutter-hexagon/), has
three pages: widgets and borders, grids
with every built-in shape, and a small strategy map with units, movement
range, path preview and field of view.

## Credits

The grid math follows Red Blob Games'
[Hexagonal Grids](https://www.redblobgames.com/grids/hexagons/).
