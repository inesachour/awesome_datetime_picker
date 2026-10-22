import 'package:flutter/widgets.dart';

/// Advanced appearance options for the wheels of a picker.
///
/// Every property is optional; unset values keep the default iOS-like look.
/// The same style is applied to every wheel of the picker. Use `ItemTheme`
/// to style one wheel individually.
///
/// ```dart
/// AwesomeDatePicker(
///   wheelStyle: AwesomeWheelStyle(
///     diameterRatio: 2.5,
///     magnification: 1.15,
///     selectorBorderRadius: BorderRadius.circular(12),
///   ),
/// )
/// ```
@immutable
class AwesomeWheelStyle {
  /// Ratio between the diameter of the wheel and the height of the picker.
  /// A larger value makes the wheel flatter (default 1.5).
  final double? diameterRatio;

  /// How strongly the wheel looks curved, between 0 (flat) and 0.01
  /// (default 0.01).
  final double? perspective;

  /// Scale applied to the selected item, e.g. 1.2 enlarges it by 20%
  /// (default 1, no magnification).
  final double? magnification;

  /// How tightly items are packed along the wheel. Values above 1 show more
  /// items in the same height (default 1).
  final double? squeeze;

  /// Opacity of the items above and below the selected one, from 0 to 1
  /// (default 1, fully opaque).
  final double? overAndUnderCenterOpacity;

  /// Corner radius of the selector highlight (default: square corners).
  ///
  /// Ignored when [selectorDecoration] is set.
  final BorderRadius? selectorBorderRadius;

  /// Color of the outline drawn around the selector of the wheel that has the
  /// keyboard focus (default: the primary color of the theme).
  final Color? focusColor;

  /// Fully custom decoration of the selector highlight (border, gradient,
  /// shadow, ...). When set, it replaces the picker's `selectorColor` and
  /// [selectorBorderRadius].
  final Decoration? selectorDecoration;

  /// Creates a wheel style. All properties are optional.
  const AwesomeWheelStyle({
    this.diameterRatio,
    this.perspective,
    this.magnification,
    this.squeeze,
    this.overAndUnderCenterOpacity,
    this.selectorBorderRadius,
    this.selectorDecoration,
    this.focusColor,
  })  : assert(diameterRatio == null || diameterRatio > 0,
            'diameterRatio must be greater than 0'),
        assert(perspective == null || (perspective > 0 && perspective <= 0.01),
            'perspective must be in (0, 0.01]'),
        assert(magnification == null || magnification > 0,
            'magnification must be greater than 0'),
        assert(
            squeeze == null || squeeze > 0, 'squeeze must be greater than 0'),
        assert(
            overAndUnderCenterOpacity == null ||
                (overAndUnderCenterOpacity >= 0 &&
                    overAndUnderCenterOpacity <= 1),
            'overAndUnderCenterOpacity must be between 0 and 1');

  /// A look close to the iPhone wheel: a strongly curved wheel that packs more
  /// items into the same height, and a selector with rounded corners.
  ///
  /// The values are the ones of Flutter's `CupertinoPicker`. A starting point:
  /// use [copyWith] to change a property.
  ///
  /// ```dart
  /// AwesomeDatePicker(wheelStyle: AwesomeWheelStyle.ios())
  /// ```
  const AwesomeWheelStyle.ios()
      : diameterRatio = 1.07,
        perspective = 0.003,
        magnification = null,
        squeeze = 1.45,
        overAndUnderCenterOpacity = null,
        selectorBorderRadius = const BorderRadius.all(Radius.circular(8)),
        selectorDecoration = null,
        focusColor = null;

  /// A flat, list-like wheel with a rounded, pill-shaped selector, closer to
  /// Material design than to the iPhone wheel.
  ///
  /// A starting point: use [copyWith] to change a property.
  const AwesomeWheelStyle.material()
      : diameterRatio = 6,
        perspective = 0.001,
        magnification = null,
        squeeze = null,
        overAndUnderCenterOpacity = null,
        selectorBorderRadius = const BorderRadius.all(Radius.circular(16)),
        selectorDecoration = null,
        focusColor = null;

