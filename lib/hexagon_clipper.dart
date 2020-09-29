import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hexagon/utils.dart';

import 'hexagon_type.dart';

class HexagonClipper extends CustomClipper<Path> {
  final HexagonType type;

  HexagonClipper(this.type);

  @override
  Path getClip(Size size) {
    return HexagonUtils.hexagonPath(size, type);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    if (oldClipper is HexagonClipper) {
      return oldClipper.type != type;
    }
    return true;
  }
}
