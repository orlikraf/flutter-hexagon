import 'package:flutter/material.dart';
import 'package:hexagon/src/grid/coordinates.dart';

import '../hexagon_type.dart';
import '../hexagon_widget.dart';

class HexagonGrid extends StatelessWidget {
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
          children: children.call(_maxHexCount));
    }
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children.call(_maxHexCount));
  }

  Widget _crossAxis(
    int currentDepth,
    List<Widget> Function(int count) children,
  ) {
    if (hexType.isPointy) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children.call(_maxHexCount - currentDepth));
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children.call(_maxHexCount - currentDepth));
  }

  Widget _padding(int depth, Size size, Widget child) {
    double h = hexType.isPointy ? (size.width / 2) * depth : 0.0;
    double v = hexType.isFlat ? (size.height / 2) * depth : 0.0;
    print('padding: depth: $depth, h: $h, v: $v');
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // var edgeInsets = EdgeInsets.symmetric(
      //   vertical: _displaceColumns *
      //       (size.height / (8 * hexType.pointyFactor(false))),
      //   horizontal:
      //   _displaceRows * (size.width / (8 * hexType.flatFactor(false))),
      // );
      // var builder = buildHexagon?.call(Coordinates.zero);

      print('------------------');
      // print('template: $builder');
      print('depth: $depth');
      print('------------------');

      Size size = _hexSize(constraints);
      print('size: $size');

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

      if (depth == 0) {
        return Container(
          color: color,
          child: buildHex(Coordinates.zero),
        );
      }

      return Container(
        color: color,
        child: _mainAxis(
          (mainCount) {
            return List.generate(mainCount, (mainIndex) {
              int currentDepth = mainIndex - depth;
              print('currentDepth: $currentDepth');
              return _padding(
                currentDepth.abs(),
                size,
                _crossAxis(
                  currentDepth.abs(),
                  (crossCount) => List.generate(crossCount, (crossIndex) {
                    if (currentDepth <= 0)
                      crossIndex = -depth - currentDepth + crossIndex;
                    else
                      crossIndex = -depth + crossIndex;

                    final coordinates =
                        Coordinates.axial(crossIndex, currentDepth);
                    print('coordinates: $coordinates');

                    return buildHex.call(coordinates);
                  }),
                ),
              );
            });
          },
        ),
      );
    });
  }

  Size _hexSize(BoxConstraints constraints, {HexagonWidget template}) {
    // if (template != null &&
    //     (template.width != null || template.height != null)) {
    //   return Size(template.width, template.height);
    // }
    print('constraints: $constraints');
    double maxWidth = constraints.maxWidth;
    double maxHeight = constraints.maxHeight;
    if (maxWidth.isFinite && maxHeight.isFinite) {
      var ratio = maxWidth / maxHeight;
      print('ratio: $ratio');
      print('hex ratio: ${hexType.ratio}');

      if (ratio > hexType.ratio) {
        maxWidth = double.infinity;
      } else if (ratio < hexType.ratio) {
        maxHeight = double.infinity;
      }
    } else if (maxWidth.isInfinite && maxHeight.isInfinite) {
      maxWidth = width ?? maxWidth;
      maxHeight = height ?? maxHeight;
    }

    if (maxWidth.isFinite) {
      print('maxWidth isFinite');
      if (hexType.isFlat) {
        print('isFlat');
        //todo check
        var quarters = maxWidth / (1 + (0.75 * (2 * depth)));
        var size = Size(quarters, quarters * hexType.ratio);
        return size * hexType.flatFactor(false);
      }
      //is Pointy
      print('isPointy');
      var width = maxWidth / (depth == 0 ? 1 : (_maxHexCount));
      print('maxW: $maxWidth');
      print('width: $width');

      return Size(width, width * hexType.ratio);
    } else if (maxHeight.isFinite) {
      print('maxHeight isFinite');
      if (hexType.isPointy) {
        var quarters =
            maxHeight / (depth == 0 ? 1.0 : (1 + (0.75 * (2 * depth))));
        var size = Size(quarters / hexType.ratio, quarters) *
            hexType.pointyFactor(false);

        // if (size.width * depth > maxWidth) {
        //   return size * (maxWidth / size.width);
        // }
        return size;
      }
      //is Flat
      var height = maxHeight / (depth == 0 ? 1.0 : (_maxHexCount));
      return Size(height / hexType.ratio, height);
    } else {
      throw Exception(
          'Error: Infinite constraints in both grid dimensions and no size in hexagon template!');
    }
  }
}
