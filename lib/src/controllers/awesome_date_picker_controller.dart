import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/utils/awesome_date_utils.dart';
import 'package:flutter/material.dart';

class AwesomeDatePickerController extends ChangeNotifier {
  final AwesomeDate minDate;
  final AwesomeDate maxDate;
  final LocaleType locale;
  //final bool Function(DateTime)? dayFilter;

  late AwesomeDate _selectedDate;

  AwesomeDate get selectedDate => _selectedDate;

  AwesomeDatePickerController({
    required this.minDate,
    required this.maxDate,
    required this.locale,
    AwesomeDate? initialDate,
    //this.dayFilter,
  }) {
    _selectedDate = initialDate ?? minDate; //TODO TODAY BUT VERIF
  }

  set selectedDate(AwesomeDate date) {
    _selectedDate = date;
    notifyListeners();
  }

  List<String> get years {
    return List.generate(
        maxDate.year - minDate.year + 1, (i) => (minDate.year + i).toString());
  }

  List<String> get monthsNumbers {
    int maxValue = 12, minValue = 1;
    if (selectedDate.year == maxDate.year) {
      maxValue = maxDate.month;
    }
    if (selectedDate.year == minDate.year) {
      minValue = minDate.month;
    }
    return List.generate(
        maxValue - minValue + 1, (index) => (index + minValue).toString());
  }

  List<String> get monthsNames {
    int maxValue = 12, minValue = 1;
    if (selectedDate.year == maxDate.year) {
      maxValue = maxDate.month;
    }
    if (selectedDate.year == minDate.year) {
      minValue = minDate.month;
    }
    List<String> allMonthsNames = AwesomeDateUtils.getMonthNames(locale);
    return allMonthsNames.sublist(minValue - 1, maxValue);
  }

  List<String> get days {
    int maxValue =
            DateUtils.getDaysInMonth(selectedDate.year, selectedDate.month),
        minValue = 1;
    if (selectedDate.year == maxDate.year &&
        selectedDate.month == maxDate.month) {
      maxValue = maxDate.day;
    }
    if (selectedDate.year == minDate.year &&
        selectedDate.month == minDate.month) {
      minValue = minDate.day;
    }

    List<String> allDays =
        AwesomeDateUtils.getMonthDays(selectedDate.year, selectedDate.month);
    return allDays.sublist(minValue - 1, maxValue);
  }

  onSelectedYearChanged(int index) {
    int day = selectedDate.day;
    int daysInMonth =
        DateUtils.getDaysInMonth(index + minDate.year, selectedDate.month);
    if (selectedDate.day > daysInMonth) {
      day = daysInMonth;
    }
    selectedDate = AwesomeDate(
        year: index + minDate.year, month: selectedDate.month, day: day);

    DateTime nativeSelectedDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    if (nativeSelectedDate
        .isBefore(DateTime(minDate.year, minDate.month, minDate.day))) {
      selectedDate = minDate;
    } else if (nativeSelectedDate
        .isAfter(DateTime(maxDate.year, maxDate.month, maxDate.day))) {
      selectedDate = maxDate;
    }
  }

  onSelectedMonthNumberChanged(int index) {
    int day = selectedDate.day;
    int daysInMonth = DateUtils.getDaysInMonth(selectedDate.year, index + 1);
    if (selectedDate.day > daysInMonth) {
      day = daysInMonth;
    }
    selectedDate =
        AwesomeDate(year: selectedDate.year, month: index + 1, day: day);

    DateTime nativeSelectedDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    if (nativeSelectedDate
        .isBefore(DateTime(minDate.year, minDate.month, minDate.day))) {
      selectedDate = minDate;
    } else if (nativeSelectedDate
        .isAfter(DateTime(maxDate.year, maxDate.month, maxDate.day))) {
      selectedDate = maxDate;
    }
  }

  onSelectedMonthNameChanged(int index) {
    int day = selectedDate.day;
    int daysInMonth = DateUtils.getDaysInMonth(selectedDate.year, index + 1);
    if (selectedDate.day > daysInMonth) {
      day = daysInMonth;
    }
    selectedDate =
        AwesomeDate(year: selectedDate.year, month: index + 1, day: day);

    DateTime nativeSelectedDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    if (nativeSelectedDate
        .isBefore(DateTime(minDate.year, minDate.month, minDate.day))) {
      selectedDate = minDate;
    } else if (nativeSelectedDate
        .isAfter(DateTime(maxDate.year, maxDate.month, maxDate.day))) {
      selectedDate = maxDate;
    }
  }

  onSelectedDayChanged(int index) {
    selectedDate = AwesomeDate(
        year: selectedDate.year, month: selectedDate.month, day: index + 1);

    DateTime nativeSelectedDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    if (nativeSelectedDate
        .isBefore(DateTime(minDate.year, minDate.month, minDate.day))) {
      selectedDate = minDate;
    } else if (nativeSelectedDate
        .isAfter(DateTime(maxDate.year, maxDate.month, maxDate.day))) {
      selectedDate = maxDate;
    }
  }
}
