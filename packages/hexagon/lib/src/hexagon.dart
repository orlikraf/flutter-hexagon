import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hexagon_core/hexagon_core.dart';

import 'hexagon_border.dart';
import 'hexagon_theme.dart';

/// How a [Hexagon] chooses its size.
enum HexagonFit {
  /// The largest regular hexagon that fits the incoming constraints, like
  /// [AspectRatio]. If both dimensions are unbounded it falls back to [wrap].
  contain,

  /// The smallest regular hexagon that encloses the child.
  wrap,
}

/// Where a [Hexagon] lays out its child when it uses [HexagonFit.contain].
enum HexagonChildArea {
  /// The largest rectangle inside the hexagon. The child is laid out loosely
  /// and positioned with [Hexagon.alignment]. Good for text and icons, which
  /// stay fully visible.
  inscribed,

  /// The hexagon's whole bounding box. The child is laid out tightly and
  /// clipped to the hexagon. Good for images and backgrounds.
  bounds,
}

/// A hexagon-shaped surface with an optional child.
///
/// The hexagon sizes itself during layout (see [fit]), paints with Material
/// elevation and ink, and only reacts to pointers inside its outline, so
/// hexagons can overlap their bounding boxes in grids.
///
/// ```dart
/// Hexagon(
///   type: HexagonType.pointy,
///   width: 120,
///   cornerRadius: 8,
///   color: Colors.amber,
///   onTap: () {},
///   child: const Icon(Icons.hive),
/// )
/// ```
///
/// Defaults for color, elevation, corners and outline come from
/// [HexagonThemeData].
class Hexagon extends StatelessWidget {
  /// Creates a hexagon.
  const Hexagon({
    super.key,
    this.type = HexagonType.flat,
    this.child,
    this.width,
    this.height,
    this.fit = HexagonFit.contain,
    this.childArea = HexagonChildArea.inscribed,
    this.alignment = Alignment.center,
    this.color,
    this.elevation,
    this.shadowColor,
    this.cornerRadius,
    this.side,
    this.clipBehavior = Clip.antiAlias,
    this.onTap,
    this.onLongPress,
    this.onHover,
    this.mouseCursor,
  })  : assert(width == null || width >= 0),
        assert(height == null || height >= 0),
        assert(elevation == null || elevation >= 0),
        assert(cornerRadius == null || cornerRadius >= 0);

  /// Creates a flat hexagon.
  const Hexagon.flat({
    Key? key,
    Widget? child,
    double? width,
    double? height,
    HexagonFit fit = HexagonFit.contain,
    HexagonChildArea childArea = HexagonChildArea.inscribed,
    AlignmentGeometry alignment = Alignment.center,
    Color? color,
    double? elevation,
    Color? shadowColor,
    double? cornerRadius,
    BorderSide? side,
    Clip clipBehavior = Clip.antiAlias,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
    ValueChanged<bool>? onHover,
    MouseCursor? mouseCursor,
  }) : this(
          key: key,
          type: HexagonType.flat,
          child: child,
          width: width,
          height: height,
          fit: fit,
          childArea: childArea,
          alignment: alignment,
          color: color,
          elevation: elevation,
          shadowColor: shadowColor,
          cornerRadius: cornerRadius,
          side: side,
          clipBehavior: clipBehavior,
          onTap: onTap,
          onLongPress: onLongPress,
          onHover: onHover,
          mouseCursor: mouseCursor,
        );

  /// Creates a pointy hexagon.
  const Hexagon.pointy({
    Key? key,
    Widget? child,
    double? width,
    double? height,
    HexagonFit fit = HexagonFit.contain,
    HexagonChildArea childArea = HexagonChildArea.inscribed,
    AlignmentGeometry alignment = Alignment.center,
    Color? color,
    double? elevation,
    Color? shadowColor,
    double? cornerRadius,
    BorderSide? side,
    Clip clipBehavior = Clip.antiAlias,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
    ValueChanged<bool>? onHover,
    MouseCursor? mouseCursor,
  }) : this(
          key: key,
          type: HexagonType.pointy,
          child: child,
          width: width,
          height: height,
          fit: fit,
          childArea: childArea,
          alignment: alignment,
          color: color,
          elevation: elevation,
          shadowColor: shadowColor,
          cornerRadius: cornerRadius,
          side: side,
          clipBehavior: clipBehavior,
          onTap: onTap,
          onLongPress: onLongPress,
          onHover: onHover,
          mouseCursor: mouseCursor,
        );

