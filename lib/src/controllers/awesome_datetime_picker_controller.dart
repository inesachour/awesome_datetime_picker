import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/material.dart';

class AwesomeDateTimePickerController extends ChangeNotifier {
  final AwesomeDateTime minDateTime;
  final AwesomeDateTime maxDateTime;

  late AwesomeDateTime _selectedDateTime;
  AwesomeDateTime get selectedDateTime => _selectedDateTime;

  AwesomeDateTimePickerController({
    required this.minDateTime,
    required this.maxDateTime,
    AwesomeDateTime? initialDateTime,
  }) {
    _selectedDateTime = initialDateTime ?? minDateTime;
    _clampDateTime();
  }

  // Central update method
  void _setDateTime(AwesomeDate date, AwesomeTime time) {
    _selectedDateTime = AwesomeDateTime(date: date, time: time);
    _clampDateTime();
    notifyListeners();
  }

  // Clamp to min/max rules
  void _clampDateTime() {
    final minDT = DateTime(
      minDateTime.date.year,
      minDateTime.date.month,
      minDateTime.date.day,
      minDateTime.time.hour,
      minDateTime.time.minute,
    );
    final maxDT = DateTime(
      maxDateTime.date.year,
      maxDateTime.date.month,
      maxDateTime.date.day,
      maxDateTime.time.hour,
      maxDateTime.time.minute,
    );
    final native = DateTime(
      _selectedDateTime.date.year,
      _selectedDateTime.date.month,
      _selectedDateTime.date.day,
      _selectedDateTime.time.hour,
      _selectedDateTime.time.minute,
    );

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

  // Dynamic min/max time based on current date
  AwesomeTime get minTime {
    return _selectedDateTime.date == minDateTime.date
        ? minDateTime.time
        : AwesomeTime(hour: 0, minute: 0);
  }

  AwesomeTime get maxTime {
    return _selectedDateTime.date == maxDateTime.date
        ? maxDateTime.time
        : AwesomeTime(hour: 23, minute: 59);
  }
}
