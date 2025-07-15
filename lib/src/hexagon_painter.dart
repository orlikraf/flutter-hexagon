import 'package:flutter/material.dart';

import 'hexagon_path_builder.dart';

/// This class is responsible for painting HexagonWidget color and shadow in proper shape.
class HexagonPainter extends CustomPainter {
  HexagonPainter(
    this.pathBuilder, {
    this.color,
    this.elevation = 0,
    this.borderColor,
    this.borderWidth = 0,
  });

  final HexagonPathBuilder pathBuilder;
  final double elevation;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;

  final Paint _paint = Paint();
  final Paint _borderPaint = Paint();
  Path? _path;

  @override
  void paint(Canvas canvas, Size size) {
    Path path = pathBuilder.build(size);
    _path = path;

    // Draw shadow
    if (elevation > 0) {
      canvas.drawShadow(path, Colors.black, elevation, false);
    }

    // Draw fill
    // keep default as white to not cause breaking changes
    _paint.color = color ?? Colors.white;
    _paint.isAntiAlias = true;
    _paint.style = PaintingStyle.fill;
    canvas.drawPath(path, _paint);

    // Draw border
    if (borderWidth > 0 && borderColor != null) {
      _borderPaint.color = borderColor!;
      _borderPaint.isAntiAlias = true;
      _borderPaint.style = PaintingStyle.stroke;
      _borderPaint.strokeWidth = borderWidth;
      canvas.drawPath(path, _borderPaint);
    }
  }

  @override
  bool hitTest(Offset position) {
    return _path?.contains(position) ?? false;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HexagonPainter &&
          runtimeType == other.runtimeType &&
          pathBuilder == other.pathBuilder &&
          elevation == other.elevation &&
          color == other.color &&
          borderColor == other.borderColor &&
          borderWidth == other.borderWidth;

  @override
  int get hashCode =>
      pathBuilder.hashCode ^
      elevation.hashCode ^
      color.hashCode ^
      borderColor.hashCode ^
      borderWidth.hashCode;
}
