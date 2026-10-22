import 'package:awesome_datetime_picker/src/core/models/awesome_date.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_date_range.dart';
import 'package:flutter/foundation.dart';

/// Reads and drives the selection of an [AwesomeDateRangePicker] from code.
///
/// Like a `TextEditingController`, it is optional: pass one to the picker's
/// `controller` parameter when you need to read the selected range outside of
/// `onChanged`, or to change it programmatically.
///
/// ```dart
/// final controller = AwesomeDateRangePickerController();
///
/// AwesomeDateRangePicker(controller: controller);
///
/// controller.value = AwesomeDateRange(
///   start: AwesomeDate(year: 2025, month: 12, day: 24),
///   end: AwesomeDate(year: 2025, month: 12, day: 31),
/// ); // moves the wheels
/// print(controller.value); // always the range shown by the wheels
/// controller.reset(); // back to the initial value
/// ```
///
/// The picker keeps `value` in sync with the wheels: if you assign a range the
/// picker cannot select (outside its limits, too short or too long, on
/// excluded dates, ...), the closest selectable range is shown and `value` is
/// updated to match.
///
/// Dispose the controller when it is no longer needed.
class AwesomeDateRangePickerController extends ValueNotifier<AwesomeDateRange> {
  /// Creates a controller starting at [initialValue] (default: from today to
  /// today).
  AwesomeDateRangePickerController({AwesomeDateRange? initialValue})
      : this._(initialValue ?? _today());

  AwesomeDateRangePickerController._(super.value) : initialValue = value;

  /// The range this controller started with, restored by [reset].
  final AwesomeDateRange initialValue;

  /// Sets [value] back to [initialValue].
  void reset() => value = initialValue;

  static AwesomeDateRange _today() {
    final today = AwesomeDate.today();
    return AwesomeDateRange(start: today, end: today);
  }
}
