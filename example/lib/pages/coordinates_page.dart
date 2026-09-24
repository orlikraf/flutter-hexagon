import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';

enum _Selection { neighbors, ring, spiral, line }

/// Tap a tile to see [Coordinates] helpers: its neighbours, a ring, a
/// spiral, or the line from the center.
class CoordinatesPage extends StatefulWidget {
  const CoordinatesPage({super.key});

  @override
  State<CoordinatesPage> createState() => _CoordinatesPageState();
}

class _CoordinatesPageState extends State<CoordinatesPage> {
  Coordinates _tapped = const Coordinates.axial(1, 1);
  _Selection _selection = _Selection.neighbors;

  Set<Coordinates> get _highlighted => switch (_selection) {
    _Selection.neighbors => _tapped.neighbors.toSet(),
    _Selection.ring => _tapped.ring(2).toSet(),
    _Selection.spiral => _tapped.spiral(2).toSet(),
    _Selection.line => Coordinates.zero.lineTo(_tapped).toSet(),
  };

  @override
  Widget build(BuildContext context) {
    final highlighted = _highlighted;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: SegmentedButton<_Selection>(
            segments: const [
              ButtonSegment(
                value: _Selection.neighbors,
                label: Text('neighbors'),
              ),
              ButtonSegment(value: _Selection.ring, label: Text('ring(2)')),
              ButtonSegment(value: _Selection.spiral, label: Text('spiral(2)')),
              ButtonSegment(value: _Selection.line, label: Text('lineTo')),
            ],
            selected: {_selection},
            onSelectionChanged: (selection) =>
                setState(() => _selection = selection.first),
          ),
        ),
        Text('Tapped: ${_tapped.q}, ${_tapped.r}'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: HexagonGrid.pointy(
              depth: 4,
              buildTile: (coordinates) => HexagonWidgetBuilder(
                padding: 2,
                cornerRadius: 6,
                color: coordinates == _tapped
                    ? Colors.deepOrange
                    : highlighted.contains(coordinates)
                    ? Colors.amber
                    : Colors.blueGrey.shade100,
              ),
              buildChild: (coordinates) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _tapped = coordinates),
                child: Center(
                  child: Text(
                    '${coordinates.q},${coordinates.r}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
