import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';
import 'package:hexagon/src/hexagon_path_builder2.dart';

class HexagonWidget2 extends StatelessWidget {
  const HexagonWidget2({
    required this.type,
    this.elevation = 0,
    this.child,
    super.key,
  });

  final HexagonType type;
  final double elevation;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    HexagonPathBuilder2 pathBuilder = HexagonPathBuilder2(
      type,
      // inBounds: true,
      borderRadius: 0,
    );

    return GestureDetector(
      onTap: () {
        print('on Tap hex');
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 0, //type == HexagonType.flat ? 36.0 : 0,
        ),
        child: DecoratedBox(
          position: DecorationPosition.background,
          decoration: HexagonDecoration(
            color: Colors.blue.withOpacity(0.5),
            shape: type,
            inside: false,
            // image: DecorationImage(
            //   image: AssetImage('assets/bee_square.jpg'),
            // ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 0, // 25.0,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class HexagonDecoration extends Decoration {
  const HexagonDecoration({
    this.shape = HexagonType.flat,
    this.border,
    this.color,
    this.borderRadius = 0,
    this.image,
    required this.inside,
  });

  final DecorationImage? image;
  final HexagonType shape;
  final bool inside;
  final Color? color;
  final double borderRadius;
  final HexagonBorder? border;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _HexagonDecorationPainter(
      this,
      onChanged,
      debugCircle: kDebugMode,
    );
  }

  Point<double> _flatHexagonCorner(Offset center, double size, int i) {
    var angleDeg = 60 * i;
    var angleRad = pi / 180 * angleDeg;
    return Point(
        center.dx + size * cos(angleRad), center.dy + size * sin(angleRad));
  }

  Point<double> _pointyHexagonCorner(Offset center, double size, int i) {
    var angleDeg = 60 * i - 30;
    var angleRad = pi / 180 * angleDeg;
    return Point(
        center.dx + size * cos(angleRad), center.dy + size * sin(angleRad));
  }

  /// Calculates hexagon corners for given size and center.
  List<Point<double>> _flatHexagonCornerList(Offset center, double size) =>
      List<Point<double>>.generate(
        6,
        (index) => _flatHexagonCorner(center, size, index),
        growable: false,
      );

  /// Calculates hexagon corners for given size and center.
  List<Point<double>> _pointyHexagonCornerList(Offset center, double size) =>
      List<Point<double>>.generate(
        6,
        (index) => _pointyHexagonCorner(center, size, index),
        growable: false,
      );

  Point<double> _pointBetween(
    Point<double> start,
    Point<double> end, {
    double? distance,
    double? fraction,
  }) {
    double xLength = end.x - start.x;
    double yLength = end.y - start.y;
    if (fraction == null) {
      if (distance == null) {
        throw Exception('Distance or fraction should be specified.');
      }
      double length = sqrt(xLength * xLength + yLength * yLength);
      fraction = distance / length;
    }
    return Point(start.x + xLength * fraction, start.y + yLength * fraction);
  }

  Point<double> _radiusStart(
    Point<double> corner,
    int index,
    List<Point<double>> cornerList,
    double radius,
  ) {
    var prevCorner =
        index > 0 ? cornerList[index - 1] : cornerList[cornerList.length - 1];
    double distance = radius * tan(pi / 6);
    return _pointBetween(corner, prevCorner, distance: distance);
  }

  Point<double> _radiusEnd(
    Point<double> corner,
    int index,
    List<Point<double>> cornerList,
    double radius,
  ) {
    var nextCorner =
        index < cornerList.length - 1 ? cornerList[index + 1] : cornerList[0];
    double distance = radius * tan(pi / 6);
    return _pointBetween(corner, nextCorner, distance: distance);
  }

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    List<Point<double>> cornerList;
    final Offset center = rect.center;

    final scaleFactor = 1; // (inside ? 0.5 : 0.8);

    final sideSizeFromRect = shape.calculateHexagonSide(rect.width, rect.height);
    print('clipRect, sideSize: $sideSizeFromRect');
    print('clipRect, rect: ${rect.width * scaleFactor}');
    print('clipRect, rect: ${rect.height * scaleFactor}');

    switch (shape) {
      case HexagonType.flat:
        cornerList = _flatHexagonCornerList(center, sideSizeFromRect);
      case HexagonType.pointy:
        cornerList =
            _pointyHexagonCornerList(center, rect.height * scaleFactor);
    }

    final path = Path();
    if (borderRadius > 0) {
      Point<double> rStart;
      Point<double> rEnd;
      cornerList.asMap().forEach((index, point) {
        rStart = _radiusStart(point, index, cornerList, borderRadius);
        rEnd = _radiusEnd(point, index, cornerList, borderRadius);
        if (index == 0) {
          path.moveTo(rStart.x, rStart.y);
        } else {
          path.lineTo(rStart.x, rStart.y);
        }
        // rough approximation of an circular arc for 120 deg angle.
        Point<double> control1 = _pointBetween(rStart, point, fraction: 0.7698);
        Point<double> control2 = _pointBetween(rEnd, point, fraction: 0.7698);
        path.cubicTo(
          control1.x,
          control1.y,
          control2.x,
          control2.y,
          rEnd.x,
          rEnd.y,
        );
      });
    } else {
      cornerList.asMap().forEach((index, point) {
        if (index == 0) {
          path.moveTo(point.x, point.y);
        } else {
          path.lineTo(point.x, point.y);
        }
      });
    }

    return path..close();
  }

  @override
  bool get isComplex => false; // boxShadow != null;

// @override
// bool hitTest(Size size, Offset position, { TextDirection? textDirection }) {
//   assert((Offset.zero & size).contains(position));
//   switch (shape) {
//     case BoxShape.rectangle:
//       if (borderRadius != null) {
//         final RRect bounds = borderRadius!.resolve(textDirection).toRRect(Offset.zero & size);
//         return bounds.contains(position);
//       }
//       return true;
//     case BoxShape.circle:
//     // Circles are inscribed into our smallest dimension.
//       final Offset center = size.center(Offset.zero);
//       final double distance = (position - center).distance;
//       return distance <= math.min(size.width, size.height) / 2.0;
//   }
// }

// /// Returns a new box decoration that is scaled by the given factor.
// BoxDecoration scale(double factor) {
//   return BoxDecoration(
//     color: Color.lerp(null, color, factor),
//     image: DecorationImage.lerp(null, image, factor),
//     border: BoxBorder.lerp(null, border, factor),
//     borderRadius: BorderRadiusGeometry.lerp(null, borderRadius, factor),
//     boxShadow: BoxShadow.lerpList(null, boxShadow, factor),
//     gradient: gradient?.scale(factor),
//     shape: shape,
//   );
// }
}

class _HexagonDecorationPainter extends BoxPainter {
  _HexagonDecorationPainter(
    this._decoration,
    VoidCallback? onChanged, {
    this.debugCircle = false,
  }) : super(onChanged);

