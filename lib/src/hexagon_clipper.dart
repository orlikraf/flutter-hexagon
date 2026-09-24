import 'package:flutter/widgets.dart';

import 'hexagon_path_builder.dart';

/// Clips to the hexagon outline given by [pathBuilder].
class HexagonClipper extends CustomClipper<Path> {
  /// Creates a clipper in the shape built by [pathBuilder].
  HexagonClipper(this.pathBuilder);

  /// Builds the hexagon outline for the clipped size.
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
