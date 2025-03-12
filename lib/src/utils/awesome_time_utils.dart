class AwesomeTimeUtils {
  static const List<String> amPm = ["AM", "PM"];

  static String getAmPm(int hour) {
    if (hour <= 12) {
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
    return hour % 12; // Convert 24h to 12h format
  }
}
