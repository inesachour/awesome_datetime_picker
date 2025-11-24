class AwesomeTimeUtils {
  static const List<String> amPm = ["AM", "PM"];

  static List<String> amPmHours = List.generate(12, (index) {
    if (index == 0) {
      return "12";
    } else {
      return (index).toString();
    }
  });

  /// Get AM/PM for a given hour (0-23)
  /// Fixed: hour 0 = AM, hours 1-11 = AM, hour 12 = PM, hours 13-23 = PM
  static String getAmPm(int hour) {
    if (hour == 0 || (hour >= 1 && hour < 12)) {
      return "AM";
    }
    return "PM";
  }

  /// Convert 12-hour format to 24-hour format
  /// Fixed: PM hours should only add 12 if hour != 12
  static int convertTo24HourFormat(int hour, String amPm) {
    if (amPm == "AM") {
      if (hour == 12) {
        return 0; // 12 AM = 00:00
      } else {
        return hour; // 1-11 AM = 1-11
      }
    } else {
      // PM
      if (hour == 12) {
        return 12; // 12 PM = 12:00
      } else {
        return hour + 12; // 1-11 PM = 13-23
      }
    }
  }

  /// Convert 24-hour format to 12-hour format
  static int convertTo12HourFormat(int hour) {
    if (hour == 0) return 12; // Midnight
    if (hour <= 12) return hour;
    return hour - 12;
  }

  /// Toggle between AM and PM (add/subtract 12 hours)
  static int toggleAmPm(int hour) {
    return (hour + 12) % 24;
  }
}

