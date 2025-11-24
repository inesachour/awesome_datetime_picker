import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/material.dart';

class AwesomeDateTimePickerController extends ChangeNotifier {
  final AwesomeDateTime minDateTime;
  final AwesomeDateTime maxDateTime;

  AwesomeDateTime _selectedDateTime;
  AwesomeDateTime get selectedDateTime => _selectedDateTime;

  // Cache for min/max time
  AwesomeTime? _cachedMinTime;
  AwesomeDate? _cachedMinTimeDate;
  AwesomeTime? _cachedMaxTime;
  AwesomeDate? _cachedMaxTimeDate;

  AwesomeDateTimePickerController({
    required this.minDateTime,
    required this.maxDateTime,
    AwesomeDateTime? initialDateTime,
  }) : _selectedDateTime = initialDateTime ?? minDateTime {
    _clampDateTime();
  }

  // Central update method
  void _setDateTime(AwesomeDate date, AwesomeTime time) {
    _selectedDateTime = AwesomeDateTime(date: date, time: time);
    _clampDateTime();

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
          : const AwesomeTime(hour: 23, minute: 59);
      _cachedMaxTimeDate = _selectedDateTime.date;
    }
    return _cachedMaxTime!;
  }
}

