import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';

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
    final max = maxTime ?? const AwesomeTime(hour: 23, minute: 59);
    
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
    final minDT = (minDate ?? const AwesomeDate(year: 1900, month: 1, day: 1)).toDateTime();
    final maxDT = (maxDate ?? const AwesomeDate(year: 2100, month: 12, day: 31)).toDateTime();
    
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
        )).toDateTime();
    final maxDT = (maxDateTime ?? 
        AwesomeDateTime(
          date: const AwesomeDate(year: 2100, month: 12, day: 31),
          time: const AwesomeTime(hour: 23, minute: 59),
        )).toDateTime();
    
    return !dt.isBefore(minDT) && !dt.isAfter(maxDT);
  }
}

