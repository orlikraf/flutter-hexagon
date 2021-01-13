import 'dart:ui';

import 'package:flutter/material.dart';

import 'hexagon_type.dart';
import 'utils.dart';

class HexagonClipper extends CustomClipper<Path> {
  HexagonClipper(this.type, {this.inBounds});

  final HexagonType type;
  final bool inBounds;

  @override
  Path getClip(Size size) {
    return HexagonUtils.hexagonPath(size, type, inBounds: inBounds);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    if (oldClipper is HexagonClipper) {
      return oldClipper.type != type;
    }
    return true;
  }
}
