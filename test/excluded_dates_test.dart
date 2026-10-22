import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/core/utils/validation_utils.dart';
import 'package:awesome_datetime_picker/src/date/date_picker_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget w) => MaterialApp(home: Scaffold(body: Center(child: w)));

AwesomeDate d(int y, int m, int day) =>
    AwesomeDate(year: y, month: m, day: day);

DatePickerLogic build({
  required AwesomeDate initial,
  List<int>? weekdays,
  List<AwesomeDate>? dates,
  bool Function(AwesomeDate)? predicate,
  AwesomeDate? min,
  AwesomeDate? max,
}) =>
    DatePickerLogic(
      minDate: min ?? d(2025, 1, 1),
      maxDate: max ?? d(2025, 12, 31),
      locale: LocaleType.en,
      initialDate: initial,
      excludedWeekdays: weekdays,
      excludedDates: dates,
      selectableDayPredicate: predicate,
    );

void main() {
  group('excludedDates', () {
    test('an excluded initial date moves to the next day', () {
      final c = build(initial: d(2025, 12, 25), dates: [d(2025, 12, 25)]);
      expect(c.selectedDate, d(2025, 12, 26));
    });

    test('a run of excluded dates is skipped, even across months', () {
      final c = build(
        initial: d(2025, 1, 30),
        dates: [d(2025, 1, 30), d(2025, 1, 31), d(2025, 2, 1)],
      );
      expect(c.selectedDate, d(2025, 2, 2));
    });

    test('the day wheel hides excluded dates', () {
      final c = build(
        initial: d(2025, 6, 1),
        dates: [d(2025, 6, 10), d(2025, 6, 11)],
      );
      expect(c.days, isNot(contains('10')));
      expect(c.days, isNot(contains('11')));
      expect(c.days, contains('12'));
      expect(c.days.length, 28);
    });

    test(
        'an excluded date at the end of the range falls back to the previous '
        'one', () {
      final c = build(
        initial: d(2025, 12, 31),
        dates: [d(2025, 12, 31), d(2025, 12, 30)],
      );
      expect(c.selectedDate, d(2025, 12, 29));
    });

    test('combines with excluded weekdays', () {
      // 2025-06-13 is a Friday; Saturday/Sunday excluded and Monday 16th is a holiday
      final c = build(
        initial: d(2025, 6, 14),
        weekdays: const [DateTime.saturday, DateTime.sunday],
        dates: [d(2025, 6, 16)],
      );
      expect(c.selectedDate, d(2025, 6, 17));
    });

    test('excluding every date fails fast in debug mode', () {
      expect(
        () => build(
          initial: d(2025, 6, 1),
          min: d(2025, 6, 1),
          max: d(2025, 6, 2),
          dates: [d(2025, 6, 1), d(2025, 6, 2)],
        ),
        throwsAssertionError,
      );
    });
  });

  group('selectableDayPredicate', () {
    test('rejected dates are never selected', () {
      // only even days are selectable
      bool even(AwesomeDate date) => date.day.isEven;
      final c = build(initial: d(2025, 6, 15), predicate: even);
      expect(c.selectedDate, d(2025, 6, 16));
      expect(c.days.every((day) => int.parse(day).isEven), isTrue);
    });

    test(
        'a user selection on a rejected date moves to the nearest accepted '
        'one', () {
      bool even(AwesomeDate date) => date.day.isEven;
      final c = build(initial: d(2025, 6, 16), predicate: even);
      c.setSelectedDate(d(2025, 6, 21));
      expect(c.selectedDate, d(2025, 6, 22));
    });

    test('works for ranges far from the selection (no 30-day limit)', () {
      // everything before 2025-11-20 is rejected
      bool late(AwesomeDate date) =>
          !date.toDateTime().isBefore(DateTime(2025, 11, 20));
      final c = build(initial: d(2025, 1, 5), predicate: late);
      expect(c.selectedDate, d(2025, 11, 20));
    });

    test('a predicate that rejects everything fails fast in debug mode', () {
      expect(
        () => build(initial: d(2025, 6, 1), predicate: (_) => false),
        throwsAssertionError,
      );
    });

    test('combines with weekdays and dates', () {
      final c = build(
        initial: d(2025, 6, 16), // Monday
        weekdays: const [DateTime.monday],
        dates: [d(2025, 6, 17)],
        predicate: (date) => date.day != 18,
      );
      expect(c.selectedDate, d(2025, 6, 19));
    });
  });

  group('ValidationUtils.hasSelectableDate', () {
    test('true without exclusions', () {
      expect(ValidationUtils.hasSelectableDate(), isTrue);
    });

    test('false when the predicate rejects the whole range', () {
      expect(
        ValidationUtils.hasSelectableDate(
          minDate: d(2025, 1, 1),
          maxDate: d(2025, 1, 31),
          selectableDayPredicate: (_) => false,
        ),
        isFalse,
      );
    });

    test('true when one date remains', () {
      expect(
        ValidationUtils.hasSelectableDate(
          minDate: d(2025, 1, 1),
          maxDate: d(2025, 1, 3),
          excludedDates: [d(2025, 1, 1), d(2025, 1, 2)],
        ),
        isTrue,
      );
    });
  });

  group('widgets', () {
    testWidgets('a controller value on a holiday is moved and written back',
        (t) async {
      final controller =
          AwesomeDatePickerController(initialValue: d(2025, 12, 20));
      await t.pumpWidget(wrap(AwesomeDatePicker(
        controller: controller,
        minDate: d(2025, 1, 1),
        maxDate: d(2025, 12, 31),
        excludedDates: [d(2025, 12, 25), d(2025, 12, 26)],
      )));

      controller.value = d(2025, 12, 25);
      await t.pumpAndSettle();
      expect(controller.value, d(2025, 12, 27));
    });

    testWidgets('a new predicate re-applies the rules and keeps the selection',
        (t) async {
      final events = <AwesomeDate>[];
      Widget build(bool Function(AwesomeDate)? predicate,
              {AwesomeDate? initial}) =>
          wrap(AwesomeDatePicker(
            minDate: d(2025, 6, 1),
            maxDate: d(2025, 6, 30),
            initialDate: initial,
            selectableDayPredicate: predicate,
            onChanged: events.add,
          ));

      await t.pumpWidget(build(null, initial: d(2025, 6, 15)));
      expect(events, isEmpty);

      // from now on odd days are rejected: 15 -> 16
      await t.pumpWidget(build(_evenOnly));
      await t.pumpAndSettle();
      expect(events.last, d(2025, 6, 16));
    });

    testWidgets('the date-time picker honors excluded dates', (t) async {
      final controller = AwesomeDateTimePickerController(
        initialValue: AwesomeDateTime(
            date: d(2025, 12, 20), time: const AwesomeTime(hour: 9, minute: 0)),
      );
      await t.pumpWidget(wrap(AwesomeDateTimePicker(
        controller: controller,
        minDateTime: AwesomeDateTime(
            date: d(2025, 1, 1), time: const AwesomeTime(hour: 0, minute: 0)),
        maxDateTime: AwesomeDateTime(
            date: d(2025, 12, 31),
            time: const AwesomeTime(hour: 23, minute: 59)),
        excludedDates: [d(2025, 12, 25)],
      )));

      controller.value = AwesomeDateTime(
          date: d(2025, 12, 25), time: const AwesomeTime(hour: 14, minute: 30));
      await t.pumpAndSettle();
      expect(controller.value.date, d(2025, 12, 26));
      expect(controller.value.time, const AwesomeTime(hour: 14, minute: 30));
    });

    testWidgets('an exclusion list that removes everything asserts', (t) async {
      expect(
        () => AwesomeDatePicker(
          minDate: d(2025, 6, 1),
          maxDate: d(2025, 6, 1),
          excludedDates: [d(2025, 6, 1)],
        ),
        throwsAssertionError,
      );
    });
  });
}

bool _evenOnly(AwesomeDate date) => date.day.isEven;
