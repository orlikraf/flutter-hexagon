// TODO(phase-2): rename to lowerCamelCase with deprecated aliases.
// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

import '../hexagon_type.dart';
import '../hexagon_widget.dart';

enum GridType { EVEN, ODD }

extension _GridTypeExtension on GridType {
  bool displace(int mainIndex, int crossIndex) {
    if (crossIndex == 0) {
      return displaceFront(mainIndex);
    }
    return displaceBack(mainIndex);
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
  const HexagonOffsetGrid.oddFlat({
    super.key,
    required this.columns,
    required this.rows,
    this.color,
    this.padding,
    this.buildTile,
    this.buildChild,
    this.hexagonBuilder,
  }) : assert(columns > 0),
       assert(rows > 0),
       hexType = HexagonType.FLAT,
       gridType = GridType.ODD;

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
  const HexagonOffsetGrid.evenFlat({
    super.key,
    required this.columns,
    required this.rows,
    this.color,
    this.padding,
    this.buildTile,
    this.buildChild,
    this.hexagonBuilder,
  }) : assert(columns > 0),
       assert(rows > 0),
       hexType = HexagonType.FLAT,
       gridType = GridType.EVEN;

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
  const HexagonOffsetGrid.oddPointy({
    super.key,
    required this.columns,
    required this.rows,
    this.color,
    this.padding,
    this.buildTile,
    this.buildChild,
    this.hexagonBuilder,
  }) : assert(columns > 0),
       assert(rows > 0),
       hexType = HexagonType.POINTY,
       gridType = GridType.ODD;

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
  const HexagonOffsetGrid.evenPointy({
    super.key,
    required this.columns,
    required this.rows,
    this.color,
    this.padding,
    this.buildTile,
    this.buildChild,
    this.hexagonBuilder,
  }) : assert(columns > 0),
       assert(rows > 0),
       hexType = HexagonType.POINTY,
       gridType = GridType.EVEN;

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

  /// Tolerance for rounding errors when checking whether the grid fits.
  static const double _epsilon = 1e-9;

  /// Rows of a flat grid, in tile heights: displaced columns add half a
  /// tile when there is more than one column.
  double get _rowSpan => rows + (columns > 1 ? 0.5 : 0);

  /// Columns of a pointy grid, in tile widths: displaced rows add half a
  /// tile when there is more than one row.
  double get _columnSpan => columns + (rows > 1 ? 0.5 : 0);

  /// The size of each tile, chosen so the whole grid fits the available
  /// space in both dimensions.
  Size _hexSize(BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth - (padding?.horizontal ?? 0);
    final maxHeight = constraints.maxHeight - (padding?.vertical ?? 0);

    if (maxWidth.isFinite) {
      final sizeFromWidth = _hexSizeWidthConstrained(maxWidth);
      if (!maxHeight.isFinite ||
          _gridHeight(sizeFromWidth) <= maxHeight + _epsilon) {
        return sizeFromWidth;
      }
    }
    if (maxHeight.isFinite) {
      return _hexSizeHeightConstrained(maxHeight);
    }
    throw FlutterError(
      'HexagonOffsetGrid has unbounded width and height.\n'
      'Place it in a parent that constrains at least one dimension.',
    );
  }

  /// Height of the grid, including its edge insets, for tiles of [size].
  double _gridHeight(Size size) => hexType.isFlat
      ? size.height * _rowSpan
      : size.height * (rows + 1 / 3);

  Size _hexSizeWidthConstrained(double maxWidth) {
    if (hexType.isFlat) {
      var quarters = maxWidth / (1 + (0.75 * (columns - 1)));
      var size = Size(quarters, quarters * hexType.ratio);
      return size * hexType.flatFactor(false);
    }
    final width = maxWidth / _columnSpan;
    return Size(width, width * hexType.ratio);
  }

  Size _hexSizeHeightConstrained(double maxHeight) {
    if (hexType.isPointy) {
      var quarters = maxHeight / (1 + (0.75 * (rows - 1)));
      var size = Size(quarters / hexType.ratio, quarters);
      return size * hexType.pointyFactor(false);
    }
    final height = maxHeight / _rowSpan;
    return Size(height / hexType.ratio, height);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      hexagonBuilder?.key == null,
      'HexagonOffsetGrid.hexagonBuilder is a template shared by every tile, '
      'so its key would be duplicated. Give tiles their own keys with '
      'buildTile.',
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        var size = _hexSize(constraints);
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
                    return SizedBox(
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

                  HexagonWidgetBuilder builder =
                      buildTile?.call(col, row) ??
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
