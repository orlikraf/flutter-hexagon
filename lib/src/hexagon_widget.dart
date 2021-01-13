library hexagon;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'hexagon_clipper.dart';
import 'hexagon_painter.dart';
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
    this.padding,
    this.elevation = 0,
    this.inBounds = true,
    @required this.type,
  })  : assert(width != null || height != null),
        assert((elevation ?? 0) >= 0),
        assert(type != null),
        this._template = false,
        super(key: key);

  /// Preferably provide one dimension ([width] or [height]) and the other will be calculated accordingly to hexagon aspect ratio
  ///
  /// [elevation] - Mustn't be negative. Default = 0
  ///
  /// [padding] - Mustn't be negative.
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
      this.padding,
      this.elevation = 0,
      this.inBounds = true})
      : assert(width != null || height != null),
        assert((elevation ?? 0) >= 0),
        this._template = false,
        this.type = HexagonType.FLAT;

  /// Preferably provide one dimension ([width] or [height]) and the other will be calculated accordingly to hexagon aspect ratio
  ///
  /// [elevation] - Mustn't be negative. Default = 0
  ///
  /// [padding] - Mustn't be negative.
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
      this.padding,
      this.elevation = 0,
      this.inBounds = true})
      : assert(width != null || height != null),
        assert((elevation ?? 0) >= 0),
        this._template = false,
        this.type = HexagonType.POINTY;

  ///Used in grids. Not for regular use.
  HexagonWidget.template({this.color, this.elevation, this.padding, this.child})
      : this.height = 1.0,
        this.width = 1.0,
        this._template = true,
        this.inBounds = null,
        this.type = null;

  final bool _template;
  final HexagonType type;
  final double width;
  final double height;
  final double elevation;
  final bool inBounds;
  final Widget child;
  final Color color;
  final double padding;

  bool get isTemplate => _template == true;

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
    assert(!isTemplate);

    return Align(
      child: Container(
        padding: EdgeInsets.all(padding ?? 0.0),
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

  //TODO create HexagonWidgetBuilder class instead of complicated template and copy function
  HexagonWidget copyWith({
    HexagonType type,
    double width,
    double height,
    double elevation,
    double padding,
    Color color,
    Widget child,
    bool inBounds,
  }) {
    return HexagonWidget(
      type: type ?? this.type,
      inBounds: inBounds ?? this.inBounds,
      width: isTemplate ? width : width ?? this.width,
      height: isTemplate ? height : height ?? this.height,
      child: isTemplate ? child : child ?? this.child,
      padding: isTemplate ? this.padding ?? padding : padding ?? this.padding,
      elevation: elevation ?? this.elevation,
      color: color ?? this.color,
    );
  }
}
