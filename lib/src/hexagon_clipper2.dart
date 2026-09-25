import 'package:flutter/material.dart';

import 'hexagon_path_builder2.dart';

class HexagonClipper2 extends CustomClipper<Path> {
  HexagonClipper2(this.pathBuilder);

  final HexagonPathBuilder2 pathBuilder;

  @override
  Path getClip(Size size) {
    return pathBuilder.build(size);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    if (oldClipper is HexagonClipper2) {
      return oldClipper.pathBuilder != pathBuilder;
    }
    return true;
  }
}
