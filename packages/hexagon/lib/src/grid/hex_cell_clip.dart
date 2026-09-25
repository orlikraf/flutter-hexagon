import 'package:flutter/widgets.dart';
import 'package:hexagon_core/hexagon_core.dart';

import '../hexagon_border.dart';

/// Limits hit testing of [child] to a hexagon outline without clipping its
/// painting, so neighboring cells with overlapping bounding boxes each get
/// the pointers inside their own hexagon.
class HexCellClip extends StatelessWidget {
  /// Creates the clip.
  const HexCellClip({super.key, required this.type, required this.child});

  /// Orientation of the hexagon.
  final HexagonType type;

  /// The cell's content.
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipPath(
        clipper: ShapeBorderClipper(shape: HexagonBorder(type: type)),
        clipBehavior: Clip.none,
        child: child,
      );
}
