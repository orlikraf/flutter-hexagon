import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';

/// Offset grids addressed by column and row, scrolling vertically or
/// horizontally.
class OffsetGridPage extends StatefulWidget {
  const OffsetGridPage({super.key});

  @override
  State<OffsetGridPage> createState() => _OffsetGridPageState();
}

class _OffsetGridPageState extends State<OffsetGridPage> {
  bool _vertical = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Flat, vertical')),
              ButtonSegment(value: false, label: Text('Pointy, horizontal')),
            ],
            selected: {_vertical},
            onSelectionChanged: (selection) =>
                setState(() => _vertical = selection.first),
          ),
        ),
        Expanded(child: _vertical ? _verticalGrid() : _horizontalGrid()),
      ],
    );
  }

  Widget _verticalGrid() {
    return SingleChildScrollView(
      child: HexagonOffsetGrid.evenFlat(
        color: Colors.yellow.shade100,
        padding: const EdgeInsets.all(8),
        columns: 5,
        rows: 10,
        buildTile: (col, row) => HexagonWidgetBuilder(
          color: row.isEven ? Colors.yellow : Colors.orangeAccent,
          elevation: 2,
          padding: 2,
        ),
        buildChild: (col, row) => Text('$col, $row'),
      ),
    );
  }

  Widget _horizontalGrid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: HexagonOffsetGrid.oddPointy(
        color: Colors.black54,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        columns: 9,
        rows: 4,
        // Returning null uses the default template, leaving a plain tile.
        buildTile: (col, row) => row.isOdd && col.isOdd
            ? null
            : HexagonWidgetBuilder(
                elevation: col.toDouble(),
                padding: 4,
                cornerRadius: row.isOdd ? 24 : null,
                color: col == 1 || row == 1 ? Colors.lightBlue.shade200 : null,
                child: Text('$col, $row'),
              ),
      ),
    );
  }
}
