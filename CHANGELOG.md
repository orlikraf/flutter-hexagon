# Changelog

All notable changes to this package. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the package
follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

Upgrading from 0.2? See [doc/migration.md](doc/migration.md).

### Added

- `HexagonBorder`: a hexagon `OutlinedBorder` for `Material`, `Card`,
  `InkWell`, `ShapeDecoration` and `ShapeBorderClipper`, with an optional
  outline (`side`) and smooth `lerp` between corner radii.
- `Coordinates` helpers: `neighbors`, `ring`, `spiral`, `rotate`, `lineTo`,
  `Coordinates.nearest` and `operator *`.
- `HexDirections.of(type)`: the six neighbour directions, clockwise.
- `clipBehavior` on `HexagonWidget` and `HexagonWidgetBuilder`.
- `key` on `HexagonGrid` and `HexagonOffsetGrid`.
- `HexagonPathBuilder` is exported.
- API documentation for every public member.

### Changed

- Requires Dart 3.8 / Flutter 3.32 or newer.
- Tiles without a child are no longer clipped, so they build fewer widgets:
  large grids build and lay out 20–50% faster.
- `HexagonGrid.buildTile` may return `null` to use `hexagonBuilder`, as
  documented.
- `HexagonWidgetBuilder.build` types its `inBounds` parameter as `bool`.
- Grid constructors, `HexagonWidget.flat`, `HexagonWidget.pointy` and
  `Coordinates.axial` are `const`.
- `HexDirections` fields are `const`, and the class can't be instantiated.
- New asserts: `Coordinates.cube` components must sum to 0; a grid's
  shared `hexagonBuilder` must not have a key (use `buildTile` for per-tile
  keys); every `HexagonOffsetGrid` constructor requires `columns > 0` and
  `rows > 0`.
- `HexagonType.flat.name` is now `'flat'` (was `'FLAT'`).

### Deprecated

These keep working until 1.0.0:

- `HexagonType.FLAT` / `POINTY`: use `flat` / `pointy`.
- `GridType.EVEN` / `ODD`: use `even` / `odd`.
- `HexDirections.pointyDownRight`, `pointyDownLeft`, `flatDown`,
  `flatRightTop`, `flatRightDown`, `flatLeftTop`, `flatLeftDown`: use the
  `...Bottom...` / `...TopRight`-style names.
- `HexagonTypeExtension.flatFactor` / `pointyFactor`: layout internals.

### Fixed

- `HexagonOffsetGrid` overflowed its box for some sizes and shapes.
- `HexagonGrid` overflowed for some sizes, ignored `padding` when `width`
  or `height` was set, and could exceed its parent's constraints.
- `Coordinates.hashCode` collided heavily, slowing down maps and sets.
- Rounded corners are circular arcs; `cornerRadius` is clamped to what the
  hexagon allows, and negative values are ignored as documented.
- A hexagon given both `width` and `height` is fitted inside its box
  instead of painted outside it.

## [0.2.0] - 2023-05-01

- Migrated to null safety.

## [0.1.1] - 2021-03-12

- Single row/column offset grids won't have displaced tiles.

## [0.1.0] - 2021-02-04

- Added HexagonGrid
- Added Coordinates
- Added _`padding`_ attribute to HexagonOffsetGrid
- Updated example

## [0.0.7] - 2021-01-22

- BREAKING CHANGE - Introducing HexagonWidgetBuilder in replacement of HexagonWidget.template() constructor.
- BREAKING CHANGE - HexagonOffsetGrid renamed attribute _buildHexagon_ to _buildTile_. Please adjust HexagonOffsetGrid usage;
- Added _`cornerRadius'_ attribute to HexagonWidget
- Other inner changes

## [0.0.6] - 2021-01-13

- BREAKING CHANGE - updated whole library imports to single line `import 'package:hexagon/hexagon.dart';`
- Fixed exception on `HexagonPainter.hitTest`

## [0.0.5] - 2021-01-07

- Added _`padding`_ attribute to HexagonWidget
- Added _`hexagonPadding`_ to HexagonOffsetGrid

## [0.0.4] - 2020-11-08

- Added HexagonOffsetGrid.
- Changed default elevation to 0 in HexagonWidget.
- Updated example and readme.

## [0.0.3] - 2020-10-06

- Updated example and readme.
- Some code refactoring.

## [0.0.2] - 2020-10-04

- Changed HexagonShadowPainter to HexagonPainter.
- Added extensions for HexagonType.
- Added named constructors for flat and pointy HexagonWidgets.
- Added color parameter for HexagonWidget.
- Added inBounds parameter as a preparation for upcoming HexagonGrids.

## [0.0.1] - 2020-09-29

- First release.
