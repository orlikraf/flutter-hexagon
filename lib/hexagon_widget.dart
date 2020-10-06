library hexagon;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'hexagon_clipper.dart';
import 'hexagon_painter.dart';
import 'hexagon_type.dart';

class HexagonWidget extends StatelessWidget {
  /// Preferably provide one dimension ([width] or [height]) and the other will be counted accordingly to hexagon aspect ratio
  ///
  /// [elevation] - Must be zero or positive int. Default = 2
  ///
  /// [color] - Color used to fill hexagon. Use transparency with 0 elevation
  ///
  /// [inBounds] - Set to false if you want to overlap hexagon corners outside it's space.
  ///
  /// [child] - You content. Keep in mind that it will be clipped.
  ///
  /// [type] - A type of hexagon has to be either [HexagonType.FLAT] or [HexagonType.POINTY]
  const HexagonWidget({
    Key key,
    this.width,
    this.height,
    this.color,
    this.child,
    this.elevation = 2,
    this.inBounds = true,
    @required this.type,
  })  : assert(width != null || height != null),
        assert((elevation ?? 0) >= 0),
        assert(type != null),
        super(key: key);

  /// Preferably provide one dimension ([width] or [height]) and the other will be counted accordingly to hexagon aspect ratio
  ///
  /// [elevation] - Must be zero or positive int. Default = 2
  ///
  /// [color] - Color used to fill hexagon. Use transparency with 0 elevation
  ///
  /// [inBounds] - Set to false if you want to overlap hexagon corners outside it's space.
  ///
  /// [child] - You content. Keep in mind that it will be clipped.
  HexagonWidget.flat(
      {this.width,
      this.height,
      this.color,
      this.child,
      this.elevation = 2,
      this.inBounds = true})
      : assert(width != null || height != null),
        assert((elevation ?? 0) >= 0),
        this.type = HexagonType.FLAT;

  /// Preferably provide one dimension ([width] or [height]) and the other will be counted accordingly to hexagon aspect ratio
  ///
  /// [elevation] - Must be zero or positive int. Default = 2
  ///
  /// [color] - Color used to fill hexagon. Use transparency with 0 elevation
  ///
  /// [inBounds] - Set to false if you want to overlap hexagon corners outside it's space.
  ///
  /// [child] - You content. Keep in mind that it will be clipped.
  HexagonWidget.pointy(
      {this.width,
      this.height,
      this.color,
      this.child,
      this.elevation = 2,
      this.inBounds = true})
      : assert(width != null || height != null),
        assert((elevation ?? 0) >= 0),
        this.type = HexagonType.POINTY;

  final HexagonType type;
  final double width;
  final double height;
  final double elevation;
  final bool inBounds;
  final Widget child;
  final Color color;

  Size _innerSize() {
    var flatFactor = type.flatFactor(inBounds);
    var pointyFactor = type.pointyFactor(inBounds);

    if (height != null && width != null) return Size(width, height);
    if (height != null)
      return Size((height * type.ratio) * flatFactor / pointyFactor, height);
    if (width != null)
      return Size(width, (width / type.ratio) / flatFactor * pointyFactor);
    return null;
  }

  Size _contentSize() {
    var flatFactor = type.flatFactor(inBounds);
    var pointyFactor = type.pointyFactor(inBounds);

    if (height != null && width != null) return Size(width, height);
    if (height != null)
      return Size((height * type.ratio) / pointyFactor, height / pointyFactor);
    if (width != null)
      return Size(width / flatFactor, (width / type.ratio) / flatFactor);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var innerSize = _innerSize();
    var contentSize = _contentSize();

    return Align(
      child: Container(
        width: innerSize.width,
        height: innerSize.height,
        child: CustomPaint(
          painter: HexagonPainter(
            type,
            color: color,
            elevation: elevation,
            inBounds: inBounds,
          ),
          child: ClipPath(
            clipper: HexagonClipper(type, inBounds: inBounds),
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
