import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/utils/awesome_date_utils.dart';
import 'package:awesome_datetime_picker/src/utils/awesome_time_utils.dart';
import 'package:awesome_datetime_picker/src/utils/validation_utils.dart';
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
    _selectedDateTime = initialDateTime ?? minDateTime; //TODO NOW BUT VERIF
  }

  set selectedTime(AwesomeTime time) {
    _selectedDateTime.time = time;
    notifyListeners();
  }

  set selectedDate(AwesomeDate date) {
    _selectedDateTime.date = date;
    if (date.year == maxDateTime.date.year &&
        date.month == maxDateTime.date.month &&
        date.day == maxDateTime.date.day) {
      if (AwesomeTimeUtils.isAfter(_selectedDateTime.time, maxDateTime.time)) {
        _selectedDateTime.time = maxDateTime.time;
      }
    } else if (date.year == minDateTime.date.year &&
        date.month == minDateTime.date.month &&
        date.day == minDateTime.date.day) {
      if (AwesomeTimeUtils.isBefore(_selectedDateTime.time, minDateTime.time)) {
        _selectedDateTime.time = minDateTime.time;
      }
    }
    notifyListeners();
  }

  AwesomeTime get minTime {
    if (_selectedDateTime.date.year == minDateTime.date.year &&
        _selectedDateTime.date.month == minDateTime.date.month &&
        _selectedDateTime.date.day == minDateTime.date.day) {
      return minDateTime.time;
    }
    return AwesomeTime(hour: 00, minute: 00);
  }

  AwesomeTime get maxTime {
    if (_selectedDateTime.date.year == maxDateTime.date.year &&
        _selectedDateTime.date.month == maxDateTime.date.month &&
        _selectedDateTime.date.day == maxDateTime.date.day) {
      return maxDateTime.time;
    }
    return AwesomeTime(hour: 23, minute: 59);
  }
}
