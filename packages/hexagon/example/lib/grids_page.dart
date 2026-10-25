import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';

enum _Shape { hexagon, rectangle, parallelogram, triangle }

/// `HexGrid` with the built-in `HexShape`s. Tap cells to select them.
class GridsPage extends StatefulWidget {
  const GridsPage({super.key});

  @override
  State<GridsPage> createState() => _GridsPageState();
}

class _GridsPageState extends State<GridsPage> {
  _Shape _shape = _Shape.hexagon;
  HexagonType _type = HexagonType.flat;
  double _spacing = 4;
  int _size = 3;
  HexTrianglePointing _pointing = HexTrianglePointing.up;
  bool _hollow = false;
  final Set<Hex> _selected = {};

  List<Hex> get _cells {
    if (_shape == _Shape.triangle) {
      return HexShape.triangle(
        _size * 2 + 1,
        type: _type,
        pointing: _pointing,
        hollow: _hollow,
      );
    }
    final cells = switch (_shape) {
      _Shape.hexagon => HexShape.hexagon(_size),
      _Shape.rectangle =>
        HexShape.rectangle(_size * 2 + 1, _size + 2, type: _type),
      _Shape.parallelogram => HexShape.parallelogram(_size + 2, _size + 1),
      _Shape.triangle => const <Hex>[],
    };
    return _hollow ? HexShape.outline(cells) : cells;
  }

  void _toggle(Hex hex) => setState(() {
        if (!_selected.remove(hex)) {
          _selected.add(hex);
        }
      });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<_Shape>(
                segments: [
                  for (final shape in _Shape.values)
                    ButtonSegment(value: shape, label: Text(shape.name)),
                ],
                selected: {_shape},
                onSelectionChanged: (value) => setState(() {
                  _shape = value.single;
                  _selected.clear();
                }),
              ),
              SegmentedButton<HexagonType>(
                segments: const [
                  ButtonSegment(value: HexagonType.flat, label: Text('flat')),
                  ButtonSegment(
                    value: HexagonType.pointy,
                    label: Text('pointy'),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (value) => setState(() {
                  _type = value.single;
                  _selected.clear();
                }),
              ),
              if (_shape == _Shape.triangle)
                SegmentedButton<HexTrianglePointing>(
                  segments: const [
                    ButtonSegment(
                      value: HexTrianglePointing.up,
                      icon: Icon(Icons.arrow_upward),
                      tooltip: 'Points up, resting on its base',
                    ),
                    ButtonSegment(
                      value: HexTrianglePointing.down,
                      icon: Icon(Icons.arrow_downward),
                      tooltip: 'Points down',
                    ),
                    ButtonSegment(
                      value: HexTrianglePointing.left,
                      icon: Icon(Icons.arrow_back),
                      tooltip: 'Points left',
                    ),
                    ButtonSegment(
                      value: HexTrianglePointing.right,
                      icon: Icon(Icons.arrow_forward),
                      tooltip: 'Points right',
                    ),
                  ],
                  selected: {_pointing},
                  onSelectionChanged: (value) => setState(() {
                    _pointing = value.single;
                    _selected.clear();
                  }),
                ),
              FilterChip(
                label: const Text('hollow'),
                selected: _hollow,
                onSelected: (value) => setState(() {
                  _hollow = value;
                  _selected.clear();
                }),
              ),
              SizedBox(
                width: 220,
                child: Row(
                  children: [
                    const Text('size'),
                    Expanded(
                      child: Slider(
                        value: _size.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: '$_size',
                        onChanged: (value) => setState(() {
                          _size = value.round();
                          _selected.clear();
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 220,
                child: Row(
                  children: [
                    const Text('spacing'),
                    Expanded(
                      child: Slider(
                        value: _spacing,
                        max: 16,
                        onChanged: (value) => setState(() => _spacing = value),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: HexGrid(
              cells: _cells,
              type: _type,
              spacing: _spacing,
              onHexTap: _toggle,
              itemBuilder: (context, hex) {
                final selected = _selected.contains(hex);
                return Hexagon(
                  type: _type,
                  color: selected ? colors.primary : colors.primaryContainer,
                  elevation: selected ? 4 : 0,
                  child: FittedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        '${hex.q}, ${hex.r}',
                        style: TextStyle(
                          color: selected
                              ? colors.onPrimary
                              : colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
