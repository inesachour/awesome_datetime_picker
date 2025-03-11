import 'package:awesome_datetime_picker/src/data/picker_type.dart';

/// Enum representing different date formats for the [AwesomeDatePicker] and [AwesomeDateTimePicker] widgets.
enum AwesomeDateFormat {
  /// Day, Month (number), Year format (e.g., 12/05/2023).
  dMy([PickerType.day, PickerType.month_number, PickerType.year]),

  /// Day, Month (text), Year format (e.g., 12 May 2023).
  dMMy([PickerType.day, PickerType.month_text, PickerType.year]),

  /// Year, Month (number), Day format (e.g., 2023/05/12).
  yMd([PickerType.year, PickerType.month_number, PickerType.day]),

  /// Year, Month (text), Day format (e.g., 2023 May 12).
  yMMd([PickerType.year, PickerType.month_text, PickerType.day]);

  final List<PickerType> value;

  const AwesomeDateFormat(this.value);
}

/// Enum representing different time formats for the [AwesomeTimePicker] and [AwesomeDateTimePicker] widgets.
enum AwesomeTimeFormat {
  /// 12-hour time format (hour and minute) (e.g., 2:30 PM).
  hm([PickerType.hour_12, PickerType.minute, PickerType.am_pm]),

  /// 24-hour time format (hour and minute) (e.g., 14:30).
  Hm([PickerType.hour_24, PickerType.minute]);

  final List<PickerType> value;

  const AwesomeTimeFormat(this.value);
}
