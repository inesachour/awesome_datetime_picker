// ignore_for_file: public_member_api_docs
// Internal implementation file: it is not exported by the package, so its
// members are documented at class level only.

import 'package:awesome_datetime_picker/src/core/models/awesome_date.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_datetime.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_time.dart';
import 'package:awesome_datetime_picker/src/core/utils/awesome_time_utils.dart';
import 'package:flutter/material.dart';

/// Logic behind [AwesomeDateTimePicker]: holds the selected date-time and
/// derives the time limits that apply to the currently selected date.
class DateTimePickerLogic extends ChangeNotifier {
  /// Earliest selectable date-time (moved up onto the minute grid).
  final AwesomeDateTime minDateTime;

  /// Latest selectable date-time (moved down onto the minute grid).
  final AwesomeDateTime maxDateTime;

  /// Distance in minutes between two selectable minutes (a divisor of 60).
  final int minuteInterval;

  /// Whether the picker has a seconds wheel. Without one the selected second
  /// is always 0.
  final bool showSeconds;

  /// Distance in seconds between two selectable seconds (a divisor of 60).
  /// Only used when [showSeconds] is true.
  final int secondInterval;

  AwesomeDateTime _selectedDateTime;
  AwesomeDateTime get selectedDateTime => _selectedDateTime;

  // Cache for min/max time
  AwesomeTime? _cachedMinTime;
  AwesomeDate? _cachedMinTimeDate;
  AwesomeTime? _cachedMaxTime;
  AwesomeDate? _cachedMaxTimeDate;

  DateTimePickerLogic({
    required AwesomeDateTime minDateTime,
    required AwesomeDateTime maxDateTime,
    AwesomeDateTime? initialDateTime,
    this.minuteInterval = 1,
    this.showSeconds = false,
    this.secondInterval = 1,
  })  : assert(minuteInterval >= 1 && 60 % minuteInterval == 0,
            'minuteInterval must be a divisor of 60'),
        assert(secondInterval >= 1 && 60 % secondInterval == 0,
            'secondInterval must be a divisor of 60'),
        minDateTime = _snap(minDateTime, minuteInterval,
            showSeconds ? secondInterval : 60, _Snap.up),
        maxDateTime = _snap(maxDateTime, minuteInterval,
            showSeconds ? secondInterval : 60, _Snap.down),
        _selectedDateTime = _snap(initialDateTime ?? _now(), minuteInterval,
            showSeconds ? secondInterval : 60, _Snap.nearest) {
    _clampDateTime();
  }

  /// Seconds between two valid times: [secondInterval], or 60 (whole minutes)
  /// when seconds are not shown.
  int get _secondStep => showSeconds ? secondInterval : 60;

  /// Moves [value] onto the minute/second grid. Works on UTC values so
  /// daylight-saving changes cannot shift the result; the grid may carry into
  /// the next day (e.g. 23:50 rounded up to a 15-minute grid).
  static AwesomeDateTime _snap(AwesomeDateTime value, int minuteInterval,
      int secondStep, _Snap direction) {
    if (minuteInterval == 1 && secondStep == 1) return value;
    final total = value.time.secondOfDay;
    final int snapped;
    switch (direction) {
      case _Snap.up:
        snapped =
            AwesomeTimeUtils.snapSecondsUp(total, minuteInterval, secondStep);
      case _Snap.down:
        snapped =
            AwesomeTimeUtils.snapSecondsDown(total, minuteInterval, secondStep);
      case _Snap.nearest:
        snapped = AwesomeTimeUtils.snapSecondsNearest(
            total, minuteInterval, secondStep);
    }
    final date = DateTime.utc(value.date.year, value.date.month, value.date.day)
        .add(Duration(seconds: snapped));
    return AwesomeDateTime(
      date: AwesomeDate(year: date.year, month: date.month, day: date.day),
      time: AwesomeTime(
          hour: date.hour, minute: date.minute, second: date.second),
    );
  }

  /// The current date and time, used when no initial value is given
  /// (it is clamped into the min/max range right after).
  static AwesomeDateTime _now() {
    final now = AwesomeDateTime.now();
    // Whole minutes: the seconds of "now" are noise for a default value.
    return now.copyWith(time: now.time.copyWith(second: 0));
  }

  // Central update method
  void _setDateTime(AwesomeDate date, AwesomeTime time) {
    final previous = _selectedDateTime;
    _selectedDateTime = AwesomeDateTime(date: date, time: time);
    _clampDateTime();
    if (_selectedDateTime == previous) return;

    // Invalidate time caches
    _cachedMinTime = null;
    _cachedMaxTime = null;

    notifyListeners();
  }

  // Clamp to min/max rules
  void _clampDateTime() {
    final minDT = minDateTime.toDateTime();
    final maxDT = maxDateTime.toDateTime();
    final native = _selectedDateTime.toDateTime();

    if (native.isBefore(minDT)) {
      _selectedDateTime = minDateTime;
    } else if (native.isAfter(maxDT)) {
      _selectedDateTime = maxDateTime;
    }
  }

  /// Selects [value], rounded to the minute interval and clamped into the
  /// min/max range. Does nothing if the selection is unchanged.
  void setDateTime(AwesomeDateTime value) {
    final snapped = _snap(value, minuteInterval, _secondStep, _Snap.nearest);
    _setDateTime(snapped.date, snapped.time);
  }

  // Public setters
  void setDate(AwesomeDate date) {
    _setDateTime(date, _selectedDateTime.time);
  }

  void setTime(AwesomeTime time) {
    _setDateTime(_selectedDateTime.date, time);
  }

  // Dynamic min/max time based on current date with caching
  AwesomeTime get minTime {
    if (_cachedMinTime == null ||
        _cachedMinTimeDate != _selectedDateTime.date) {
      _cachedMinTime = _selectedDateTime.date == minDateTime.date
          ? minDateTime.time
          : const AwesomeTime(hour: 0, minute: 0);
      _cachedMinTimeDate = _selectedDateTime.date;
    }
    return _cachedMinTime!;
  }

  AwesomeTime get maxTime {
    if (_cachedMaxTime == null ||
        _cachedMaxTimeDate != _selectedDateTime.date) {
      _cachedMaxTime = _selectedDateTime.date == maxDateTime.date
          ? maxDateTime.time
          : AwesomeTime(hour: 23, minute: 59, second: showSeconds ? 59 : 0);
      _cachedMaxTimeDate = _selectedDateTime.date;
    }
    return _cachedMaxTime!;
  }
}

/// Direction in which a value is moved onto the minute grid.
enum _Snap { up, down, nearest }
