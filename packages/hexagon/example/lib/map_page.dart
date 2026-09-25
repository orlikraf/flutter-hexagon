import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';

enum Terrain {
  water(Color(0xFF3F7FD0), null),
  grass(Color(0xFF8BC34A), 1),
  forest(Color(0xFF2E7D32), 2, blocksSight: true),
  hills(Color(0xFFBCAAA4), 3),
  mountain(Color(0xFF6D4C41), null, blocksSight: true);

  const Terrain(this.color, this.cost, {this.blocksSight = false});

  final Color color;

  /// Movement cost to enter, null if impassable.
  final double? cost;

  final bool blocksSight;
}

class Unit {
  const Unit(this.name, this.icon, this.color, {this.movement = 5});

  final String name;
  final IconData icon;
  final Color color;
  final double movement;
}

/// Builds a deterministic island-ish map from a few overlapping waves.
HexMap<Terrain> generateMap(int columns, int rows) {
  final random = math.Random(7);
  final phases = [for (var i = 0; i < 6; i++) random.nextDouble() * math.pi * 2];
  return HexMap.fromCells(HexShape.rectangle(columns, rows), (hex) {
    final offset = hex.toOffset(HexagonType.flat);
    final x = offset.column / columns;
    final y = offset.row / rows;
    final edge = math.min(math.min(x, 1 - x), math.min(y, 1 - y));
    final height = 0.35 * math.sin(x * 9 + phases[0]) +
        0.35 * math.sin(y * 7 + phases[1]) +
        0.25 * math.sin((x + y) * 13 + phases[2]) +
        0.15 * math.sin((x - y) * 23 + phases[3]) +
        math.min(edge * 6, 1) -
        0.35;
    if (height < 0) return Terrain.water;
    if (height < 0.35) return Terrain.grass;
    if (height < 0.6) return Terrain.forest;
    if (height < 0.8) return Terrain.hills;
    return Terrain.mountain;
  });
}

/// A small strategy map: pan, zoom, select a unit to see where it can move
/// and what it can see, hover or tap a hex to plan a path, tap again to move.
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const _layout = HexLayout.flat(radius: 22, spacing: 1);

  final HexMap<Terrain> _terrain = generateMap(48, 36);
  late final Set<Hex> _cells = _terrain.cells.toSet();
  final HexGridController _controller = HexGridController();
  late final Map<Hex, Unit> _units = _placeUnits();

  Hex? _selected;
  Map<Hex, double> _reach = const {};
  Set<Hex> _reachCells = const {};
  List<Hex> _path = const [];
  Set<Hex> _vision = const {};
  bool _showVision = true;

  Map<Hex, Unit> _placeUnits() {
    const units = [
      Unit('Scout', Icons.directions_run, Colors.orange, movement: 7),
      Unit('Knight', Icons.shield, Colors.indigo),
      Unit('Archer', Icons.gps_fixed, Colors.pink, movement: 4),
    ];
    final land = _terrain.where((hex, t) => t == Terrain.grass).toList();
    final center = HexShape.rectangle(48, 36)[48 * 18 + 24];
    land.sort((a, b) => a.distanceTo(center).compareTo(b.distanceTo(center)));
    return {
      for (var i = 0; i < units.length && i * 5 < land.length; i++)
        land[i * 5]: units[i],
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _passable(Hex hex) =>
      _terrain[hex]?.cost != null && !_units.containsKey(hex);

  double? _cost(Hex from, Hex to) => _terrain[to]?.cost;

  bool _blocksSight(Hex hex) => _terrain[hex]?.blocksSight ?? true;

  void _select(Hex? hex) {
    _selected = hex;
    _path = const [];
    final unit = hex == null ? null : _units[hex];
    if (hex == null || unit == null) {
      _reach = const {};
      _reachCells = const {};
      _vision = const {};
      return;
    }
    _reach = hex.reachable(
      movement: unit.movement,
      passable: _passable,
      cost: _cost,
    );
    _reachCells = _reach.keys.toSet()..remove(hex);
    _vision = hex.fieldOfView(8, blocksSight: _blocksSight);
  }

  void _onTap(Hex hex) {
    setState(() {
      final selected = _selected;
      if (_units.containsKey(hex)) {
        _select(hex == selected ? null : hex);
      } else if (selected != null && _reachCells.contains(hex)) {
        _units[hex] = _units.remove(selected)!;
        _select(hex);
      } else {
        _select(null);
      }
    });
  }

  void _onHover(Hex? hex) {
    final selected = _selected;
    if (selected == null) return;
    setState(() {
      _path = hex != null && _reachCells.contains(hex)
          ? selected.pathTo(hex, passable: _passable, cost: _cost) ?? const []
          : const [];
    });
  }

  void _paintPath(Canvas canvas, HexCell cell) {
    final index = _path.indexOf(cell.hex);
    canvas.drawCircle(
      cell.center,
      index == _path.length - 1 ? 8 : 4,
      Paint()..color = Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedUnit = _selected == null ? null : _units[_selected];
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: Terrain.water.color,
            child: HexGridView(
              layout: _layout,
              cells: _cells,
              controller: _controller,
              initialCenter: _units.keys.first,
              minScale: 0.3,
              maxScale: 4,
              onHexTap: _onTap,
              onHexHover: _onHover,
              layers: [
                HexPaintLayer.fill(
                  colorOf: (hex) => _terrain[hex]!.color,
                  cornerRadius: 3,
                ),
                HexPaintLayer.fill(
                  cells: _reachCells,
                  color: Colors.white.withValues(alpha: 0.35),
                  strokeColor: Colors.white,
                  cornerRadius: 3,
                ),
                if (_showVision && _selected != null)
                  HexPaintLayer.fill(
                    colorOf: (hex) => _vision.contains(hex)
                        ? null
                        : Colors.black.withValues(alpha: 0.45),
                  ),
                HexPaintLayer(cells: _path, painter: _paintPath),
                HexWidgetLayer(
                  cells: _units.keys.toSet(),
                  builder: (context, hex) => _UnitToken(
                    unit: _units[hex]!,
                    selected: hex == _selected,
                    onTap: () => _onTap(hex),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          top: 16,
          right: 16,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedUnit == null
                          ? 'Tap a unit to select it.'
                          : '${selectedUnit.name}: ${_reachCells.length} hexes '
                              'in reach. Hover or tap one to move.',
                    ),
                  ),
                  const Text('Vision'),
                  Switch(
                    value: _showVision,
                    onChanged: (value) => setState(() => _showVision = value),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'zoom-in',
                shape: const HexagonBorder(),
                onPressed: () => _zoom(1.5),
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'zoom-out',
                shape: const HexagonBorder(),
                onPressed: () => _zoom(1 / 1.5),
                child: const Icon(Icons.remove),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'center',
                shape: const HexagonBorder(),
                onPressed: () => _controller.animateTo(
                  _selected ?? _units.keys.first,
                ),
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _zoom(double factor) {
    final center = _controller.centerHex ?? _units.keys.first;
    _controller.animateTo(center, scale: _controller.scale * factor);
  }
}

class _UnitToken extends StatelessWidget {
  const _UnitToken({
    required this.unit,
    required this.selected,
    required this.onTap,
  });

  final Unit unit;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: AnimatedScale(
        scale: selected ? 1.15 : 1,
        duration: const Duration(milliseconds: 200),
        child: Hexagon(
          color: unit.color,
          elevation: selected ? 8 : 3,
          side: selected
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
          onTap: onTap,
          child: Tooltip(
            message: unit.name,
            child: Icon(unit.icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}
