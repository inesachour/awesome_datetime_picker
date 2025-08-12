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
    _selectedTime = initialTime != null &&
            AwesomeTimeUtils.isBefore(initialTime, maxTime) &&
            AwesomeTimeUtils.isAfter(initialTime, minTime)
        ? initialTime
        : minTime; //TODO NOW BUT VERIF
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
    int maxIndex = AwesomeTimeUtils.getAmPm(maxTime.hour) != selectedAmPm
        ? 11
        : AwesomeTimeUtils.convertTo12HourFormat(maxTime.hour);

    int minIndex = AwesomeTimeUtils.getAmPm(minTime.hour) != selectedAmPm
        ? 0
        : AwesomeTimeUtils.convertTo12HourFormat(minTime.hour);

    return List.generate(
        maxIndex - minIndex + 1, (i) => (minIndex + i).toString());
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

  List<String> get amPm {
    if (AwesomeTimeUtils.getAmPm(maxTime.hour) == "AM") {
      return ["AM"];
    } else if (AwesomeTimeUtils.getAmPm(minTime.hour) == "PM") {
      return ["PM"];
    }
    return AwesomeTimeUtils.amPm;
  }

  onSelectedHourChanged(String newValue) {
    selectedTime =
        AwesomeTime(hour: int.parse(newValue), minute: selectedTime.minute);

    DateTime nativeSelectedTime =
        DateTime(2025, 1, 1, selectedTime.hour, selectedTime.minute);
    if (nativeSelectedTime
        .isBefore(DateTime(2025, 1, 1, minTime.hour, minTime.minute))) {
      selectedTime = minTime;
    } else if (nativeSelectedTime
        .isAfter(DateTime(2025, 1, 1, maxTime.hour, maxTime.minute))) {
      selectedTime = maxTime;
    }
  }

  onSelectedAmPmHourChanged(String newValue) {
    selectedTime = AwesomeTime(
        hour: AwesomeTimeUtils.convertTo24HourFormat(
            int.parse(newValue) == 0 ? 12 : int.parse(newValue), selectedAmPm),
        minute: selectedTime.minute);

    DateTime nativeSelectedTime =
        DateTime(2025, 1, 1, selectedTime.hour, selectedTime.minute);
    if (nativeSelectedTime
        .isBefore(DateTime(2025, 1, 1, minTime.hour, minTime.minute))) {
      selectedTime = minTime;
    } else if (nativeSelectedTime
        .isAfter(DateTime(2025, 1, 1, maxTime.hour, maxTime.minute))) {
      selectedTime = maxTime;
    }
  }

  onSelectedMinuteChanged(String newValue) {
    selectedTime =
        AwesomeTime(hour: selectedTime.hour, minute: int.parse(newValue));

    DateTime nativeSelectedTime =
        DateTime(2025, 1, 1, selectedTime.hour, selectedTime.minute);
    if (nativeSelectedTime
        .isBefore(DateTime(2025, 1, 1, minTime.hour, minTime.minute))) {
      selectedTime = minTime;
    } else if (nativeSelectedTime
        .isAfter(DateTime(2025, 1, 1, maxTime.hour, maxTime.minute))) {
      selectedTime = maxTime;
    }
  }

  onSelectedAmPmChanged(String newValue) {
    selectedAmPm = newValue;
    selectedTime.hour = AwesomeTimeUtils.toggleAmPm(selectedTime.hour);
  }
}
