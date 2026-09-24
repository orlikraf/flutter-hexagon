import 'package:flutter/widgets.dart';

import 'hexagon_clipper.dart';
import 'hexagon_layout.dart';
import 'hexagon_painter.dart';
import 'hexagon_path_builder.dart';
import 'hexagon_type.dart';

/// A hexagon-shaped tile with an optional [child], clipped to the shape.
///
/// Give it a [width] or a [height]; the other dimension follows from the
/// hexagon's aspect ratio. If both are given, the largest hexagon that fits
/// is drawn, centered.
///
/// ```dart
/// HexagonWidget.pointy(
///   width: 120,
///   color: Colors.amber,
///   elevation: 4,
///   cornerRadius: 8,
///   child: const Text('Hello'),
/// )
/// ```
class HexagonWidget extends StatelessWidget {
  /// Creates a hexagon of the given [type].
  const HexagonWidget({
    super.key,
    this.width,
    this.height,
    this.color,
    this.child,
    this.padding = 0.0,
    this.cornerRadius = 0.0,
    this.elevation = 0,
    this.inBounds = true,
    required this.type,
  }) : assert(width != null || height != null),
       assert(elevation >= 0);

  /// Creates a hexagon with flat top and bottom edges.
  const HexagonWidget.flat({
    super.key,
    this.width,
    this.height,
    this.color,
    this.child,
    this.padding = 0.0,
    this.elevation = 0,
    this.cornerRadius = 0.0,
    this.inBounds = true,
  }) : assert(width != null || height != null),
       assert(elevation >= 0),
       type = HexagonType.flat;

  /// Creates a hexagon with corners pointing up and down.
  const HexagonWidget.pointy({
    super.key,
    this.width,
    this.height,
    this.color,
    this.child,
    this.padding = 0.0,
    this.elevation = 0,
    this.cornerRadius = 0.0,
    this.inBounds = true,
  }) : assert(width != null || height != null),
       assert(elevation >= 0),
       type = HexagonType.pointy;

  /// The orientation of the hexagon.
  final HexagonType type;

  /// The width of the hexagon. When null, it follows from [height].
  final double? width;

  /// The height of the hexagon. When null, it follows from [width].
  final double? height;

  /// Size of the shadow under the hexagon. Must not be negative.
  ///
  /// Use 0 with a translucent [color], since shadows show through.
  final double elevation;

  /// Whether the hexagon fits inside [width] × [height].
  ///
  /// When false, the pointed ends overflow the box by an eighth of the
  /// hexagon on each side, so tiles placed side by side interlock. The grids
  /// use this.
  final bool inBounds;

  /// The content of the hexagon, centered and clipped to its shape.
  final Widget? child;

  /// The fill color. White when null.
  final Color? color;

  /// Empty space around the hexagon inside its box. Must not be negative.
  final double padding;

  /// Radius of the rounded corners. Values <= 0 give sharp corners; values
  /// larger than the hexagon allows are clamped.
  final double cornerRadius;

  Size _innerSize() {
    var widthFactor = type.widthFactor(inBounds);
    var heightFactor = type.heightFactor(inBounds);

    if (height != null && width != null) return Size(width!, height!);
    if (height != null) {
      return Size((height! * type.ratio) * widthFactor / heightFactor, height!);
    }
    if (width != null) {
      return Size(width!, (width! / type.ratio) / widthFactor * heightFactor);
    }
    return Size.zero; //dead path
  }

  Size _contentSize() {
    var widthFactor = type.widthFactor(inBounds);
    var heightFactor = type.heightFactor(inBounds);

    if (height != null && width != null) return Size(width!, height!);
    if (height != null) {
      return Size(
        (height! * type.ratio) / heightFactor,
        height! / heightFactor,
      );
    }
    if (width != null) {
      return Size(width! / widthFactor, (width! / type.ratio) / widthFactor);
    }
    return Size.zero; //dead path
  }

  @override
  Widget build(BuildContext context) {
    var innerSize = _innerSize();
    var contentSize = _contentSize();

    HexagonPathBuilder pathBuilder = HexagonPathBuilder(
      type,
      inBounds: inBounds,
      borderRadius: cornerRadius,
    );

    return Align(
      child: Container(
        padding: EdgeInsets.all(padding),
        width: innerSize.width,
        height: innerSize.height,
        child: CustomPaint(
          painter: HexagonPainter(
            pathBuilder,
            color: color,
            elevation: elevation,
          ),
          child: ClipPath(
            clipper: HexagonClipper(pathBuilder),
            child: OverflowBox(
              alignment: Alignment.center,
              maxHeight: contentSize.height,
              maxWidth: contentSize.width,
              child: Align(alignment: Alignment.center, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// A template for the [HexagonWidget] tiles of a grid.
///
/// The grids set each tile's type and size; this sets the rest. Pass one as
/// a grid's `hexagonBuilder` to style every tile, or return one from its
/// `buildTile` to style a single tile.
class HexagonWidgetBuilder {
  /// A key for the built tile.
  ///
  /// Only set it on builders returned from `buildTile`, where each tile gets
  /// its own builder. A grid's `hexagonBuilder` is shared by every tile, so
  /// the grids assert that it has no key.
  final Key? key;

  /// See [HexagonWidget.elevation]. Defaults to 0.
  final double? elevation;

  /// See [HexagonWidget.color].
  final Color? color;

  /// See [HexagonWidget.padding]. Defaults to 0.
  final double? padding;

  /// See [HexagonWidget.cornerRadius]. Defaults to 0.
  final double? cornerRadius;

  /// See [HexagonWidget.child]. A grid's `buildChild` replaces it.
  final Widget? child;

  /// Creates a tile template.
  HexagonWidgetBuilder({
    this.key,
    this.elevation,
    this.color,
    this.padding,
    this.cornerRadius,
    this.child,
  });

  /// Creates a template for invisible tiles without a shadow, for example
  /// to leave gaps in a grid while keeping its layout.
  HexagonWidgetBuilder.transparent({
    this.key,
    this.padding,
    this.cornerRadius,
    this.child,
  }) : elevation = 0,
       color = const Color(0x00000000);

  /// Builds a [HexagonWidget] from this template.
  ///
  /// When [replaceChild] is true, [child] is used instead of this
  /// template's [HexagonWidgetBuilder.child], even when null.
  HexagonWidget build({
    required HexagonType type,
    required bool inBounds,
    double? width,
    double? height,
    Widget? child,
    bool replaceChild = false,
  }) {
    return HexagonWidget(
      key: key,
      type: type,
      inBounds: inBounds,
      width: width,
      height: height,
      color: color,
      padding: padding ?? 0.0,
      cornerRadius: cornerRadius ?? 0.0,
      elevation: elevation ?? 0,
      child: replaceChild ? child : this.child,
    );
  }
}
