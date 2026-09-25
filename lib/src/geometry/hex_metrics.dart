import 'dart:math';

import 'package:flutter/widgets.dart';

import '../hexagon_layout.dart';
import '../hexagon_type.dart';

/// Geometry shared by the widgets and grids. Not exported.
///
/// Terms used here:
/// - A *hexagon* is the full regular hexagon, corner to corner.
/// - A *tile* is the layout box of a hexagon laid out with `inBounds`
///   false: 3/4 of the hexagon along the axis of its pointed ends, whose
///   points then overflow by 1/8 on each side so that neighbours interlock.
abstract final class HexMetrics {
  /// The square root of 3. A hexagon's edge-to-edge size is √3/2 times its
  /// corner-to-corner size.
  static final double sqrt3 = sqrt(3);

  /// Tolerance for rounding errors when checking whether a layout fits.
  static const double epsilon = 1e-9;

  /// How far a tile's pointed end overflows its box, as a fraction of the
  /// hexagon.
  static const double overflow = 1 / 8;

  /// The number of hexagons spanned by [count] interlocked tiles in a line.
  static double interlockedSpan(int count) => 1 + 0.75 * (count - 1);

  /// The tile of a hexagon [hexagonWidth] wide.
  static Size tileFromWidth(HexagonType type, double hexagonWidth) =>
      type.isFlat
      ? Size(0.75 * hexagonWidth, hexagonWidth * sqrt3 / 2)
      : Size(hexagonWidth, hexagonWidth * sqrt3 / 2);

  /// The tile of a hexagon [hexagonHeight] tall.
  static Size tileFromHeight(HexagonType type, double hexagonHeight) =>
      type.isFlat
      ? Size(hexagonHeight * sqrt3 / 2, hexagonHeight)
      : Size(hexagonHeight * sqrt3 / 2, 0.75 * hexagonHeight);

  /// Space along the pointed axis for the overflowing ends of the outermost
  /// tiles of a grid of [tile]s.
  static EdgeInsets edgeInsets(HexagonType type, Size tile) => type.isFlat
      ? EdgeInsets.symmetric(horizontal: tile.width / 0.75 * overflow)
      : EdgeInsets.symmetric(vertical: tile.height / 0.75 * overflow);

  /// The circumradius of the largest hexagon that fits in [size], or whose
  /// box of [size] it overflows as described above when [inBounds] is
  /// false.
  static double circumradius(HexagonType type, Size size, bool inBounds) {
    if (type.isFlat) {
      return min(
        size.width / type.widthFactor(inBounds) / 2,
        size.height / sqrt3,
      );
    }
    return min(
      size.height / type.heightFactor(inBounds) / 2,
      size.width / sqrt3,
    );
  }
}
