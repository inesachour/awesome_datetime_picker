// ignore_for_file: public_member_api_docs
// Internal implementation file: it is not exported by the package, so its
// members are documented at class level only.

import 'package:awesome_datetime_picker/src/core/models/awesome_time.dart';
import 'package:awesome_datetime_picker/src/core/utils/awesome_time_utils.dart';
import 'package:awesome_datetime_picker/src/core/utils/validation_utils.dart';
import 'package:flutter/material.dart';

/// Logic behind [AwesomeTimePicker]: holds the selected time, clamps it to the
/// min/max range, applies hour exclusions and builds each wheel's items for
/// both 12-hour and 24-hour formats.
class TimePickerLogic extends ChangeNotifier {
  /// Earliest selectable time (moved up onto the [minuteInterval] grid).
  final AwesomeTime minTime;

  /// Latest selectable time (moved down onto the [minuteInterval] grid).
  final AwesomeTime maxTime;
  final List<int>? excludedHours;

  /// Distance in minutes between two selectable minutes (a divisor of 60).
  final int minuteInterval;

  /// Whether the picker has a seconds wheel. Without one the selected second
  /// is always 0.
  final bool showSeconds;

  /// Distance in seconds between two selectable seconds (a divisor of 60).
  /// Only used when [showSeconds] is true.
  final int secondInterval;

  /// The second grid used to snap times: [secondInterval], or 60 (whole
  /// minutes only) when seconds are not shown.
  final int _secondStep;

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
  List<String>? _cachedSeconds;
  int? _cachedSecondsKey;
  List<String>? _cachedAmPm;

  TimePickerLogic({
    required AwesomeTime minTime,
    required AwesomeTime maxTime,
    AwesomeTime? initialTime,
    this.excludedHours,
    this.minuteInterval = 1,
    this.showSeconds = false,
    this.secondInterval = 1,
  })  : assert(minuteInterval >= 1 && 60 % minuteInterval == 0,
            'minuteInterval must be a divisor of 60'),
        assert(secondInterval >= 1 && 60 % secondInterval == 0,
            'secondInterval must be a divisor of 60'),
        _secondStep = showSeconds ? secondInterval : 60,
        minTime = AwesomeTimeUtils.snapUp(
            minTime, minuteInterval, showSeconds ? secondInterval : 60),
        maxTime = AwesomeTimeUtils.snapDown(
            maxTime, minuteInterval, showSeconds ? secondInterval : 60),
        _selectedTime = _initialSelection(
            initialTime,
            AwesomeTimeUtils.snapUp(
                minTime, minuteInterval, showSeconds ? secondInterval : 60),
            AwesomeTimeUtils.snapDown(
                maxTime, minuteInterval, showSeconds ? secondInterval : 60),
            minuteInterval,
            showSeconds ? secondInterval : 60),
        _selectedAmPm = AwesomeTimeUtils.getAmPm(_initialSelection(
                initialTime,
                AwesomeTimeUtils.snapUp(
                    minTime, minuteInterval, showSeconds ? secondInterval : 60),
                AwesomeTimeUtils.snapDown(
                    maxTime, minuteInterval, showSeconds ? secondInterval : 60),
                minuteInterval,
                showSeconds ? secondInterval : 60)
            .hour) {
    assert(
      ValidationUtils.hasSelectableTime(
          minTime: minTime, maxTime: maxTime, excludedHours: excludedHours),
      'excludedHours excludes every hour between minTime and maxTime',
    );
    // Ensure initial time is valid regarding exclusions
    if (_isHourExcluded(_selectedTime.hour)) {
      final nextValid = _findNextValidTime(_selectedTime);
      _selectedTime = nextValid;
      _selectedAmPm = AwesomeTimeUtils.getAmPm(nextValid.hour);
    }
  }

