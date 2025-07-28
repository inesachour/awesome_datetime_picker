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

  List<String> get months {
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
}
