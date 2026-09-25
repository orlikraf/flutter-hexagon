import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hexagon/hexagon.dart';

bool kDebugFlag = true;

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool showSliver = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Spacer(),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: showSliver == false
                    ? Colors.white.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
              ),
              onPressed: () {
                setState(() => showSliver = false);
              },
              child: Text('single'),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: showSliver
                    ? Colors.white.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
              ),
              onPressed: () {
                setState(() => showSliver = true);
              },
              child: Text('sliver'),
            ),
            const Spacer(),
          ],
        ),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: showSliver
            ? SliverExample()
            : HexWidget(
                size: 500,
                child: Text('0'),
              ),
      ),
    );
  }
}

class SliverExample extends StatelessWidget {
  const SliverExample({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverHexGrid(),
      ],
    );
  }
}

class SliverHexGrid extends StatelessWidget {
  final double hexSize = 100;
  final double gap;

  const SliverHexGrid({this.gap = 0, super.key}); // Size of the hexagons

  Offset _calculateHexPosition(int row, int column) {
    // Hexagon width and height based on the given size
    final double hexWidth = hexSize;
    final double hexHeight =
        hexSize; // * HexagonType.sqrt3 /2; // sqrt(3) * size

    // Offset for odd rows (staggered columns)
    double offsetX =
        column == 0 ? 0 : hexWidth / 2; // Offset only for the odd column

    // Calculate the y-position with staggered rows
    double offsetY = row * hexHeight + gap * row;

    return Offset(offsetX, offsetY);
  }

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          // Calculate the row and column
          int column = index % 2; // 2 columns: 0 for even, 1 for odd
          int row = index ~/ 2; // Dividing by 2 for the 2 rows per index

          // Calculate position using the staggered row method
          final Offset position = _calculateHexPosition(row, column);

          return Transform.translate(
            offset: position, // Translate the hexagon to the correct position
            child: HexWidget(
              size: hexSize,
              child: Text(
                index.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ); // Return hexagon for each index
        },
        childCount: 100, // Total number of hexagons to render
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns
        crossAxisSpacing: gap, // Horizontal gap between columns
        mainAxisSpacing: gap, // Vertical gap between hexagons
      ),
    );
  }
}

class HexWidget extends StatelessWidget {
  final double size;
  final HexagonType type;
  final Widget? child;

  const HexWidget({
    required this.size,
    this.type = HexagonType.flat,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HexPainter(type),
      size: Size(size, size),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(child: child),
      ),
    );
  }
}

class HexPainter extends CustomPainter {
  final HexagonType type;
  final HexagonPathBuilder2 pathBuilder;

  HexPainter(this.type)
      : pathBuilder = HexagonPathBuilder2(
          type,
        );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red;

    var hexSide = size.width / 2;
    var hexHeight = hexSide * HexagonType.sqrt3 / 2;

    if (kDebugFlag) {
      paint.color = Colors.green.withOpacity(0.5);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint,
      );
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        hexSide,
        paint,
      );
    }

    final path = pathBuilder.build(size);

    paint.color = Colors.blue;
    canvas.drawPath(path, paint);

    if (kDebugFlag) {
      paint.color = Colors.red.withOpacity(0.5);
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        hexHeight,
        paint,
      );
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        2,
        paint..color = Colors.black,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class HexSliverChildDelegate extends SliverChildDelegate {
  @override
  int? get estimatedChildCount => 100;

  @override
  Widget? build(BuildContext context, int index) {
    return HexWidget(size: 100);
  }

  @override
  bool shouldRebuild(covariant SliverChildDelegate oldDelegate) {
    return false;
  }
}

class SliverHexGridWidget extends SliverMultiBoxAdaptorWidget {
  const SliverHexGridWidget({
    required super.delegate,
    required this.gridDelegate,
    super.key,
  });
  /// The delegate that controls the size and position of the children.
  final SliverHexGridDelegate gridDelegate;

  @override
  RenderSliverHexGrid createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    return RenderSliverHexGrid(
      childManager: element,
      //todo change
      size: 100,
      type: HexagonType.flat,
      gridDelegate: gridDelegate,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSliverGrid renderObject) {
    renderObject.gridDelegate = gridDelegate;
  }

