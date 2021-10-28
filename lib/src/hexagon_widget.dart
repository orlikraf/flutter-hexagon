library hexagon;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'hexagon_clipper.dart';
import 'hexagon_painter.dart';
import 'hexagon_path_builder.dart';
import 'hexagon_type.dart';

class HexagonWidget extends StatelessWidget {
  /// Preferably provide one dimension ([width] or [height]) and the other will be calculated accordingly to hexagon aspect ratio
  ///
  /// [elevation] - Mustn't be negative. Default = 0
  ///
  /// [padding] - Mustn't be negative.
  ///
  /// [color] - Color used to fill hexagon. Use transparency with 0 elevation
  ///
  /// [cornerRadius] - Radius of hexagon corners. Values <= 0 have no effect.
  ///
  /// [inBounds] - Set to false if you want to overlap hexagon corners outside it's space.
  ///
  /// [child] - You content. Keep in mind that it will be clipped.
  ///
  /// [type] - A type of hexagon has to be either [HexagonType.FLAT] or [HexagonType.POINTY]
  const HexagonWidget({
    Key? key,
    this.width,
    this.height,
    this.color,
    this.child,
    this.padding,
    this.cornerRadius,
    this.elevation = 0,
    this.inBounds = true,
    required this.type,
  })  : assert(width != null || height != null),
        assert((elevation) >= 0),
        super(key: key);

  /// Preferably provide one dimension ([width] or [height]) and the other will be calculated accordingly to hexagon aspect ratio
  ///
  /// [elevation] - Mustn't be negative. Default = 0
  ///
  /// [padding] - Mustn't be negative.
  ///
  /// [color] - Color used to fill hexagon. Use transparency with 0 elevation
  ///
  /// [cornerRadius] - Border radius of hexagon corners. Values <= 0 have no effect.
  ///
  /// [inBounds] - Set to false if you want to overlap hexagon corners outside it's space.
  ///
  /// [child] - You content. Keep in mind that it will be clipped.
  HexagonWidget.flat({
    this.width,
    this.height,
    this.color,
    this.child,
    this.padding,
    this.elevation = 0,
    this.cornerRadius,
    this.inBounds = true,
  })  : assert(width != null || height != null),
        assert((elevation) >= 0),
        type = HexagonType.FLAT;

  /// Preferably provide one dimension ([width] or [height]) and the other will be calculated accordingly to hexagon aspect ratio
  ///
  /// [elevation] - Mustn't be negative. Default = 0
  ///
  /// [padding] - Mustn't be negative.
  ///
  /// [color] - Color used to fill hexagon. Use transparency with 0 elevation
  ///
  /// [cornerRadius] - Border radius of hexagon corners. Values <= 0 have no effect.
  ///
  /// [inBounds] - Set to false if you want to overlap hexagon corners outside it's space.
  ///
  /// [child] - You content. Keep in mind that it will be clipped.
  HexagonWidget.pointy({
    this.width,
    this.height,
    this.color,
    this.child,
    this.padding,
    this.elevation = 0,
    this.cornerRadius,
    this.inBounds = true,
  })  : assert(width != null || height != null),
        assert((elevation) >= 0),
        type = HexagonType.POINTY;

  final HexagonType type;
  final double? width;
  final double? height;
  final double elevation;
  final bool inBounds;
  final Widget? child;
  final Color? color;
  final double? padding;
  final double? cornerRadius;

  Size _innerSize() {
    var flatFactor = type.flatFactor(inBounds);
    var pointyFactor = type.pointyFactor(inBounds);

    if (height != null && width != null) return Size(width!, height!);
    if (height != null) return Size((height! * type.ratio) * flatFactor / pointyFactor, height!);
    if (width != null) return Size(width!, (width! / type.ratio) / flatFactor * pointyFactor);
    return const Size.square(0);
  }

  Size _contentSize() {
    var flatFactor = type.flatFactor(inBounds);
    var pointyFactor = type.pointyFactor(inBounds);

    if (height != null && width != null) return Size(width!, height!);
    if (height != null) return Size((height! * type.ratio) / pointyFactor, height! / pointyFactor);
    if (width != null) return Size(width! / flatFactor, (width! / type.ratio) / flatFactor);
    return const Size.square(0);
  }

  @override
  Widget build(BuildContext context) {
    var innerSize = _innerSize();
    var contentSize = _contentSize();

    HexagonPathBuilder pathBuilder = HexagonPathBuilder(type, inBounds: inBounds, borderRadius: cornerRadius);

    return Align(
      child: Container(
        padding: EdgeInsets.all(padding ?? 0.0),
        width: innerSize.width,
        height: innerSize.height,
        child: CustomPaint(
          painter: HexagonPainter(
            pathBuilder,
            color: color,
            elevation: elevation,
          ),
          child: ClipPath(
            clipper: HexagonClipper(pathBuilder),
            child: OverflowBox(
              alignment: Alignment.center,
              maxHeight: contentSize.height,
              maxWidth: contentSize.width,
              child: Align(
                alignment: Alignment.center,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HexagonWidgetBuilder {
  final Key? key;
  final double elevation;
  final Color? color;
  final double? padding;
  final double? cornerRadius;
  final Widget? child;

  HexagonWidgetBuilder({
    this.key,
    required this.elevation,
    this.color,
    this.padding,
    this.cornerRadius,
    this.child,
  });

  HexagonWidgetBuilder.transparent({
    this.key,
    this.padding,
    this.cornerRadius,
    this.child,
  })  : elevation = 0,
        color = Colors.transparent;

  HexagonWidget build(
    HexagonType type, {
    double? width,
    double? height,
    bool inBounds = true,
    Widget? child,
    bool replaceChild = false,
  }) {
    return HexagonWidget(
      key: key,
      type: type,
      inBounds: inBounds,
      width: width,
      height: height,
      child: replaceChild ? child : this.child,
      color: color,
      padding: padding,
      cornerRadius: cornerRadius,
      elevation: elevation,
    );
  }
}
