import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';

/// Single hexagons: sized by width or height, with images, and with and
/// without clipping.
class WidgetsPage extends StatelessWidget {
  const WidgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const padding = 8.0;
    const height = 150.0;
    final width = (MediaQuery.sizeOf(context).width - 4 * padding) / 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(padding),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 2 * padding,
        runSpacing: 2 * padding,
        children: [
          HexagonWidget.flat(
            width: width,
            child: AspectRatio(
              aspectRatio: HexagonType.flat.ratio,
              child: Image.asset('assets/bee.jpg', fit: BoxFit.fitHeight),
            ),
          ),
          HexagonWidget.pointy(
            width: width,
            child: AspectRatio(
              aspectRatio: HexagonType.pointy.ratio,
              child: Image.asset('assets/tram.jpg', fit: BoxFit.fitWidth),
            ),
          ),
          const HexagonWidget.flat(
            height: height,
            color: Colors.orangeAccent,
            child: Text('flat\nheight: 150'),
          ),
          const HexagonWidget.pointy(
            height: height,
            color: Colors.red,
            cornerRadius: 16,
            child: Text('pointy\nrounded corners'),
          ),
          HexagonWidget.flat(
            width: width,
            color: Colors.limeAccent,
            elevation: 8,
            child: const Text('flat\nelevation: 8'),
          ),
          HexagonWidget.pointy(
            width: width,
            color: Colors.lightBlue,
            clipBehavior: Clip.none,
            child: const Text(
              'pointy\nClip.none: this text is wider than the hexagon',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
