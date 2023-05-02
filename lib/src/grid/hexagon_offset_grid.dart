import 'package:flutter/material.dart';

import '../hexagon_type.dart';
import '../hexagon_widget.dart';

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
  ///Grid of flat hexagons with odd columns starting with tile and even with a space.
  ///
  /// [columns] - Required positive integer. Count of columns in grid.
  ///
  /// [rows] - Required positive integer. Count of rows in grid.
  ///
  /// [color] - Background color of this grid.
  ///
  /// [padding] - Grid padding.
  ///
  /// [hexagonBuilder] - Used as template for tiles. Will be overridden by [buildTile].
  ///
  /// [buildTile] - Provide a HexagonWidgetBuilder that will be used to create given tile (at col,row). Return null to use default [hexagonBuilder].
  ///
  /// [buildChild] - Provide a Widget to be used in a HexagonWidget for given tile (col,row). Any returned value will override child provided in [buildTile] or hexagonBuilder.
  HexagonOffsetGrid.oddFlat({
    required this.columns,
    required this.rows,
    this.color,
    this.padding,
    this.buildTile,
    this.buildChild,
    this.hexagonBuilder,
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
  /// [padding] - Grid padding.
  ///
  /// [hexagonBuilder] - Used as template for tiles. Will be overridden by [buildTile].
  ///
  /// [buildTile] - Provide a HexagonWidgetBuilder that will be used to create given tile (at col,row). Return null to use default [hexagonBuilder].
  ///
  /// [buildChild] - Provide a Widget to be used in a HexagonWidget for given tile (col,row). Any returned value will override child provided in [buildTile] or hexagonBuilder.
  HexagonOffsetGrid.evenFlat({
    required this.columns,
    required this.rows,
    this.color,
    this.padding,
    this.buildTile,
    this.buildChild,
    this.hexagonBuilder,
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
  /// [padding] - Grid padding.
  ///
  /// [hexagonBuilder] - Used as template for tiles. Will be overridden by [buildTile].
  ///
  /// [buildTile] - Provide a HexagonWidgetBuilder that will be used to create given tile (at col,row). Return null to use default [hexagonBuilder].
  ///
  /// [buildChild] - Provide a Widget to be used in a HexagonWidget for given tile (col,row). Any returned value will override child provided in [buildTile] or hexagonBuilder.
  HexagonOffsetGrid.oddPointy({
    required this.columns,
    required this.rows,
    this.color,
    this.padding,
    this.buildTile,
    this.buildChild,
    this.hexagonBuilder,
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
  /// [padding] - Grid padding.
  ///
  /// [hexagonBuilder] - Used as template for tiles. Will be overridden by [buildTile].
  ///
  /// [buildTile] - Provide a HexagonWidgetBuilder that will be used to create given tile (at col,row). Return null to use default [hexagonBuilder].
  ///
  /// [buildChild] - Provide a Widget to be used in a HexagonWidget for given tile (col,row). Any returned value will override child provided in [buildTile] or hexagonBuilder.
  HexagonOffsetGrid.evenPointy({
    required this.columns,
    required this.rows,
    this.color,
    this.padding,
    this.buildTile,
    this.buildChild,
    this.hexagonBuilder,
  })  : this.hexType = HexagonType.POINTY,
        this.gridType = GridType.EVEN;

  final HexagonType hexType;
  final GridType gridType;
  final int columns;
  final int rows;
  final Color? color;
  final EdgeInsets? padding;
  final HexagonWidgetBuilder? hexagonBuilder;
  final Widget Function(int col, int row)? buildChild;
  final HexagonWidgetBuilder? Function(int col, int row)? buildTile;

  int get _displaceColumns => hexType.isPointy ? 1 : 0;

  int get _displaceRows => hexType.isFlat ? 1 : 0;

  Widget _mainAxis(List<Widget> Function(int count) children) {
    return hexType.isPointy
        ? Column(children: children.call(rows + _displaceRows))
        : Row(children: children.call(columns + _displaceColumns));
  }

  Widget _crossAxis(List<Widget> Function(int count) children) {
    return hexType.isPointy
        ? Row(children: children.call(columns + _displaceColumns))
        : Column(children: children.call(rows + _displaceRows));
  }

  Size _hexSize(double maxWidth, double maxHeight) {
    if (maxWidth.isFinite && maxHeight.isFinite) {
      maxWidth -= (padding?.horizontal ?? 0);
      maxHeight -= (padding?.vertical ?? 0);
      //determine aspect ratio of grid, and of container
      var gridWidth;
      var gridHeight;
      if (hexType.isFlat) {
        gridWidth = 1 + (0.75 * (columns - 1));
        gridHeight = rows + (_displaceRows / 2);
      } else {
        gridWidth = columns + (_displaceColumns / 2);
        gridHeight = 1 + (0.75 * (rows - 1));
      }
      var gridAspectRatio = gridWidth / gridHeight;
      var constraintAspectRatio = maxWidth / maxHeight;
      if (constraintAspectRatio <= gridAspectRatio) {
        //constrained by width
        return _hexSizeWidthConstrained(maxWidth);
      } else {
        return _hexSizeHeightConstrained(maxHeight);
      }
    } else if (maxWidth.isFinite) {
      maxWidth -= (padding?.horizontal ?? 0);
      return _hexSizeWidthConstrained(maxWidth);
    } else if (maxHeight.isFinite) {
      maxHeight -= (padding?.vertical ?? 0);
      return _hexSizeHeightConstrained(maxHeight);
    } else {
      throw Exception('Error: Infinite constraints in both dimensions!');
    }
  }

  Size _hexSizeWidthConstrained(double maxWidth) {
    if (hexType.isFlat) {
      var quarters = maxWidth / (1 + (0.75 * (columns - 1)));
      var size = Size(quarters, quarters * hexType.ratio);
      return size * hexType.flatFactor(false);
    }
    var half = maxWidth / (columns * 2 + _displaceColumns);
    return Size(half * 2, half * 2 * hexType.ratio);
  }

  Size _hexSizeHeightConstrained(double maxHeight) {
    if (hexType.isPointy) {
      var quarters = maxHeight / (1 + (0.75 * (rows - 1)));
      var size = Size(quarters / hexType.ratio, quarters);
      return size * hexType.pointyFactor(false);
    }
    var half = maxHeight / (rows * 2 + _displaceRows);
    return Size(half * 2 / hexType.ratio, half * 2);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var size = _hexSize(constraints.maxWidth, constraints.maxHeight);
        EdgeInsets edgeInsets = EdgeInsets.symmetric(
          vertical: hexType.isPointy
              ? (size.height / (8 * hexType.pointyFactor(false)))
              : 0,
          horizontal: hexType.isFlat
              ? (size.width / (8 * hexType.flatFactor(false)))
              : 0,
        );
        edgeInsets += padding ?? EdgeInsets.zero;
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
                    //return container with half the size of the hexagon for displaced row/column
                    return Container(
                      width: (hexType.isPointy && rows > 1)
                          ? size.width / 2
                          : null,
                      height: (hexType.isFlat && columns > 1)
                          ? size.height / 2
                          : null,
                    );
                  }
                  //calculate human readable column & row
                  final col = (hexType.isPointy
                      ? (crossIndex -
                          (gridType.displaceFront(mainIndex) ? 1 : 0))
                      : mainIndex);
                  final row = hexType.isPointy
                      ? mainIndex
                      : (crossIndex -
                          (gridType.displaceFront(mainIndex) ? 1 : 0));

                  HexagonWidgetBuilder builder = buildTile?.call(col, row) ??
                      hexagonBuilder ??
                      HexagonWidgetBuilder();

                  //use template values
                  return builder.build(
                    type: hexType,
                    inBounds: false,
                    width: hexType.isPointy ? size.width : null,
                    height: hexType.isFlat ? size.height : null,
                    child: buildChild?.call(col, row),
                    replaceChild: buildChild != null,
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}
