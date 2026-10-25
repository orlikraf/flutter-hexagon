/// Hexagonal grid math in pure Dart.
///
/// * [Hex] – axial/cube coordinates with neighbors, distances, rotations,
///   lines, rings and conversions to offset and doubled coordinates.
/// * [HexLayout] – mapping between hexes and pixel positions.
/// * [HexShape] – common map shapes.
/// * [HexMap] – per-cell storage.
/// * [HexSearch] – movement range, A* pathfinding, line of sight and field
///   of view.
library;

import 'src/hex.dart';
import 'src/hex_layout.dart';
import 'src/hex_map.dart';
import 'src/hex_search.dart';
import 'src/hex_shape.dart';

export 'src/hex.dart';
export 'src/hex_layout.dart';
export 'src/hex_map.dart';
export 'src/hex_search.dart';
export 'src/hex_shape.dart';
export 'src/hexagon_type.dart';
export 'src/pixel.dart';
