import 'package:awesome_datetime_picker/src/core/models/awesome_date.dart';
import 'package:flutter/foundation.dart';

/// An immutable range of dates, from [start] to [end] (both included).
///
/// Used to read back the date-range picker and to give it an initial value,
/// e.g. `AwesomeDateRange(start: AwesomeDate(year: 2025, month: 6, day: 1), end: AwesomeDate(year: 2025, month: 6, day: 7))`.
@immutable
class AwesomeDateRange {
  /// The first date of the range.
  final AwesomeDate start;

  /// The last date of the range. It is never before [start] in a range
  /// returned by a picker.
  final AwesomeDate end;

  /// Creates a range from [start] to [end].
  const AwesomeDateRange({required this.start, required this.end});

  /// Number of days between [start] and [end]: 0 when they are the same day,
  /// 1 for consecutive days (e.g. one night in a hotel).
  int get lengthInDays {
    final from = DateTime.utc(start.year, start.month, start.day);
    final to = DateTime.utc(end.year, end.month, end.day);
    return to.difference(from).inDays;
  }

  /// Whether [date] is between [start] and [end], both included.
  bool contains(AwesomeDate date) {
    final value = date.toDateTime();
    return !value.isBefore(start.toDateTime()) &&
        !value.isAfter(end.toDateTime());
  }

  /// Create a copy with optional field updates
  AwesomeDateRange copyWith({AwesomeDate? start, AwesomeDate? end}) {
    return AwesomeDateRange(start: start ?? this.start, end: end ?? this.end);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AwesomeDateRange &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'AwesomeDateRange($start - $end)';
}
