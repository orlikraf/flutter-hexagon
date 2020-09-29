import 'package:flutter/material.dart';
import 'package:hexagon/utils.dart';

import 'hexagon_type.dart';

class HexagonShadowsPainter extends CustomPainter {
  HexagonShadowsPainter(this.type, {this.elevation});

  final HexagonType type;
  final double elevation;

  Path _path;

  @override
  void paint(Canvas canvas, Size size) {
    _path = HexagonUtils.hexagonPath(size, type);
    canvas.drawShadow(_path, Colors.black, elevation ?? 0, false);
  }

  @override
  bool hitTest(Offset position) {
    return _path.contains(position);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
