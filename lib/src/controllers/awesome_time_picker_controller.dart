import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/utils/awesome_time_utils.dart';
import 'package:flutter/material.dart';

class AwesomeTimePickerController extends ChangeNotifier {
  final AwesomeTime minTime;
  final AwesomeTime maxTime;

  AwesomeTime _selectedTime;
  String _selectedAmPm;

  AwesomeTime get selectedTime => _selectedTime;
  String get selectedAmPm => _selectedAmPm;

  // Cache for computed lists
  List<String>? _cachedHours;
  List<String>? _cachedAmPmHours;
  String? _cachedAmPmHoursKey;
  List<String>? _cachedMinutes;
  int? _cachedMinutesHour;
  List<String>? _cachedAmPm;

  AwesomeTimePickerController({
    required this.minTime,
    required this.maxTime,
    AwesomeTime? initialTime,
  })  : _selectedTime = (initialTime != null &&
                !initialTime.isBefore(minTime) &&
                !initialTime.isAfter(maxTime))
            ? initialTime
            : minTime,
        _selectedAmPm = AwesomeTimeUtils.getAmPm((initialTime != null &&
                !initialTime.isBefore(minTime) &&
                !initialTime.isAfter(maxTime))
            ? initialTime.hour
            : minTime.hour);

  /// Centralized setter — clamps and notifies
  void _setTime(int hour, int minute) {
    // Build new time
    var newTime = AwesomeTime(hour: hour, minute: minute);

    // Clamp to min/max range
    if (newTime.isBefore(minTime)) {
      newTime = minTime;
    } else if (newTime.isAfter(maxTime)) {
      newTime = maxTime;
    }

    _selectedTime = newTime;
    _selectedAmPm = AwesomeTimeUtils.getAmPm(newTime.hour);

    // Invalidate caches that depend on selected time
    _cachedMinutes = null;
    _cachedAmPmHours = null;

    notifyListeners();
  }

  /// Update hour in 24-hour mode
  void onSelectedHourChanged(String newValue) {
    _setTime(int.parse(newValue), _selectedTime.minute);
  }

  /// Update hour in 12-hour (AM/PM) mode
  void onSelectedAmPmHourChanged(String newValue) {
    final hour12 = int.parse(newValue);
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

  // ===== Computed Lists with Caching =====

  /// Hours in 24-hour format
  List<String> get hours {
    if (_cachedHours == null) {
      _cachedHours = List.generate(
        maxTime.hour - minTime.hour + 1,
        (i) => (minTime.hour + i).toString(),
      );
    }
    return _cachedHours!;
  }

  /// Hours in AM/PM mode
  List<String> get amPmHours {
    final cacheKey = _selectedAmPm;
    if (_cachedAmPmHours == null || _cachedAmPmHoursKey != cacheKey) {
      // Determine the range of hours available for the selected AM/PM
      int minHour12, maxHour12;

      if (_selectedAmPm == "AM") {
        // AM: hours 12, 1-11 (representing 00:00-11:59)
        if (AwesomeTimeUtils.getAmPm(minTime.hour) == "AM") {
          minHour12 = AwesomeTimeUtils.convertTo12HourFormat(minTime.hour);
        } else {
          minHour12 = 12; // Start from midnight
        }

        if (AwesomeTimeUtils.getAmPm(maxTime.hour) == "AM") {
          maxHour12 = AwesomeTimeUtils.convertTo12HourFormat(maxTime.hour);
        } else {
          maxHour12 = 11; // End at 11 AM
        }
      } else {
        // PM: hours 12, 1-11 (representing 12:00-23:59)
        if (AwesomeTimeUtils.getAmPm(minTime.hour) == "PM") {
          minHour12 = AwesomeTimeUtils.convertTo12HourFormat(minTime.hour);
        } else {
          minHour12 = 12; // Start from noon
        }

        if (AwesomeTimeUtils.getAmPm(maxTime.hour) == "PM") {
          maxHour12 = AwesomeTimeUtils.convertTo12HourFormat(maxTime.hour);
        } else {
          maxHour12 = 11; // End at 11 PM
        }
      }

      // Generate the list: 12, 1, 2, ..., 11
      // We need to handle the wrap-around (12 comes before 1)
      List<String> hours = [];
      if (minHour12 == 12) {
        hours.add("12");
        for (int i = 1; i <= maxHour12 && i <= 11; i++) {
          hours.add(i.toString());
        }
      } else {
        // minHour12 is 1-11
        for (int i = minHour12; i <= maxHour12 && i <= 11; i++) {
          hours.add(i.toString());
        }
      }

      _cachedAmPmHours = hours;
      _cachedAmPmHoursKey = cacheKey;
    }
    return _cachedAmPmHours!;
  }

  /// Minutes list
  List<String> get minutes {
    if (_cachedMinutes == null || _cachedMinutesHour != _selectedTime.hour) {
      int minValue = 0;
      int maxValue = 59;

      if (_selectedTime.hour == maxTime.hour) {
        maxValue = maxTime.minute;
      }
      if (_selectedTime.hour == minTime.hour) {
        minValue = minTime.minute;
      }

      _cachedMinutes = List.generate(
        maxValue - minValue + 1,
        (i) => (i + minValue).toString(),
      );
      _cachedMinutesHour = _selectedTime.hour;
    }
    return _cachedMinutes!;
  }

  /// AM/PM options
  List<String> get amPm {
    if (_cachedAmPm == null) {
      if (AwesomeTimeUtils.getAmPm(maxTime.hour) == "AM") {
        _cachedAmPm = ["AM"];
      } else if (AwesomeTimeUtils.getAmPm(minTime.hour) == "PM") {
        _cachedAmPm = ["PM"];
      } else {
        _cachedAmPm = AwesomeTimeUtils.amPm;
      }
    }
    return _cachedAmPm!;
  }
}
