/// The kind of value a single wheel of a picker displays.
///
/// Date and time formats are expressed as ordered lists of these types.
enum PickerType {
  /// Day of the month (1-31).
  day,

  /// Month as a number (1-12).
  // ignore: constant_identifier_names
  month_number,

  /// Month as a localized name (e.g. "January").
  // ignore: constant_identifier_names
  month_text,

  /// Four-digit year.
  year,

  /// Hour on a 12-hour clock (12, 1-11).
  // ignore: constant_identifier_names
  hour_12,

  /// Hour on a 24-hour clock (0-23).
  // ignore: constant_identifier_names
  hour_24,

  /// Minute (0-59).
  minute,

  /// Day period, "AM" or "PM".
  // ignore: constant_identifier_names
  am_pm,
}
