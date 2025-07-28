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
}
