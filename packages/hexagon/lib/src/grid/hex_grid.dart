import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:hexagon_core/hexagon_core.dart';

import '../geometry.dart';
import 'hex_cell_clip.dart';

/// Builds the widget for one cell of a hex grid.
typedef HexWidgetBuilder = Widget Function(BuildContext context, Hex hex);

/// A grid of hexagonal cells with one widget per cell.
///
/// Suited to boards and menus of up to a few hundred cells. For large maps,
/// use [HexGridView], which paints cells on a canvas and builds only what is
/// visible.
///
/// Pick the cells with [HexShape] or any collection of [Hex]es:
///
/// ```dart
/// HexGrid(
///   cells: HexShape.hexagon(2),
///   type: HexagonType.pointy,
///   spacing: 4,
///   itemBuilder: (context, hex) => Hexagon(
///     type: HexagonType.pointy,
///     child: Text('${hex.q}, ${hex.r}'),
///   ),
///   onHexTap: (hex) => print(hex),
/// )
/// ```
///
/// Each cell's widget gets the exact size of the hexagon's bounding box, and
/// only receives pointers inside its hexagon.
class HexGrid extends StatelessWidget {
  /// Creates a hex grid.
  const HexGrid({
    super.key,
    required this.cells,
    required this.itemBuilder,
    this.type = HexagonType.flat,
    this.radius,
    this.spacing = 0,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.center,
    this.onHexTap,
  })  : assert(radius == null || radius > 0),
        assert(spacing >= 0);

  /// The cells of the grid.
  final Iterable<Hex> cells;

  /// Builds the widget of each cell.
  final HexWidgetBuilder itemBuilder;

  /// Orientation of the hexagons.
  final HexagonType type;

  /// Radius of each hexagon (center to corner). If null, the hexagons are
  /// sized so the grid fits the incoming constraints; if those are unbounded
  /// in both directions, 32 is used.
  final double? radius;

  /// Gap between neighboring hexagons.
  final double spacing;

  /// Space around the grid.
  final EdgeInsetsGeometry padding;

  /// Position of the grid when it is smaller than its constraints.
  final AlignmentGeometry alignment;

  /// Called when a cell is tapped, unless the cell's widget handles the tap
  /// itself.
  final ValueChanged<Hex>? onHexTap;

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.maybeOf(context);
    final list = LinkedHashSet<Hex>.of(cells).toList(growable: false);
    return CustomMultiChildLayout(
      delegate: _HexGridDelegate(
        cells: list,
        type: type,
        radius: radius,
        spacing: spacing,
        padding: padding.resolve(textDirection),
        alignment: alignment.resolve(textDirection),
      ),
      children: [
        for (final hex in list)
          LayoutId(
            id: hex,
            child: HexCellClip(
              type: type,
              child: _tappable(hex, itemBuilder(context, hex)),
            ),
          ),
      ],
    );
  }

  Widget _tappable(Hex hex, Widget child) {
    final onHexTap = this.onHexTap;
    if (onHexTap == null) {
      return child;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onHexTap(hex),
      child: child,
    );
  }
}

class _HexGridDelegate extends MultiChildLayoutDelegate {
  _HexGridDelegate({
    required this.cells,
    required this.type,
    required this.radius,
    required this.spacing,
    required this.padding,
    required this.alignment,
  });

  static const double _defaultRadius = 32;

  final List<Hex> cells;
  final HexagonType type;
  final double? radius;
  final double spacing;
  final EdgeInsets padding;
  final Alignment alignment;

  double _radiusFor(double maxWidth, double maxHeight) {
    final fixed = radius;
    if (fixed != null) {
      return fixed;
    }
    final unit = HexLayout(type: type, radius: 1);
    final unitBounds = unit.boundsOf(cells);
    // Distance between the outermost centers, measured in steps.
    final spanX = unitBounds.width - unit.cellWidth;
    final spanY = unitBounds.height - unit.cellHeight;
    final gap = spacing / sqrt3;
    final availableWidth = maxWidth - padding.horizontal;
    final availableHeight = maxHeight - padding.vertical;
    var result = double.infinity;
    if (availableWidth.isFinite) {
      result = math.min(
        result,
        (availableWidth - spanX * gap) / (spanX + type.widthForRadius(1)),
      );
    }
    if (availableHeight.isFinite) {
      result = math.min(
        result,
        (availableHeight - spanY * gap) / (spanY + type.heightForRadius(1)),
      );
    }
    if (result == double.infinity) {
      return _defaultRadius;
    }
    return math.max(result, 0.001);
  }

  HexLayout _layout(double maxWidth, double maxHeight) => HexLayout(
        type: type,
        radius: _radiusFor(maxWidth, maxHeight),
        spacing: spacing,
      );

  @override
  Size getSize(BoxConstraints constraints) {
    final layout = _layout(constraints.maxWidth, constraints.maxHeight);
    final bounds = layout.boundsOf(cells);
    return constraints.constrain(
      Size(
        bounds.width + padding.horizontal,
        bounds.height + padding.vertical,
      ),
    );
  }

  @override
  void performLayout(Size size) {
    final layout = _layout(size.width, size.height);
    final bounds = layout.rectOfAll(cells);
    final free = Size(
      math.max(0, size.width - padding.horizontal - bounds.width),
      math.max(0, size.height - padding.vertical - bounds.height),
    );
    final shift =
        padding.topLeft + alignment.alongSize(free) - bounds.topLeft;
    final cellSize = Size(layout.cellWidth, layout.cellHeight);
    for (final hex in cells) {
      if (hasChild(hex)) {
        layoutChild(hex, BoxConstraints.tight(cellSize));
        positionChild(hex, layout.rectOf(hex).topLeft + shift);
      }
    }
  }

  @override
  bool shouldRelayout(_HexGridDelegate oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.radius != radius ||
      oldDelegate.spacing != spacing ||
      oldDelegate.padding != padding ||
      oldDelegate.alignment != alignment ||
      !_sameCells(oldDelegate.cells, cells);

  static bool _sameCells(List<Hex> a, List<Hex> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
