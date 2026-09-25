import 'package:flutter/widgets.dart';
import 'package:hexagon_core/hexagon_core.dart';

import 'hex_grid.dart';

/// Geometry of one cell, handed to [HexCellPainter]s.
///
/// Coordinates are in the pixel space of the grid's [HexLayout].
class HexCell {
  /// Creates the geometry of [hex].
  HexCell(this.hex, this.center, this.rect, this.localPath);

  /// The cell.
  final Hex hex;

  /// Center of the cell.
  final Offset center;

  /// Bounding box of the cell.
  final Rect rect;

  /// The cell's outline, centered on [Offset.zero].
  ///
  /// Shared by every cell of a layer. Drawing it after
  /// `canvas.translate(center.dx, center.dy)` avoids creating a path per
  /// cell.
  final Path localPath;

  Path? _path;

  /// The cell's outline at its position.
  Path get path => _path ??= localPath.shift(center);
}

/// Paints one cell on a [HexPaintLayer].
typedef HexCellPainter = void Function(Canvas canvas, HexCell cell);

/// Picks a color for a cell.
typedef HexColorBuilder = Color? Function(Hex hex);

/// One layer of a [HexGridView]. Layers are stacked in order, the first one
/// at the bottom.
sealed class HexLayer {
  /// Creates a layer covering [cells].
  const HexLayer({this.cells});

  /// The cells this layer covers. Null means every cell of the grid.
  ///
  /// Prefer a [Set], or keep passing the same object between builds, so the
  /// view doesn't have to convert it again.
  final Iterable<Hex>? cells;
}

/// A layer that paints its visible cells on a canvas.
///
/// This is the fast path for large maps: nothing is built per cell, and only
/// the cells in the viewport are painted.
///
/// ```dart
/// HexPaintLayer(
///   painter: (canvas, cell) {
///     canvas.drawPath(cell.path, Paint()..color = terrain[cell.hex]!.color);
///   },
/// )
/// ```
class HexPaintLayer extends HexLayer {
  /// Creates a layer that calls [painter] for each visible cell.
  ///
  /// Pass a [repaint] listenable (an animation, a `ChangeNotifier` holding
  /// game state) to repaint when it changes.
  const HexPaintLayer({
    required HexCellPainter this.painter,
    super.cells,
    this.repaint,
    this.cornerRadius = 0,
  })  : color = null,
        colorOf = null,
        strokeColor = null,
        strokeWidth = 0;

  /// Creates a layer that fills each cell with a color and optionally
  /// outlines it.
  ///
  /// [colorOf] picks a color per cell; return null to leave a cell unpainted.
  /// Without [colorOf], every cell gets [color], which defaults to the
  /// theme's `ColorScheme.surfaceContainerHighest`.
  const HexPaintLayer.fill({
    this.color,
    this.colorOf,
    this.strokeColor,
    this.strokeWidth = 1,
    this.cornerRadius = 0,
    super.cells,
    this.repaint,
  }) : painter = null;

  /// Custom painter, or null for a fill layer.
  final HexCellPainter? painter;

  /// Repaints the layer when it notifies.
  final Listenable? repaint;

  /// Radius of the rounded corners of [HexCell.path].
  final double cornerRadius;

  /// Fill color of a fill layer.
  final Color? color;

  /// Per-cell fill color of a fill layer.
  final HexColorBuilder? colorOf;

  /// Outline color of a fill layer. No outline if null.
  final Color? strokeColor;

  /// Outline width of a fill layer.
  final double strokeWidth;
}

/// A layer with a widget for each of its visible cells.
///
/// Use it for the few cells that need to be interactive or animated, such as
/// units, markers or labels, on top of [HexPaintLayer]s. Each widget gets its
/// cell's bounding box and only receives pointers inside the hexagon.
class HexWidgetLayer extends HexLayer {
  /// Creates a widget layer.
  const HexWidgetLayer({required this.builder, super.cells});

  /// Builds the widget of each visible cell.
  final HexWidgetBuilder builder;
}
