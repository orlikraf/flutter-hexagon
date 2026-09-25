# Migration guide

## 0.2 → 0.3

0.3 requires **Dart 3.8 / Flutter 3.32** or newer. On older Flutter,
dependency resolution keeps you on 0.2.

Nothing is removed. Renamed APIs keep their old names, marked
`@Deprecated`, until 1.0.0. Your analyzer points at each use, and the
table below gives the replacement.

### Renamed

| 0.2 | 0.3 |
|-----|-----|
| `HexagonType.FLAT` | `HexagonType.flat` |
| `HexagonType.POINTY` | `HexagonType.pointy` |
| `GridType.EVEN` | `GridType.even` |
| `GridType.ODD` | `GridType.odd` |
| `HexDirections.pointyDownRight` | `HexDirections.pointyBottomRight` |
| `HexDirections.pointyDownLeft` | `HexDirections.pointyBottomLeft` |
| `HexDirections.flatDown` | `HexDirections.flatBottom` |
| `HexDirections.flatRightTop` | `HexDirections.flatTopRight` |
| `HexDirections.flatRightDown` | `HexDirections.flatBottomRight` |
| `HexDirections.flatLeftTop` | `HexDirections.flatTopLeft` |
| `HexDirections.flatLeftDown` | `HexDirections.flatBottomLeft` |

`HexagonTypeExtension.flatFactor` and `pointyFactor` are deprecated with
no replacement: they are layout internals.

One visible difference: `HexagonType.flat.name` is now `'flat'` (it was
`'FLAT'`). If you store enum names, for example in saved games, map the
old spellings when reading them back.

### Changed behaviour

- **Grids fit their box.** `HexagonOffsetGrid` and `HexagonGrid` no
  longer overflow for some sizes, so tiles may be slightly smaller than
  before in boxes where they used to overflow.
  - Single-row pointy and single-column flat offset grids no longer
    reserve an empty half tile.
  - `HexagonGrid` now subtracts `padding` when `width` or `height` is
    set, and never grows beyond its parent.
- **Corners.** Rounded corners are circular arcs, so they look slightly
  rounder than before. `cornerRadius` is clamped to what the hexagon
  allows, and negative values are ignored.
- **Width and height together.** A `HexagonWidget` with both `width` and
  `height` draws the largest hexagon that fits, centered, instead of
  painting outside its box.
- **New asserts:**
  - a grid's shared `hexagonBuilder` must not have a key; give tiles keys
    through `buildTile`
  - every `HexagonOffsetGrid` constructor requires `columns > 0` and
    `rows > 0`
  - `Coordinates.cube(x, y, z)` requires `x + y + z == 0`
- **`HexDirections`** fields are now `const`, and the class can no longer
  be instantiated (it only ever held constants).

### New

- `HexDirections.of(type)`: the six neighbour directions, clockwise.
- `HexagonPathBuilder` is exported, for custom painting or clipping in
  the same shape as a `HexagonWidget`.
- `HexagonGrid.buildTile` may return `null` to use `hexagonBuilder`.
- `Coordinates.axial` is a `const` constructor.
- `HexagonGrid` and `HexagonOffsetGrid` take a `key`, and all widget
  constructors are `const`.

## Planned for 1.0

- The deprecated names above are removed.
- `HexagonWidget` stops wrapping itself in an `Align`. Today it expands to
  fill any bounded parent. Afterwards it sizes to its `width`/`height`,
  as other widgets do, and you add `Center` or `Align` yourself where you
  want it centered.
