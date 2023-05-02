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
