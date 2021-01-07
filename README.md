# Hexagon

A widget in a shape of hexagon.
Inspired by fantastic hexagons analysis available on [redblobgames](https://www.redblobgames.com/grids/hexagons/).

<img src="https://raw.githubusercontent.com/rSquared-software/flutter-hexagon/master/example/hexagon_example_1.png" width="200"> <img src="https://raw.githubusercontent.com/rSquared-software/flutter-hexagon/master/example/hexagon_example_2.png" width="200"> <img src="https://raw.githubusercontent.com/rSquared-software/flutter-hexagon/master/example/hexagon_example_3.png" width="200">

## Installation
Add this to your package's pubspec.yaml file:

[![pub package](https://img.shields.io/pub/v/hexagon.svg)](https://pub.dev/packages/hexagon)

```yaml
dependencies:
  hexagon: ^0.0.5
```

## Usage

### Single widget
Width or height must be set when defining a HexagonWidget. The other dimension is calculated based on selected HexagonType.
Use named constructors for flat or pointy for simple shaped hexagon. Elevation changes hexagon shadow size.

```dart
HexagonWidget.flat(
  width: w,
  color: Colors.limeAccent,
  child: Text('A flat tile'),
),
HexagonWidget.pointy(
  width: w,
  color: Colors.red,
  elevation: 0,
  child: Text('A pointy tile'),
),
```

The `template` constructor is used in grids and will throw an error while rendering.

### Grids
#### Offset Grid
[Check Coordinates Offset on redblobgames](https://www.redblobgames.com/grids/hexagons/#coordinates-offset)

Simple coordinate system similar to regular table.

As hexagon columns or rows can begin with hex or an empty space this grid has 4 named constructors to represent all combinations with flat and pointy hexagons.
* oddPointy
* evenPointy
* oddFlat
* evenFlat

Every constructor requires `columns` and `rows` params.
At least one of grid constrains must be finite. The grid will fit given rows and columns in given space.

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    HexagonOffsetGrid.oddPointy(
      columns: 5,
      rows: 10,
      buildHexagon: (col, row) => HexagonWidget.template(
        color: row.isEven ? Colors.yellow : Colors.orangeAccent,
        elevation: 2,
        child: Text('${col+1}, ${row+1}'),
      ),
      buildChild: (col, row) {
        return Text('$col, $row');
      },
    ),
  ],
),
```

To customize `HexagonWidget` in grid use buildHexagon function and return a `HexagonWidget.template(color, elevation, child)`.
If you provide a `buildChild` function it will override any child provided in template.

#### Hexagon Grid

* _Soon_

## Road map

* ~~Margins between tiles in HexagonOffsetGrid~~ (Added padding since `0.0.5`)
* Hexagonal shaped grid (using cube/axial coordinates system)
* Solve content spacing in hexagon widget
* Check performance