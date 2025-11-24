import 'package:awesome_datetime_picker/src/models/awesome_date.dart';
import 'package:awesome_datetime_picker/src/models/awesome_time.dart';
import 'package:flutter/foundation.dart';

@immutable
class AwesomeDateTime {
  final AwesomeDate date;
  final AwesomeTime time;

  const AwesomeDateTime({
    required this.date,
    required this.time,
  });

  /// Create a copy with optional field updates
  AwesomeDateTime copyWith({
    AwesomeDate? date,
    AwesomeTime? time,
  }) {
    return AwesomeDateTime(
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }

  /// Convert to DateTime
  DateTime toDateTime() {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AwesomeDateTime &&
        other.date == date &&
        other.time == time;
  }

  @override
  int get hashCode => Object.hash(date, time);

  @override
  String toString() => 'AwesomeDateTime($date $time)';
}
