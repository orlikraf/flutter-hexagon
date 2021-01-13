import 'package:flutter/material.dart';

import 'hexagon_type.dart';
import 'utils.dart';

/// This class is responsible for painting HexagonWidget color and shadow in proper shape.
class HexagonPainter extends CustomPainter {
  HexagonPainter(this.type, {this.color, this.inBounds, this.elevation});

  final HexagonType type;
  final bool inBounds;
  final double elevation;
  final Color color;

  final Paint _paint = Paint();
  Path _path;

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = color ?? Colors.white;
    _paint.isAntiAlias = true;
    _paint.style = PaintingStyle.fill;

    _path = HexagonUtils.hexagonPath(size, type, inBounds: inBounds);
    if ((elevation ?? 0) > 0)
      canvas.drawShadow(_path, Colors.black, elevation ?? 0, false);
    canvas.drawPath(_path, _paint);

    // _paint.color = Colors.purple;
    // _paint.strokeWidth = 0;
    // _paint.style = PaintingStyle.stroke;
    // canvas.drawPath(_path, _paint);
  }

  @override
  bool hitTest(Offset position) {
    if (_path == null) {
      return false;
    }
    return _path.contains(position);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
