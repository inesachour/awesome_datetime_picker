import 'package:awesome_datetime_picker/src/theme/item_theme.dart';

/// Theme for the time picker, allowing customization of hour and minute items.
class AwesomeTimePickerTheme {
  /// The theme for the hour item in the time picker.
  /// It customizes the appearance of the hour picker element.
  final ItemTheme? hourTheme;

  /// The theme for the minute item in the time picker.
  /// It customizes the appearance of the minute picker element.
  final ItemTheme? minuteTheme;

  /// The theme for the AM/PM item in the time picker.
  /// It customizes the appearance of the AM/PM picker element.
  final ItemTheme? ampmTheme;

  const AwesomeTimePickerTheme(
      {this.hourTheme, this.minuteTheme, this.ampmTheme});
}
