import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hexagon_core/hexagon_core.dart';

import '../geometry.dart';
import '../hexagon_border.dart';
import 'hex_cell_clip.dart';
import 'hex_layers.dart';

/// A pannable, zoomable view of a hex map that only paints and builds the
/// cells in its viewport.
///
/// Cells are drawn by [layers], bottom to top: [HexPaintLayer]s paint on a
/// canvas and scale to tens of thousands of cells, [HexWidgetLayer]s build
/// widgets for a few cells such as units or markers.
///
/// ```dart
/// HexGridView(
///   layout: const HexLayout.flat(radius: 24),
///   cells: terrain.keys.toSet(),
///   controller: controller,
///   layers: [
///     HexPaintLayer.fill(colorOf: (hex) => terrain[hex]!.color),
///     HexPaintLayer(painter: paintHighlights, repaint: highlights),
///     HexWidgetLayer(cells: units.keys, builder: buildUnit),
///   ],
///   onHexTap: select,
/// )
/// ```
///
/// Use a [HexGridController] to move the camera or ask which hex is where.
class HexGridView extends StatefulWidget {
  /// Creates a hex grid view.
  const HexGridView({
    super.key,
    required this.layout,
    required this.cells,
    this.layers = const [HexPaintLayer.fill()],
    this.controller,
    this.onHexTap,
    this.onHexLongPress,
    this.onHexHover,
    this.padding = EdgeInsets.zero,
    this.initialCenter,
    this.initialScale = 1,
    this.minScale = 0.1,
    this.maxScale = 8,
    this.boundaryMargin = const EdgeInsets.all(double.infinity),
    this.panEnabled = true,
    this.scaleEnabled = true,
    this.clipBehavior = Clip.hardEdge,
  })  : assert(minScale > 0),
        assert(maxScale >= minScale),
        assert(initialScale > 0);

  /// Position and size of the hexagons.
  final HexLayout layout;

  /// The cells of the map.
  ///
  /// Prefer a [Set], or keep passing the same object between builds, so the
  /// view doesn't have to convert it again.
  final Iterable<Hex> cells;

  /// What to draw, bottom to top.
  final List<HexLayer> layers;

  /// Moves the camera and reports the hovered hex. If null, the view creates
  /// its own.
  final HexGridController? controller;

  /// Called when a cell is tapped, unless a widget on a [HexWidgetLayer]
  /// handles the tap itself.
  final ValueChanged<Hex>? onHexTap;

  /// Called when a cell is long-pressed.
  final ValueChanged<Hex>? onHexLongPress;

  /// Called when the mouse moves onto another cell, or off the map (null).
  final ValueChanged<Hex?>? onHexHover;

  /// Space around the map's cells.
  final EdgeInsets padding;

  /// Hex in the middle of the viewport when the view first appears. Defaults
  /// to the middle of the map. Ignored if the controller already has a
  /// transformation.
  final Hex? initialCenter;

  /// Zoom level when the view first appears.
  final double initialScale;

  /// Smallest zoom level.
  final double minScale;

  /// Largest zoom level.
  final double maxScale;

  /// How far past the map the camera may move. Unlimited by default.
  final EdgeInsets boundaryMargin;

  /// Whether dragging pans the map.
  final bool panEnabled;

  /// Whether pinching and scrolling zoom the map.
  final bool scaleEnabled;

  /// How the map is clipped to the view.
  final Clip clipBehavior;

  @override
  State<HexGridView> createState() => _HexGridViewState();
}

/// Controls the camera of a [HexGridView] and reports the hovered hex.
///
/// Notifies its listeners when [hoveredHex] changes. Listen to
/// [transformation] for camera changes.
class HexGridController extends ChangeNotifier {
  /// Creates a controller, optionally with a starting camera transform.
  HexGridController({Matrix4? initialTransform})
      : transformation = TransformationController(initialTransform);

  /// The camera transform (scene to viewport) of the attached view.
  final TransformationController transformation;

  _HexGridViewState? _view;
  Hex? _hoveredHex;

  /// The cell under the mouse pointer, if any.
  Hex? get hoveredHex => _hoveredHex;

  /// Current zoom level.
  double get scale => transformation.value.getMaxScaleOnAxis();

  /// Whether a [HexGridView] is using this controller.
  bool get hasView => _view != null;

  _HexGridViewState get _attachedView {
    final view = _view;
    if (view == null) {
      throw StateError('HexGridController is not attached to a HexGridView.');
    }
    return view;
  }

  /// Centers the camera on [hex], optionally at a new zoom level.
  void jumpTo(Hex hex, {double? scale}) {
    final view = _attachedView;
    transformation.value =
        view._matrixCentering(view._contentPointOf(hex), scale ?? this.scale);
  }

  /// Animates the camera to [hex], optionally to a new zoom level.
  ///
  /// The returned future completes when the animation ends.
  Future<void> animateTo(
    Hex hex, {
    double? scale,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeInOutCubic,
  }) {
    final view = _attachedView;
    return view._animateTo(
      view._matrixCentering(view._contentPointOf(hex), scale ?? this.scale),
      duration,
      curve,
    );
  }

