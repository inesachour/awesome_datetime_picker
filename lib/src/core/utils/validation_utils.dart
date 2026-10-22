import 'package:awesome_datetime_picker/src/core/models/awesome_date.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_datetime.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_time.dart';

/// Range validation used by the pickers' debug-mode asserts.
class ValidationUtils {
  /// Validate that minTime is before or equal to maxTime
  static bool isValidTimeRange({
    required AwesomeTime? minTime,
    required AwesomeTime? maxTime,
  }) {
    if (minTime == null || maxTime == null) return true;
    return !minTime.isAfter(maxTime);
  }

  /// Validate that initialTime is within minTime and maxTime range
  static bool isValidInitialTime({
    AwesomeTime? time,
    AwesomeTime? minTime,
    AwesomeTime? maxTime,
  }) {
    if (time == null) return true;

    final min = minTime ?? const AwesomeTime(hour: 0, minute: 0);
    final max = maxTime ?? const AwesomeTime(hour: 23, minute: 59, second: 59);

    return !time.isBefore(min) && !time.isAfter(max);
  }

  /// Validate that minDate is before or equal to maxDate
  static bool isValidDateRange({
    required AwesomeDate? minDate,
    required AwesomeDate? maxDate,
  }) {
    if (minDate == null || maxDate == null) return true;

    final minDT = minDate.toDateTime();
    final maxDT = maxDate.toDateTime();

    return minDT.isBefore(maxDT) || minDT.isAtSameMomentAs(maxDT);
  }

  /// Validate that initialDate is within minDate and maxDate range
  static bool isValidInitialDate({
    AwesomeDate? date,
    AwesomeDate? minDate,
    AwesomeDate? maxDate,
  }) {
    if (date == null) return true;

    final dateDT = date.toDateTime();
    final minDT = (minDate ?? const AwesomeDate(year: 1900, month: 1, day: 1))
        .toDateTime();
    final maxDT = (maxDate ?? const AwesomeDate(year: 2100, month: 12, day: 31))
        .toDateTime();

    return !dateDT.isBefore(minDT) && !dateDT.isAfter(maxDT);
  }

  /// Validate that minDateTime is before or equal to maxDateTime
  static bool isValidDateTimeRange({
    required AwesomeDateTime? minDateTime,
    required AwesomeDateTime? maxDateTime,
  }) {
    if (minDateTime == null || maxDateTime == null) return true;

    final minDT = minDateTime.toDateTime();
    final maxDT = maxDateTime.toDateTime();

    return minDT.isBefore(maxDT) || minDT.isAtSameMomentAs(maxDT);
  }

  /// Validate that initialDateTime is within minDateTime and maxDateTime range
  static bool isValidInitialDateTime({
    AwesomeDateTime? dateTime,
    AwesomeDateTime? minDateTime,
    AwesomeDateTime? maxDateTime,
  }) {
    if (dateTime == null) return true;

    final dt = dateTime.toDateTime();
    final minDT = (minDateTime ??
            AwesomeDateTime(
              date: const AwesomeDate(year: 1900, month: 1, day: 1),
              time: const AwesomeTime(hour: 0, minute: 0),
            ))
        .toDateTime();
    final maxDT = (maxDateTime ??
            AwesomeDateTime(
              date: const AwesomeDate(year: 2100, month: 12, day: 31),
              time: const AwesomeTime(hour: 23, minute: 59, second: 59),
            ))
        .toDateTime();

    return !dt.isBefore(minDT) && !dt.isAfter(maxDT);
  }

  /// Whether at least one hour between [minTime] and [maxTime] is not in
  /// [excludedHours] (so the time wheels are never empty).
  static bool hasSelectableTime({
    AwesomeTime? minTime,
    AwesomeTime? maxTime,
    List<int>? excludedHours,
  }) {
    if (excludedHours == null || excludedHours.isEmpty) return true;
    final first = minTime?.hour ?? 0;
    final last = maxTime?.hour ?? 23;
    for (int h = first; h <= last; h++) {
      if (!excludedHours.contains(h)) return true;
    }
    return false;
  }

  /// Whether at least one date between [minDate] and [maxDate] can be
  /// selected, i.e. is not on one of the [excludedWeekdays], not one of the
  /// [excludedDates] and accepted by [selectableDayPredicate] (so the day wheel
  /// is never empty).
  ///
  /// With a predicate the range is scanned day by day (it is only used by
  /// debug-mode asserts, and stops at the first selectable date). A range that
  /// is too long to scan entirely is assumed to contain a selectable date.
  static bool hasSelectableDate({
    AwesomeDate? minDate,
    AwesomeDate? maxDate,
    List<int>? excludedWeekdays,
    List<AwesomeDate>? excludedDates,
    bool Function(AwesomeDate date)? selectableDayPredicate,
  }) {
    final noWeekdays = excludedWeekdays == null || excludedWeekdays.isEmpty;
    final noDates = excludedDates == null || excludedDates.isEmpty;
    if (noWeekdays && noDates && selectableDayPredicate == null) return true;

    final first = minDate ?? const AwesomeDate(year: 1900, month: 1, day: 1);
    final last = maxDate ?? const AwesomeDate(year: 2100, month: 12, day: 31);
    final lastDay = last.toDateTime();
    final excluded = excludedDates?.toSet() ?? const <AwesomeDate>{};

    const maxScan = 20000;
    for (int i = 0; i < maxScan; i++) {
      final day = DateTime(first.year, first.month, first.day + i);
      if (day.isAfter(lastDay)) return false;
      final date = AwesomeDate(year: day.year, month: day.month, day: day.day);
      if (!noWeekdays && excludedWeekdays.contains(day.weekday)) continue;
      if (excluded.contains(date)) continue;
      if (selectableDayPredicate != null && !selectableDayPredicate(date)) {
        continue;
      }
      return true;
    }
    return true; // too long to scan: assume something is selectable
  }
}