  /// Orientation of the hexagon.
  final HexagonType type;

  /// Content of the hexagon, clipped to its outline.
  final Widget? child;

  /// Fixed width. The height follows from the hexagon's proportions unless
  /// [height] is set too.
  final double? width;

  /// Fixed height. The width follows from the hexagon's proportions unless
  /// [width] is set too.
  final double? height;

  /// How the hexagon chooses its size.
  final HexagonFit fit;

  /// Where the child is laid out with [HexagonFit.contain].
  final HexagonChildArea childArea;

  /// Position of the child inside its area.
  final AlignmentGeometry alignment;

  /// Fill color. Defaults to [HexagonThemeData.color], then
  /// [ColorScheme.surfaceContainerHighest].
  final Color? color;

  /// Shadow elevation. Defaults to [HexagonThemeData.elevation], then 0.
  final double? elevation;

  /// Shadow color. Defaults to [HexagonThemeData.shadowColor], then
  /// [ColorScheme.shadow].
  final Color? shadowColor;

  /// Radius of the rounded corners. Defaults to
  /// [HexagonThemeData.cornerRadius], then 0.
  final double? cornerRadius;

  /// Outline. Defaults to [HexagonThemeData.side], then none.
  final BorderSide? side;

  /// How the child is clipped to the hexagon.
  final Clip clipBehavior;

  /// Called when the hexagon is tapped. Setting it adds an ink ripple.
  final GestureTapCallback? onTap;

  /// Called when the hexagon is long-pressed.
  final GestureLongPressCallback? onLongPress;

  /// Called when a mouse pointer enters (true) or leaves (false) the hexagon.
  final ValueChanged<bool>? onHover;

  /// Mouse cursor over the hexagon when it is interactive.
  final MouseCursor? mouseCursor;

  @override
  Widget build(BuildContext context) {
    final theme = HexagonThemeData.of(context);
    final colors = Theme.of(context).colorScheme;
    final shape = HexagonBorder(
      type: type,
      cornerRadius: cornerRadius ?? theme.cornerRadius ?? 0,
      side: side ?? theme.side ?? BorderSide.none,
    );

    Widget content = _HexagonContent(
      type: type,
      fit: fit,
      childArea: childArea,
      alignment: alignment,
      textDirection: Directionality.maybeOf(context),
      child: child,
    );

    if (onTap != null || onLongPress != null || onHover != null) {
      content = InkWell(
        customBorder: shape,
        onTap: onTap,
        onLongPress: onLongPress,
        onHover: onHover,
        mouseCursor: mouseCursor,
        child: content,
      );
    }

    Widget result = _HexagonBox(
      type: type,
      fit: fit,
      shape: shape,
      child: Material(
        shape: shape,
        color: color ?? theme.color ?? colors.surfaceContainerHighest,
        elevation: elevation ?? theme.elevation ?? 0,
        shadowColor: shadowColor ?? theme.shadowColor ?? colors.shadow,
        clipBehavior: clipBehavior,
        child: content,
      ),
    );

    if (width != null || height != null) {
      result = SizedBox(width: width, height: height, child: result);
    }
    return result;
  }
}

/// Sizes the hexagon and restricts hit testing to its outline.
class _HexagonBox extends SingleChildRenderObjectWidget {
  const _HexagonBox({
    required this.type,
    required this.fit,
    required this.shape,
    super.child,
  });

  final HexagonType type;
  final HexagonFit fit;
  final ShapeBorder shape;

  @override
  RenderHexagonBox createRenderObject(BuildContext context) =>
      RenderHexagonBox(type: type, fit: fit, shape: shape);

  @override
  void updateRenderObject(BuildContext context, RenderHexagonBox renderObject) {
    renderObject
      ..type = type
      ..fit = fit
      ..shape = shape;
  }
}

