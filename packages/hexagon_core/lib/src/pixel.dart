import 'dart:math' as math;

/// A point in pixel (screen) space.
///
/// `hexagon_core` has no Flutter dependency, so it uses this small value type
/// instead of `Offset`. The `hexagon` package converts it to and from
/// `Offset`.
final class PixelPoint {
  /// Creates a point at ([x], [y]).
  const PixelPoint(this.x, this.y);

  /// The origin, (0, 0).
  static const PixelPoint zero = PixelPoint(0, 0);

  /// Horizontal coordinate, growing to the right.
  final double x;

  /// Vertical coordinate, growing downwards.
  final double y;

  /// Component-wise sum.
  PixelPoint operator +(PixelPoint other) => PixelPoint(x + other.x, y + other.y);

  /// Component-wise difference.
  PixelPoint operator -(PixelPoint other) => PixelPoint(x - other.x, y - other.y);

  /// Scales both components by [factor].
  PixelPoint operator *(double factor) => PixelPoint(x * factor, y * factor);

  /// Distance to [other].
  double distanceTo(PixelPoint other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  @override
  bool operator ==(Object other) =>
      other is PixelPoint && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'PixelPoint($x, $y)';
}

/// An axis-aligned rectangle in pixel (screen) space.
final class PixelRect {
  /// Creates a rectangle from its left, top, right and bottom edges.
  const PixelRect.fromLTRB(this.left, this.top, this.right, this.bottom);

  /// Creates a rectangle from its top-left corner and size.
  const PixelRect.fromLTWH(double left, double top, double width, double height)
      : this.fromLTRB(left, top, left + width, top + height);

  /// Creates a rectangle of [width] × [height] centered on [center].
  PixelRect.fromCenter({
    required PixelPoint center,
    required double width,
    required double height,
  }) : this.fromLTRB(
          center.x - width / 2,
          center.y - height / 2,
          center.x + width / 2,
          center.y + height / 2,
        );

  /// An empty rectangle at the origin.
  static const PixelRect zero = PixelRect.fromLTRB(0, 0, 0, 0);

  /// Left edge.
  final double left;

  /// Top edge.
  final double top;

  /// Right edge.
  final double right;

  /// Bottom edge.
  final double bottom;

  /// `right - left`.
  double get width => right - left;

  /// `bottom - top`.
  double get height => bottom - top;

  /// The middle of the rectangle.
  PixelPoint get center => PixelPoint((left + right) / 2, (top + bottom) / 2);

  /// Whether [point] lies inside the rectangle (edges included).
  bool contains(PixelPoint point) =>
      point.x >= left && point.x <= right && point.y >= top && point.y <= bottom;

  /// Whether this rectangle and [other] overlap.
  bool overlaps(PixelRect other) =>
      left < other.right &&
      other.left < right &&
      top < other.bottom &&
      other.top < bottom;

  /// The smallest rectangle containing both this rectangle and [other].
  PixelRect expandToInclude(PixelRect other) => PixelRect.fromLTRB(
        math.min(left, other.left),
        math.min(top, other.top),
        math.max(right, other.right),
        math.max(bottom, other.bottom),
      );

  /// Grows the rectangle by [delta] on every side.
  PixelRect inflate(double delta) =>
      PixelRect.fromLTRB(left - delta, top - delta, right + delta, bottom + delta);

  @override
  bool operator ==(Object other) =>
      other is PixelRect &&
      other.left == left &&
      other.top == top &&
      other.right == right &&
      other.bottom == bottom;

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() => 'PixelRect.fromLTRB($left, $top, $right, $bottom)';
}
