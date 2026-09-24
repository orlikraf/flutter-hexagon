import 'dart:math' show min;

import 'package:flutter/widgets.dart';

import '../hexagon_layout.dart';
import '../hexagon_type.dart';
import '../hexagon_widget.dart';
import 'coordinates.dart';

/// A hexagon-shaped grid of hexagons, addressed by [Coordinates].
///
/// The grid has `1 + 3 * depth * (depth + 1)` tiles: one in the center and
/// [depth] rings around it. It fills the available space, or [width] and
/// [height] when given, while keeping its aspect ratio.
///
/// ```dart
/// HexagonGrid.pointy(
///   depth: 2,
///   buildTile: (coordinates) => HexagonWidgetBuilder(
///     color: coordinates == Coordinates.zero ? Colors.red : Colors.white,
///   ),
///   buildChild: (coordinates) => Text('${coordinates.q}, ${coordinates.r}'),
/// )
/// ```
class HexagonGrid extends StatelessWidget {
  /// Creates a grid of hexagons of the given [hexType].
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

  /// Creates a grid of pointy hexagons.
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
       hexType = HexagonType.pointy;

  /// Creates a grid of flat hexagons.
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
       hexType = HexagonType.flat;

  /// The orientation of the tiles.
  final HexagonType hexType;

  /// The width of the grid. When null, the grid fills the available width.
  final double? width;

  /// The height of the grid. When null, the grid fills the available
  /// height.
  final double? height;

  /// The number of rings of tiles around the center tile. Must not be
  /// negative; 0 gives a single tile.
  final int depth;

  /// The background color of the grid.
  final Color? color;

  /// Space around the tiles, inside the grid.
  final EdgeInsets? padding;

  /// The template for every tile, unless [buildTile] returns one.
  ///
  /// It must not have a key, since every tile shares it.
  final HexagonWidgetBuilder? hexagonBuilder;

  /// Returns the child of the tile at the given coordinates. Overrides the
  /// child of [hexagonBuilder] and [buildTile].
  final Widget Function(Coordinates coordinates)? buildChild;

  /// Returns the template for the tile at the given coordinates, or null to
  /// use [hexagonBuilder].
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
              (size.height / (8 * hexType.heightFactor(false)))),
          horizontal:
              ((hexType.isFlat ? 1 : 0) *
              (size.width / (8 * hexType.widthFactor(false)))),
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
          hexType.widthFactor(false);
    }
    //is Pointy
    var width = maxWidth / (depth == 0 ? 1 : (_maxHexCount));
    return Size(
      width,
      (width / hexType.ratio) /
          hexType.widthFactor(false) *
          hexType.heightFactor(false),
    );
  }

  Size _fromHeight(double maxHeight) {
    if (hexType.isPointy) {
      var quarters =
          maxHeight / (depth == 0 ? 1.0 : (1.0 + (0.75 * (2 * depth))));
      return Size(quarters / hexType.ratio, quarters) *
          hexType.heightFactor(false);
    }
    //is Flat
    var height = maxHeight / (depth == 0 ? 1.0 : (_maxHexCount));
    return Size(
      (height * hexType.ratio) *
          hexType.widthFactor(false) /
          hexType.heightFactor(false),
      height,
    );
  }
}