/// Render object that gives its child the size of a regular hexagon's
/// bounding box and only accepts hits inside [shape].
class RenderHexagonBox extends RenderProxyBox {
  /// Creates the render object.
  RenderHexagonBox({
    required HexagonType type,
    required HexagonFit fit,
    required ShapeBorder shape,
    RenderBox? child,
  })  : _type = type,
        _fit = fit,
        _shape = shape,
        super(child);

  /// Orientation of the hexagon.
  HexagonType get type => _type;
  HexagonType _type;
  set type(HexagonType value) {
    if (value == _type) {
      return;
    }
    _type = value;
    _hitPath = null;
    markNeedsLayout();
  }

  /// How the size is chosen.
  HexagonFit get fit => _fit;
  HexagonFit _fit;
  set fit(HexagonFit value) {
    if (value == _fit) {
      return;
    }
    _fit = value;
    markNeedsLayout();
  }

  /// Outline used for hit testing.
  ShapeBorder get shape => _shape;
  ShapeBorder _shape;
  set shape(ShapeBorder value) {
    if (value == _shape) {
      return;
    }
    _shape = value;
    _hitPath = null;
  }

  Path? _hitPath;
  Size? _hitPathSize;

  bool _contains(BoxConstraints constraints) =>
      fit == HexagonFit.contain &&
      (constraints.hasBoundedWidth || constraints.hasBoundedHeight);

  Size _containedSize(BoxConstraints constraints) {
    if (constraints.isTight) {
      return constraints.smallest;
    }
    final ratio = type.ratio;
    var width = constraints.maxWidth;
    double height;
    if (width.isFinite) {
      height = width / ratio;
    } else {
      height = constraints.maxHeight;
      width = height * ratio;
    }
    if (width > constraints.maxWidth) {
      width = constraints.maxWidth;
      height = width / ratio;
    }
    if (height > constraints.maxHeight) {
      height = constraints.maxHeight;
      width = height * ratio;
    }
    if (width < constraints.minWidth) {
      width = constraints.minWidth;
      height = width / ratio;
    }
    if (height < constraints.minHeight) {
      height = constraints.minHeight;
      width = height * ratio;
    }
    return constraints.constrain(Size(width, height));
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    if (_contains(constraints)) {
      return _containedSize(constraints);
    }
    return child?.getDryLayout(constraints) ?? constraints.smallest;
  }

  @override
  void performLayout() {
    if (_contains(constraints)) {
      size = _containedSize(constraints);
      child?.layout(BoxConstraints.tight(size));
    } else if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      size = constraints.constrain(child!.size);
    } else {
      size = constraints.smallest;
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      fit == HexagonFit.contain && height.isFinite
          ? height * type.ratio
          : super.computeMinIntrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      fit == HexagonFit.contain && height.isFinite
          ? height * type.ratio
          : super.computeMaxIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) =>
      fit == HexagonFit.contain && width.isFinite
          ? width / type.ratio
          : super.computeMinIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      fit == HexagonFit.contain && width.isFinite
          ? width / type.ratio
          : super.computeMaxIntrinsicHeight(width);

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position)) {
      return false;
    }
    if (_hitPath == null || _hitPathSize != size) {
      _hitPath = shape.getOuterPath(Offset.zero & size);
      _hitPathSize = size;
    }
    if (!_hitPath!.contains(position)) {
      return false;
    }
    return super.hitTest(result, position: position);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<HexagonType>('type', type))
      ..add(EnumProperty<HexagonFit>('fit', fit));
  }
}

/// Places the child in the hexagon's inscribed rectangle or bounding box, or
/// sizes the hexagon around the child.
class _HexagonContent extends SingleChildRenderObjectWidget {
  const _HexagonContent({
    required this.type,
    required this.fit,
    required this.childArea,
    required this.alignment,
    required this.textDirection,
    super.child,
  });

  final HexagonType type;
  final HexagonFit fit;
  final HexagonChildArea childArea;
  final AlignmentGeometry alignment;
  final TextDirection? textDirection;

  @override
  RenderHexagonContent createRenderObject(BuildContext context) =>
      RenderHexagonContent(
        type: type,
        fit: fit,
        childArea: childArea,
        alignment: alignment,
        textDirection: textDirection,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderHexagonContent renderObject,
  ) {
    renderObject
      ..type = type
      ..fit = fit
      ..childArea = childArea
      ..alignment = alignment
      ..textDirection = textDirection;
  }
}

