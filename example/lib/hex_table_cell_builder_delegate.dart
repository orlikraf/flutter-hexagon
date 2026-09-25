import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class HexagonTableCellBuilderDelegate extends TwoDimensionalChildBuilderDelegate
    with TableCellDelegateMixin {
  HexagonTableCellBuilderDelegate({required super.builder});

  @override
  TableSpan? buildColumn(int index) {
    return TableSpan(
      extent: FixedTableSpanExtent(100),
    );
  }

  @override
  TableSpan? buildRow(int index) {
    return TableSpan(
      extent: FixedTableSpanExtent(50),
      backgroundDecoration: HexagonSpanDecoration()
    );
  }

  @override
  int? get columnCount => 50;

  @override
  int? get rowCount => 50;
}



class HexagonSpanDecoration extends SpanDecoration {
  HexagonSpanDecoration({
    Color color = const Color(0xFF000000),
    BorderRadius? borderRadius,
    bool consumeSpanPadding = true,
  }) : super(
    color: color,
    borderRadius: borderRadius,
    consumeSpanPadding: consumeSpanPadding,
  );

  @override
  void paint(SpanDecorationPaintDetails details) {
    if (color != null) {
      final Paint paint = Paint()
        ..color = color!
        ..isAntiAlias = true;

      final Path hexagonPath = Path();
      final double width = details.rect.width;
      final double height = details.rect.height;
      final double sideLength = width / 2;
      final double centerX = details.rect.center.dx;
      final double centerY = details.rect.center.dy;

      hexagonPath.moveTo(centerX, centerY - height / 2);
      hexagonPath.lineTo(centerX + sideLength, centerY - height / 4);
      hexagonPath.lineTo(centerX + sideLength, centerY + height / 4);
      hexagonPath.lineTo(centerX, centerY + height / 2);
      hexagonPath.lineTo(centerX - sideLength, centerY + height / 4);
      hexagonPath.lineTo(centerX - sideLength, centerY - height / 4);
      hexagonPath.close();

      details.canvas.drawPath(hexagonPath, paint);
    }
    if (border != null) {
      border!.paint(details, borderRadius);
    }
  }
}