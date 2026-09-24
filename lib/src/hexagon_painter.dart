import 'package:flutter/widgets.dart';

import 'hexagon_path_builder.dart';

/// Paints a hexagon's fill and shadow, in the shape given by [pathBuilder].
class HexagonPainter extends CustomPainter {
  /// Creates a painter that fills the hexagon with [color] and casts a
  /// shadow for [elevation].
  HexagonPainter(this.pathBuilder, {this.color, this.elevation = 0});

  /// Builds the hexagon outline for the painted size.
  final HexagonPathBuilder pathBuilder;

  /// Size of the shadow. No shadow is drawn when 0.
  final double elevation;

  /// Fill color. White when null.
  final Color? color;

  static const Color _defaultColor = Color(0xFFFFFFFF);
  static const Color _shadowColor = Color(0xFF000000);

  final Paint _paint = Paint();
  Path? _path;

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = color ?? _defaultColor;
    _paint.isAntiAlias = true;
    _paint.style = PaintingStyle.fill;

    Path path = pathBuilder.build(size);
    _path = path;

    if (elevation > 0) {
      canvas.drawShadow(path, _shadowColor, elevation, false);
    }
    canvas.drawPath(path, _paint);
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
          color == other.color;

  @override
  int get hashCode => Object.hash(pathBuilder, elevation, color);
}
