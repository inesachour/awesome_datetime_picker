import 'package:awesome_datetime_picker/src/core/data/picker_type.dart';

/// Enum representing different date formats for the [AwesomeDatePicker] and [AwesomeDateTimePicker] widgets.
enum AwesomeDateFormat {
  /// Day, Month (number), Year format (e.g., 12/05/2023).
  dMy([PickerType.day, PickerType.month_number, PickerType.year]),

  /// Day, Month (text), Year format (e.g., 12 May 2023).
  dMMy([PickerType.day, PickerType.month_text, PickerType.year]),

  /// Year, Month (number), Day format (e.g., 2023/05/12).
  yMd([PickerType.year, PickerType.month_number, PickerType.day]),

  /// Year, Month (text), Day format (e.g., 2023 May 12).
  yMMd([PickerType.year, PickerType.month_text, PickerType.day]),

  /// Month (number), Year format without a day wheel (e.g., 05/2023).
  ///
  /// The selected date is the first day of the chosen month. Day exclusions
  /// do not apply.
  // ignore: constant_identifier_names
  My([PickerType.month_number, PickerType.year]),

  /// Month (text), Year format without a day wheel (e.g., May 2023).
  ///
  /// The selected date is the first day of the chosen month. Day exclusions
  /// do not apply.
  // ignore: constant_identifier_names
  MMy([PickerType.month_text, PickerType.year]),

  /// Year, Month (number) format without a day wheel (e.g., 2023/05).
  ///
  /// The selected date is the first day of the chosen month. Day exclusions
  /// do not apply.
  yM([PickerType.year, PickerType.month_number]),

  /// Year, Month (text) format without a day wheel (e.g., 2023 May).
  ///
  /// The selected date is the first day of the chosen month. Day exclusions
  /// do not apply.
  yMM([PickerType.year, PickerType.month_text]),

  /// Day, Month (number) format without a year wheel (e.g., 12/05).
  ///
  /// For birthdays and dates that repeat every year. The year stays the one of
  /// the initial date (2000, a leap year, when there is none) so that
  /// 29 February can be selected. Limits and day exclusions do not apply.
  dM([PickerType.day, PickerType.month_number]),

  /// Day, Month (text) format without a year wheel (e.g., 12 May).
  ///
  /// For birthdays and dates that repeat every year. The year stays the one of
  /// the initial date (2000, a leap year, when there is none) so that
  /// 29 February can be selected. Limits and day exclusions do not apply.
  dMM([PickerType.day, PickerType.month_text]),

  /// Month (number), Day format without a year wheel (e.g., 05/12).
  ///
  /// For birthdays and dates that repeat every year. The year stays the one of
  /// the initial date (2000, a leap year, when there is none) so that
  /// 29 February can be selected. Limits and day exclusions do not apply.
  // ignore: constant_identifier_names
  Md([PickerType.month_number, PickerType.day]),

  /// Month (text), Day format without a year wheel (e.g., May 12).
  ///
  /// For birthdays and dates that repeat every year. The year stays the one of
  /// the initial date (2000, a leap year, when there is none) so that
  /// 29 February can be selected. Limits and day exclusions do not apply.
  // ignore: constant_identifier_names
  MMd([PickerType.month_text, PickerType.day]);

  /// The wheels to display, in order from left to right.
  final List<PickerType> value;

  /// Whether this format shows a day wheel. Formats without one select whole
  /// months: the value is the first day of the chosen month.
  bool get hasDay => value.contains(PickerType.day);

  /// Whether this format shows a year wheel. Formats without one (`dM`, `dMM`,
  /// `Md`, `MMd`) pick a day of the year that repeats: the year stays fixed.
  bool get hasYear => value.contains(PickerType.year);

  /// Creates a date format from the ordered list of wheels it displays.
  const AwesomeDateFormat(this.value);
}

/// Enum representing different time formats for the [AwesomeTimePicker] and [AwesomeDateTimePicker] widgets.
enum AwesomeTimeFormat {
  /// 12-hour time format (hour and minute) (e.g., 2:30 PM).
  hm([PickerType.hour_12, PickerType.minute, PickerType.am_pm]),

  /// 24-hour time format (hour and minute) (e.g., 14:30).
  // ignore: constant_identifier_names
  Hm([PickerType.hour_24, PickerType.minute]),

  /// 12-hour time format with seconds (e.g., 2:30:15 PM).
  hms([
    PickerType.hour_12,
    PickerType.minute,
    PickerType.second,
    PickerType.am_pm
  ]),

  /// 24-hour time format with seconds (e.g., 14:30:15).
  // ignore: constant_identifier_names
  Hms([PickerType.hour_24, PickerType.minute, PickerType.second]);

  /// The wheels to display, in order from left to right.
  final List<PickerType> value;

  /// Whether this format shows a seconds wheel.
  bool get hasSeconds => value.contains(PickerType.second);

  /// Creates a time format from the ordered list of wheels it displays.
  const AwesomeTimeFormat(this.value);
}

/// Enum representing which wheels an [AwesomeDurationPicker] displays.
enum AwesomeDurationFormat {
  /// Hours and minutes (e.g., 1 h 30 min). The seconds are 0.
  hm,

  /// Minutes and seconds (e.g., 12 min 30 s). The minutes are not limited to
  /// 59: they count the whole duration, up to [AwesomeDurationPicker.maxDuration].
  ms,

  /// Hours, minutes and seconds (e.g., 1 h 30 min 15 s).
  hms;

  /// Whether this format shows an hours wheel.
  bool get hasHours => this != ms;

  /// Whether this format shows a seconds wheel.
  bool get hasSeconds => this != hm;
}
