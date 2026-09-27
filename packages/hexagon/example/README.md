# hexagon example

A gallery of the `hexagon` package, also
[running in the browser](https://orlikraf.github.io/flutter-hexagon/).

* **Widgets** ([widgets_page.dart](lib/widgets_page.dart)): `Hexagon` in
  flat and pointy, with images, wrap sizing, rounded corners and outlines,
  and `HexagonBorder` on buttons, cards and an animated container.
* **Grids** ([grids_page.dart](lib/grids_page.dart)): `HexGrid` with every
  `HexShape`, flat or pointy, adjustable spacing and tap-to-select.
* **Scrolling** ([scrolling_page.dart](lib/scrolling_page.dart)):
  `SliverHexGrid` in a `CustomScrollView`, as a horizontal zigzag strip and
  an endless honeycomb that sizes its hexagons to fit.
* **Game map** ([map_page.dart](lib/map_page.dart)): `HexGridView` with
  generated terrain, units on a widget layer, movement range, path preview
  and field of view, plus camera controls.

```sh
flutter run
```
