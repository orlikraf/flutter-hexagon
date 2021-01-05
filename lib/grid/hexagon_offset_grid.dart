import 'package:flutter/material.dart';
import 'package:hexagon/hexagon_type.dart';
import 'package:hexagon/hexagon_widget.dart';

enum GridType { EVEN, ODD }

extension _GridTypeExtension on GridType {
  bool displace(int mainIndex, int crossIndex) {
    if (crossIndex == 0) {
      return this.displaceFront(mainIndex);
    }
    return this.displaceBack(mainIndex);
  }

  bool displaceFront(int index) {
    return (this == GridType.ODD && index.isOdd) ||
        (this == GridType.EVEN && index.isEven);
  }

  bool displaceBack(int index) {
    return (this == GridType.ODD && index.isEven) ||
        (this == GridType.EVEN && index.isOdd);
  }
}

class HexagonOffsetGrid extends StatelessWidget {
  final HexagonType hexType;
  final GridType gridType;

  final int columns;
  final int rows;
  final Color color;
  final EdgeInsetsGeometry hexagonPadding;
  final Widget Function(int col, int row) buildChild;
  final HexagonWidget Function(int col, int row) buildHexagon;

  ///Grid of flat hexagons with odd columns starting with tile and even with a space.
  ///
  /// [columns] - Required positive integer. Count of columns in grid.
  ///
  /// [rows] - Required positive integer. Count of rows in grid.
  ///
  /// [color] - Background color of this grid.
  ///
  /// [hexagonPadding] - Used for padding around all Hexagon tiles.
  ///
  /// [buildHexagon] - Provide a HexagonWidget.template() to be used for given tile (col,row). Returning null value will be represented as translucent tile.
  ///
  /// [buildChild] - Provide a Widget to be used in a HexagonWidget for given tile (col,row). Any returned value will override child provided in [buildHexagon] function.
  HexagonOffsetGrid.oddFlat({
    @required this.columns,
    @required this.rows,
    this.color,
    this.buildChild,
    this.buildHexagon,
    this.hexagonPadding: const EdgeInsets.all(0.0),
  })  : assert(columns > 0),
        assert(rows > 0),
        this.hexType = HexagonType.FLAT,
        this.gridType = GridType.ODD;

  ///Grid of flat hexagons with even columns starting with tile and odd with a space.
  ///
  /// [columns] - Required positive integer. Count of columns in grid.
  ///
  /// [rows] - Required positive integer. Count of rows in grid.
  ///
  /// [color] - Background color of this grid.
  ///
  /// [hexagonPadding] - Used for padding around all Hexagon tiles.
  ///
  /// [buildHexagon] - Provide a HexagonWidget.template() to be used for given tile (col,row). Returning null value will be represented as translucent tile.
  ///
  /// [buildChild] - Provide a Widget to be used in a HexagonWidget for given tile (col,row). Any returned value will override child provided in [buildHexagon] function.
  HexagonOffsetGrid.evenFlat({
    @required this.columns,
    @required this.rows,
    this.color,
    this.buildChild,
    this.buildHexagon,
    this.hexagonPadding: const EdgeInsets.all(0.0),
  })  : this.hexType = HexagonType.FLAT,
        this.gridType = GridType.EVEN;

  ///Grid of pointy hexagons with odd rows starting with tile and even with a space.
  ///
  /// [columns] - Required positive integer. Count of columns in grid.
  ///
  /// [rows] - Required positive integer. Count of rows in grid.
  ///
  /// [color] - Background color of this grid.
  ///
  /// [hexagonPadding] - Used for padding around all Hexagon tiles.
  ///
  /// [buildHexagon] - Provide a HexagonWidget.template() to be used for given tile (col,row). Returning null value will be represented as translucent tile.
  ///
  /// [buildChild] - Provide a Widget to be used in a HexagonWidget for given tile (col,row). Any returned value will override child provided in [buildHexagon] function.
  HexagonOffsetGrid.oddPointy({
    @required this.columns,
    @required this.rows,
    this.color,
    this.buildChild,
    this.buildHexagon,
    this.hexagonPadding: const EdgeInsets.all(0.0),
  })  : this.hexType = HexagonType.POINTY,
        this.gridType = GridType.ODD;

