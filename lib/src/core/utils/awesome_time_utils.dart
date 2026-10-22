// ignore_for_file: public_member_api_docs
// Internal implementation file: it is not exported by the package, so its
// members are documented at class level only.

import 'package:awesome_datetime_picker/src/core/models/awesome_time.dart';

/// Time helpers: AM/PM and 12-hour/24-hour conversions.
class AwesomeTimeUtils {
  /// Seconds in a day, the exclusive upper bound of a time of day.
  static const int secondsPerDay = 24 * 3600;

  /// The valid times are the ones whose minute is a multiple of
  /// [minuteInterval] and whose second is a multiple of [secondInterval]. When
  /// seconds are not shown, pass 60 as [secondInterval]: only whole minutes
  /// are valid.

  /// Smallest valid time not before [secondOfDay] (seconds since midnight; the
  /// result can be past the end of the day).
  static int snapSecondsUp(
      int secondOfDay, int minuteInterval, int secondInterval) {
    final minute = secondOfDay ~/ 60;
    final second = secondOfDay % 60;
    if (minute % minuteInterval == 0) {
      final snapped =
          ((second + secondInterval - 1) ~/ secondInterval) * secondInterval;
      if (snapped < 60) return minute * 60 + snapped;
      // No valid second left in this minute: first valid minute after it.
      final next =
          ((minute + minuteInterval) ~/ minuteInterval) * minuteInterval;
      return next * 60;
    }
    final next =
        ((minute + minuteInterval - 1) ~/ minuteInterval) * minuteInterval;
    return next * 60;
  }

  /// Largest valid time not after [secondOfDay] (seconds since midnight).
  static int snapSecondsDown(
      int secondOfDay, int minuteInterval, int secondInterval) {
    final minute = secondOfDay ~/ 60;
    final second = secondOfDay % 60;
    if (minute % minuteInterval == 0) {
      return minute * 60 + (second ~/ secondInterval) * secondInterval;
    }
    final previous = (minute ~/ minuteInterval) * minuteInterval;
    return previous * 60 + (59 ~/ secondInterval) * secondInterval;
  }

  /// Valid time closest to [secondOfDay]; ties round up.
  static int snapSecondsNearest(
      int secondOfDay, int minuteInterval, int secondInterval) {
    final up = snapSecondsUp(secondOfDay, minuteInterval, secondInterval);
    final down = snapSecondsDown(secondOfDay, minuteInterval, secondInterval);
    return (up - secondOfDay) <= (secondOfDay - down) ? up : down;
  }

  static AwesomeTime _fromSecondOfDay(int secondOfDay) => AwesomeTime(
        hour: secondOfDay ~/ 3600,
        minute: secondOfDay % 3600 ~/ 60,
        second: secondOfDay % 60,
      );

  /// Latest valid time of the day.
  static int _lastValid(int minuteInterval, int secondInterval) =>
      snapSecondsDown(secondsPerDay - 1, minuteInterval, secondInterval);

  /// The closest valid time that is not before [time], capped to the last
  /// valid time of the day.
  static AwesomeTime snapUp(AwesomeTime time, int minuteInterval,
      [int secondInterval = 60]) {
    final snapped =
        snapSecondsUp(time.secondOfDay, minuteInterval, secondInterval);
    final last = _lastValid(minuteInterval, secondInterval);
    return _fromSecondOfDay(snapped > last ? last : snapped);
  }

  /// The closest valid time that is not after [time].
  static AwesomeTime snapDown(AwesomeTime time, int minuteInterval,
      [int secondInterval = 60]) {
    return _fromSecondOfDay(
        snapSecondsDown(time.secondOfDay, minuteInterval, secondInterval));
  }

  /// The valid time nearest to [time] (halves round up), capped to the last
  /// valid time of the day.
  static AwesomeTime snapNearest(AwesomeTime time, int minuteInterval,
      [int secondInterval = 60]) {
    final snapped =
        snapSecondsNearest(time.secondOfDay, minuteInterval, secondInterval);
    final last = _lastValid(minuteInterval, secondInterval);
    return _fromSecondOfDay(snapped > last ? last : snapped);
  }

  static const List<String> amPm = ["AM", "PM"];

  static List<String> amPmHours = List.generate(12, (index) {
    if (index == 0) {
      return "12";
    } else {
      return (index).toString();
    }
  });

  /// Formats [value] with at least two digits (e.g. 5 -> "05").
  static String twoDigits(int value) => value.toString().padLeft(2, '0');

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
