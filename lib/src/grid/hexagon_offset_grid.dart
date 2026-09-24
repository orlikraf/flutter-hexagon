import 'package:flutter/widgets.dart';

import '../hexagon_layout.dart';
import '../hexagon_type.dart';
import '../hexagon_widget.dart';

/// Which columns (flat tiles) or rows (pointy tiles) of a
/// [HexagonOffsetGrid] are shifted by half a tile, counting from 0.
///
/// These match the "even-q", "odd-q", "even-r" and "odd-r" layouts on
/// [Red Blob Games](https://www.redblobgames.com/grids/hexagons/#coordinates-offset).
enum GridType {
  /// Even columns are shifted down, or even rows shifted right.
  even,

  /// Odd columns are shifted down, or odd rows shifted right.
  odd;

  /// Deprecated alias of [even].
  @Deprecated('Use GridType.even. Will be removed in 1.0.0.')
  // ignore: constant_identifier_names
  static const EVEN = even;

  /// Deprecated alias of [odd].
  @Deprecated('Use GridType.odd. Will be removed in 1.0.0.')
  // ignore: constant_identifier_names
  static const ODD = odd;
}

extension _GridTypeExtension on GridType {
  bool displace(int mainIndex, int crossIndex) {
    if (crossIndex == 0) {
      return displaceFront(mainIndex);
    }
    return displaceBack(mainIndex);
  }

  bool displaceFront(int index) {
    return (this == GridType.odd && index.isOdd) ||
        (this == GridType.even && index.isEven);
  }

  bool displaceBack(int index) {
    return (this == GridType.odd && index.isEven) ||
        (this == GridType.even && index.isOdd);
  }
}

/// A rectangular grid of hexagons, addressed by column and row.
///
/// Every other column (flat tiles) or row (pointy tiles) is shifted by half
/// a tile; the constructor name says which ([GridType]). The grid fits
/// [columns] × [rows] tiles into the available space, which must be
/// bounded in at least one dimension.
///
/// ```dart
/// HexagonOffsetGrid.oddPointy(
///   columns: 5,
///   rows: 10,
///   buildTile: (col, row) => HexagonWidgetBuilder(
///     color: row.isEven ? Colors.yellow : Colors.orange,
///   ),
///   buildChild: (col, row) => Text('$col, $row'),
/// )
/// ```
class HexagonOffsetGrid extends StatelessWidget {
  /// Creates a grid of flat hexagons with odd columns shifted down.
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
       hexType = HexagonType.flat,
       gridType = GridType.odd;

  /// Creates a grid of flat hexagons with even columns shifted down.
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
       hexType = HexagonType.flat,
       gridType = GridType.even;

  /// Creates a grid of pointy hexagons with odd rows shifted right.
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
       hexType = HexagonType.pointy,
       gridType = GridType.odd;

  /// Creates a grid of pointy hexagons with even rows shifted right.
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
       hexType = HexagonType.pointy,
       gridType = GridType.even;

  /// The orientation of the tiles.
  final HexagonType hexType;

  /// Which columns or rows are shifted by half a tile.
  final GridType gridType;

  /// The number of columns. Must be positive.
  final int columns;

  /// The number of rows. Must be positive.
  final int rows;

  /// The background color of the grid.
  final Color? color;

  /// Space around the tiles, inside the grid.
  final EdgeInsets? padding;

  /// The template for every tile, unless [buildTile] returns one.
  ///
  /// It must not have a key, since every tile shares it.
  final HexagonWidgetBuilder? hexagonBuilder;

  /// Returns the child of the tile at the given column and row. Overrides
  /// the child of [hexagonBuilder] and [buildTile].
  final Widget Function(int col, int row)? buildChild;

  /// Returns the template for the tile at the given column and row, or null
  /// to use [hexagonBuilder].
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
  double _gridHeight(Size size) =>
      hexType.isFlat ? size.height * _rowSpan : size.height * (rows + 1 / 3);

  Size _hexSizeWidthConstrained(double maxWidth) {
    if (hexType.isFlat) {
      var quarters = maxWidth / (1 + (0.75 * (columns - 1)));
      var size = Size(quarters, quarters * hexType.ratio);
      return size * hexType.widthFactor(false);
    }
    final width = maxWidth / _columnSpan;
    return Size(width, width * hexType.ratio);
  }

  Size _hexSizeHeightConstrained(double maxHeight) {
    if (hexType.isPointy) {
      var quarters = maxHeight / (1 + (0.75 * (rows - 1)));
      var size = Size(quarters / hexType.ratio, quarters);
      return size * hexType.heightFactor(false);
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
              ? (size.height / (8 * hexType.heightFactor(false)))
              : 0,
          horizontal: hexType.isFlat
              ? (size.width / (8 * hexType.widthFactor(false)))
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
