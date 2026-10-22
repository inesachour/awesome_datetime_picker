import 'package:awesome_datetime_picker/src/core/models/awesome_datetime.dart';
import 'package:flutter/foundation.dart';

/// Reads and drives the selection of an [AwesomeDateTimePicker] from code.
///
/// Like a `TextEditingController`, it is optional: pass one to the picker's
/// `controller` parameter when you need to read the selected date-time outside
/// of `onChanged`, or to change it programmatically.
///
/// ```dart
/// final controller = AwesomeDateTimePickerController();
///
/// AwesomeDateTimePicker(controller: controller);
///
/// controller.value = AwesomeDateTime(
///   date: AwesomeDate(year: 2025, month: 12, day: 25),
///   time: const AwesomeTime(hour: 18, minute: 0),
/// ); // moves the wheels
/// print(controller.value); // always the date-time shown by the wheels
/// controller.reset(); // back to the initial value
/// ```
///
/// The picker keeps `value` in sync with the wheels: if you assign a value the
/// picker cannot select (outside its range, on an excluded weekday or hour, off
/// the minute interval, ...), the closest selectable value is shown and `value`
/// is updated to match.
///
/// The `onChanged` callback of the picker is only called for changes made by
/// the user, not for changes made through the controller; listen to the
/// controller to be notified of every change.
///
/// Dispose the controller when it is no longer needed.
class AwesomeDateTimePickerController extends ValueNotifier<AwesomeDateTime> {
  /// Creates a controller starting at [initialValue] (default: now).
  AwesomeDateTimePickerController({AwesomeDateTime? initialValue})
      : this._(initialValue ?? AwesomeDateTime.now());

  AwesomeDateTimePickerController._(super.value) : initialValue = value;

  /// The date-time this controller started with, restored by [reset].
  final AwesomeDateTime initialValue;

  /// Sets [value] back to [initialValue].
  void reset() => value = initialValue;
}
