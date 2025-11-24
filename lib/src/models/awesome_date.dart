import 'package:flutter/foundation.dart';

@immutable
class AwesomeDate {
  final int year;
  final int month;
  final int day;

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
