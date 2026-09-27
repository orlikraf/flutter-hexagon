import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:hexagon_core/hexagon_core.dart';

import 'hex_cell_clip.dart';

/// Builds the widget for the item at [index] of a [SliverHexGrid].
typedef HexIndexedWidgetBuilder = Widget Function(
  BuildContext context,
  int index,
);

/// A lazily built, scrollable grid of hexagons, for use in a
/// [CustomScrollView] next to other slivers.
///
/// Items are placed in reading order: along the cross axis first (left to
/// right when scrolling vertically), then line after line along the scroll
/// direction. Neighboring lines interlock like a honeycomb.
///
/// ```dart
/// CustomScrollView(
///   slivers: [
///     const SliverAppBar(title: Text('Hive')),
///     SliverHexGrid.builder(
///       gridDelegate: const SliverHexGridDelegate.count(
///         crossAxisCount: 5,
///         type: HexagonType.pointy,
///         spacing: 4,
///       ),
///       itemCount: 500,
///       itemBuilder: (context, index) => Hexagon(
///         type: HexagonType.pointy,
///         child: Text('$index'),
///       ),
///     ),
///   ],
/// )
/// ```
///
/// Each item gets its hexagon's bounding box and only receives pointers
/// inside the hexagon, so the interlocking cells don't steal each other's
/// taps.
///
/// With `crossAxisCount: 1` the grid becomes a single zigzag strip of
/// hexagons.
class SliverHexGrid extends StatelessWidget {
  /// Creates a hex grid from a [SliverChildDelegate].
  const SliverHexGrid({
    super.key,
    required this.gridDelegate,
    required this.delegate,
  });

  /// Creates a hex grid that builds [itemCount] items on demand, or an
  /// endless grid when [itemCount] is null.
  SliverHexGrid.builder({
    super.key,
    required this.gridDelegate,
    required HexIndexedWidgetBuilder itemBuilder,
    int? itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
  }) : delegate = SliverChildBuilderDelegate(
          (context, index) => HexCellClip(
            type: gridDelegate.type,
            child: itemBuilder(context, index),
          ),
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        );

  /// Creates a hex grid of the given [children].
  SliverHexGrid.list({
    super.key,
    required this.gridDelegate,
    required List<Widget> children,
  }) : delegate = SliverChildListDelegate([
          for (final child in children)
            HexCellClip(type: gridDelegate.type, child: child),
        ]);

  /// Decides the size of the hexagons and how they are placed.
  final SliverHexGridDelegate gridDelegate;

  /// Supplies the items. Items from [SliverHexGrid.new] are not clipped for
  /// hit testing; wrap them in [HexCellClip] if they overlap.
  final SliverChildDelegate delegate;

  @override
  Widget build(BuildContext context) =>
      SliverGrid(gridDelegate: gridDelegate, delegate: delegate);
}

/// Sizes and places the hexagons of a [SliverHexGrid] (or of a plain
/// [SliverGrid] or [GridView]).
///
/// Use [SliverHexGridDelegate.count] for a fixed number of hexagons across
/// the grid, or [SliverHexGridDelegate.extent] for hexagons of at most a
/// given size, as many as fit.
///
/// Rows of pointy hexagons are straight, so with vertical scrolling every
/// other row is shifted by half a hexagon. Flat hexagons form straight
/// columns, so their rows zigzag instead. With horizontal scrolling the
/// roles swap.
class SliverHexGridDelegate extends SliverGridDelegate {
  /// Places [crossAxisCount] hexagons across the grid, sized to fill it.
  const SliverHexGridDelegate.count({
    required int this.crossAxisCount,
    this.type = HexagonType.pointy,
    this.spacing = 0,
    this.parity = OffsetParity.odd,
  })  : maxCellExtent = null,
        assert(crossAxisCount > 0),
        assert(spacing >= 0);

  /// Places as many hexagons across the grid as fit when each is at most
  /// [maxCellExtent] wide (along the cross axis), sized to fill the grid.
  const SliverHexGridDelegate.extent({
    required double this.maxCellExtent,
    this.type = HexagonType.pointy,
    this.spacing = 0,
    this.parity = OffsetParity.odd,
  })  : crossAxisCount = null,
        assert(maxCellExtent > 0),
        assert(spacing >= 0);

  /// Number of hexagons across the grid, for [SliverHexGridDelegate.count].
  final int? crossAxisCount;

  /// Largest extent of a hexagon along the cross axis, for
  /// [SliverHexGridDelegate.extent].
  final double? maxCellExtent;

  /// Orientation of the hexagons.
  final HexagonType type;

  /// Gap between the edges of neighboring hexagons.
  final double spacing;

  /// Which lines are shifted by half a hexagon: with [OffsetParity.odd] the
  /// first line starts flush with the edge and the second is shifted.
  final OffsetParity parity;

