import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';

class AwesomeTimeUtils {
  static const List<String> amPm = ["AM", "PM"];

  static List<String> amPmHours = List.generate(12, (index) {
    if (index == 0) {
      return "12";
    } else {
      return (index + 1).toString();
    }
  });

  static String getAmPm(int hour) {
    if (hour <= 12 && hour != 0) {
      return "AM";
    }
    return "PM";
  }

  static int convertTo24HourFormat(int hour, String amPm) {
    if (amPm == "AM") {
      if (hour == 12) {
        return 0;
      } else {
        return hour;
      }
    } else {
      return hour + 12;
    }
  }

  static int convertTo12HourFormat(int hour) {
    if (hour == 0) return 12;
    if (hour == 12) return 12;
    return hour % 12;
  }

  static int toggleAmPm(int hour) {
    return (hour + 12) % 24;
  }

  static bool isAfter(AwesomeTime time1, AwesomeTime time2) {
    if (time1.hour > time2.hour) {
      return true;
    } else if (time1.hour == time2.hour) {
      return time1.minute > time2.minute;
    }
    return false;
  }

  static bool isBefore(AwesomeTime time1, AwesomeTime time2) {
    if (time1.hour < time2.hour) {
      return true;
    } else if (time1.hour == time2.hour) {
      return time1.minute < time2.minute;
    }
    return false;
  }
}
