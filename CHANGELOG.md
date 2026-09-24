## Unreleased

See [doc/migration.md](doc/migration.md) for upgrading from 0.2.

* Requires Dart 3.8 / Flutter 3.32 or newer.
* Renamed, with the old names deprecated until 1.0.0: `HexagonType.flat` /
  `.pointy`, `GridType.even` / `.odd`, and `HexDirections` names made
  consistent (e.g. `flatBottom`, `pointyBottomRight`). `flatFactor` and
  `pointyFactor` are deprecated.
* Added `HexDirections.of(type)` and exported `HexagonPathBuilder`.
* Added `HexagonBorder`, a hexagon `OutlinedBorder` for `Material`, `Card`,
  `InkWell`, `ShapeDecoration` and `ShapeBorderClipper`, with an optional
  outline (`side`) and smooth `lerp` between corner radii.
* Added `clipBehavior` to `HexagonWidget` and `HexagonWidgetBuilder`. Tiles
  without a child are no longer clipped, so they build fewer widgets.
* `HexDirections` fields are `const`; `Coordinates.axial` is `const`;
  `Coordinates.cube` asserts `x + y + z == 0`.
* Every public API is documented.
* Fixed: `HexagonOffsetGrid` overflowing its box for some sizes and shapes.
* Fixed: `HexagonGrid` overflowing for some sizes, ignoring `padding` when
  `width` or `height` is set, and exceeding its parent's constraints.
* Fixed: `Coordinates.hashCode` collisions that slowed down maps and sets.
* Fixed: rounded corners are now circular arcs; `cornerRadius` is clamped
  to what the hexagon allows, and negative values are ignored as
  documented.
* Fixed: a hexagon given both `width` and `height` is now fitted inside its
  box instead of painted outside it.
* `HexagonGrid.buildTile` may return `null` to use `hexagonBuilder`, as
  documented.
* Grids now assert when the shared `hexagonBuilder` has a key (use
  `buildTile` for per-tile keys), and every `HexagonOffsetGrid`
  constructor asserts `columns > 0` and `rows > 0`.
* `HexagonGrid` and `HexagonOffsetGrid` accept a `key`; grid constructors
  and `HexagonWidget.flat` / `.pointy` are now `const`.
* `HexagonWidgetBuilder.build` types its `inBounds` parameter as `bool`.

## [0.2.0] - 01.05.2023

* Migrated to null safety.

## [0.1.1] - 12.03.2021

* Single row/column offset grids won't have displaces tiles.

## [0.1.0] - 04.02.2021

* Added HexagonGrid
* Added Coordinates
* Added _`padding`_ attribute to HexagonOffsetGrid
* Updated example

## [0.0.7] - 22.01.2021

* BREAKING CHANGE - Introducing HexagonWidgetBuilder in replacement of HexagonWidget.template() constructor.
* BREAKING CHANGE - HexagonOffsetGrid renamed attribute _buildHexagon_ to _buildTile_. Please adjust HexagonOffsetGrid usage;
* Added _`cornerRadius'_ attribute to HexagonWidget
* Other inner changes

## [0.0.6] - 13.01.2021

* BREAKING CHANGE - updated whole library imports to single line `import 'package:hexagon/hexagon.dart';`
* Fixed exception on `HexagonPainter.hitTest`

## [0.0.5] - 07.01.2021

* Added _`padding`_ attribute to HexagonWidget
* Added _`hexagonPadding`_ to HexagonOffsetGrid

## [0.0.4] - 08.11.2020

* Added HexagonOffsetGrid.
* Changed default elevation to 0 in HexagonWidget.
* Updated example and readme.

## [0.0.3] - 06.10.2020

* Updated example and readme.
* Some code refactoring.

## [0.0.2] - 04.10.2020

* Changed HexagonShadowPainter to HexagonPainter.
* Added extensions for HexagonType.
* Added named constructors for flat and pointy HexagonWidgets.
* Added color parameter for HexagonWidget.
* Added inBounds parameter as a preparation for upcoming HexagonGrids.

## [0.0.1] - 29.09.2020

* First release.
