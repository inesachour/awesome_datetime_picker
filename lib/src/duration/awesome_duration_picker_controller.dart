import 'package:flutter/foundation.dart';

/// Reads and drives the selection of an [AwesomeDurationPicker] from code.
///
/// Like a `TextEditingController`, it is optional: pass one to the picker's
/// `controller` parameter when you need to read the selected duration outside
/// of `onChanged`, or to change it programmatically.
///
/// ```dart
/// final controller = AwesomeDurationPickerController(
///   initialValue: const Duration(minutes: 25),
/// );
///
/// AwesomeDurationPicker(controller: controller);
///
/// controller.value = const Duration(hours: 1, minutes: 30); // moves the wheels
/// print(controller.value); // always the duration shown by the wheels
/// controller.reset(); // back to the initial value
/// ```
///
/// The picker keeps `value` in sync with the wheels: if you assign a duration
/// the picker cannot select (outside its limits, off the minute interval, with
/// seconds the wheels do not show...), the closest selectable duration is
/// shown and `value` is updated to match.
///
/// The `onChanged` callback of the picker is only called for changes made by
/// the user, not for changes made through the controller; listen to the
/// controller to be notified of every change.
///
/// Dispose the controller when it is no longer needed.
class AwesomeDurationPickerController extends ValueNotifier<Duration> {
  /// Creates a controller starting at [initialValue] (default: zero).
  AwesomeDurationPickerController({this.initialValue = Duration.zero})
      : super(initialValue);

  /// The duration this controller started with, restored by [reset].
  final Duration initialValue;

  /// Sets [value] back to [initialValue].
  void reset() => value = initialValue;
}
