library hexagon;

import 'package:flutter/material.dart';
import 'package:hexagon/hexagon_shadows_painter.dart';
import 'package:hexagon/hexagon_type.dart';

import 'hexagon_clipper.dart';

class HexagonWidget extends StatelessWidget {
  const HexagonWidget({
    Key key,
    this.width,
    this.height,
    this.elevation = 2,
    this.child,
    this.type = HexagonType.FLAT,
  })  : assert((elevation ?? 0) >= 0),
        super(key: key);

  final HexagonType type;
  final double width;
  final double height;
  final double elevation;
  final Widget child;

  double get _ratio {
    if (type == HexagonType.FLAT) return 1.1547005 / 1;
    return 1 / 1.1547005;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: CustomPaint(
        painter: HexagonShadowsPainter(type, elevation: elevation),
        child: AspectRatio(
          aspectRatio: _ratio,
          child: ClipPath(
            clipper: HexagonClipper(type),
            child: Container(color: Colors.white, child: child),
          ),
        ),
      ),
    );
  }
}