  /// The cell at [position] in the view's coordinates, or null if there is no
  /// cell there.
  Hex? hexAtViewport(Offset position) {
    final view = _attachedView;
    return view._cellAt(transformation.toScene(position));
  }

  /// The cell in the middle of the viewport, or null if there is none.
  Hex? get centerHex {
    final view = _attachedView;
    return hexAtViewport(view._viewportSize.center(Offset.zero));
  }

  void _setHovered(Hex? hex) {
    if (hex == _hoveredHex) {
      return;
    }
    _hoveredHex = hex;
    notifyListeners();
  }

  @override
  void dispose() {
    transformation.dispose();
    super.dispose();
  }
}

class _HexGridViewState extends State<HexGridView>
    with SingleTickerProviderStateMixin {
  HexGridController? _ownController;
  late final AnimationController _animation;
  Animation<Matrix4>? _cameraAnimation;

  final Expando<Set<Hex>> _cellSets = Expando<Set<Hex>>();
  final Map<double, Path> _templates = {};

  late Set<Hex> _cells;
  late Offset _origin;
  late Size _contentSize;
  Size _viewportSize = Size.zero;
  bool _cameraInitialized = false;

  HexGridController get _controller =>
      widget.controller ?? (_ownController ??= HexGridController());

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(vsync: this)
      ..addListener(_onCameraTick);
    _controller._view = this;
    _updateGeometry();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initCamera());
  }

  @override
  void didUpdateWidget(HexGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      final oldController = oldWidget.controller ?? _ownController;
      if (oldController?._view == this) {
        oldController!._view = null;
      }
      if (widget.controller != null && _ownController != null) {
        // The InteractiveViewer still listens to the old controller until it
        // rebuilds, so dispose of it after this frame.
        final ownController = _ownController!;
        _ownController = null;
        WidgetsBinding.instance
            .addPostFrameCallback((_) => ownController.dispose());
      }
      _controller._view = this;
    }
    if (!identical(oldWidget.cells, widget.cells) ||
        oldWidget.layout != widget.layout ||
        oldWidget.padding != widget.padding) {
      _updateGeometry();
    }
    if (oldWidget.layout != widget.layout) {
      _templates.clear();
    }
  }

  @override
  void dispose() {
    if (_controller._view == this) {
      _controller._view = null;
    }
    _ownController?.dispose();
    _animation.dispose();
    super.dispose();
  }

  void _updateGeometry() {
    _cells = _setOf(widget.cells);
    final bounds = widget.layout.rectOfAll(_cells);
    _origin = bounds.topLeft - widget.padding.topLeft;
    _contentSize = widget.padding.inflateSize(bounds.size);
  }

  Set<Hex> _setOf(Iterable<Hex> cells) {
    if (cells is Set<Hex>) {
      return cells;
    }
    return _cellSets[cells] ??= cells.toSet();
  }

  Path _templateFor(double cornerRadius) =>
      _templates[cornerRadius] ??= HexagonBorder(
        type: widget.layout.type,
        cornerRadius: cornerRadius,
      ).getOuterPath(
        Rect.fromCenter(
          center: Offset.zero,
          width: widget.layout.cellWidth,
          height: widget.layout.cellHeight,
        ),
      );

  Offset _contentPointOf(Hex hex) => widget.layout.centerOf(hex) - _origin;

  Hex? _cellAt(Offset contentPoint) {
    final hex = widget.layout.hexAt(contentPoint + _origin);
    return _cells.contains(hex) ? hex : null;
  }

  Matrix4 _matrixCentering(Offset contentPoint, double scale) {
    final s = scale.clamp(widget.minScale, widget.maxScale);
    final tx = _viewportSize.width / 2 - s * contentPoint.dx;
    final ty = _viewportSize.height / 2 - s * contentPoint.dy;
    return Matrix4(s, 0, 0, 0, 0, s, 0, 0, 0, 0, 1, 0, tx, ty, 0, 1);
  }

  void _initCamera() {
    if (!mounted || _cameraInitialized) {
      return;
    }
    _cameraInitialized = true;
    if (_controller.transformation.value != Matrix4.identity()) {
      return;
    }
    final center = widget.initialCenter;
    final point = center != null
        ? _contentPointOf(center)
        : _contentSize.center(Offset.zero);
    _controller.transformation.value =
        _matrixCentering(point, widget.initialScale);
  }

  Future<void> _animateTo(Matrix4 target, Duration duration, Curve curve) {
    _animation.duration = duration;
    _cameraAnimation = Matrix4Tween(
      begin: _controller.transformation.value,
      end: target,
    ).animate(CurvedAnimation(parent: _animation, curve: curve));
    return _animation.forward(from: 0);
  }

  void _onCameraTick() {
    final animation = _cameraAnimation;
    if (animation != null) {
      _controller.transformation.value = animation.value;
    }
  }

  void _stopCamera() {
    if (_animation.isAnimating) {
      _animation.stop();
    }
  }

  Iterable<Hex> _visibleCells(Set<Hex> cells, Rect visible) {
    final layout = widget.layout;
    final estimate = (visible.width / layout.horizontalStep + 2) *
        (visible.height / layout.verticalStep + 2);
    if (cells.length <= estimate) {
      return cells.where((hex) => layout.rectOf(hex).overlaps(visible));
    }
    return layout.hexesIn(visible).where(cells.contains);
  }

  Widget _buildLayer(BuildContext context, HexLayer layer, Rect visible) {
    final cells = layer.cells == null ? _cells : _setOf(layer.cells!);
    final visibleCells = _visibleCells(cells, visible).toList(growable: false);
    switch (layer) {
      case final HexPaintLayer paintLayer:
        return Positioned.fill(
          child: CustomPaint(
            painter: _HexLayerPainter(
              layer: paintLayer,
              layout: widget.layout,
              cells: visibleCells,
              origin: _origin,
              template: _templateFor(paintLayer.cornerRadius),
              defaultColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        );
      case final HexWidgetLayer widgetLayer:
        return Positioned.fill(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final hex in visibleCells)
                Positioned.fromRect(
                  key: ValueKey<Hex>(hex),
                  rect: widget.layout.rectOf(hex).shift(-_origin),
                  child: HexCellClip(
                    type: widget.layout.type,
                    child: widgetLayer.builder(context, hex),
                  ),
                ),
            ],
          ),
        );
    }
  }

  Widget _buildContent(BuildContext context, Rect visible) {
    Widget content = SizedBox.fromSize(
      size: _contentSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final layer in widget.layers)
            _buildLayer(context, layer, visible),
        ],
      ),
    );

    final onHexTap = widget.onHexTap;
    final onHexLongPress = widget.onHexLongPress;
    if (onHexTap != null || onHexLongPress != null) {
      content = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapUp: onHexTap == null
            ? null
            : (details) {
                final hex = _cellAt(details.localPosition);
                if (hex != null) {
                  onHexTap(hex);
                }
              },
        onLongPressStart: onHexLongPress == null
            ? null
            : (details) {
                final hex = _cellAt(details.localPosition);
                if (hex != null) {
                  onHexLongPress(hex);
                }
              },
        child: content,
      );
    }

    return MouseRegion(
      opaque: false,
      onHover: (event) => _hover(_cellAt(event.localPosition)),
      onExit: (_) => _hover(null),
      child: content,
    );
  }

  void _hover(Hex? hex) {
    if (hex == _controller.hoveredHex) {
      return;
    }
    _controller._setHovered(hex);
    widget.onHexHover?.call(hex);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewportSize = constraints.biggest;
        return InteractiveViewer.builder(
          transformationController: _controller.transformation,
          boundaryMargin: widget.boundaryMargin,
          minScale: widget.minScale,
          maxScale: widget.maxScale,
          panEnabled: widget.panEnabled,
          scaleEnabled: widget.scaleEnabled,
          clipBehavior: widget.clipBehavior,
          onInteractionStart: (_) => _stopCamera(),
          builder: (context, viewport) {
            final xs = [
              viewport.point0.x,
              viewport.point1.x,
              viewport.point2.x,
              viewport.point3.x,
            ];
            final ys = [
              viewport.point0.y,
              viewport.point1.y,
              viewport.point2.y,
              viewport.point3.y,
            ];
            final visible = Rect.fromLTRB(
              xs.reduce(math.min),
              ys.reduce(math.min),
              xs.reduce(math.max),
              ys.reduce(math.max),
            ).shift(_origin);
            return _buildContent(context, visible);
          },
        );
      },
    );
  }
}

