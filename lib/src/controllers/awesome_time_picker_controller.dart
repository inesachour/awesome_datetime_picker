import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/utils/awesome_time_utils.dart';
import 'package:flutter/material.dart';

class AwesomeTimePickerController extends ChangeNotifier {
  final AwesomeTime minTime;
  final AwesomeTime maxTime;

  late AwesomeTime _selectedTime;
  late String _selectedAmPm;

  AwesomeTime get selectedTime => _selectedTime;
  String get selectedAmPm => _selectedAmPm;

  AwesomeTimePickerController({
    required this.minTime,
    required this.maxTime,
    AwesomeTime? initialTime,
  }) {
    _selectedTime = (initialTime != null &&
            AwesomeTimeUtils.isBefore(initialTime, maxTime) &&
            AwesomeTimeUtils.isAfter(initialTime, minTime))
        ? initialTime
        : minTime;

    _selectedAmPm = AwesomeTimeUtils.getAmPm(_selectedTime.hour);
  }

  /// Centralized setter — clamps and notifies
  void _setTime(int hour, int minute) {
    // Build new time
    var newTime = AwesomeTime(hour: hour, minute: minute);

    // Clamp to min/max range
    final minDT = DateTime(2025, 1, 1, minTime.hour, minTime.minute);
    final maxDT = DateTime(2025, 1, 1, maxTime.hour, maxTime.minute);
    final native = DateTime(2025, 1, 1, hour, minute);

    if (native.isBefore(minDT)) {
      newTime = minTime;
    } else if (native.isAfter(maxDT)) {
      newTime = maxTime;
    }

    _selectedTime = newTime;
    _selectedAmPm = AwesomeTimeUtils.getAmPm(newTime.hour);

    notifyListeners();
  }

  /// Update hour in 24-hour mode
  void onSelectedHourChanged(String newValue) {
    _setTime(int.parse(newValue), _selectedTime.minute);
  }

  /// Update hour in 12-hour (AM/PM) mode
  void onSelectedAmPmHourChanged(String newValue) {
    final hour12 = int.parse(newValue) == 0 ? 12 : int.parse(newValue);
    final hour24 =
        AwesomeTimeUtils.convertTo24HourFormat(hour12, _selectedAmPm);
    _setTime(hour24, _selectedTime.minute);
  }

  /// Update minutes
  void onSelectedMinuteChanged(String newValue) {
    _setTime(_selectedTime.hour, int.parse(newValue));
  }

  /// Update AM/PM
  void onSelectedAmPmChanged(String newValue) {
    _selectedAmPm = newValue;
    final toggledHour = AwesomeTimeUtils.toggleAmPm(_selectedTime.hour);
    _setTime(toggledHour, _selectedTime.minute);
  }

  // ===== Computed Lists =====

  /// Hours in 24-hour format
  List<String> get hours => List.generate(
        maxTime.hour - minTime.hour + 1,
        (i) => (minTime.hour + i).toString(),
      );

  /// Hours in AM/PM mode
  List<String> get amPmHours {
    int maxIndex = AwesomeTimeUtils.getAmPm(maxTime.hour) != _selectedAmPm
        ? 11
        : AwesomeTimeUtils.convertTo12HourFormat(maxTime.hour);

    int minIndex = AwesomeTimeUtils.getAmPm(minTime.hour) != _selectedAmPm
        ? 0
        : AwesomeTimeUtils.convertTo12HourFormat(minTime.hour);

    return List.generate(
      maxIndex - minIndex + 1,
      (i) => (minIndex + i).toString(),
    );
  }

  /// Minutes list
  List<String> get minutes {
    int minValue = 0;
    int maxValue = 59;

    if (_selectedTime.hour == maxTime.hour) {
      maxValue = maxTime.minute;
    }
    if (_selectedTime.hour == minTime.hour) {
      minValue = minTime.minute;
    }

    return List.generate(
      maxValue - minValue + 1,
      (i) => (i + minValue).toString(),
    );
  }

  /// AM/PM options
  List<String> get amPm {
    if (AwesomeTimeUtils.getAmPm(maxTime.hour) == "AM") return ["AM"];
    if (AwesomeTimeUtils.getAmPm(minTime.hour) == "PM") return ["PM"];
    return AwesomeTimeUtils.amPm;
  }
}