  final HexagonDecoration _decoration;
  final bool debugCircle;

  void _paintBox(
    Canvas canvas,
    Rect rect,
    Paint paint,
    TextDirection? textDirection,
  ) {
    // print('painting - size: $size');
    Path path =
        _decoration.getClipPath(rect, textDirection ?? TextDirection.ltr);

    if (debugCircle) {
      // double radius = max(path.getBounds().width, path.getBounds().height) / 2;
      double radius = rect.diagonalLength / 2;
      Offset center = rect.center;
      paint.color = Colors.red.withOpacity(0.2);
      canvas.drawCircle(center, radius, paint);
    }

    paint.color = _decoration.color ?? Colors.white;
    paint.isAntiAlias = true;
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
    // switch (_decoration.shape) {
    //   case BoxShape.circle:
    //     assert(_decoration.borderRadius == null);
    //     final Offset center = rect.center;
    //     final double radius = rect.shortestSide / 2.0;
    //     canvas.drawCircle(center, radius, paint);
    //   case BoxShape.rectangle:
    //     if (_decoration.borderRadius == null || _decoration.borderRadius == BorderRadius.zero) {
    //       canvas.drawRect(rect, paint);
    //     } else {
    //       canvas.drawRRect(_decoration.borderRadius!.resolve(textDirection).toRRect(rect), paint);
    //     }
    // }
  }

  void _paintShadows(Canvas canvas, Rect rect) {
    // if (_decoration.boxShadow == null) {
    //   return;
    // }
    // for (final BoxShadow boxShadow in _decoration.boxShadow!) {
    //   final Paint paint = boxShadow.toPaint();
    //   final Rect bounds = rect.shift(boxShadow.offset).inflate(boxShadow.spreadRadius);
    //   _paintBox(canvas, bounds, paint, textDirection);
    // }
  }

  void _paintBackgroundColor(Canvas canvas, Rect rect) {
    // if (_decoration.color != null || _decoration.gradient != null) {
    //   _paintBox(canvas, rect, _getBackgroundPaint(rect, textDirection), textDirection);
    // }
    if (_decoration.color != null) {
      _paintBox(canvas, rect, Paint(), null);
    }
  }

  DecorationImagePainter? _imagePainter;

  void _paintBackgroundImage(
    Canvas canvas,
    Rect rect,
    ImageConfiguration configuration,
  ) {
    if (_decoration.image == null) {
      return;
    }
    _imagePainter ??= _createImagePainter(onChanged!);
    Path? clipPath = _decoration.getClipPath(rect, TextDirection.ltr);
    // switch (_decoration.shape) {
    //   case BoxShape.circle:
    //     assert(_decoration.borderRadius == null);
    //     final Offset center = rect.center;
    //     final double radius = rect.shortestSide / 2.0;
    //     final Rect square = Rect.fromCircle(center: center, radius: radius);
    //     clipPath = Path()..addOval(square);
    //   case BoxShape.rectangle:
    //     if (_decoration.borderRadius != null) {
    //       clipPath = Path()..addRRect(_decoration.borderRadius!.resolve(configuration.textDirection).toRRect(rect));
    //     }
    // }
    _imagePainter!.paint(canvas, rect, clipPath, configuration);
  }

