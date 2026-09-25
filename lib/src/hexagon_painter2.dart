import 'package:flutter/material.dart';

import 'hexagon_path_builder2.dart';

/// This class is responsible for painting HexagonWidget color and shadow in proper shape.
class HexagonPainter2 extends CustomPainter {
  HexagonPainter2(
    this.pathBuilder, {
    this.color,
    this.elevation = 0,
  });

  final HexagonPathBuilder2 pathBuilder;
  final double elevation;
  final Color? color;

  final Paint _paint = Paint();
  Path? _path;

  @override
  void paint(Canvas canvas, Size size) {
    //todo by default background color
    _paint.color = color ?? Colors.white;
    _paint.isAntiAlias = true;
    _paint.style = PaintingStyle.fill;
    print('painting - size: $size');
    Path path = pathBuilder.build(size);
    _path = path;

    if (elevation > 0) {
      canvas.drawShadow(path, Colors.black, elevation, false);
    }
    canvas.drawPath(path, _paint);
  }

  @override
  bool hitTest(Offset position) => _path?.contains(position) ?? false;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HexagonPainter2 &&
          runtimeType == other.runtimeType &&
          pathBuilder == other.pathBuilder &&
          elevation == other.elevation &&
          color == other.color;

  @override
  int get hashCode =>
      pathBuilder.hashCode ^ elevation.hashCode ^ color.hashCode;
}
