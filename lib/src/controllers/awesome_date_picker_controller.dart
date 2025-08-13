import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/utils/awesome_date_utils.dart';
import 'package:flutter/material.dart';

class AwesomeDatePickerController extends ChangeNotifier {
  final AwesomeDate minDate;
  final AwesomeDate maxDate;
  final LocaleType locale;

  late AwesomeDate _selectedDate;
  AwesomeDate get selectedDate => _selectedDate;

  AwesomeDatePickerController({
    required this.minDate,
    required this.maxDate,
    required this.locale,
    AwesomeDate? initialDate,
  }) {
    _selectedDate = initialDate ?? minDate;
  }

  /// Centralized setter
  void _setDate(int year, int month, int day) {
    // Clamp day to month max
    final maxDay = DateUtils.getDaysInMonth(year, month);
    if (day > maxDay) day = maxDay;

    // Build new date
    var newDate = AwesomeDate(year: year, month: month, day: day);

    // Clamp to min/max range
    final minDT = DateTime(minDate.year, minDate.month, minDate.day);
    final maxDT = DateTime(maxDate.year, maxDate.month, maxDate.day);
    final native = DateTime(year, month, day);

    if (native.isBefore(minDT)) {
      newDate = minDate;
    } else if (native.isAfter(maxDT)) {
      newDate = maxDate;
    }

    _selectedDate = newDate;
    notifyListeners();
  }

  void onSelectedYearChanged(String newValue) {
    final year = int.parse(newValue);
    _setDate(year, _selectedDate.month, _selectedDate.day);
  }

  void onSelectedMonthNumberChanged(String newValue) {
    final month = int.parse(newValue);
    _setDate(_selectedDate.year, month, _selectedDate.day);
  }

  void onSelectedMonthNameChanged(String newValue) {
    final monthNumber =
        AwesomeDateUtils.getMonthNames(locale).indexOf(newValue) + 1;
    _setDate(_selectedDate.year, monthNumber, _selectedDate.day);
  }

  void onSelectedDayChanged(String newValue) {
    final day = int.parse(newValue);
    _setDate(_selectedDate.year, _selectedDate.month, day);
  }


  List<String> get years => List.generate(
        maxDate.year - minDate.year + 1,
        (i) => (minDate.year + i).toString(),
      );

  List<String> get monthsNumbers {
    int minValue = (selectedDate.year == minDate.year) ? minDate.month : 1;
    int maxValue = (selectedDate.year == maxDate.year) ? maxDate.month : 12;

    return List.generate(
        maxValue - minValue + 1, (i) => (i + minValue).toString());
  }

  List<String> get monthsNames {
    int minValue = (selectedDate.year == minDate.year) ? minDate.month : 1;
    int maxValue = (selectedDate.year == maxDate.year) ? maxDate.month : 12;

    final allMonthsNames = AwesomeDateUtils.getMonthNames(locale);
    return allMonthsNames.sublist(minValue - 1, maxValue);
  }

  List<String> get days {
    int minValue = 1;
    int maxValue =
        DateUtils.getDaysInMonth(selectedDate.year, selectedDate.month);

    if (selectedDate.year == minDate.year &&
        selectedDate.month == minDate.month) {
      minValue = minDate.day;
    }
    if (selectedDate.year == maxDate.year &&
        selectedDate.month == maxDate.month) {
      maxValue = maxDate.day;
    }

    final allDays =
        AwesomeDateUtils.getMonthDays(selectedDate.year, selectedDate.month);
    return allDays.sublist(minValue - 1, maxValue);
  }
}
