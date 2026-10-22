import 'package:flutter/foundation.dart';

/// An immutable time of day (hour, minute and optionally second) on a 24-hour
/// clock.
///
/// Used to configure and read back the time pickers, e.g. `AwesomeTime(hour: 14, minute: 30)`.
/// The [second] defaults to 0 and only matters for pickers that show a seconds
/// wheel (see `AwesomeTimeFormat.Hms`). Times are [Comparable], ordered from
/// 00:00:00 to 23:59:59.
@immutable
class AwesomeTime implements Comparable<AwesomeTime> {
  /// The hour of the day, from 0 to 23.
  final int hour;

  /// The minute of the hour, from 0 to 59.
  final int minute;

  /// The second of the minute, from 0 to 59 (default 0).
  final int second;

  /// Creates a time from its [hour] (0-23), [minute] (0-59) and optional
  /// [second] (0-59).
  const AwesomeTime({
    required this.hour,
    required this.minute,
    this.second = 0,
  })  : assert(hour >= 0 && hour <= 23, 'hour must be between 0 and 23'),
        assert(minute >= 0 && minute <= 59, 'minute must be between 0 and 59'),
        assert(second >= 0 && second <= 59, 'second must be between 0 and 59');

  /// Create a copy with optional field updates
  AwesomeTime copyWith({
    int? hour,
    int? minute,
    int? second,
  }) {
    return AwesomeTime(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
    );
  }

  /// Convert to DateTime for comparisons (uses arbitrary date)
  DateTime toDateTime() {
    return DateTime(2000, 1, 1, hour, minute, second);
  }

  /// Number of seconds since midnight.
  int get secondOfDay => hour * 3600 + minute * 60 + second;

  /// Check if this time is before another time
  bool isBefore(AwesomeTime other) => compareTo(other) < 0;

  /// Check if this time is after another time
  bool isAfter(AwesomeTime other) => compareTo(other) > 0;

  @override
  int compareTo(AwesomeTime other) => secondOfDay.compareTo(other.secondOfDay);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AwesomeTime &&
        other.hour == hour &&
        other.minute == minute &&
        other.second == second;
  }

  @override
  int get hashCode => Object.hash(hour, minute, second);

  @override
  String toString() => second == 0
      ? 'AwesomeTime($hour:$minute)'
      : 'AwesomeTime($hour:$minute:$second)';
}
