// Pre-1.0 API, kept for compatibility and deprecated. See MIGRATION.md.
// ignore_for_file: deprecated_member_use_from_same_package, public_member_api_docs, unnecessary_this, curly_braces_in_flow_control_structures, use_key_in_widget_constructors, use_super_parameters, prefer_const_constructors_in_immutables, constant_identifier_names, sort_child_properties_last, prefer_typing_uninitialized_variables, prefer_final_fields, unnecessary_null_comparison, sized_box_for_whitespace, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import 'hexagon_path_builder.dart';

/// This class is responsible for painting HexagonWidget color and shadow in proper shape.
@Deprecated('Use HexagonBorder, e.g. with ShapeDecoration or Material. Will be removed in 2.0.0.')
class HexagonPainter extends CustomPainter {
  HexagonPainter(this.pathBuilder, {this.color, this.elevation = 0});

  final HexagonPathBuilder pathBuilder;
  final double elevation;
  final Color? color;

  final Paint _paint = Paint();
  Path? _path;

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = color ?? Colors.white;
    _paint.isAntiAlias = true;
    _paint.style = PaintingStyle.fill;

    Path path = pathBuilder.build(size);
    _path = path;

    if ((elevation) > 0)
      canvas.drawShadow(path, Colors.black, elevation, false);
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
  int get hashCode =>
      pathBuilder.hashCode ^ elevation.hashCode ^ color.hashCode;
}
