# Hexagon

A widget in a shape of hexagon.
Inspired by fantastic hexagons analysis available on [redblobgames](https://www.redblobgames.com/grids/hexagons/).

<img src="https://raw.githubusercontent.com/rSquared-software/flutter-hexagon/master/example/hexagon_example_1.png" width="200"> <img src="https://raw.githubusercontent.com/rSquared-software/flutter-hexagon/master/example/hexagon_example_2.png" width="200"> <img src="https://raw.githubusercontent.com/rSquared-software/flutter-hexagon/master/example/hexagon_example_3.png" width="200"> <img src="https://raw.githubusercontent.com/rSquared-software/flutter-hexagon/master/example/hexagon_example_4.png" width="200">

## Installation
Add this to your package's pubspec.yaml file:

[![pub package](https://img.shields.io/pub/v/hexagon.svg)](https://pub.dev/packages/hexagon)

```yaml
dependencies:
  hexagon: ^0.2.0
```

## Usage

```dart
import 'package:hexagon/hexagon.dart';

//...
```

### Single widget
Width or height must be set when defining a HexagonWidget. The other dimension is calculated based on selected HexagonType.
Use named constructors for flat or pointy for simple shaped hexagon. Elevation changes hexagon shadow size.

```dart
HexagonWidget.flat(
  width: w,
  color: Colors.limeAccent,
  padding: 4.0,
  child: Text('A flat tile'),
),
HexagonWidget.pointy(
  width: w,
  color: Colors.red,
  elevation: 8,
  child: Text('A pointy tile'),
),
```

#### Borders
You can add borders to hexagons using the `borderWidth` and `borderColor` properties:

```dart
HexagonWidget.flat(
  width: 120,
  color: Colors.white,
  borderWidth: 3,
  borderColor: Colors.black,
  child: Text('Hexagon with border'),
),
HexagonWidget.pointy(
  height: 100,
  color: Colors.lightBlue,
  borderWidth: 5,
  borderColor: Colors.darkBlue,
  elevation: 4,
  child: Icon(Icons.star),
),
```

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
      buildTile: (col, row) => HexagonWidgetBuilder(
        color: row.isEven ? Colors.yellow : Colors.orangeAccent,
        elevation: 2,
      ),
      buildChild: (col, row) {
        return Text('$col, $row');
      },
    ),
  ],
),
```

To customize any `HexagonWidget` in grid use buildHexagon function and return a `HexagonWidgetBuilder` for tile of your choosing.
If you provide a `buildChild` function it will override any child provided in builder.

#### Hexagon Grid
As it is expected this grid is in a shape of hexagon.
Since offset coordinates wouldn't be intuitive in this case HexagonGrid uses cube and axial coordinates systems.
You can read about them here: [Cube coordinates](https://www.redblobgames.com/grids/hexagons/#coordinates-cube), [Axial coordinates](https://www.redblobgames.com/grids/hexagons/#coordinates-axial).

`Coordinates` class combines both of them as they are easily convertible between each other.

```dart
Coordinates tileQR = Coordinates.axial(q, r);

Coordinates tileXYZ = Coordinates.cube(x, y, z);
```

`HexagonGrid` requires to be constrained by its parent or else you have to provide at lest one size dimension (width or height). Currently this widget will fit itself to fill given space or best match to given size.
Everything related to customize hexagon tiles is similar as in offset grid above.

Below example of using `HexagonGrid` with `InteractiveViewer`.

```dart
InteractiveViewer(
  minScale: 0.2,
  maxScale: 4.0,
  constrained: false,
  child: HexagonGrid.pointy(
    color: Colors.pink,
    depth: depth,
    width: 1920,
    buildTile: (coordinates) => HexagonWidgetBuilder(
      padding: 2.0,
      cornerRadius: 8.0,
      child: Text('${coordinates.q}, ${coordinates.r}'),
    ),
  ),
)
```

## Road map

* ~~Margins between tiles in HexagonOffsetGrid~~ (Added padding since `0.0.5`)
* ~~Hexagonal shaped grid (using cube/axial coordinates system)~~ (since `0.1.0`)
* ~~null-safety~~ (since `0.2.0`)
* Solve content spacing in hexagon widget
* Check performance - any ideas how?