class _HexLayerPainter extends CustomPainter {
  _HexLayerPainter({
    required this.layer,
    required this.layout,
    required this.cells,
    required this.origin,
    required this.template,
    required this.defaultColor,
  }) : super(repaint: layer.repaint);

  final HexPaintLayer layer;
  final HexLayout layout;
  final List<Hex> cells;
  final Offset origin;
  final Path template;
  final Color defaultColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(-origin.dx, -origin.dy);
    final painter = layer.painter;
    if (painter != null) {
      for (final hex in cells) {
        final center = layout.centerOf(hex);
        painter(canvas, HexCell(hex, center, layout.rectOf(hex), template));
      }
    } else {
      _paintFill(canvas);
    }
    canvas.restore();
  }

  void _paintFill(Canvas canvas) {
    final fill = Paint()..style = PaintingStyle.fill;
    final strokeColor = layer.strokeColor;
    final stroke = strokeColor == null
        ? null
        : (Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = layer.strokeWidth
          ..color = strokeColor);
    final colorOf = layer.colorOf;
    for (final hex in cells) {
      final color = colorOf != null
          ? colorOf(hex)
          : (layer.color ?? defaultColor);
      if (color == null) {
        continue;
      }
      final center = layout.centerOf(hex);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.drawPath(template, fill..color = color);
      if (stroke != null) {
        canvas.drawPath(template, stroke);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_HexLayerPainter oldDelegate) => true;
}
