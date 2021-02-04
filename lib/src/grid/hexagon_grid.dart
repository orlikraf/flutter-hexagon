import 'package:flutter/material.dart';

import '../hexagon_type.dart';
import '../hexagon_widget.dart';
import 'coordinates.dart';

class HexagonGrid extends StatelessWidget {
  HexagonGrid({
    this.width,
    this.height,
    this.depth = 0,
    @required this.hexType,
    this.color,
    this.buildTile,
    this.buildChild,
    this.hexagonBuilder,
  })  : assert(depth >= 0),
        assert(hexType != null);

  HexagonGrid.pointy({
    this.width,
    this.height,
    this.depth = 0,
    this.color,
    this.buildTile,
    this.buildChild,
    this.hexagonBuilder,
  })  : assert(depth >= 0),
        this.hexType = HexagonType.POINTY;

  HexagonGrid.flat({
    this.width,
    this.height,
    this.depth = 0,
    this.color,
    this.buildTile,
    this.buildChild,
    this.hexagonBuilder,
  })  : assert(depth >= 0),
        this.hexType = HexagonType.FLAT;

  final HexagonType hexType;

  final double width;
  final double height;
  final int depth;
  final Color color;
  final HexagonWidgetBuilder hexagonBuilder;
  final Widget Function(Coordinates coordinates) buildChild;
  final HexagonWidgetBuilder Function(Coordinates coordinates) buildTile;

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
      int currentDepth, List<Widget> Function(int count) children) {
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
    return LayoutBuilder(
      builder: (context, constraints) {
        Size size = _hexSize(constraints);

        HexagonWidget buildHex(Coordinates coordinates) {
          HexagonWidgetBuilder builder = buildTile?.call(coordinates) ??
              hexagonBuilder ??
              HexagonWidgetBuilder();

          return builder.build(
            hexType,
            inBounds: false,
            width: size.width,
            height: size.height,
            child: buildChild?.call(coordinates),
            replaceChild: buildChild != null,
          );
        }

        var edgeInsets = EdgeInsets.symmetric(
          vertical: ((hexType.isPointy ? 1 : 0) *
              (size.height / (8 * hexType.pointyFactor(false)))),
          horizontal: ((hexType.isFlat ? 1 : 0) *
              (size.width / (8 * hexType.flatFactor(false)))),
        );

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
          child: _mainAxis(
            (mainCount) {
              return List.generate(
                mainCount,
                (mainIndex) {
                  int currentDepth = mainIndex - depth;
                  return _crossAxis(
                    currentDepth.abs(),
                    (crossCount) {
                      return List.generate(crossCount, (crossIndex) {
                        if (currentDepth <= 0)
                          crossIndex = -depth - currentDepth + crossIndex;
                        else
                          crossIndex = -depth + crossIndex;

                        final coordinates = Coordinates.axial(
                          crossIndex,
                          currentDepth,
                        );
                        return buildHex.call(coordinates);
                      });
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Size _hexSize(BoxConstraints constraints) {
    double maxWidth = constraints.maxWidth;
    double maxHeight = constraints.maxHeight;

    if (width != null || height != null) {
      maxWidth = width ?? double.infinity;
      maxHeight = height ?? double.infinity;
    }
    if (maxWidth.isFinite && maxHeight.isFinite) {
      var sizeFromHeight = _fromHeight(maxHeight);
      var sizeFromWidth = _fromWidth(maxWidth);

      if (hexType.isFlat) {
        var hh = (maxHeight - (sizeFromHeight.height * _maxHexCount));
        var hw = (maxHeight - (sizeFromWidth.height * _maxHexCount));
        if (hh == 0 && hw < 0) {
          return sizeFromHeight;
        } else
          return sizeFromWidth;
      } else {
        var wh = (maxWidth - (sizeFromHeight.width * _maxHexCount));
        var ww = (maxWidth - (sizeFromWidth.width * _maxHexCount));
        if (ww == 0 && wh < 0) {
          return sizeFromWidth;
        } else
          return sizeFromHeight;
      }
    } else if (maxWidth.isFinite) {
      return _fromWidth(maxWidth);
    } else if (maxHeight.isFinite) {
      return _fromHeight(maxHeight);
    } else {
      throw Exception('Error: Infinite constraints in both grid dimensions!');
    }
  }

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
