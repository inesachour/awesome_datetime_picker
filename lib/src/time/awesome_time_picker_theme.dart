import 'package:awesome_datetime_picker/src/shared/item_theme.dart';

/// Theme for the time picker, allowing customization of hour, minute, second
/// and AM/PM items.
class AwesomeTimePickerTheme {
  /// The theme for the hour item in the time picker.
  /// It customizes the appearance of the hour picker element.
  final ItemTheme? hourTheme;

  /// The theme for the minute item in the time picker.
  /// It customizes the appearance of the minute picker element.
  final ItemTheme? minuteTheme;

  /// The theme for the second item in the time picker.
  /// It customizes the appearance of the second picker element and falls back
  /// to [minuteTheme] when not set.
  final ItemTheme? secondTheme;

  /// The theme for the AM/PM item in the time picker.
  /// It customizes the appearance of the AM/PM picker element.
  final ItemTheme? ampmTheme;

  /// Creates a time picker theme. Unset items use the picker defaults.
  const AwesomeTimePickerTheme(
      {this.hourTheme, this.minuteTheme, this.secondTheme, this.ampmTheme});
}
