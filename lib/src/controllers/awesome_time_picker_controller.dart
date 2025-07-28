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
    _selectedTime = initialTime ?? minTime; //TODO NOW BUT VERIF
    _selectedAmPm = AwesomeTimeUtils.getAmPm(selectedTime.hour);
  }

  set selectedTime(AwesomeTime time) {
    _selectedTime = time;
    notifyListeners();
  }

  set selectedAmPm(String amPm) {
    _selectedAmPm = amPm;
    notifyListeners();
  }

  List<String> get hours {
    return List.generate(
        maxTime.hour - minTime.hour + 1, (i) => (minTime.hour + i).toString());
  }

  List<String> get amPmHours {
    int maxValue = AwesomeTimeUtils.getAmPm(maxTime.hour) != selectedAmPm
        ? 11
        : hours.indexOf(
            AwesomeTimeUtils.convertTo12HourFormat(maxTime.hour).toString());

    int minValue = AwesomeTimeUtils.getAmPm(minTime.hour) != selectedAmPm
        ? 0
        : hours.indexOf(
            AwesomeTimeUtils.convertTo12HourFormat(minTime.hour).toString());

    return List.generate(
        maxValue - minValue + 1, (i) => (minValue + i).toString());
  }

  List<String> get minutes {
    int maxValue = 59, minValue = 0;
    if (selectedTime.hour == maxTime.hour) {
      maxValue = maxTime.minute;
    }
    if (selectedTime.hour == minTime.hour) {
      minValue = minTime.minute;
    }
    return List.generate(
        maxValue - minValue + 1, (index) => (index + minValue).toString());
  }
}
