import 'package:awesome_datetime_picker/src/core/models/awesome_date.dart';
import 'package:flutter/foundation.dart';

/// Reads and drives the selection of an [AwesomeDatePicker] from code.
///
/// Like a `TextEditingController`, it is optional: pass one to the picker's
/// `controller` parameter when you need to read the selected date outside of
/// `onChanged`, or to change it programmatically.
///
/// ```dart
/// final controller = AwesomeDatePickerController(
///   initialValue: AwesomeDate(year: 2025, month: 6, day: 15),
/// );
///
/// AwesomeDatePicker(controller: controller);
///
/// controller.value = AwesomeDate(year: 2025, month: 12, day: 25); // moves the wheels
/// print(controller.value); // always the date shown by the wheels
/// controller.reset(); // back to the initial value
/// ```
///
/// The picker keeps `value` in sync with the wheels: if you assign a date the
/// picker cannot select (outside its range, on an excluded weekday, ...), the
/// closest selectable date is shown and `value` is updated to match.
///
/// The `onChanged` callback of the picker is only called for changes made by
/// the user, not for changes made through the controller; listen to the
/// controller to be notified of every change.
///
/// Dispose the controller when it is no longer needed.
class AwesomeDatePickerController extends ValueNotifier<AwesomeDate> {
  /// Creates a controller starting at [initialValue] (default: today).
  AwesomeDatePickerController({AwesomeDate? initialValue})
      : this._(initialValue ?? AwesomeDate.today());

  AwesomeDatePickerController._(super.value) : initialValue = value;

  /// The date this controller started with, restored by [reset].
  final AwesomeDate initialValue;

  /// Sets [value] back to [initialValue].
  void reset() => value = initialValue;
}
