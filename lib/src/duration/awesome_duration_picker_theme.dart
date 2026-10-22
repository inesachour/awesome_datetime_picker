import 'package:awesome_datetime_picker/src/shared/item_theme.dart';

/// Theme for the duration picker, allowing customization of the wheel of each
/// unit.
///
/// A unit has its own theme whichever wheel it is on: in the minutes and
/// seconds format the minutes wheel uses [minuteTheme].
class AwesomeDurationPickerTheme {
  /// The theme for the hours wheel.
  final ItemTheme? hourTheme;

  /// The theme for the minutes wheel.
  final ItemTheme? minuteTheme;

  /// The theme for the seconds wheel.
  final ItemTheme? secondTheme;

  /// Creates a duration picker theme. Unset wheels use the picker defaults.
  const AwesomeDurationPickerTheme({
    this.hourTheme,
    this.minuteTheme,
    this.secondTheme,
  });
}
