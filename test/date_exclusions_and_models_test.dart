import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/date/date_picker_logic.dart';
import 'package:flutter_test/flutter_test.dart';

DatePickerLogic build({
  required AwesomeDate initial,
  List<int>? excluded,
  AwesomeDate min = const AwesomeDate(year: 2025, month: 1, day: 1),
  AwesomeDate max = const AwesomeDate(year: 2025, month: 12, day: 31),
}) =>
    DatePickerLogic(
      minDate: min,
      maxDate: max,
      locale: LocaleType.en,
      initialDate: initial,
      excludedWeekdays: excluded,
    );

void main() {
  group('weekday exclusions', () {
    test('move an excluded initial date to the next valid day', () {
      // 2025-06-14 is a Saturday.
      final c = build(
        initial: const AwesomeDate(year: 2025, month: 6, day: 14),
        excluded: const [DateTime.saturday, DateTime.sunday],
      );
      expect(c.selectedDate, const AwesomeDate(year: 2025, month: 6, day: 16));
    });

    test('fall back to the previous valid day at the end of the range', () {
      // 2025-12-31 is a Wednesday; exclude Wed..Sun so only Mon/Tue remain.
      final c = build(
        initial: const AwesomeDate(year: 2025, month: 12, day: 31),
        excluded: const [3, 4, 5, 6, 7],
      );
      expect(c.selectedDate, const AwesomeDate(year: 2025, month: 12, day: 30));
    });

    test('excluded days are removed from the day wheel', () {
      final c = build(
        initial: const AwesomeDate(year: 2025, month: 6, day: 16),
        excluded: const [DateTime.saturday, DateTime.sunday],
      );
      expect(c.days, isNot(contains('14')));
      expect(c.days, isNot(contains('15')));
      expect(c.days, contains('16'));
    });

    test('excluding every weekday fails fast in debug mode', () {
      expect(
        () => build(
          initial: const AwesomeDate(year: 2025, month: 6, day: 14),
          excluded: const [1, 2, 3, 4, 5, 6, 7],
        ),
        throwsAssertionError,
      );
    });
  });

  group('models', () {
    test('AwesomeDate rejects an impossible month or day', () {
      expect(() => AwesomeDate(year: 2025, month: 13, day: 1),
          throwsAssertionError);
      expect(() => AwesomeDate(year: 2025, month: 1, day: 0),
          throwsAssertionError);
    });

    test('AwesomeTime rejects an impossible hour or minute', () {
      expect(() => AwesomeTime(hour: 24, minute: 0), throwsAssertionError);
      expect(() => AwesomeTime(hour: 0, minute: 60), throwsAssertionError);
    });
  });
}