  ///Grid of pointy hexagons with even rows starting with tile and odd with a space.
  ///
  /// [columns] - Required positive integer. Count of columns in grid.
  ///
  /// [rows] - Required positive integer. Count of rows in grid.
  ///
  /// [color] - Background color of this grid.
  ///
  /// [hexagonPadding] - Used for padding around all Hexagon tiles.
  ///
  /// [buildHexagon] - Provide a HexagonWidget.template() to be used for given tile (col,row). Returning null value will be represented as translucent tile.
  ///
  /// [buildChild] - Provide a Widget to be used in a HexagonWidget for given tile (col,row). Any returned value will override child provided in [buildHexagon] function.
  HexagonOffsetGrid.evenPointy({
    @required this.columns,
    @required this.rows,
    this.color,
    this.buildChild,
    this.buildHexagon,
    this.hexagonPadding: const EdgeInsets.all(0.0),
  })  : this.hexType = HexagonType.POINTY,
        this.gridType = GridType.EVEN;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var size = _hexSize(constraints.maxWidth, constraints.maxHeight);
        var edgeInsets = EdgeInsets.symmetric(
          vertical: _displaceColumns *
              (size.height / (8 * hexType.pointyFactor(false))),
          horizontal:
              _displaceRows * (size.width / (8 * hexType.flatFactor(false))),
        );
        return Container(
          color: color,
          padding: edgeInsets,
          child: _mainAxis(
            (mainCount) => List.generate(
              mainCount,
              (mainIndex) => _crossAxis(
                (crossCount) => List.generate(crossCount, (crossIndex) {
                  if ((crossIndex == 0 || crossIndex >= crossCount - 1) &&
                      gridType.displace(mainIndex, crossIndex)) {
                    return Container(
                      width: hexType.isPointy ? size.width / 2 : null,
                      height: hexType.isFlat ? size.height / 2 : null,
                    );
                  }
                  final col = (hexType.isPointy
                      ? (crossIndex -
                          (gridType.displaceFront(mainIndex) ? 1 : 0))
                      : mainIndex);
                  final row = hexType.isPointy
                      ? mainIndex
                      : (crossIndex -
                          (gridType.displaceFront(mainIndex) ? 1 : 0));

                  var hexagonTemplate = buildHexagon?.call(col, row);

                  if (buildHexagon != null && hexagonTemplate == null) {
                    hexagonTemplate =
                        HexagonWidget.template(color: Colors.transparent);
                  } else if (hexagonTemplate?.isTemplate != true)
                    hexagonTemplate = HexagonWidget.template();

                  return Padding(
                    padding: hexagonPadding,
                    child: hexagonTemplate?.copyWith(
                      type: hexType,
                      inBounds: false,
                      width: hexType.isPointy ? size.width : null,
                      height: hexType.isFlat ? size.height : null,
                      child: buildChild != null
                          ? buildChild.call(col, row)
                          : hexagonTemplate.child,
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _mainAxis(List<Widget> Function(int count) children) {
    if (hexType.isPointy) {
      return Column(children: children.call(rows + _displaceRows));
    }
    return Row(children: children.call(columns + _displaceColumns));
  }

  Widget _crossAxis(List<Widget> Function(int count) children) {
    if (hexType.isPointy) {
      return Row(children: children.call(columns + _displaceColumns));
    }
    return Column(children: children.call(rows + _displaceRows));
  }

  int get _displaceColumns => hexType.isPointy ? 1 : 0;

  int get _displaceRows => hexType.isFlat ? 1 : 0;

  Size _hexSize(double maxWidth, double maxHeight) {
    if (maxWidth.isFinite) {
      if (hexType.isFlat) {
        var quarters = (maxWidth - columns * hexagonPadding.horizontal) /
            (1 + (0.75 * (columns - 1)));
        var size = Size(quarters, quarters * hexType.ratio);
        return size * hexType.flatFactor(false);
      }
      var half = (maxWidth - columns * hexagonPadding.horizontal) /
          (columns * 2 + _displaceColumns);
      return Size(half * 2, half * 2 * hexType.ratio);
    } else if (maxHeight.isFinite) {
      if (hexType.isPointy) {
        var quarters = (maxHeight - rows * hexagonPadding.vertical) /
            (1 + (0.75 * (rows - 1)));
        var size = Size(quarters / hexType.ratio, quarters);
        return size * hexType.pointyFactor(false);
      }
      var half = (maxHeight - rows * hexagonPadding.vertical) /
          (rows * 2 + _displaceRows);
      return Size(half * 2 / hexType.ratio, half * 2);
    } else {
      throw Exception('Error: Infinite constraints in both dimensions!');
    }
  }
}
