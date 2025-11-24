import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/utils/awesome_time_utils.dart';
import 'package:flutter/material.dart';

class AwesomeTimePickerController extends ChangeNotifier {
  final AwesomeTime minTime;
  final AwesomeTime maxTime;
  final List<int>? excludedHours;

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
    this.excludedHours,
  })  : _selectedTime = (initialTime != null &&
                !initialTime.isBefore(minTime) &&
                !initialTime.isAfter(maxTime))
            ? initialTime
            : minTime,
        _selectedAmPm = AwesomeTimeUtils.getAmPm((initialTime != null &&
                !initialTime.isBefore(minTime) &&
                !initialTime.isAfter(maxTime))
            ? initialTime.hour
            : minTime.hour) {
    // Ensure initial time is valid regarding exclusions
    if (_isHourExcluded(_selectedTime.hour)) {
      final nextValid = _findNextValidTime(_selectedTime);
      _selectedTime = nextValid;
      _selectedAmPm = AwesomeTimeUtils.getAmPm(nextValid.hour);
    }
  }

  bool _isHourExcluded(int hour) {
    return excludedHours?.contains(hour) ?? false;
  }

  AwesomeTime _findNextValidTime(AwesomeTime time) {
    if (excludedHours == null || excludedHours!.isEmpty) return time;

    int currentHour = time.hour;
    int currentMinute = time.minute;

    // Try to find a valid hour within the next 24 hours
    for (int i = 0; i < 24; i++) {
      if (!_isHourExcluded(currentHour)) {
        return AwesomeTime(hour: currentHour, minute: currentMinute);
      }
      currentHour = (currentHour + 1) % 24;
    }
    return time; // Fallback if all hours are excluded
  }

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

    // Check exclusions
    if (_isHourExcluded(newTime.hour)) {
      newTime = _findNextValidTime(newTime);
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
      List<String> validHours = [];
      for (int i = minTime.hour; i <= maxTime.hour; i++) {
        if (!_isHourExcluded(i)) {
          validHours.add(i.toString());
        }
      }
      _cachedHours = validHours;
    }
    return _cachedHours!;
  }

  /// Hours in AM/PM mode
  List<String> get amPmHours {
    final cacheKey = _selectedAmPm;
    if (_cachedAmPmHours == null || _cachedAmPmHoursKey != cacheKey) {
      _cachedAmPmHours = _getHourRangeFor12HourFormat(_selectedAmPm);
      _cachedAmPmHoursKey = cacheKey;
    }
    return _cachedAmPmHours!;
  }

  /// Helper: Generate 12-hour format hour list for given AM/PM period
  /// Returns hours in format: 12, 1, 2, 3, ..., 11
  List<String> _getHourRangeFor12HourFormat(String amPm) {
    // Determine min and max hours in 12-hour format (12, 1-11)
    final minHour12 = _getMinHourFor12HourFormat(amPm);
    final maxHour12 = _getMaxHourFor12HourFormat(amPm);

    // Generate list: handle wrap-around where 12 comes before 1
    List<String> hours = [];

    // Helper to add if valid
    void addIfValid(int h12) {
      final h24 = AwesomeTimeUtils.convertTo24HourFormat(h12, amPm);
      if (!_isHourExcluded(h24)) {
        hours.add(h12.toString());
      }
    }

    if (minHour12 == 12) {
      addIfValid(12);
      for (int i = 1; i <= maxHour12 && i <= 11; i++) {
        addIfValid(i);
      }
    } else {
      for (int i = minHour12; i <= maxHour12; i++) {
        addIfValid(i);
      }
    }
    return hours;
  }

  /// Get minimum hour for the selected AM/PM period
  int _getMinHourFor12HourFormat(String amPm) {
    final minTimeIsInSamePeriod =
        AwesomeTimeUtils.getAmPm(minTime.hour) == amPm;
    if (minTimeIsInSamePeriod) {
      return AwesomeTimeUtils.convertTo12HourFormat(minTime.hour);
    } else {
      return 12; // Start from 12 (midnight for AM, noon for PM)
    }
  }

  /// Get maximum hour for the selected AM/PM period
  int _getMaxHourFor12HourFormat(String amPm) {
    final maxTimeIsInSamePeriod =
        AwesomeTimeUtils.getAmPm(maxTime.hour) == amPm;
    if (maxTimeIsInSamePeriod) {
      return AwesomeTimeUtils.convertTo12HourFormat(maxTime.hour);
    } else {
      return 11; // End at 11 (11 AM or 11 PM)
    }
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
