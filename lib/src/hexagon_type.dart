import 'dart:math';
import 'dart:ui';

extension RectExtension on Rect {
  double get diagonalLength {
    return sqrt(pow(this.width, 2) + pow(this.height, 2));
  }

  void printData() {
    print('rect:\n'
        'width: $width\n'
        'height: $height\n'
        'diagonal: $diagonalLength\n'
        'ration: ${width / height}\n');
  }
}

///Enum for hexagon "orientation".
enum HexagonType {
  flat,
  pointy,
  ;

  static double _ratioPointy = (sqrt(3) / 2);
  static double _ratioFlat = 1 / _ratioPointy;

  double getHeight(double size) {
    if (isFlat) {
      return size * HexagonType._sqrt3;
    }
    return size * 2;
  }

  double get ratio {
    if (isFlat) {
      return _ratioFlat;
    }
    return _ratioPointy;
  }

  static double _sqrt3 = sqrt(3);
  static double sqrt3 = _sqrt3;



  double calculateHexagonSide(double width, double height) {
    // Calculate the diagonal of the rectangle
    double diagonal = sqrt(pow(width, 2) + pow(height, 2));

    // Calculate side length constraints
    double sFromWidth = width / 2;
    double sFromHeight = height / sqrt(3);
    double sFromDiagonal = diagonal / 2;

    // Return the maximum of the three constraints
    return max(sFromWidth, max(sFromHeight, sFromDiagonal));
  }

  double sideSizeFromRect(Rect rect) {
    rect.printData();

    //find rect ratio
    double rectRatio = rect.width / rect.height;
    double hexRectRatio = 1 / 2;

    final _flatSizeToHeight = 1 / _sqrt3;
    print('rectRatio: $rectRatio vs _flatSizeToHeight: $_flatSizeToHeight');
    double rectDiagonal = rect.diagonalLength;

    if (isFlat) {
      print('rect: ${rect.width}x${rect.height}');
      print('diagonal $rectDiagonal vs ${rect.width * 2}');
      double hexHeight = rect.height;
      double assumedSize = hexHeight * _flatSizeToHeight;
      print('assumed size: $assumedSize');
      return assumedSize;

      if (rectRatio <= _flatSizeToHeight) {
        return assumedSize;
      } else if (assumedSize < rect.width) {
        var diff = assumedSize - rect.width;
        var sizeRatio = assumedSize / rect.width;
        //tutaj rect ma jakies bardzo konkretne ratio które musi sie dac przelozyc na przekatna
        print('diff: $diff');
        print('sizeRatio: $sizeRatio');
        double hexHeight = rect.height * 1.25;
        assumedSize = hexHeight * _flatSizeToHeight;

        return assumedSize;
      } else {
        return assumedSize;
      }

      var rectToFlat = rectRatio / _flatSizeToHeight;
      var flatToRect = _flatSizeToHeight / rectRatio;

      print('rectToFlat: $rectToFlat');
      print('flatToRect: $flatToRect');

      var e = rectRatio * HexagonType._sqrt3;
      print('flat size * recRat: ${e}');

      return assumedSize * e;

      //.....
      //.../|
      //../.|
      //./..|
      //.\..|
      //..\.|
      //...\|
      //= 1/2s

      var assumedWidth = rect.width; // * (_flatSizeToHeight);
      print('assumedWidth $assumedWidth');

      var widthRatio = rect.width / assumedWidth;
      print('widthRatio: $widthRatio');

      var assumedHeight = assumedWidth * _flatSizeToHeight;
      print('assumedHeight: $assumedHeight');
      var d = rect.height * assumedHeight;
      print('heigt/assumedHeigt ratio');

      print('return: ${assumedWidth * d}');

      return rect.width;
      return assumedWidth * d;

      return rectDiagonal / 2;

      if (rectDiagonal > rect.width * 2) {
        return rectDiagonal / 2;
      }
      print('--------------------\n');

      if (rect.width <= rect.height) {
        return rect.width;
      }

      if (rectRatio > _flatSizeToHeight) {
        return rectDiagonal / 2 * (ratio);
      } else {
        return rectDiagonal / 2;
      }
      // if (rect.width >= rect.height) {
      print('return width/ sqrt(3)');
      return rectDiagonal / 2 * (ratio);
      // }
    }

    return (_sqrt3 * rectDiagonal) / 2;

    double rectangleArea = rect.width * rect.height;
    print("Rectangle area: ${rectangleArea}");

    double circumradius = rectangleArea /
        (3 *
            sqrt(3) *
            sqrt(rect.width * rect.width + rect.height * rect.height));
    print("Circumradius: ${circumradius}");

    double hexagonSide = 2 * circumradius * sin((60 * pi) / 180);
    print("Hexagon side: ${hexagonSide}");

    return hexagonSide;

    if (isFlat) {
      print('ratio: $ratio');
      if (rectRatio > ratio) {
        print('return width * somthing');
        return rect.width;
      } else {
        print('return width');
        return rect.width;
      }
      return rect.width / ratio;
    }
    return rect.height / ratio;
  }

  bool get isPointy => this == HexagonType.pointy;

  bool get isFlat => this == HexagonType.flat;

  @Deprecated('unused')
  double flatFactor([bool inBounds = true]) =>
      (isFlat && inBounds == false) ? 0.75 : 1;

  @Deprecated('unused')
  double pointyFactor([bool inBounds = true]) =>
      (isPointy && inBounds == false) ? 0.75 : 1;
}
