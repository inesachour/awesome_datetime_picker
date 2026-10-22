import 'package:awesome_datetime_picker/src/core/models/awesome_time.dart';
import 'package:flutter/foundation.dart';

/// Reads and drives the selection of an [AwesomeTimePicker] from code.
///
/// Like a `TextEditingController`, it is optional: pass one to the picker's
/// `controller` parameter when you need to read the selected time outside of
/// `onChanged`, or to change it programmatically.
///
/// ```dart
/// final controller = AwesomeTimePickerController(
///   initialValue: const AwesomeTime(hour: 9, minute: 30),
/// );
///
/// AwesomeTimePicker(controller: controller);
///
/// controller.value = const AwesomeTime(hour: 14, minute: 0); // moves the wheels
/// print(controller.value); // always the time shown by the wheels
/// controller.reset(); // back to the initial value
/// ```
///
/// The picker keeps `value` in sync with the wheels: if you assign a time the
/// picker cannot select (outside its range, in an excluded hour, off the
/// minute interval, ...), the closest selectable time is shown and `value` is
/// updated to match. The value is always on a 24-hour clock.
///
/// The `onChanged` callback of the picker is only called for changes made by
/// the user, not for changes made through the controller; listen to the
/// controller to be notified of every change.
///
/// Dispose the controller when it is no longer needed.
class AwesomeTimePickerController extends ValueNotifier<AwesomeTime> {
  /// Creates a controller starting at [initialValue] (default: the current
  /// time).
  AwesomeTimePickerController({AwesomeTime? initialValue})
      : this._(initialValue ?? AwesomeTime.now());

  AwesomeTimePickerController._(super.value) : initialValue = value;

  /// The time this controller started with, restored by [reset].
  final AwesomeTime initialValue;

  /// Sets [value] back to [initialValue].
  void reset() => value = initialValue;
}
