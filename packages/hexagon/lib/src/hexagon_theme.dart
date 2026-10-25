import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Default look of [Hexagon] widgets, set through [ThemeData.extensions].
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: const [
///       HexagonThemeData(cornerRadius: 6, elevation: 2),
///     ],
///   ),
/// )
/// ```
@immutable
class HexagonThemeData extends ThemeExtension<HexagonThemeData>
    with Diagnosticable {
  /// Creates a hexagon theme. Unset values fall back to defaults derived from
  /// the [ColorScheme].
  const HexagonThemeData({
    this.color,
    this.elevation,
    this.shadowColor,
    this.cornerRadius,
    this.side,
  });

  /// Fill color. Defaults to [ColorScheme.surfaceContainerHighest].
  final Color? color;

  /// Elevation of the hexagon's shadow. Defaults to 0.
  final double? elevation;

  /// Shadow color. Defaults to [ColorScheme.shadow].
  final Color? shadowColor;

  /// Radius of the hexagon's rounded corners. Defaults to 0.
  final double? cornerRadius;

  /// Outline of the hexagon. Defaults to [BorderSide.none].
  final BorderSide? side;

  /// The hexagon theme of the closest [Theme], or an empty one.
  static HexagonThemeData of(BuildContext context) =>
      Theme.of(context).extension<HexagonThemeData>() ??
      const HexagonThemeData();

  @override
  HexagonThemeData copyWith({
    Color? color,
    double? elevation,
    Color? shadowColor,
    double? cornerRadius,
    BorderSide? side,
  }) =>
      HexagonThemeData(
        color: color ?? this.color,
        elevation: elevation ?? this.elevation,
        shadowColor: shadowColor ?? this.shadowColor,
        cornerRadius: cornerRadius ?? this.cornerRadius,
        side: side ?? this.side,
      );

  @override
  HexagonThemeData lerp(HexagonThemeData? other, double t) {
    if (other == null) {
      return this;
    }
    return HexagonThemeData(
      color: Color.lerp(color, other.color, t),
      elevation: lerpDouble(elevation, other.elevation, t),
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t),
      cornerRadius: lerpDouble(cornerRadius, other.cornerRadius, t),
      side: _lerpSide(side, other.side, t),
    );
  }

  static BorderSide? _lerpSide(BorderSide? a, BorderSide? b, double t) {
    if (a == null && b == null) {
      return null;
    }
    return BorderSide.lerp(a ?? BorderSide.none, b ?? BorderSide.none, t);
  }

  @override
  bool operator ==(Object other) =>
      other is HexagonThemeData &&
      other.color == color &&
      other.elevation == elevation &&
      other.shadowColor == shadowColor &&
      other.cornerRadius == cornerRadius &&
      other.side == side;

  @override
  int get hashCode =>
      Object.hash(color, elevation, shadowColor, cornerRadius, side);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('color', color, defaultValue: null))
      ..add(DoubleProperty('elevation', elevation, defaultValue: null))
      ..add(ColorProperty('shadowColor', shadowColor, defaultValue: null))
      ..add(DoubleProperty('cornerRadius', cornerRadius, defaultValue: null))
      ..add(DiagnosticsProperty<BorderSide>('side', side, defaultValue: null));
  }
}
