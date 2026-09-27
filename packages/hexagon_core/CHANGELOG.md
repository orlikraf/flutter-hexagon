## 1.0.0

First release, split out of `hexagon` so the grid math can be used without
Flutter.

* `Hex`: axial/cube coordinates, arithmetic, distance, neighbors and
  diagonals, rotation, reflection, lines, rings, spirals and ranges.
* Offset (odd/even, rows or columns) and doubled coordinate conversions.
* `FractionalHex` with cube rounding.
* `HexLayout`: hex ↔ pixel conversion with spacing and origin, corners,
  bounds and visible-hex queries (`hexesInRect`).
* `HexShape`: hexagon, rectangle, parallelogram and triangle maps.
  Triangles point up, down, left or right for both hexagon types (exact when
  the base follows the hexagons' flat sides, stepped otherwise), can be
  centered on a hex or hollow. `HexShape.outline` and `HexShape.centerOn`
  work with any shape.
* `HexMap<T>`: per-cell storage.
* `HexSearch`: `reachable` (Dijkstra), `pathTo` (A*), `canSee` and
  `fieldOfView`.
* `HexagonType` (moved from `hexagon`), with the old `FLAT`/`POINTY` names
  kept as deprecated aliases and `dart fix` support for renaming them.
