import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/date/date_picker_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget w) => MaterialApp(home: Scaffold(body: Center(child: w)));

AwesomeDate d(int y, int m, int day) =>
    AwesomeDate(year: y, month: m, day: day);

DatePickerLogic logic({
  AwesomeDate? initial,
  AwesomeDate? min,
  AwesomeDate? max,
}) =>
    DatePickerLogic(
      minDate: min ?? d(1900, 1, 1),
      maxDate: max ?? d(2100, 12, 31),
      locale: LocaleType.en,
      initialDate: initial,
      hasYearWheel: false,
    );

void main() {
  group('formats', () {
    test('which formats have a year wheel', () {
      for (final f in [
        AwesomeDateFormat.dMy,
        AwesomeDateFormat.dMMy,
        AwesomeDateFormat.yMd,
        AwesomeDateFormat.yMMd,
        AwesomeDateFormat.My,
        AwesomeDateFormat.MMy,
        AwesomeDateFormat.yM,
        AwesomeDateFormat.yMM,
      ]) {
        expect(f.hasYear, isTrue, reason: '$f');
      }
      for (final f in [
        AwesomeDateFormat.dM,
        AwesomeDateFormat.dMM,
        AwesomeDateFormat.Md,
        AwesomeDateFormat.MMd,
      ]) {
        expect(f.hasYear, isFalse, reason: '$f');
        expect(f.hasDay, isTrue, reason: '$f');
      }
    });
  });

  group('logic', () {
    test('the year stays the one of the initial date', () {
      final c = logic(initial: d(2023, 6, 15));
      c.onSelectedMonthNumberChanged('11');
      c.onSelectedDayChanged('3');
      expect(c.selectedDate, d(2023, 11, 3));
    });

    test('without an initial date the reference year is a leap year', () {
      final c = logic();
      expect(c.selectedDate.year, DatePickerLogic.referenceYear);
      expect(DateTime(DatePickerLogic.referenceYear, 2, 29).day, 29);
    });

    test('29 February can be selected without an initial date', () {
      final c = logic(initial: d(2000, 3, 1));
      c.onSelectedMonthNumberChanged('2');
      c.onSelectedDayChanged('29');
      expect(c.selectedDate, d(2000, 2, 29));
      expect(c.days.length, 29);
    });

    test('29 February follows the year of the initial date', () {
      final leap = logic(initial: d(2024, 2, 10));
      expect(leap.days.length, 29);
      final regular = logic(initial: d(2025, 2, 10));
      expect(regular.days.length, 28);
    });

    test('the day is clamped when the month is shorter', () {
      final c = logic(initial: d(2025, 1, 31));
      c.onSelectedMonthNumberChanged('2');
      expect(c.selectedDate, d(2025, 2, 28));
    });

    test('all twelve months and every day are offered, whatever the limits',
        () {
      final c = logic(
        initial: d(2025, 6, 15),
        min: d(2025, 3, 10),
        max: d(2025, 9, 20),
      );
      expect(c.monthsNumbers.length, 12);
      expect(c.monthsNames.length, 12);
      expect(c.minDate, d(2025, 1, 1));
      expect(c.maxDate, d(2025, 12, 31));
    });

    test('a selection in another year is brought back to the fixed year', () {
      final c = logic(initial: d(2025, 6, 15));
      c.setSelectedDate(d(2031, 12, 24));
      expect(c.selectedDate, d(2025, 12, 24));
    });

    test('day exclusions do not apply', () {
      final c = DatePickerLogic(
        minDate: d(1900, 1, 1),
        maxDate: d(2100, 12, 31),
        locale: LocaleType.en,
        initialDate: d(2025, 6, 15),
        hasYearWheel: false,
        excludedWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        excludedDates: [d(2025, 6, 15)],
        selectableDayPredicate: (_) => false,
      );
      expect(c.selectedDate, d(2025, 6, 15));
    });
  });

  group('widgets', () {
    testWidgets('dM shows only a day and a month wheel', (t) async {
      await t.pumpWidget(wrap(AwesomeDatePicker(
          dateFormat: AwesomeDateFormat.dM, initialDate: d(2024, 5, 12))));
      expect(find.byType(ListWheelScrollView), findsNWidgets(2));
      expect(find.text('12'), findsWidgets);
      expect(find.text('2024'), findsNothing);
    });

    testWidgets('the order of the wheels follows the format', (t) async {
      Future<List<String>> firstItems(AwesomeDateFormat f) async {
        await t.pumpWidget(wrap(AwesomeDatePicker(
            dateFormat: f, initialDate: d(2024, 5, 12), visibleItemCount: 3)));
        return [
          for (final text in t.widgetList<Text>(find.byType(Text))) text.data!,
        ];
      }

      final dayFirst = await firstItems(AwesomeDateFormat.dMM);
      final monthFirst = await firstItems(AwesomeDateFormat.MMd);
      expect(dayFirst.indexOf('12'), lessThan(dayFirst.indexOf('May')));
      expect(monthFirst.indexOf('May'), lessThan(monthFirst.indexOf('12')));
    });

    testWidgets('scrolling reports the fixed year', (t) async {
      final events = <AwesomeDate>[];
      await t.pumpWidget(wrap(AwesomeDatePicker(
        dateFormat: AwesomeDateFormat.MMd,
        initialDate: d(2023, 5, 12),
        onChanged: events.add,
      )));
      await t.drag(
          find.byType(ListWheelScrollView).first, const Offset(0, -45));
      await t.pumpAndSettle();
      expect(events.last, d(2023, 6, 12));
    });

    testWidgets('a controller keeps the year', (t) async {
      final controller =
          AwesomeDatePickerController(initialValue: d(2024, 2, 29));
      await t.pumpWidget(wrap(AwesomeDatePicker(
          controller: controller, dateFormat: AwesomeDateFormat.dMM)));
      await t.pumpAndSettle();
      expect(controller.value, d(2024, 2, 29));

      controller.value = d(1999, 12, 25);
      await t.pumpAndSettle();
      expect(controller.value, d(2024, 12, 25));
    });

    testWidgets('29 February is available by default', (t) async {
      final controller =
          AwesomeDatePickerController(initialValue: d(2000, 1, 1));
      await t.pumpWidget(wrap(AwesomeDatePicker(
          controller: controller, dateFormat: AwesomeDateFormat.dM)));
      controller.value = d(2000, 2, 29);
      await t.pumpAndSettle();
      expect(controller.value, d(2000, 2, 29));
    });

    testWidgets('month names are localized', (t) async {
      await t.pumpWidget(wrap(AwesomeDatePicker(
        dateFormat: AwesomeDateFormat.dMM,
        localeName: 'fr',
        initialDate: d(2024, 2, 10),
      )));
      expect(find.text('février'), findsOneWidget);
    });

    testWidgets('exclusions and weekday labels are ignored without a year',
        (t) async {
      await t.pumpWidget(wrap(AwesomeDatePicker(
        dateFormat: AwesomeDateFormat.dM,
        initialDate: d(2025, 6, 15),
        excludedWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        showWeekday: true,
      )));
      expect(t.takeException(), isNull);
      expect(find.text('15'), findsWidgets);
      expect(find.textContaining('Sun'), findsNothing);
    });

    testWidgets('the date-time and range pickers need a year', (t) async {
      await t.pumpWidget(
          wrap(const AwesomeDateTimePicker(dateFormat: AwesomeDateFormat.dM)));
      expect(t.takeException(), isA<AssertionError>());
      expect(() => AwesomeDateRangePicker(dateFormat: AwesomeDateFormat.dM),
          throwsAssertionError);
    });

    testWidgets('the modal shortcut works with a year-less format', (t) async {
      AwesomeDate? result;
      await t.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async => result = await showAwesomeDatePicker(
              context,
              dateFormat: AwesomeDateFormat.dMM,
              initialDate: d(2024, 2, 29),
            ),
            child: const Text('open'),
          ),
        ),
      ));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      expect(result, d(2024, 2, 29));
    });
  });
}