  @override
  SliverHexGridLayout getLayout(SliverConstraints constraints) {
    final axis = constraints.axis;
    final width = constraints.crossAxisExtent;
    final count = crossAxisCount ?? _countFor(width, axis);
    return SliverHexGridLayout(
      type: type,
      axis: axis,
      crossAxisCount: count,
      radius: _radiusFor(width, axis, count),
      spacing: spacing,
      parity: parity,
      crossAxisExtent: width,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  int _countFor(double width, Axis axis) {
    final maxExtent = maxCellExtent!;
    for (var count = 1; count < 10000; count++) {
      final radius = _radiusFor(width, axis, count);
      final extent = axis == Axis.vertical
          ? type.widthForRadius(radius)
          : type.heightForRadius(radius);
      if (extent <= maxExtent) {
        return count;
      }
    }
    return 10000;
  }

  /// The radius at which [count] hexagons per line (and the half-hexagon
  /// shift of every other line) exactly fill [width].
  double _radiusFor(double width, Axis axis, int count) {
    final unit = SliverHexGridLayout(
      type: type,
      axis: axis,
      crossAxisCount: count,
      radius: 1,
      spacing: 0,
      parity: parity,
      crossAxisExtent: 0,
      reverseCrossAxis: false,
    );
    // With spacing s the extent is span · (radius + s / √3) + cell · radius.
    final span = unit._crossSpanOfCenters;
    final cell = unit._cellCross;
    final radius = (width - span * spacing / sqrt3) / (span + cell);
    return math.max(radius, 0.001);
  }

  @override
  bool shouldRelayout(SliverHexGridDelegate oldDelegate) =>
      oldDelegate.crossAxisCount != crossAxisCount ||
      oldDelegate.maxCellExtent != maxCellExtent ||
      oldDelegate.type != type ||
      oldDelegate.spacing != spacing ||
      oldDelegate.parity != parity;
}

/// The placement of hexagons computed by [SliverHexGridDelegate].
///
/// Item `index` sits on line `index ~/ crossAxisCount` at position
/// `index % crossAxisCount` along it, which maps to offset coordinates
/// (see [hexOf]) and from there to pixels through [layout].
class SliverHexGridLayout extends SliverGridLayout {
  /// Creates the layout.
  SliverHexGridLayout({
    required this.type,
    required this.axis,
    required this.crossAxisCount,
    required double radius,
    required double spacing,
    required this.parity,
    required this.crossAxisExtent,
    required this.reverseCrossAxis,
  })  : assert(crossAxisCount > 0),
        layout = HexLayout(type: type, radius: radius, spacing: spacing) {
    // Everything repeats every two lines, so the first two describe it all.
    var minCross = double.infinity;
    var maxCrossCenter = double.negativeInfinity;
    var minCrossCenter = double.infinity;
    for (var index = 0; index < 2 * crossAxisCount; index++) {
      final (cross, _) = _center(index);
      minCross = math.min(minCross, cross - _cellCross / 2);
      minCrossCenter = math.min(minCrossCenter, cross);
      maxCrossCenter = math.max(maxCrossCenter, cross);
    }
    var minMain = double.infinity;
    var maxMain = double.negativeInfinity;
    for (var index = 0; index < crossAxisCount; index++) {
      final (_, main) = _center(index);
      minMain = math.min(minMain, main - _cellMain / 2);
      maxMain = math.max(maxMain, main + _cellMain / 2);
    }
    _minCross = minCross;
    _minMain = minMain;
    _lineSpan = maxMain - minMain;
    _lineStep = _center(crossAxisCount).$2 - _center(0).$2;
    _crossSpanOfCenters = (maxCrossCenter - minCrossCenter) / layout.radius;
  }

  /// Orientation of the hexagons.
  final HexagonType type;

  /// Scroll direction.
  final Axis axis;

  /// Number of hexagons on each line across the grid.
  final int crossAxisCount;

  /// Which lines are shifted by half a hexagon.
  final OffsetParity parity;

  /// Width of the grid along the cross axis.
  final double crossAxisExtent;

  /// Whether the cross axis runs right to left (or bottom to top).
  final bool reverseCrossAxis;

  /// The pixel layout of the hexagons, before scrolling.
  final HexLayout layout;

  late final double _minCross;
  late final double _minMain;
  late final double _lineSpan;
  late final double _lineStep;
  late final double _crossSpanOfCenters;

  double get _cellCross =>
      axis == Axis.vertical ? layout.cellWidth : layout.cellHeight;

  double get _cellMain =>
      axis == Axis.vertical ? layout.cellHeight : layout.cellWidth;

  /// Radius of the hexagons.
  double get radius => layout.radius;

  /// The hex coordinates of the item at [index].
  Hex hexOf(int index) {
    final line = index ~/ crossAxisCount;
    final position = index % crossAxisCount;
    return axis == Axis.vertical
        ? Hex.fromOffset(position, line, type, parity: parity)
        : Hex.fromOffset(line, position, type, parity: parity);
  }

  /// Center of the item at [index] as (cross axis, main axis) coordinates,
  /// before normalizing.
  (double, double) _center(int index) {
    final point = layout.hexToPixel(hexOf(index));
    return axis == Axis.vertical ? (point.x, point.y) : (point.y, point.x);
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final (cross, main) = _center(index);
    var crossOffset = cross - _cellCross / 2 - _minCross;
    if (reverseCrossAxis) {
      crossOffset = crossAxisExtent - crossOffset - _cellCross;
    }
    return SliverGridGeometry(
      scrollOffset: main - _cellMain / 2 - _minMain,
      crossAxisOffset: crossOffset,
      mainAxisExtent: _cellMain,
      crossAxisExtent: _cellCross,
    );
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    // The first line whose far edge is past the scroll offset.
    final line = ((scrollOffset - _lineSpan) / _lineStep).floor() + 1;
    return math.max(0, line) * crossAxisCount;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    // The last line that starts before the scroll offset.
    final lines = (scrollOffset / _lineStep).ceil();
    return math.max(0, crossAxisCount * lines - 1);
  }

  @override
  double computeMaxScrollOffset(int childCount) {
    if (childCount <= 0) {
      return 0;
    }
    final lastLine = (childCount - 1) ~/ crossAxisCount;
    final first = math.max(0, (lastLine - 1) * crossAxisCount);
    var end = 0.0;
    for (var index = first; index < childCount; index++) {
      end = math.max(end, getGeometryForChildIndex(index).trailingScrollOffset);
    }
    return end;
  }
}
