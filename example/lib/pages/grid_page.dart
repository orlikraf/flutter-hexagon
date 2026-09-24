import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';

/// A hexagon-shaped grid addressed by [Coordinates], with its orientation
/// and depth adjustable.
class GridPage extends StatefulWidget {
  const GridPage({super.key});

  @override
  State<GridPage> createState() => _GridPageState();
}

class _GridPageState extends State<GridPage> {
  HexagonType _type = HexagonType.flat;
  int _depth = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<HexagonType>(
                segments: const [
                  ButtonSegment(value: HexagonType.flat, label: Text('Flat')),
                  ButtonSegment(
                    value: HexagonType.pointy,
                    label: Text('Pointy'),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (selection) =>
                    setState(() => _type = selection.first),
              ),
              DropdownButton<int>(
                value: _depth,
                items: [
                  for (var depth = 0; depth <= 4; depth++)
                    DropdownMenuItem(value: depth, child: Text('Depth $depth')),
                ],
                onChanged: (depth) => setState(() => _depth = depth ?? _depth),
              ),
            ],
          ),
        ),
        Expanded(
          child: InteractiveViewer(
            minScale: 0.2,
            maxScale: 4,
            child: HexagonGrid(
              hexType: _type,
              depth: _depth,
              color: Colors.pink,
              buildTile: (coordinates) => HexagonWidgetBuilder(
                padding: 2,
                cornerRadius: 8,
                child: Text('${coordinates.q}, ${coordinates.r}'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
