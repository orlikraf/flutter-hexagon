import 'dart:math';

import 'package:flutter/material.dart';

import 'hexagon_type.dart';

class HexagonUtils {
  static Point flatHexagonCorner(Offset center, double size, int i) {
    var angleDeg = 60 * i;
    var angleRad = pi / 180 * angleDeg;
    return Point(
        center.dx + size * cos(angleRad), center.dy + size * sin(angleRad));
  }

  static Point pointyHexagonCorner(Offset center, double size, int i) {
    var angleDeg = 60 * i - 30;
    var angleRad = pi / 180 * angleDeg;
    return Point(
        center.dx + size * cos(angleRad), center.dy + size * sin(angleRad));
  }

  /// Calculates hexagon corners for given size and with given center.
  static List<Point> flatHexagonCornerList(Offset center, double size) {
    List<Point> corners = List(6);
    for (int i = 0; i < 6; i++) {
      corners[i] = flatHexagonCorner(center, size, i);
    }

    return corners;
  }

  /// Calculates hexagon corners for given size and with given center.
  static List<Point> pointyHexagonCornerList(Offset center, double size) {
    List<Point> corners = List(6);
    for (int i = 0; i < 6; i++) {
      corners[i] = pointyHexagonCorner(center, size, i);
    }
    return corners;
  }

  /// Returns path in shape of hexagon.
  static Path hexagonPath(Size size, HexagonType type, {bool inBounds}) {
    inBounds = inBounds == true;
    final center = Offset(size.width / 2, size.height / 2);

    List<Point> cornerList;
    if (type == HexagonType.FLAT) {
      cornerList = HexagonUtils.flatHexagonCornerList(
          center, size.width / type.flatFactor(inBounds) / 2);
    } else {
      cornerList = HexagonUtils.pointyHexagonCornerList(
          center, size.height / type.pointyFactor(inBounds) / 2);
    }

    final path = Path();
    cornerList.asMap().forEach((index, point) {
      if (index == 0) {
        path.moveTo(point.x, point.y);
      } else {
        path.lineTo(point.x, point.y);
      }
    });
    return path..close();
  }
}
