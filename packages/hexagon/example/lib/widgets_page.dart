import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';

/// `Hexagon` and `HexagonBorder` in everyday UI.
class WidgetsPage extends StatefulWidget {
  const WidgetsPage({super.key});

  @override
  State<WidgetsPage> createState() => _WidgetsPageState();
}

class _WidgetsPageState extends State<WidgetsPage> {
  bool _rounded = false;

  void _say(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _Section('Flat and pointy, tappable inside the outline only'),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            Hexagon(
              width: 120,
              color: colors.primaryContainer,
              onTap: () => _say('Flat tapped'),
              child: const Icon(Icons.hive, size: 40),
            ),
            Hexagon.pointy(
              width: 104,
              color: colors.tertiaryContainer,
              elevation: 6,
              onTap: () => _say('Pointy tapped'),
              child: const Icon(Icons.emoji_nature, size: 40),
            ),
            Hexagon(
              width: 120,
              cornerRadius: 16,
              color: colors.secondaryContainer,
              side: BorderSide(color: colors.secondary, width: 3),
              child: const Text('Rounded\nwith outline', textAlign: TextAlign.center),
            ),
          ],
        ),
        const _Section('Images fill the hexagon with HexagonChildArea.bounds'),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            Hexagon(
              width: 160,
              childArea: HexagonChildArea.bounds,
              child: Image.asset('assets/bee.jpg', fit: BoxFit.cover),
            ),
            Hexagon.pointy(
              width: 140,
              childArea: HexagonChildArea.bounds,
              cornerRadius: 12,
              child: Image.asset('assets/tram.jpg', fit: BoxFit.cover),
            ),
          ],
        ),
        const _Section('HexagonFit.wrap sizes the hexagon around its child'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final label in ['A', 'Chip', 'A longer label'])
              Hexagon(
                fit: HexagonFit.wrap,
                color: colors.surfaceContainerHigh,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(label),
                ),
              ),
          ],
        ),
        const _Section('HexagonBorder works with any Material shape'),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 104,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const HexagonBorder(cornerRadius: 8),
                ),
                onPressed: () => _say('Button pressed'),
                child: const Text('Button'),
              ),
            ),
            const SizedBox(
              width: 120,
              height: 104,
              child: Card(
                shape: HexagonBorder(),
                elevation: 4,
                child: Center(child: Text('Card')),
              ),
            ),
            FloatingActionButton(
              heroTag: 'hex-fab',
              shape: const HexagonBorder(type: HexagonType.pointy),
              onPressed: () => _say('FAB pressed'),
              child: const Icon(Icons.add),
            ),
          ],
        ),
        const _Section('Borders animate: tap to morph'),
        GestureDetector(
          onTap: () => setState(() => _rounded = !_rounded),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: 200,
              height: 140,
              decoration: ShapeDecoration(
                color: _rounded ? colors.primary : colors.tertiary,
                shape: HexagonBorder(
                  cornerRadius: _rounded ? 40 : 0,
                  eccentricity: _rounded ? 1 : 0,
                  side: BorderSide(
                    color: colors.onSurface,
                    width: _rounded ? 6 : 1,
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

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      );
}
