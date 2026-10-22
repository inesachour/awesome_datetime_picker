import 'package:flutter/foundation.dart';

/// An immutable calendar date (year, month, day) without a time of day.
///
/// Used to configure and read back the date pickers, e.g. `AwesomeDate(year: 2025, month: 12, day: 31)`.
@immutable
class AwesomeDate {
  /// The year, e.g. 2025.
  final int year;

  /// The month of the year, from 1 (January) to 12 (December).
  final int month;

  /// The day of the month, starting at 1.
  final int day;

  /// Creates a date from its [year], [month] and [day].
  const AwesomeDate({
    required this.year,
    required this.month,
    required this.day,
  });

  /// Create a copy with optional field updates
  AwesomeDate copyWith({
    int? year,
    int? month,
    int? day,
  }) {
    return AwesomeDate(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
    );
  }

  /// Convert to DateTime for comparisons
  DateTime toDateTime() {
    return DateTime(year, month, day);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AwesomeDate &&
        other.year == year &&
        other.month == month &&
        other.day == day;
  }

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => 'AwesomeDate($year-$month-$day)';
}
