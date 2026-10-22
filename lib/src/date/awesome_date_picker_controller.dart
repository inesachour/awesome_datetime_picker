// ignore_for_file: public_member_api_docs
// Internal implementation file: it is not exported by the package, so its
// members are documented at class level only.

import 'package:awesome_datetime_picker/src/core/data/locale.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_date.dart';
import 'package:awesome_datetime_picker/src/core/utils/awesome_date_utils.dart';
import 'package:flutter/material.dart';

/// Logic behind [AwesomeDatePicker]: holds the selected date, clamps it to the
/// min/max range, applies weekday exclusions and builds each wheel's items.
class AwesomeDatePickerController extends ChangeNotifier {
  final AwesomeDate minDate;
  final AwesomeDate maxDate;
  final LocaleType locale;
  final List<int>? excludedWeekdays;

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
    this.excludedWeekdays,
  }) : _selectedDate = _initialSelection(initialDate, minDate, maxDate) {
    // Ensure initial date is valid regarding exclusions
    if (_isDateExcluded(_selectedDate)) {
      _selectedDate = _findNextValidDate(_selectedDate);
    }
  }

  /// Uses [initialDate] (default: today), clamped into [min]..[max].
  static AwesomeDate _initialSelection(
      AwesomeDate? initialDate, AwesomeDate min, AwesomeDate max) {
    final now = DateTime.now();
    final date =
        initialDate ?? AwesomeDate(year: now.year, month: now.month, day: now.day);
    final dt = date.toDateTime();
    if (dt.isBefore(min.toDateTime())) return min;
    if (dt.isAfter(max.toDateTime())) return max;
    return date;
  }

  bool _isDateExcluded(AwesomeDate date) {
    if (excludedWeekdays == null || excludedWeekdays!.isEmpty) return false;
    final dt = date.toDateTime();
    return excludedWeekdays!.contains(dt.weekday);
  }

  AwesomeDate _findNextValidDate(AwesomeDate date) {
    if (excludedWeekdays == null || excludedWeekdays!.isEmpty) return date;

    DateTime dt = date.toDateTime();
    // Try to find a valid date within the next 30 days to avoid infinite loops
    for (int i = 0; i < 30; i++) {
      if (!excludedWeekdays!.contains(dt.weekday)) {
        return AwesomeDate(year: dt.year, month: dt.month, day: dt.day);
      }
      dt = dt.add(const Duration(days: 1));

      // Check boundaries
      final maxDt = maxDate.toDateTime();
      if (dt.isAfter(maxDt)) {
        // If we hit max date, try going backwards
        return _findPreviousValidDate(date);
      }
    }
    return date; // Fallback
  }

  AwesomeDate _findPreviousValidDate(AwesomeDate date) {
    DateTime dt = date.toDateTime();
    final minDt = minDate.toDateTime();

    for (int i = 0; i < 30; i++) {
      if (!excludedWeekdays!.contains(dt.weekday)) {
        return AwesomeDate(year: dt.year, month: dt.month, day: dt.day);
      }
      dt = dt.subtract(const Duration(days: 1));
      if (dt.isBefore(minDt)) return date; // Fallback
    }
    return date;
  }

  /// Centralized setter
  void _setDate(int year, int month, int day) {
    final clampedDay = _clampDayToMonth(year, month, day);
    var newDate = AwesomeDate(year: year, month: month, day: clampedDay);

    newDate = _clampDateToRange(newDate);
    newDate = _handleExclusions(newDate);

    if (newDate == _selectedDate) return;

    _selectedDate = newDate;

    // Invalidate caches that depend on selected date
    _cachedMonthsNumbers = null;
    _cachedMonthsNames = null;
    _cachedDays = null;

    notifyListeners();
  }

  int _clampDayToMonth(int year, int month, int day) {
    final maxDay = AwesomeDateUtils.getDaysInMonth(year, month);
    return day > maxDay ? maxDay : day;
  }

  AwesomeDate _clampDateToRange(AwesomeDate date) {
    final minDT = minDate.toDateTime();
    final maxDT = maxDate.toDateTime();
    final native = date.toDateTime();

    if (native.isBefore(minDT)) {
      return minDate;
    } else if (native.isAfter(maxDT)) {
      return maxDate;
    }
    return date;
  }

  AwesomeDate _handleExclusions(AwesomeDate date) {
    if (_isDateExcluded(date)) {
      return _findNextValidDate(date);
    }
    return date;
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
      int maxValue = AwesomeDateUtils.getDaysInMonth(
          selectedDate.year, selectedDate.month);

      if (selectedDate.year == minDate.year &&
          selectedDate.month == minDate.month) {
        minValue = minDate.day;
      }
      if (selectedDate.year == maxDate.year &&
          selectedDate.month == maxDate.month) {
        maxValue = maxDate.day;
      }

      // Generate days and filter excluded ones
      List<String> validDays = [];
      for (int i = minValue; i <= maxValue; i++) {
        final date = AwesomeDate(
            year: selectedDate.year, month: selectedDate.month, day: i);
        if (!_isDateExcluded(date)) {
          validDays.add(i.toString());
        }
      }

      _cachedDays = validDays;
      _cachedDaysYear = selectedDate.year;
      _cachedDaysMonth = selectedDate.month;
    }
    return _cachedDays!;
  }
}
