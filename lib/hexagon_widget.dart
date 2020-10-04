library hexagon;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'hexagon_clipper.dart';
import 'hexagon_painter.dart';
import 'hexagon_type.dart';

class HexagonWidget extends StatelessWidget {
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
      return Size((height / type.ratio) * flatFactor / pointyFactor, height);
    if (width != null)
      return Size(width, (width * type.ratio) / flatFactor * pointyFactor);
    return null;
  }

  Size _contentSize() {
    var flatFactor = type.flatFactor(inBounds);
    var pointyFactor = type.pointyFactor(inBounds);

    if (height != null && width != null) return Size(width, height);
    if (height != null)
      return Size((height / type.ratio) / pointyFactor, height / pointyFactor);
    if (width != null)
      return Size(width / flatFactor, (width * type.ratio) / flatFactor);
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
