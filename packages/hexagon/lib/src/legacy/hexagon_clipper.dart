// Pre-1.0 API, kept for compatibility and deprecated. See MIGRATION.md.
// ignore_for_file: deprecated_member_use_from_same_package, public_member_api_docs, unnecessary_this, curly_braces_in_flow_control_structures, use_key_in_widget_constructors, use_super_parameters, prefer_const_constructors_in_immutables, constant_identifier_names, sort_child_properties_last, prefer_typing_uninitialized_variables, prefer_final_fields, unnecessary_null_comparison, sized_box_for_whitespace, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_locals

import 'package:flutter/material.dart';
import 'hexagon_path_builder.dart';

@Deprecated('Use ClipPath.shape with HexagonBorder. Will be removed in 2.0.0.')
class HexagonClipper extends CustomClipper<Path> {
  HexagonClipper(this.pathBuilder);

  final HexagonPathBuilder pathBuilder;

  @override
  Path getClip(Size size) {
    return pathBuilder.build(size);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    if (oldClipper is HexagonClipper) {
      return oldClipper.pathBuilder != pathBuilder;
    }
    return true;
  }
}
