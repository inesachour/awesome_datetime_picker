class AwesomeTimeUtils {
  static const List<String> amPm = ["AM", "PM"];

  static String getAmPmFrom24Format(int hour) {
    if (hour < 12) {
      return "AM";
    } else {
      return "PM";
    }
  }

  static int get24FromAmPmFormat(int hour, String amPm) {
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

  static int getAmPmTimeIndex(int hour, String amPm) {
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
}
