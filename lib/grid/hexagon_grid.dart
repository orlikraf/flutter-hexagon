import 'package:flutter/material.dart';

import '../hexagon_type.dart';
import '../hexagon_widget.dart';

class HexagonGrid extends StatelessWidget {
  final HexagonType hexType;

  final Color color;
  final Widget Function(int col, int row) buildChild;
  final HexagonWidget Function(int col, int row) buildHexagon;

  HexagonGrid(this.hexType, this.color, this.buildChild, this.buildHexagon);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