  /// Uses [initialTime] (default: [min]) moved onto the minute/second grid and
  /// clamped into [min]..[max].
  static AwesomeTime _initialSelection(AwesomeTime? initialTime,
      AwesomeTime min, AwesomeTime max, int interval, int secondStep) {
    if (initialTime == null) return min;
    final snapped =
        AwesomeTimeUtils.snapNearest(initialTime, interval, secondStep);
    if (snapped.isBefore(min)) return min;
    if (snapped.isAfter(max)) return max;
    return snapped;
  }

  bool _isHourExcluded(int hour) {
    return excludedHours?.contains(hour) ?? false;
  }

  /// Nearest selectable time to [time] that stays inside [minTime]..[maxTime]:
  /// searches the following hours first, then the preceding ones, keeping the
  /// minute (adjusted at the edges of the range).
  AwesomeTime _findNextValidTime(AwesomeTime time) {
    if (excludedHours == null || excludedHours!.isEmpty) return time;

    AwesomeTime? candidate(int hour) {
      if (_isHourExcluded(hour)) return null;
      return _clampTimeToRange(
          AwesomeTime(hour: hour, minute: time.minute, second: time.second));
    }

    for (int h = time.hour; h <= maxTime.hour; h++) {
      final found = candidate(h);
      if (found != null) return found;
    }
    for (int h = time.hour - 1; h >= minTime.hour; h--) {
      final found = candidate(h);
      if (found != null) return found;
    }
    return time; // Unreachable when the exclusions leave at least one hour
  }

  /// Centralized setter — clamps and notifies
  void _setTime(int hour, int minute, int second) {
    var newTime = AwesomeTime(hour: hour, minute: minute, second: second);

    newTime = _clampTimeToRange(newTime);
    newTime = _handleExclusions(newTime);

    final newAmPm = AwesomeTimeUtils.getAmPm(newTime.hour);
    // _selectedAmPm may have been changed ahead of time by the AM/PM wheel;
    // listeners must still be told so the wheel can go back if refused.
    if (newTime == _selectedTime && newAmPm == _selectedAmPm) return;

    _selectedTime = newTime;
    _selectedAmPm = newAmPm;

    // Invalidate caches that depend on selected time
    _cachedMinutes = null;
    _cachedSeconds = null;
    _cachedAmPmHours = null;

    notifyListeners();
  }

  AwesomeTime _clampTimeToRange(AwesomeTime time) {
    if (time.isBefore(minTime)) {
      return minTime;
    } else if (time.isAfter(maxTime)) {
      return maxTime;
    }
    return time;
  }

  AwesomeTime _handleExclusions(AwesomeTime time) {
    if (_isHourExcluded(time.hour)) {
      return _findNextValidTime(time);
    }
    return time;
  }

  /// Selects [time], rounded to the minute interval and moved to the closest
  /// selectable time if needed (range, excluded hours). Does nothing if the
  /// selection is unchanged.
  void setSelectedTime(AwesomeTime time) {
    final snapped =
        AwesomeTimeUtils.snapNearest(time, minuteInterval, _secondStep);
    _setTime(snapped.hour, snapped.minute, snapped.second);
  }

  /// Update hour in 24-hour mode
  void onSelectedHourChanged(String newValue) {
    _setTime(int.parse(newValue), _selectedTime.minute, _selectedTime.second);
  }

  /// Update hour in 12-hour (AM/PM) mode
  void onSelectedAmPmHourChanged(String newValue) {
    final hour12 = int.parse(newValue);
    final hour24 =
        AwesomeTimeUtils.convertTo24HourFormat(hour12, _selectedAmPm);
    _setTime(hour24, _selectedTime.minute, _selectedTime.second);
  }

  /// Update minutes
  void onSelectedMinuteChanged(String newValue) {
    _setTime(_selectedTime.hour, int.parse(newValue), _selectedTime.second);
  }

  /// Update seconds
  void onSelectedSecondChanged(String newValue) {
    _setTime(_selectedTime.hour, _selectedTime.minute, int.parse(newValue));
  }

