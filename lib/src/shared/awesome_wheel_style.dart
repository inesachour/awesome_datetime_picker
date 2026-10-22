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
          other.selectorDecoration == selectorDecoration;

  @override
  int get hashCode => Object.hash(
        diameterRatio,
        perspective,
        magnification,
        squeeze,
        overAndUnderCenterOpacity,
        selectorBorderRadius,
        selectorDecoration,
      );
}
