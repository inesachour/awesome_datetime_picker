import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AwesomeDate', () {
    test('fromDateTime keeps the calendar day and drops the time', () {
      expect(AwesomeDate.fromDateTime(DateTime(2025, 6, 15, 23, 59, 59)),
          const AwesomeDate(year: 2025, month: 6, day: 15));
    });

    test('fromDateTime and toDateTime round-trip', () {
      const date = AwesomeDate(year: 2024, month: 2, day: 29);
      expect(AwesomeDate.fromDateTime(date.toDateTime()), date);
    });

    test('today is the current day', () {
      final now = DateTime.now();
      final today = AwesomeDate.today();
      // tolerate a midnight crossing between the two calls
      expect(
        [
          AwesomeDate.fromDateTime(now),
          AwesomeDate.fromDateTime(now.add(const Duration(seconds: 2)))
        ],
        contains(today),
      );
    });
  });

  group('AwesomeTime', () {
    test('fromDateTime keeps hour, minute and second', () {
      expect(AwesomeTime.fromDateTime(DateTime(2025, 1, 1, 9, 5, 7)),
          const AwesomeTime(hour: 9, minute: 5, second: 7));
    });

    test('fromTimeOfDay and toTimeOfDay', () {
      expect(AwesomeTime.fromTimeOfDay(const TimeOfDay(hour: 14, minute: 30)),
          const AwesomeTime(hour: 14, minute: 30));
      expect(const AwesomeTime(hour: 14, minute: 30).toTimeOfDay(),
          const TimeOfDay(hour: 14, minute: 30));
    });

    test('toTimeOfDay drops the seconds', () {
      expect(const AwesomeTime(hour: 1, minute: 2, second: 3).toTimeOfDay(),
          const TimeOfDay(hour: 1, minute: 2));
    });

    test('now is a valid time of the day', () {
      final now = AwesomeTime.now();
      expect(now.hour, inInclusiveRange(0, 23));
      expect(now.minute, inInclusiveRange(0, 59));
      expect(now.second, inInclusiveRange(0, 59));
    });
  });

  group('AwesomeDateTime', () {
    test('fromDateTime and toDateTime round-trip', () {
      final dt = DateTime(2025, 12, 31, 23, 59, 58);
      expect(AwesomeDateTime.fromDateTime(dt).toDateTime(), dt);
    });

    test('fromDateTime splits date and time', () {
      final value = AwesomeDateTime.fromDateTime(DateTime(2025, 3, 14, 10, 25));
      expect(value.date, const AwesomeDate(year: 2025, month: 3, day: 14));
      expect(value.time, const AwesomeTime(hour: 10, minute: 25));
    });

    test('now is close to the current moment', () {
      final before = DateTime.now();
      final value = AwesomeDateTime.now().toDateTime();
      final after = DateTime.now();
      expect(
          value.isBefore(before.subtract(const Duration(seconds: 1))), isFalse);
      expect(value.isAfter(after.add(const Duration(seconds: 1))), isFalse);
    });
  });
}
