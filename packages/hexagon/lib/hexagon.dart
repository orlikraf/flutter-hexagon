/// Hexagons for Flutter apps and games.
///
/// * [Hexagon] – a hexagon-shaped surface that sizes itself during layout.
/// * [HexagonBorder] – a [ShapeBorder] for `Material`, `Card`, buttons,
///   `ShapeDecoration` and `ClipPath.shape`.
/// * [HexGrid] – a grid with a widget per cell.
/// * [HexGridView] – a pannable, zoomable map painted in layers, for large
///   boards.
///
/// The grid math ([Hex], [HexLayout], [HexShape], [HexMap] and the
/// pathfinding in [HexSearch]) comes from `package:hexagon_core`, which is
/// re-exported here.
library;

import 'package:flutter/painting.dart';

import 'src/grid/hex_grid.dart';
import 'src/grid/hex_grid_view.dart';
import 'src/hexagon.dart';
import 'src/hexagon_border.dart';

export 'package:hexagon_core/hexagon_core.dart';

export 'src/geometry.dart'
    show
        HexLayoutFlutter,
        OffsetPixelPoint,
        PixelPointOffset,
        PixelRectRect,
        RectPixelRect;
export 'src/grid/hex_cell_clip.dart';
export 'src/grid/hex_grid.dart';
export 'src/grid/hex_grid_view.dart';
export 'src/grid/hex_layers.dart';
export 'src/hexagon.dart';
export 'src/hexagon_border.dart';
export 'src/hexagon_theme.dart';
// Pre-1.0 API, deprecated.
export 'src/legacy/grid/coordinates.dart';
export 'src/legacy/grid/hexagon_grid.dart';
export 'src/legacy/grid/hexagon_offset_grid.dart';
export 'src/legacy/hexagon_clipper.dart';
export 'src/legacy/hexagon_painter.dart';
export 'src/legacy/hexagon_path_builder.dart';
export 'src/legacy/hexagon_widget.dart';
export 'src/legacy/legacy_type_extension.dart';
