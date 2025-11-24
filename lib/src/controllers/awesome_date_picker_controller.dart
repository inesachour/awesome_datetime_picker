import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/utils/awesome_date_utils.dart';
import 'package:flutter/material.dart';

class AwesomeDatePickerController extends ChangeNotifier {
  final AwesomeDate minDate;
  final AwesomeDate maxDate;
  final LocaleType locale;

  AwesomeDate _selectedDate;
  AwesomeDate get selectedDate => _selectedDate;

  // Cache for computed lists
  List<String>? _cachedYears;
  List<String>? _cachedMonthsNumbers;
  int? _cachedMonthsNumbersYear;
  List<String>? _cachedMonthsNames;
  int? _cachedMonthsNamesYear;
  List<String>? _cachedDays;
  int? _cachedDaysYear;
  int? _cachedDaysMonth;

  AwesomeDatePickerController({
    required this.minDate,
    required this.maxDate,
    required this.locale,
    AwesomeDate? initialDate,
  }) : _selectedDate = initialDate ?? minDate;

  /// Centralized setter
  void _setDate(int year, int month, int day) {
    // Clamp day to month max
    final maxDay = DateUtils.getDaysInMonth(year, month);
    if (day > maxDay) day = maxDay;

    // Build new date
    var newDate = AwesomeDate(year: year, month: month, day: day);

    // Clamp to min/max range
    final minDT = minDate.toDateTime();
    final maxDT = maxDate.toDateTime();
    final native = newDate.toDateTime();

    if (native.isBefore(minDT)) {
      newDate = minDate;
    } else if (native.isAfter(maxDT)) {
      newDate = maxDate;
    }

    _selectedDate = newDate;

    // Invalidate caches that depend on selected date
    _cachedMonthsNumbers = null;
    _cachedMonthsNames = null;
    _cachedDays = null;

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

  // ===== Computed Lists with Caching =====

  List<String> get years {
    if (_cachedYears == null) {
      _cachedYears = List.generate(
        maxDate.year - minDate.year + 1,
        (i) => (minDate.year + i).toString(),
      );
    }
    return _cachedYears!;
  }

  List<String> get monthsNumbers {
    if (_cachedMonthsNumbers == null ||
        _cachedMonthsNumbersYear != selectedDate.year) {
      int minValue = (selectedDate.year == minDate.year) ? minDate.month : 1;
      int maxValue = (selectedDate.year == maxDate.year) ? maxDate.month : 12;

      _cachedMonthsNumbers = List.generate(
          maxValue - minValue + 1, (i) => (i + minValue).toString());
      _cachedMonthsNumbersYear = selectedDate.year;
    }
    return _cachedMonthsNumbers!;
  }

  List<String> get monthsNames {
    if (_cachedMonthsNames == null ||
        _cachedMonthsNamesYear != selectedDate.year) {
      int minValue = (selectedDate.year == minDate.year) ? minDate.month : 1;
      int maxValue = (selectedDate.year == maxDate.year) ? maxDate.month : 12;

      final allMonthsNames = AwesomeDateUtils.getMonthNames(locale);
      _cachedMonthsNames = allMonthsNames.sublist(minValue - 1, maxValue);
      _cachedMonthsNamesYear = selectedDate.year;
    }
    return _cachedMonthsNames!;
  }

  List<String> get days {
    if (_cachedDays == null ||
        _cachedDaysYear != selectedDate.year ||
        _cachedDaysMonth != selectedDate.month) {
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
      _cachedDays = allDays.sublist(minValue - 1, maxValue);
      _cachedDaysYear = selectedDate.year;
      _cachedDaysMonth = selectedDate.month;
    }
    return _cachedDays!;
  }
}