/// Render object that lays out a [Hexagon]'s child.
///
/// With tight constraints (or [HexagonFit.contain]) it fills them and puts the
/// child in the [childArea]. Otherwise ([HexagonFit.wrap]) it measures the
/// child and becomes the bounding box of the smallest regular hexagon that
/// encloses it.
class RenderHexagonContent extends RenderShiftedBox {
  /// Creates the render object.
  RenderHexagonContent({
    required HexagonType type,
    required HexagonFit fit,
    required HexagonChildArea childArea,
    required AlignmentGeometry alignment,
    TextDirection? textDirection,
    RenderBox? child,
  })  : _type = type,
        _fit = fit,
        _childArea = childArea,
        _alignment = alignment,
        _textDirection = textDirection,
        super(child);

  /// Orientation of the hexagon.
  HexagonType get type => _type;
  HexagonType _type;
  set type(HexagonType value) {
    if (value == _type) {
      return;
    }
    _type = value;
    markNeedsLayout();
  }

  /// How the size is chosen.
  HexagonFit get fit => _fit;
  HexagonFit _fit;
  set fit(HexagonFit value) {
    if (value == _fit) {
      return;
    }
    _fit = value;
    markNeedsLayout();
  }

  /// Where the child is laid out.
  HexagonChildArea get childArea => _childArea;
  HexagonChildArea _childArea;
  set childArea(HexagonChildArea value) {
    if (value == _childArea) {
      return;
    }
    _childArea = value;
    markNeedsLayout();
  }

  /// Position of the child inside its area.
  AlignmentGeometry get alignment => _alignment;
  AlignmentGeometry _alignment;
  set alignment(AlignmentGeometry value) {
    if (value == _alignment) {
      return;
    }
    _alignment = value;
    markNeedsLayout();
  }

  /// Text direction used to resolve [alignment].
  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (value == _textDirection) {
      return;
    }
    _textDirection = value;
    markNeedsLayout();
  }

  bool _wraps(BoxConstraints constraints) =>
      !constraints.isTight &&
      (fit == HexagonFit.wrap ||
          !constraints.hasBoundedWidth ||
          !constraints.hasBoundedHeight);

  Size _enclosingSize(Size childSize) {
    final radius = type.radiusToEnclose(childSize.width, childSize.height);
    return Size(type.widthForRadius(radius), type.heightForRadius(radius));
  }

  Rect _childRect(Size size) {
    if (childArea == HexagonChildArea.bounds) {
      return Offset.zero & size;
    }
    final radius = type.radiusToFit(size.width, size.height);
    final inscribed = type.inscribedRectForRadius(radius);
    return Rect.fromCenter(
      center: size.center(Offset.zero),
      width: inscribed.width,
      height: inscribed.height,
    );
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    if (_wraps(constraints)) {
      final childSize = child?.getDryLayout(constraints.loosen()) ?? Size.zero;
      return constraints.constrain(_enclosingSize(childSize));
    }
    return constraints.biggest;
  }

  @override
  void performLayout() {
    final child = this.child;
    final resolvedAlignment = alignment.resolve(textDirection);
    if (_wraps(constraints)) {
      if (child == null) {
        size = constraints.smallest;
        return;
      }
      child.layout(constraints.loosen(), parentUsesSize: true);
      size = constraints.constrain(_enclosingSize(child.size));
      (child.parentData! as BoxParentData).offset =
          resolvedAlignment.alongOffset(size - child.size as Offset);
      return;
    }
    size = constraints.biggest;
    if (child == null) {
      return;
    }
    final area = _childRect(size);
    if (childArea == HexagonChildArea.bounds) {
      child.layout(BoxConstraints.tight(area.size), parentUsesSize: true);
    } else {
      child.layout(BoxConstraints.loose(area.size), parentUsesSize: true);
    }
    (child.parentData! as BoxParentData).offset = area.topLeft +
        resolvedAlignment.alongOffset(area.size - child.size as Offset);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<HexagonType>('type', type))
      ..add(EnumProperty<HexagonFit>('fit', fit))
      ..add(EnumProperty<HexagonChildArea>('childArea', childArea))
      ..add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment));
  }
}