  /// Update AM/PM
  void onSelectedAmPmChanged(String newValue) {
    _selectedAmPm = newValue;
    final toggledHour = AwesomeTimeUtils.toggleAmPm(_selectedTime.hour);
    _setTime(toggledHour, _selectedTime.minute, _selectedTime.second);
  }

  // ===== Computed Lists with Caching =====

  /// Hours in 24-hour format
  List<String> get hours {
    if (_cachedHours == null) {
      List<String> validHours = [];
      for (int i = minTime.hour; i <= maxTime.hour; i++) {
        if (!_isHourExcluded(i)) {
          validHours.add(AwesomeTimeUtils.twoDigits(i));
        }
      }
      _cachedHours = validHours;
    }
    return _cachedHours!;
  }

  /// Hours in 24-hour format, including the excluded ones (see
  /// [disabledHourIndices]).
  List<String> get allHours => [
        for (int i = minTime.hour; i <= maxTime.hour; i++)
          AwesomeTimeUtils.twoDigits(i),
      ];

  /// Positions in [allHours] of the hours that cannot be selected.
  Set<int> get disabledHourIndices => {
        for (int i = minTime.hour; i <= maxTime.hour; i++)
          if (_isHourExcluded(i)) i - minTime.hour,
      };

  /// Hours of the selected AM/PM period, including the excluded ones (see
  /// [disabledAmPmHourIndices]).
  List<String> get allAmPmHours =>
      _getHourRangeFor12HourFormat(_selectedAmPm, includeExcluded: true);

  /// Positions in [allAmPmHours] of the hours that cannot be selected.
  Set<int> get disabledAmPmHourIndices {
    final hours = allAmPmHours;
    return {
      for (int i = 0; i < hours.length; i++)
        if (_isHourExcluded(AwesomeTimeUtils.convertTo24HourFormat(
            int.parse(hours[i]), _selectedAmPm)))
          i,
    };
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
  List<String> _getHourRangeFor12HourFormat(String amPm,
      {bool includeExcluded = false}) {
    // Determine min and max hours in 12-hour format (12, 1-11)
    final minHour12 = _getMinHourFor12HourFormat(amPm);
    final maxHour12 = _getMaxHourFor12HourFormat(amPm);

    // Generate list: handle wrap-around where 12 comes before 1
    List<String> hours = [];

    // Helper to add if valid
    void addIfValid(int h12) {
      final h24 = AwesomeTimeUtils.convertTo24HourFormat(h12, amPm);
      if (includeExcluded || !_isHourExcluded(h24)) {
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

      // minValue and maxValue are on the grid: they are 0 / 59 rounded onto it
      // or the (snapped) minTime / maxTime minutes.
      _cachedMinutes = [
        for (int m = minValue; m <= maxValue; m += minuteInterval)
          AwesomeTimeUtils.twoDigits(m),
      ];
      _cachedMinutesHour = _selectedTime.hour;
    }
    return _cachedMinutes!;
  }

  /// Seconds list (only used when [showSeconds] is true)
  List<String> get seconds {
    final key = _selectedTime.hour * 60 + _selectedTime.minute;
    if (_cachedSeconds == null || _cachedSecondsKey != key) {
      int minValue = 0;
      int maxValue = (59 ~/ secondInterval) * secondInterval;

      if (_selectedTime.hour == minTime.hour &&
          _selectedTime.minute == minTime.minute) {
        minValue = minTime.second;
      }
      if (_selectedTime.hour == maxTime.hour &&
          _selectedTime.minute == maxTime.minute) {
        maxValue = maxTime.second;
      }

      // minValue and maxValue are on the grid (the bounds were snapped)
      _cachedSeconds = [
        for (int sec = minValue; sec <= maxValue; sec += secondInterval)
          AwesomeTimeUtils.twoDigits(sec),
      ];
      _cachedSecondsKey = key;
    }
    return _cachedSeconds!;
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
