// ignore_for_file: public_member_api_docs
// Internal implementation file: it is not exported by the package, so its
// members are documented at class level only.

import 'package:awesome_datetime_picker/src/core/data/locale.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_date.dart';
import 'package:awesome_datetime_picker/src/core/utils/validation_utils.dart';
import 'package:awesome_datetime_picker/src/core/utils/awesome_date_utils.dart';
import 'package:flutter/material.dart';

/// Logic behind [AwesomeDatePicker]: holds the selected date, clamps it to the
/// min/max range, applies weekday exclusions and builds each wheel's items.
class DatePickerLogic extends ChangeNotifier {
  /// Earliest selectable date. Without a day wheel it is the first day of the
  /// month of the requested minimum, so that choosing that month stays valid.
  final AwesomeDate minDate;

  /// Latest selectable date. Without a day wheel it is the first day of the
  /// month of the requested maximum.
  final AwesomeDate maxDate;
  final LocaleType locale;

  /// The 12 month names shown by the month wheel, January first. Defaults to
  /// the built-in names of [locale].
  final List<String> _monthNames;

  /// Name of [month] (1-12) as shown by the month wheel.
  String monthNameOf(int month) => _monthNames[month - 1];

  /// Whether the picker has a day wheel. Without one, whole months are
  /// selected and the selected date is always the first day of the month.
  final bool hasDayWheel;
  final List<int>? excludedWeekdays;
  final List<AwesomeDate>? excludedDates;
  final bool Function(AwesomeDate date)? selectableDayPredicate;

  late final Set<AwesomeDate> _excludedDateSet = excludedDates?.toSet() ?? {};

  /// Upper bound on the days scanned to find the nearest selectable date.
  static const int _maxSearchDays = 20000;

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

  DatePickerLogic({
    required AwesomeDate minDate,
    required AwesomeDate maxDate,
    required this.locale,
    List<String>? monthNames,
    AwesomeDate? initialDate,
    this.hasDayWheel = true,
    List<int>? excludedWeekdays,
    List<AwesomeDate>? excludedDates,
    bool Function(AwesomeDate date)? selectableDayPredicate,
  })  : _monthNames = monthNames ?? AwesomeDateUtils.getMonthNames(locale),
        minDate = _firstOfMonthUnless(hasDayWheel, minDate),
        maxDate = _firstOfMonthUnless(hasDayWheel, maxDate),
        // Day exclusions have no meaning when there is no day to exclude.
        excludedWeekdays = hasDayWheel ? excludedWeekdays : null,
        excludedDates = hasDayWheel ? excludedDates : null,
        selectableDayPredicate = hasDayWheel ? selectableDayPredicate : null,
        _selectedDate = _firstOfMonthUnless(
          hasDayWheel,
          _initialSelection(
            initialDate,
            _firstOfMonthUnless(hasDayWheel, minDate),
            _firstOfMonthUnless(hasDayWheel, maxDate),
          ),
        ) {
    assert(
      ValidationUtils.hasSelectableDate(
          minDate: this.minDate,
          maxDate: this.maxDate,
          excludedWeekdays: this.excludedWeekdays,
          excludedDates: this.excludedDates,
          selectableDayPredicate: this.selectableDayPredicate),
      'the exclusions leave no selectable date between minDate and maxDate',
    );
    // Ensure initial date is valid regarding exclusions
    if (_isDateExcluded(_selectedDate)) {
      _selectedDate = _findNextValidDate(_selectedDate);
    }
  }

  static AwesomeDate _firstOfMonthUnless(bool hasDayWheel, AwesomeDate date) =>
      hasDayWheel
          ? date
          : AwesomeDate(year: date.year, month: date.month, day: 1);

  /// Uses [initialDate] (default: today), clamped into [min]..[max].
  static AwesomeDate _initialSelection(
      AwesomeDate? initialDate, AwesomeDate min, AwesomeDate max) {
    final now = DateTime.now();
    final date = initialDate ??
        AwesomeDate(year: now.year, month: now.month, day: now.day);
    final dt = date.toDateTime();
    if (dt.isBefore(min.toDateTime())) return min;
    if (dt.isAfter(max.toDateTime())) return max;
    return date;
  }

  bool get _hasExclusions =>
      (excludedWeekdays != null && excludedWeekdays!.isNotEmpty) ||
      _excludedDateSet.isNotEmpty ||
      selectableDayPredicate != null;

