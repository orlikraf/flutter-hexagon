import 'dart:math' show min;

import 'package:flutter/material.dart';

import '../hexagon_type.dart';
import '../hexagon_widget.dart';
import 'coordinates.dart';

class HexagonGrid extends StatelessWidget {
  ///Hexagon shaped grid of hexagons.
  ///
  /// [hexType] - Required. Defines hexagon shape used for this grid.
  ///
  /// [depth] - Controls how many hexagons from the center there are form grid edge. Default is 0. Must be 0 or positite int.
  ///
  /// [width] - Optional with of the grid.
  ///
  /// [height] - Optional height of the grid.
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
  const HexagonGrid({
    super.key,
    required this.hexType,
    this.depth = 0,
    this.width,
    this.height,
    this.color,
    this.padding,
    this.buildTile,
    this.buildChild,
    this.hexagonBuilder,
  }) : assert(depth >= 0);

  ///Hexagon shaped grid of pointy hexagons.
  ///
  /// [depth] - Controls how many hexagons from the center there are form grid edge. Default is 0. Must be 0 or positite int.
  ///
  /// [width] - Optional with of the grid.
  ///
  /// [height] - Optional height of the grid.
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
  const HexagonGrid.pointy({
    super.key,
    this.width,
    this.height,
    this.depth = 0,
    this.color,
    this.padding,
    this.buildTile,
    this.buildChild,
    this.hexagonBuilder,
  }) : assert(depth >= 0),
       hexType = HexagonType.POINTY;

  ///Hexagon shaped grid of flat hexagons.
  ///
  /// [depth] - Controls how many hexagons from the center there are form grid edge. Default is 0. Must be 0 or positite int.
  ///
  /// [width] - Optional with of the grid.
  ///
  /// [height] - Optional height of the grid.
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
  const HexagonGrid.flat({
    super.key,
    this.width,
    this.height,
    this.depth = 0,
    this.color,
    this.padding,
    this.buildTile,
    this.buildChild,
    this.hexagonBuilder,
  }) : assert(depth >= 0),
       hexType = HexagonType.FLAT;

  final HexagonType hexType;
  final double? width;
  final double? height;
  final int depth;
  final Color? color;
  final EdgeInsets? padding;
  final HexagonWidgetBuilder? hexagonBuilder;
  final Widget Function(Coordinates coordinates)? buildChild;
  final HexagonWidgetBuilder? Function(Coordinates coordinates)? buildTile;

  int get _maxHexCount => 1 + (depth * 2);

  Widget _mainAxis(List<Widget> Function(int count) children) {
    if (hexType.isPointy) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children.call(_maxHexCount),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children.call(_maxHexCount),
    );
  }

  Widget _crossAxis(
    int currentDepth,
    List<Widget> Function(int count) children,
  ) {
    if (hexType.isPointy) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children.call(_maxHexCount - currentDepth),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children.call(_maxHexCount - currentDepth),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(
      hexagonBuilder?.key == null,
      'HexagonGrid.hexagonBuilder is a template shared by every tile, so its '
      'key would be duplicated. Give tiles their own keys with buildTile.',
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        Size size = _hexSize(constraints);

        HexagonWidget buildHex(Coordinates coordinates) {
          HexagonWidgetBuilder builder =
              buildTile?.call(coordinates) ??
              hexagonBuilder ??
              HexagonWidgetBuilder();

          return builder.build(
            type: hexType,
            inBounds: false,
            width: size.width,
            height: size.height,
            child: buildChild?.call(coordinates),
            replaceChild: buildChild != null,
          );
        }

        var edgeInsets = EdgeInsets.symmetric(
          vertical:
              ((hexType.isPointy ? 1 : 0) *
              (size.height / (8 * hexType.pointyFactor(false)))),
          horizontal:
              ((hexType.isFlat ? 1 : 0) *
              (size.width / (8 * hexType.flatFactor(false)))),
        );

        edgeInsets += padding ?? EdgeInsets.zero;

        if (depth == 0) {
          return Container(
            color: color,
            width: width,
            height: height,
            padding: edgeInsets,
            child: buildHex(Coordinates.zero),
          );
        }

        return Container(
          color: color,
          width: width,
          height: height,
          padding: edgeInsets,
          child: _mainAxis((mainCount) {
            return List.generate(mainCount, (mainIndex) {
              int currentDepth = mainIndex - depth;
              return _crossAxis(currentDepth.abs(), (crossCount) {
                return List.generate(crossCount, (crossIndex) {
                  if (currentDepth <= 0) {
                    crossIndex = -depth - currentDepth + crossIndex;
                  } else {
                    crossIndex = -depth + crossIndex;
                  }

                  final coordinates = Coordinates.axial(
                    hexType.isPointy ? crossIndex : currentDepth,
                    hexType.isPointy ? currentDepth : crossIndex,
                  );
                  return buildHex.call(coordinates);
                });
              });
            });
          }),
        );
      },
    );
  }

  /// Tolerance for rounding errors when checking whether the grid fits.
  static const double _epsilon = 1e-9;

  /// The size of each tile, chosen so the whole grid fits the available
  /// space in both dimensions.
  Size _hexSize(BoxConstraints constraints) {
    // An explicit width or height replaces the incoming constraint, but can
    // never exceed it.
    final maxWidth =
        (width == null
            ? constraints.maxWidth
            : min(width!, constraints.maxWidth)) -
        (padding?.horizontal ?? 0);
    final maxHeight =
        (height == null
            ? constraints.maxHeight
            : min(height!, constraints.maxHeight)) -
        (padding?.vertical ?? 0);

    if (maxWidth.isFinite) {
      final sizeFromWidth = _fromWidth(maxWidth);
      if (!maxHeight.isFinite ||
          _gridHeight(sizeFromWidth) <= maxHeight + _epsilon) {
        return sizeFromWidth;
      }
    }
    if (maxHeight.isFinite) {
      return _fromHeight(maxHeight);
    }
    throw FlutterError(
      'HexagonGrid has unbounded width and height.\n'
      'Give it a width or a height, or place it in a parent that constrains '
      'at least one dimension.',
    );
  }

  /// Height of the grid, including its edge insets, for tiles of [size].
  double _gridHeight(Size size) => hexType.isFlat
      ? size.height * _maxHexCount
      : size.height * (_maxHexCount + 1 / 3);

  Size _fromWidth(double maxWidth) {
    if (hexType.isFlat) {
      var quarters =
          maxWidth / (depth == 0 ? 1.0 : (1.0 + (0.75 * (2 * depth))));
      return Size(quarters, quarters * hexType.ratio) *
          hexType.flatFactor(false);
    }
    //is Pointy
    var width = maxWidth / (depth == 0 ? 1 : (_maxHexCount));
    return Size(
      width,
      (width / hexType.ratio) /
          hexType.flatFactor(false) *
          hexType.pointyFactor(false),
    );
  }

  Size _fromHeight(double maxHeight) {
    if (hexType.isPointy) {
      var quarters =
          maxHeight / (depth == 0 ? 1.0 : (1.0 + (0.75 * (2 * depth))));
      return Size(quarters / hexType.ratio, quarters) *
          hexType.pointyFactor(false);
    }
    //is Flat
    var height = maxHeight / (depth == 0 ? 1.0 : (_maxHexCount));
    return Size(
      (height * hexType.ratio) *
          hexType.flatFactor(false) /
          hexType.pointyFactor(false),
      height,
    );
  }
}
