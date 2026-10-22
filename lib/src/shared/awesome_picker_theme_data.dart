import 'dart:ui' show lerpDouble;

import 'package:awesome_datetime_picker/src/shared/awesome_wheel_style.dart';
import 'package:flutter/material.dart';

/// The look of every picker of the package, set once in your `ThemeData`.
///
/// Without it each picker has to be given its colors, text styles and sizes.
/// With it, the pickers of the whole app (or of a part of it, through a
/// nested [Theme]) share one look:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: [
///       AwesomePickerThemeData(
///         selectedTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
///         selectorColor: Color(0x22007AFF),
///         wheelStyle: AwesomeWheelStyle.ios(),
///       ),
///     ],
///   ),
/// )
/// ```
///
/// Give [ThemeData.dark] its own [AwesomePickerThemeData] (through
/// `darkTheme`) for a different look in dark mode; the built-in colors already
/// follow the brightness when you do not set any.
///
/// ## Precedence
///
/// From the highest: the per-wheel `ItemTheme` of a picker's `theme`, then the
/// options given to the picker (`backgroundColor`, `selectedTextStyle`, ...),
/// then this theme, then the built-in defaults. The [wheelStyle] is merged
/// property by property: a picker's own `wheelStyle` overrides only the
/// properties it sets.
///
/// Only appearance is themed. Behavior (`looping`, `enableHapticFeedback`,
/// intervals, exclusions, formats...) stays an option of each picker.
@immutable
class AwesomePickerThemeData extends ThemeExtension<AwesomePickerThemeData> {
  /// Background color of the wheels.
  final Color? backgroundColor;

  /// Color of the selector (the highlight of the selected item).
  final Color? selectorColor;

  /// Text style of the selected item.
  final TextStyle? selectedTextStyle;

  /// Text style of the items that are not selected.
  final TextStyle? unselectedTextStyle;

  /// Text style of the dimmed values shown with `showDisabledValues`.
  final TextStyle? disabledTextStyle;

  /// Whether the items fade out at the top and bottom edges of the wheels.
  final bool? fadeEffect;

  /// Height of each item. Unlike the default height, it does not grow with the
  /// system text size.
  final double? itemHeight;

  /// Width of each wheel.
  final double? itemWidth;

  /// Number of items visible at once in each wheel: an odd number, at least 3.
  final int? visibleItemCount;

  /// Curvature, magnification and selector shape of the wheels. See
  /// [AwesomeWheelStyle].
  final AwesomeWheelStyle? wheelStyle;

  /// Creates a theme. Every property is optional: the ones you leave out keep
  /// the look the picker would have without a theme.
  const AwesomePickerThemeData({
    this.backgroundColor,
    this.selectorColor,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.disabledTextStyle,
    this.fadeEffect,
    this.itemHeight,
    this.itemWidth,
    this.visibleItemCount,
    this.wheelStyle,
  })  : assert(itemHeight == null || itemHeight > 0,
            'itemHeight must be greater than 0'),
        assert(itemWidth == null || itemWidth > 0,
            'itemWidth must be greater than 0'),
        assert(
          visibleItemCount == null ||
              (visibleItemCount >= 3 && visibleItemCount % 2 == 1),
          'visibleItemCount must be an odd number, at least 3',
        );

  /// The theme of the pickers below [context], or null if there is none.
  static AwesomePickerThemeData? maybeOf(BuildContext context) =>
      Theme.of(context).extension<AwesomePickerThemeData>();

  /// The theme of the pickers below [context]: an empty one (that changes
  /// nothing) if there is none.
  static AwesomePickerThemeData of(BuildContext context) =>
      maybeOf(context) ?? const AwesomePickerThemeData();

  @override
  AwesomePickerThemeData copyWith({
    Color? backgroundColor,
    Color? selectorColor,
    TextStyle? selectedTextStyle,
    TextStyle? unselectedTextStyle,
    TextStyle? disabledTextStyle,
    bool? fadeEffect,
    double? itemHeight,
    double? itemWidth,
    int? visibleItemCount,
    AwesomeWheelStyle? wheelStyle,
  }) {
    return AwesomePickerThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectorColor: selectorColor ?? this.selectorColor,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      unselectedTextStyle: unselectedTextStyle ?? this.unselectedTextStyle,
      disabledTextStyle: disabledTextStyle ?? this.disabledTextStyle,
      fadeEffect: fadeEffect ?? this.fadeEffect,
      itemHeight: itemHeight ?? this.itemHeight,
      itemWidth: itemWidth ?? this.itemWidth,
      visibleItemCount: visibleItemCount ?? this.visibleItemCount,
      wheelStyle: wheelStyle ?? this.wheelStyle,
    );
  }

  @override
  AwesomePickerThemeData lerp(
      ThemeExtension<AwesomePickerThemeData>? other, double t) {
    if (other is! AwesomePickerThemeData) return this;
    // Values that cannot be blended (a count, a flag) switch halfway.
    T? pick<T>(T? a, T? b) => t < 0.5 ? a : b;
    return AwesomePickerThemeData(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      selectorColor: Color.lerp(selectorColor, other.selectorColor, t),
      selectedTextStyle:
          TextStyle.lerp(selectedTextStyle, other.selectedTextStyle, t),
      unselectedTextStyle:
          TextStyle.lerp(unselectedTextStyle, other.unselectedTextStyle, t),
      disabledTextStyle:
          TextStyle.lerp(disabledTextStyle, other.disabledTextStyle, t),
      fadeEffect: pick(fadeEffect, other.fadeEffect),
      itemHeight: lerpDouble(itemHeight, other.itemHeight, t),
      itemWidth: lerpDouble(itemWidth, other.itemWidth, t),
      visibleItemCount: pick(visibleItemCount, other.visibleItemCount),
      wheelStyle: AwesomeWheelStyle.lerp(wheelStyle, other.wheelStyle, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AwesomePickerThemeData &&
          other.backgroundColor == backgroundColor &&
          other.selectorColor == selectorColor &&
          other.selectedTextStyle == selectedTextStyle &&
          other.unselectedTextStyle == unselectedTextStyle &&
          other.disabledTextStyle == disabledTextStyle &&
          other.fadeEffect == fadeEffect &&
          other.itemHeight == itemHeight &&
          other.itemWidth == itemWidth &&
          other.visibleItemCount == visibleItemCount &&
          other.wheelStyle == wheelStyle;

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        selectorColor,
        selectedTextStyle,
        unselectedTextStyle,
        disabledTextStyle,
        fadeEffect,
        itemHeight,
        itemWidth,
        visibleItemCount,
        wheelStyle,
      );
}
