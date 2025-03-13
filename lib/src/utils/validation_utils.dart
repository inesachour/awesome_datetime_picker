import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';

class ValidationUtils {
  static bool isValidTimeRange(
      {required AwesomeTime? minTime, required AwesomeTime? maxTime}) {
    final minDateTime =
        DateTime(2025, 1, 1, minTime?.hour ?? 00, minTime?.minute ?? 00);
    final maxDateTime =
        DateTime(2025, 1, 1, maxTime?.hour ?? 23, maxTime?.minute ?? 59);
    return minDateTime.isBefore(maxDateTime) ||
        minDateTime.isAtSameMomentAs(maxDateTime);
  }

  static bool isValidInitialTime({
    AwesomeTime? time,
    AwesomeTime? minTime,
    AwesomeTime? maxTime,
  }) {
    final timeDateTime = DateTime(2025, 1, 1, time?.hour ?? DateTime.now().hour,
        time?.minute ?? DateTime.now().minute);
    final minDateTime =
        DateTime(2025, 1, 1, minTime?.hour ?? 00, minTime?.minute ?? 00);
    final maxDateTime =
        DateTime(2025, 1, 1, maxTime?.hour ?? 23, maxTime?.minute ?? 59);

    if (timeDateTime.isBefore(minDateTime) ||
        timeDateTime.isAfter(maxDateTime)) {
      return false;
    }
    return true;
  }

  static bool isValidDateRange(
      {required AwesomeDate? minDate, required AwesomeDate? maxDate}) {
    final minDateTime = DateTime(
      minDate?.year ?? 1900,
      minDate?.month ?? 1,
      minDate?.day ?? 1,
    );
    final maxDateTime = DateTime(
      maxDate?.year ?? 2100,
      maxDate?.month ?? 12,
      maxDate?.day ?? 31,
    );
    return minDateTime.isBefore(maxDateTime) ||
        minDateTime.isAtSameMomentAs(maxDateTime);
  }

  static bool isValidInitialDate({
    AwesomeDate? date,
    AwesomeDate? minDate,
    AwesomeDate? maxDate,
  }) {
    final timeDateTime = DateTime(
      date?.year ?? DateTime.now().year,
      date?.month ?? DateTime.now().month,
      date?.day ?? DateTime.now().day,
    );
    final minDateTime = DateTime(
      minDate?.year ?? 1900,
      minDate?.month ?? 1,
      minDate?.day ?? 1,
    );
    final maxDateTime = DateTime(
      maxDate?.year ?? 2100,
      maxDate?.month ?? 12,
      maxDate?.day ?? 31,
    );

    if (timeDateTime.isBefore(minDateTime) ||
        timeDateTime.isAfter(maxDateTime)) {
      return false;
    }
    return true;
  }
}