  bool _isDateExcluded(AwesomeDate date) {
    if (!_hasExclusions) return false;
    if (excludedWeekdays != null &&
        excludedWeekdays!.contains(date.toDateTime().weekday)) {
      return true;
    }
    if (_excludedDateSet.contains(date)) return true;
    final predicate = selectableDayPredicate;
    return predicate != null && !predicate(date);
  }

  /// Nearest selectable date to [date]: the following dates first, then the
  /// preceding ones, never leaving [minDate]..[maxDate].
  AwesomeDate _findNextValidDate(AwesomeDate date) {
    if (!_hasExclusions) return date;

    final maxDt = maxDate.toDateTime();
    DateTime dt = date.toDateTime();
    for (int i = 0; i < _maxSearchDays; i++) {
      final candidate =
          AwesomeDate(year: dt.year, month: dt.month, day: dt.day);
      if (!_isDateExcluded(candidate)) return candidate;
      // Calendar step (not a 24h Duration, which breaks on DST changes)
      dt = DateTime(dt.year, dt.month, dt.day + 1);
      if (dt.isAfter(maxDt)) break;
    }
    return _findPreviousValidDate(date);
  }

  AwesomeDate _findPreviousValidDate(AwesomeDate date) {
    final minDt = minDate.toDateTime();
    DateTime dt = DateTime(date.year, date.month, date.day - 1);
    for (int i = 0; i < _maxSearchDays; i++) {
      if (dt.isBefore(minDt)) break;
      final candidate =
          AwesomeDate(year: dt.year, month: dt.month, day: dt.day);
      if (!_isDateExcluded(candidate)) return candidate;
      dt = DateTime(dt.year, dt.month, dt.day - 1);
    }
    return date; // Unreachable when the exclusions leave a selectable date
  }

  /// Selects [date], moving it to the closest selectable date if needed
  /// (range, exclusions). Does nothing if the selection is unchanged.
  void setSelectedDate(AwesomeDate date) =>
      _setDate(date.year, date.month, date.day);

  /// Centralized setter
  void _setDate(int year, int month, int day) {
    final clampedDay = hasDayWheel ? _clampDayToMonth(year, month, day) : 1;
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
    final monthNumber = _monthNames.indexOf(newValue) + 1;
    _setDate(_selectedDate.year, monthNumber, _selectedDate.day);
  }

  void onSelectedDayChanged(String newValue) {
    final day = int.parse(newValue);
    _setDate(_selectedDate.year, _selectedDate.month, day);
  }

  // ===== Computed Lists with Caching =====

  List<String> get years {
    _cachedYears ??= List.generate(
      maxDate.year - minDate.year + 1,
      (i) => (minDate.year + i).toString(),
    );
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

      final allMonthsNames = _monthNames;
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

  List<String>? _cachedAllDays;
  Set<int>? _cachedDisabledDayIndices;
  int? _cachedAllDaysYear;
  int? _cachedAllDaysMonth;

  void _ensureAllDays() {
    if (_cachedAllDays != null &&
        _cachedAllDaysYear == selectedDate.year &&
        _cachedAllDaysMonth == selectedDate.month) {
      return;
    }
    int minValue = 1;
    int maxValue =
        AwesomeDateUtils.getDaysInMonth(selectedDate.year, selectedDate.month);
    if (selectedDate.year == minDate.year &&
        selectedDate.month == minDate.month) {
      minValue = minDate.day;
    }
    if (selectedDate.year == maxDate.year &&
        selectedDate.month == maxDate.month) {
      maxValue = maxDate.day;
    }

    final days = <String>[];
    final disabled = <int>{};
    for (int i = minValue; i <= maxValue; i++) {
      final date = AwesomeDate(
          year: selectedDate.year, month: selectedDate.month, day: i);
      if (_isDateExcluded(date)) disabled.add(days.length);
      days.add(i.toString());
    }
    _cachedAllDays = days;
    _cachedDisabledDayIndices = disabled;
    _cachedAllDaysYear = selectedDate.year;
    _cachedAllDaysMonth = selectedDate.month;
  }

  /// Every day of the selected month inside the min/max range, including the
  /// ones that cannot be selected (see [disabledDayIndices]).
  List<String> get allDays {
    _ensureAllDays();
    return _cachedAllDays!;
  }

  /// Positions in [allDays] of the days that cannot be selected.
  Set<int> get disabledDayIndices {
    _ensureAllDays();
    return _cachedDisabledDayIndices!;
  }
}
