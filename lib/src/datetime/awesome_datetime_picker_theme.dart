import 'package:awesome_datetime_picker/src/date/awesome_date_picker_theme.dart';
import 'package:awesome_datetime_picker/src/time/awesome_time_picker_theme.dart';

/// Theme for the datetime picker, allowing customization of both date and time pickers.
class AwesomeDateTimePickerTheme {
  /// The theme for the date picker.
  /// It customizes the appearance of the date picker elements.
  final AwesomeDatePickerTheme? datePickerTheme;

  /// The theme for the time picker.
  /// It customizes the appearance of the time picker elements.
  final AwesomeTimePickerTheme? timePickerTheme;

  /// Creates a date-time picker theme. Unset parts use the picker defaults.
  const AwesomeDateTimePickerTheme(
      {this.datePickerTheme, this.timePickerTheme});
}
