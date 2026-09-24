import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';

/// [HexagonBorder] on Material widgets, with an outline and animated
/// corners.
class BorderPage extends StatefulWidget {
  const BorderPage({super.key});

  @override
  State<BorderPage> createState() => _BorderPageState();
}

class _BorderPageState extends State<BorderPage> {
  HexagonType _type = HexagonType.pointy;
  double _cornerRadius = 12;
  double _outline = 3;

  HexagonBorder get _border => HexagonBorder(
    type: _type,
    cornerRadius: _cornerRadius,
    side: BorderSide(color: Colors.white, width: _outline),
  );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: SegmentedButton<HexagonType>(
            segments: const [
              ButtonSegment(value: HexagonType.flat, label: Text('Flat')),
              ButtonSegment(value: HexagonType.pointy, label: Text('Pointy')),
            ],
            selected: {_type},
            onSelectionChanged: (selection) =>
                setState(() => _type = selection.first),
          ),
        ),
        Text('Corner radius: ${_cornerRadius.round()}'),
        Slider(
          value: _cornerRadius,
          max: 60,
          onChanged: (value) => setState(() => _cornerRadius = value),
        ),
        Text('Outline: ${_outline.round()}'),
        Slider(
          value: _outline,
          max: 12,
          onChanged: (value) => setState(() => _outline = value),
        ),
        const SizedBox(height: 16),
        Center(
          child: Material(
            color: Colors.teal,
            shape: _border,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tapped inside the hexagon')),
              ),
              child: const SizedBox(
                width: 200,
                height: 200,
                child: Center(
                  child: Text(
                    'Material + InkWell',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 160,
            height: 160,
            decoration: ShapeDecoration(color: Colors.indigo, shape: _border),
            child: const Center(
              child: Text(
                'ShapeDecoration',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
