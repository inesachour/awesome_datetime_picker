import 'package:awesome_datetime_picker/src/theme/item_theme.dart';

/// Theme for the date picker, allowing customization of the year, month, and day items.
class AwesomeDatePickerTheme {
  /// The theme for the year item in the date picker.
  /// It customizes the appearance of the year picker element.
  final ItemTheme? yearTheme;

  /// The theme for the month item in the date picker.
  /// It customizes the appearance of the month picker element.
  final ItemTheme? monthTheme;

  /// The theme for the day item in the date picker.
  /// It customizes the appearance of the day picker element.
  final ItemTheme? dayTheme;

  const AwesomeDatePickerTheme(
      {this.yearTheme, this.monthTheme, this.dayTheme});
}
