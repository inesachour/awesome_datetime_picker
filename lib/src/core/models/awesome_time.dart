import 'package:flutter/foundation.dart';

/// An immutable time of day (hour and minute) on a 24-hour clock.
///
/// Used to configure and read back the time pickers, e.g. `AwesomeTime(hour: 14, minute: 30)`.
/// Times are [Comparable], ordered from 00:00 to 23:59.
@immutable
class AwesomeTime implements Comparable<AwesomeTime> {
  /// The hour of the day, from 0 to 23.
  final int hour;

  /// The minute of the hour, from 0 to 59.
  final int minute;

  /// Creates a time from its [hour] (0-23) and [minute] (0-59).
  const AwesomeTime({
    required this.hour,
    required this.minute,
  });

  /// Create a copy with optional field updates
  AwesomeTime copyWith({
    int? hour,
    int? minute,
  }) {
    return AwesomeTime(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  /// Convert to DateTime for comparisons (uses arbitrary date)
  DateTime toDateTime() {
    return DateTime(2000, 1, 1, hour, minute);
  }

  /// Check if this time is before another time
  bool isBefore(AwesomeTime other) {
    if (hour < other.hour) return true;
    if (hour == other.hour) return minute < other.minute;
    return false;
  }

  /// Check if this time is after another time
  bool isAfter(AwesomeTime other) {
    if (hour > other.hour) return true;
    if (hour == other.hour) return minute > other.minute;
    return false;
  }

  @override
  int compareTo(AwesomeTime other) {
    if (hour != other.hour) return hour.compareTo(other.hour);
    return minute.compareTo(other.minute);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AwesomeTime &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => 'AwesomeTime($hour:$minute)';
}
