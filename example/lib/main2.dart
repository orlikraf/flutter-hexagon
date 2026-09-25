import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import 'hex_table_cell_builder_delegate.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return HexagonalTableView();
  }
}

class HexagonalTableView extends StatelessWidget {
  const HexagonalTableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TableView(
        delegate:
            HexagonTableCellBuilderDelegate(
              builder: (context, vicinity) {
                return Container(
                  // color: Colors.red,
                  child: Text('Cell ${vicinity.xIndex}, ${vicinity.yIndex}'),
                );
              },
            ),
        //     TableCellBuilderDelegate(
        //   cellBuilder: (context, vicinity) {
        //     return TableViewCell(
        //       child: Container(
        //         color: (vicinity.column % 2 == 0)
        //             ? Colors.red
        //             : (vicinity.row % 2 == 0)
        //                 ? Colors.green
        //                 : Colors.blue,
        //         child: Text('Cell ${vicinity.column}, ${vicinity.row}'),
        //       ),
        //     );
        //   },
        //   rowCount: 50,
        //   columnCount: 50,
        //   pinnedRowCount: 1,
        //   columnBuilder: (int index) {
        //     return TableSpan(
        //       padding: const TableSpanPadding(
        //         leading: 10,
        //         trailing: 10,
        //       ),
        //       backgroundDecoration: SpanDecoration(
        //         color: Colors.grey,
        //       ),
        //       extent: FixedSpanExtent(100),
        //     );
        //   },
        //   rowBuilder: (int index) {
        //     return TableSpan(
        //       extent: FixedSpanExtent(100),
        //       padding: TableSpanPadding(
        //         trailing: index == 0 ? 10 : 0,
        //       ),
        //     );
        //   },
        // ),
      ),
    );
  }
}

class _HexagonalNode extends StatelessWidget {
  final Widget child;

  const _HexagonalNode({required this.child});

  @override
  Widget build(BuildContext context) {
    // Wrap node in a hexagonal container
    return ClipPath(
      clipper: HexagonClipper(),
      child: child,
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(width / 2, 0);
    path.lineTo(width, height / 4);
    path.lineTo(width, 3 * height / 4);
    path.lineTo(width / 2, height);
    path.lineTo(0, 3 * height / 4);
    path.lineTo(0, height / 4);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