  DecorationImagePainter _createImagePainter(onChanged) {
    return _HexDecorationImagePainter._(
      _decoration.image!,
      _decoration.shape,
      onChanged,
    );
  }

  @override
  void dispose() {
    _imagePainter?.dispose();
    super.dispose();
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size!;
    _paintShadows(canvas, rect);
    _paintBackgroundColor(canvas, rect);
    _paintBackgroundImage(canvas, rect, configuration);

    _decoration.border?.paint(
      canvas,
      rect,
      configuration,
      shape: _decoration.shape,
      borderRadius: _decoration.borderRadius,
    );
  }
}

class HexagonBorder {
  void paint(
    Canvas canvas,
    Rect rect,
    ImageConfiguration configuration, {
    required HexagonType shape,
    required double borderRadius,
  }) {
    //todo
  }
}

class _HexDecorationImagePainter implements DecorationImagePainter {
  _HexDecorationImagePainter._(this._details, this._shape, this._onChanged);

  final DecorationImage _details;
  final HexagonType _shape;
  final VoidCallback _onChanged;

  ImageStream? _imageStream;
  ImageInfo? _image;

  @override
  void paint(Canvas canvas, Rect rect, Path? clipPath,
      ImageConfiguration configuration,
      {double blend = 1.0, BlendMode blendMode = BlendMode.srcOver}) {
    bool flipHorizontally = false;
    if (_details.matchTextDirection) {
      assert(() {
        // We check this first so that the assert will fire immediately, not just
        // when the image is ready.
        if (configuration.textDirection == null) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary(
                'DecorationImage.matchTextDirection can only be used when a TextDirection is available.'),
            ErrorDescription(
              'When DecorationImagePainter.paint() was called, there was no text direction provided '
              'in the ImageConfiguration object to match.',
            ),
            DiagnosticsProperty<DecorationImage>(
                'The DecorationImage was', _details,
                style: DiagnosticsTreeStyle.errorProperty),
            DiagnosticsProperty<ImageConfiguration>(
                'The ImageConfiguration was', configuration,
                style: DiagnosticsTreeStyle.errorProperty),
          ]);
        }
        return true;
      }());
      if (configuration.textDirection == TextDirection.rtl) {
        flipHorizontally = true;
      }
    }

    final ImageStream newImageStream = _details.image.resolve(configuration);
    if (newImageStream.key != _imageStream?.key) {
      final ImageStreamListener listener = ImageStreamListener(
        _handleImage,
        onError: _details.onError,
      );
      _imageStream?.removeListener(listener);
      _imageStream = newImageStream;
      _imageStream!.addListener(listener);
    }
    if (_image == null) {
      return;
    }

    if (clipPath != null) {
      canvas.save();
      canvas.clipPath(clipPath);
    }

    print('rect: $rect | width: ${rect.width} height: ${rect.height}');

    paintImage(
      canvas: canvas,
      rect: Rect.fromCenter(
        center: rect.center,
        width: rect.width * _shape.ratio,
        height: rect.height * _shape.ratio,
      ),
      image: _image!.image,
      debugImageLabel: _image!.debugLabel,
      scale: _details.scale * _image!.scale,
      colorFilter: _details.colorFilter,
      fit: _details.fit,
      alignment: _details.alignment.resolve(configuration.textDirection),
      centerSlice: _details.centerSlice,
      repeat: _details.repeat,
      flipHorizontally: flipHorizontally,
      opacity: _details.opacity * blend,
      filterQuality: _details.filterQuality,
      invertColors: _details.invertColors,
      isAntiAlias: _details.isAntiAlias,
      blendMode: blendMode,
    );

    if (clipPath != null) {
      canvas.restore();
    }
  }

  void _handleImage(ImageInfo value, bool synchronousCall) {
    if (_image == value) {
      return;
    }
    if (_image != null && _image!.isCloneOf(value)) {
      value.dispose();
      return;
    }
    _image?.dispose();
    _image = value;
    if (!synchronousCall) {
      _onChanged();
    }
  }

  @override
  void dispose() {
    _imageStream?.removeListener(ImageStreamListener(
      _handleImage,
      onError: _details.onError,
    ));
    _image?.dispose();
    _image = null;
  }

  @override
  String toString() {
    return '${objectRuntimeType(this, 'DecorationImagePainter')}(stream: $_imageStream, image: $_image) for $_details';
  }
}
