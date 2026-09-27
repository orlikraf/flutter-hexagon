# Migrating from 0.x to 1.0

Your 0.x code keeps compiling on 1.0: the old widgets are still exported,
marked `@Deprecated`, and will be removed in 2.0.0. Update at your own pace
using the table below.

## 1. Requirements

Dart 3.6 and Flutter 3.27 or newer.

## 2. Enum names

`HexagonType.FLAT` and `HexagonType.POINTY` are now `HexagonType.flat` and
`HexagonType.pointy`. Rename them automatically:

```sh
dart fix --apply
```

`ratio`, `isFlat` and `isPointy` are members of the enum now, so you no
longer need to import `HexagonTypeExtension` for them.

## 3. Replacements

| 0.x | 1.0 |
|---|---|
| `HexagonWidget(width: w, color: c, elevation: e, cornerRadius: r, child: …)` | `Hexagon(width: w, color: c, elevation: e, cornerRadius: r, child: …)` |
| `HexagonWidget.flat(…)` / `.pointy(…)` | `Hexagon.flat(…)` / `Hexagon.pointy(…)` |
| `HexagonWidget(padding: p, …)` | Wrap the `Hexagon` in `Padding`, or use `HexGrid(spacing: …)` |
| `HexagonWidget(inBounds: false)` | Not needed: `Hexagon` always fits its box and `HexGrid` places cells |
| Image child with `AspectRatio` | `Hexagon(childArea: HexagonChildArea.bounds, child: Image(…, fit: BoxFit.cover))` |
| `HexagonGrid(depth: d, buildTile: …, buildChild: …)` | `HexGrid(cells: HexShape.hexagon(d), itemBuilder: (context, hex) => Hexagon(…))` |
| `HexagonOffsetGrid.oddFlat(columns: c, rows: r, …)` | `HexGrid(cells: HexShape.rectangle(c, r), …)` |
| `HexagonOffsetGrid.evenPointy(columns: c, rows: r, …)` | `HexGrid(type: HexagonType.pointy, cells: HexShape.rectangle(c, r, type: HexagonType.pointy, parity: OffsetParity.even), …)` |
| `buildTile: (col, row) => …` | `itemBuilder: (context, hex)`, with `hex.toOffset(type)` for `(column, row)` |
| `HexagonWidgetBuilder(…)` | Return a `Hexagon` from `itemBuilder`; use `HexagonThemeData` for shared defaults |
| `Coordinates.axial(q, r)` | `Hex(q, r)` |
| `Coordinates.cube(x, y, z)` | `Hex.cube(x, z, y)` (0.x stored `r` in `z`) |
| `coordinates.distance(other)` | `hex.distanceTo(other)` |
| `HexDirections.pointyRight` etc. | `Hex.directions[i]` or `hex.neighbors` |
| `HexagonPainter` / `HexagonClipper` / `HexagonPathBuilder` | `HexagonBorder` with `ShapeDecoration`, `Material(shape:)` or `ClipPath.shape` |
| `InteractiveViewer` around a big `HexagonGrid` | `HexGridView`, which only builds visible cells |

## 4. Behavior differences

* `Hexagon` uses `Material`, so it needs a `Material`-compatible ancestor
  theme (any `MaterialApp`) and shows ink ripples when `onTap` is set.
* Only pointers inside the hexagon reach it. Tapping the corners of the
  bounding box no longer triggers it.
* The default color comes from `ColorScheme.surfaceContainerHighest` instead
  of white.