  /// A flat wheel whose selector is only a thin line above and below the
  /// selected item, with no fill.
  ///
  /// A starting point: use [copyWith] to change a property.
  const AwesomeWheelStyle.minimal()
      : diameterRatio = 8,
        perspective = 0.0005,
        magnification = null,
        squeeze = null,
        overAndUnderCenterOpacity = null,
        selectorBorderRadius = null,
        selectorDecoration = const BoxDecoration(
          border: Border.symmetric(
            horizontal: BorderSide(color: Color(0x55808080)),
          ),
        ),
        focusColor = null;

  /// This style where a property is null filled in from [base]: the
  /// properties set here win. Used to put the style of a picker over the one
  /// of the theme.
  AwesomeWheelStyle mergedOver(AwesomeWheelStyle base) {
    return AwesomeWheelStyle(
      diameterRatio: diameterRatio ?? base.diameterRatio,
      perspective: perspective ?? base.perspective,
      magnification: magnification ?? base.magnification,
      squeeze: squeeze ?? base.squeeze,
      overAndUnderCenterOpacity:
          overAndUnderCenterOpacity ?? base.overAndUnderCenterOpacity,
      selectorBorderRadius: selectorBorderRadius ?? base.selectorBorderRadius,
      selectorDecoration: selectorDecoration ?? base.selectorDecoration,
      focusColor: focusColor ?? base.focusColor,
    );
  }

  /// Linear interpolation between two styles, used when the theme changes
  /// with an animation. A property that is set in only one of them switches
  /// halfway.
  static AwesomeWheelStyle? lerp(
      AwesomeWheelStyle? a, AwesomeWheelStyle? b, double t) {
    if (a == null && b == null) return null;
    if (identical(a, b)) return a;
    double? number(double? x, double? y) {
      if (x == null || y == null) return t < 0.5 ? x : y;
      return x + (y - x) * t;
    }

    return AwesomeWheelStyle(
      diameterRatio: number(a?.diameterRatio, b?.diameterRatio),
      perspective: number(a?.perspective, b?.perspective),
      magnification: number(a?.magnification, b?.magnification),
      squeeze: number(a?.squeeze, b?.squeeze),
      overAndUnderCenterOpacity:
          number(a?.overAndUnderCenterOpacity, b?.overAndUnderCenterOpacity),
      selectorBorderRadius: BorderRadius.lerp(
          a?.selectorBorderRadius, b?.selectorBorderRadius, t),
      selectorDecoration:
          Decoration.lerp(a?.selectorDecoration, b?.selectorDecoration, t),
      focusColor: Color.lerp(a?.focusColor, b?.focusColor, t),
    );
  }

  /// Creates a copy of this style with the given properties replaced.
  ///
  /// A property that is not given keeps its value; a value cannot be reset to
  /// "unset" with this method.
  AwesomeWheelStyle copyWith({
    double? diameterRatio,
    double? perspective,
    double? magnification,
    double? squeeze,
    double? overAndUnderCenterOpacity,
    BorderRadius? selectorBorderRadius,
    Decoration? selectorDecoration,
    Color? focusColor,
  }) {
    return AwesomeWheelStyle(
      diameterRatio: diameterRatio ?? this.diameterRatio,
      perspective: perspective ?? this.perspective,
      magnification: magnification ?? this.magnification,
      squeeze: squeeze ?? this.squeeze,
      overAndUnderCenterOpacity:
          overAndUnderCenterOpacity ?? this.overAndUnderCenterOpacity,
      selectorBorderRadius: selectorBorderRadius ?? this.selectorBorderRadius,
      selectorDecoration: selectorDecoration ?? this.selectorDecoration,
      focusColor: focusColor ?? this.focusColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AwesomeWheelStyle &&
          other.diameterRatio == diameterRatio &&
          other.perspective == perspective &&
          other.magnification == magnification &&
          other.squeeze == squeeze &&
          other.overAndUnderCenterOpacity == overAndUnderCenterOpacity &&
          other.selectorBorderRadius == selectorBorderRadius &&
          other.selectorDecoration == selectorDecoration &&
          other.focusColor == focusColor;

  @override
  int get hashCode => Object.hash(
        diameterRatio,
        perspective,
        magnification,
        squeeze,
        overAndUnderCenterOpacity,
        selectorBorderRadius,
        selectorDecoration,
        focusColor,
      );
}
