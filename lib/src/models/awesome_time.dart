import 'package:flutter/foundation.dart';

@immutable
class AwesomeTime implements Comparable<AwesomeTime> {
  final int hour;
  final int minute;

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
