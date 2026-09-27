import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';

/// `SliverHexGrid` inside a `CustomScrollView`: a horizontal zigzag strip and
/// an endless, lazily built honeycomb.
class ScrollingPage extends StatefulWidget {
  const ScrollingPage({super.key});

  @override
  State<ScrollingPage> createState() => _ScrollingPageState();
}

class _ScrollingPageState extends State<ScrollingPage> {
  HexagonType _type = HexagonType.pointy;
  double _maxExtent = 90;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 120,
          flexibleSpace: const FlexibleSpaceBar(
            title: Text('SliverHexGrid'),
          ),
          actions: [
            SegmentedButton<HexagonType>(
              segments: const [
                ButtonSegment(value: HexagonType.pointy, label: Text('pointy')),
                ButtonSegment(value: HexagonType.flat, label: Text('flat')),
              ],
              selected: {_type},
              onSelectionChanged: (value) =>
                  setState(() => _type = value.single),
            ),
            const SizedBox(width: 8),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child:
                Text('A strip: one line of hexagons', style: text.titleMedium),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 110,
            child: CustomScrollView(
              scrollDirection: Axis.horizontal,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverHexGrid.builder(
                    gridDelegate: const SliverHexGridDelegate.count(
                      crossAxisCount: 2,
                      type: HexagonType.flat,
                      spacing: 3,
                    ),
                    itemCount: 60,
                    itemBuilder: (context, index) => Hexagon(
                      color: index.isEven
                          ? colors.tertiaryContainer
                          : colors.secondaryContainer,
                      onTap: () {},
                      child: Text('$index'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'An endless honeycomb, built as you scroll',
                    style: text.titleMedium,
                  ),
                ),
                const Text('max size'),
                SizedBox(
                  width: 160,
                  child: Slider(
                    value: _maxExtent,
                    min: 40,
                    max: 200,
                    onChanged: (value) => setState(() => _maxExtent = value),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverHexGrid.builder(
            gridDelegate: SliverHexGridDelegate.extent(
              maxCellExtent: _maxExtent,
              type: _type,
              spacing: 4,
            ),
            itemBuilder: (context, index) => Hexagon(
              type: _type,
              color:
                  HSLColor.fromAHSL(1, (index * 17) % 360, 0.55, 0.6).toColor(),
              cornerRadius: 4,
              onTap: () => ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text('Hexagon $index'))),
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text('$index'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