  @override
  double estimateMaxScrollOffset(
    SliverConstraints? constraints,
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    return super.estimateMaxScrollOffset(
          constraints,
          firstIndex,
          lastIndex,
          leadingScrollOffset,
          trailingScrollOffset,
        ) ??
        gridDelegate
            .getLayout(constraints!)
            .computeMaxScrollOffset(delegate.estimatedChildCount!);
  }
}

class SliverHexGridDelegate extends SliverGridDelegate {
  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    // TODO: implement getLayout
    throw UnimplementedError();
  }

  @override
  bool shouldRelayout(covariant SliverGridDelegate oldDelegate) {
    return false;
  }
  
}

class SliverHexGridLayout extends SliverGridLayout {
  @override
  double computeMaxScrollOffset(int childCount) {
    // TODO: implement computeMaxScrollOffset
    throw UnimplementedError();
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    // TODO: implement getGeometryForChildIndex
    throw UnimplementedError();
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    // TODO: implement getMaxChildIndexForScrollOffset
    throw UnimplementedError();
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    // TODO: implement getMinChildIndexForScrollOffset
    throw UnimplementedError();
  }


}

class RenderSliverHexGrid extends RenderSliverMultiBoxAdaptor {
  final HexagonType type;
  final double size;

  RenderSliverHexGrid({
    required super.childManager,
    required SliverHexGridDelegate gridDelegate,
    required this.type,
    required this.size,
  }) : _gridDelegate = gridDelegate;

  SliverHexGridDelegate get gridDelegate => _gridDelegate;
  SliverHexGridDelegate _gridDelegate;

  set gridDelegate(SliverHexGridDelegate value) {
    if (_gridDelegate == value) {
      return;
    }
    if (value.runtimeType != _gridDelegate.runtimeType ||
        value.shouldRelayout(_gridDelegate)) {
      markNeedsLayout();
    }
    _gridDelegate = value;
  }

  @override
  double childCrossAxisPosition(RenderBox child) {
    final SliverGridParentData childParentData =
        child.parentData! as SliverGridParentData;
    return childParentData.crossAxisOffset!;
  }

  @override
  void performLayout() {
    double currentOffset = constraints.scrollOffset;
    double maxExtent = 0;

    RenderBox? child = firstChild;
    int index = 0;

    while (child != null) {
      // child.layout(
      //   constraints.asBoxConstraints(
      //     minExtent: tileWidth,
      //     maxExtent: tileWidth,
      //   ),
      //   parentUsesSize: true,
      // );

      // // Calculate position
      // final SliverMultiBoxAdaptorParentData childParentData =
      //     child.parentData as SliverMultiBoxAdaptorParentData;
      // final Offset position = _calculateHexTilePosition(index);
      // // Set the layout offset for the vertical axis (dy)
      // childParentData.layoutOffset =
      //     position.dy; // Use the `dy` for vertical position
      //
      // maxExtent = max(maxExtent, position.dy + tileHeight);
      //
      // // Move to the next child
      // child = childAfter(child);
      // index++;
    }

    // geometry = SliverGeometry(
    //   scrollExtent: maxExtent,
    //   paintExtent: constraints.remainingPaintExtent.clamp(0.0, maxExtent),
    //   maxPaintExtent: maxExtent,
    // );
    //
    // removeUnusedChildren(index);
  }

  void removeUnusedChildren(int startIndex) {
    RenderBox? child = firstChild;
    int index = 0;

    while (child != null) {
      // If the current index is greater than the start index, remove the child
      if (index >= startIndex) {
        final RenderBox childToRemove = child;
        child = childAfter(child); // Move to the next child
        childManager.removeChild(childToRemove);
      } else {
        // Move to the next child
        child = childAfter(child);
      }
      index++;
    }
  }

// Offset _calculateHexTilePosition(int index) {
//   final int column = index % _columnsPerRow;
//   final int row = index ~/ _columnsPerRow;
//
//   final double x = column * (tileWidth * 0.75);
//   final double y =
//       row * (tileHeight * 0.5) + (column.isOdd ? tileHeight / 2 : 0);
//
//   return Offset(x, y);
// }
//
// int get _columnsPerRow =>
//     (constraints.crossAxisExtent / (tileWidth * 0.75)).floor();
}
