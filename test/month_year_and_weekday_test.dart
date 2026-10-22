import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/date/date_picker_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget w) => MaterialApp(home: Scaffold(body: Center(child: w)));

AwesomeDate d(int y, int m, int day) =>
    AwesomeDate(year: y, month: m, day: day);

void main() {
  group('formats', () {
    test('only the day-based formats have a day wheel', () {
      expect(AwesomeDateFormat.dMy.hasDay, isTrue);
      expect(AwesomeDateFormat.dMMy.hasDay, isTrue);
      expect(AwesomeDateFormat.yMd.hasDay, isTrue);
      expect(AwesomeDateFormat.yMMd.hasDay, isTrue);
      expect(AwesomeDateFormat.My.hasDay, isFalse);
      expect(AwesomeDateFormat.MMy.hasDay, isFalse);
      expect(AwesomeDateFormat.yM.hasDay, isFalse);
      expect(AwesomeDateFormat.yMM.hasDay, isFalse);
    });
  });

  group('month and year (logic)', () {
    DatePickerLogic month({AwesomeDate? initial}) => DatePickerLogic(
          minDate: d(2025, 3, 15),
          maxDate: d(2026, 8, 20),
          locale: LocaleType.en,
          initialDate: initial,
          hasDayWheel: false,
        );

    test('the selection is always the first day of the month', () {
      expect(month(initial: d(2025, 6, 15)).selectedDate, d(2025, 6, 1));
    });

    test('limits are whole months: the first and last month stay selectable',
        () {
      final c = month(initial: d(2025, 6, 1));
      expect(c.minDate, d(2025, 3, 1));
      expect(c.maxDate, d(2026, 8, 1));
      c.setSelectedDate(d(2025, 3, 20));
      expect(c.selectedDate, d(2025, 3, 1));
      c.setSelectedDate(d(2026, 8, 25));
      expect(c.selectedDate, d(2026, 8, 1));
    });

    test('changing the month or year keeps day 1', () {
      final c = month(initial: d(2025, 6, 1));
      c.onSelectedMonthNumberChanged('11');
      expect(c.selectedDate, d(2025, 11, 1));
      c.onSelectedYearChanged('2026');
      expect(c.selectedDate, d(2026, 8, 1)); // clamped to the last month
    });

    test('day exclusions are ignored', () {
      final c = DatePickerLogic(
        minDate: d(2025, 1, 1),
        maxDate: d(2025, 12, 31),
        locale: LocaleType.en,
        initialDate: d(2025, 6, 1), // a Sunday
        hasDayWheel: false,
        excludedWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        selectableDayPredicate: (_) => false,
      );
      expect(c.selectedDate, d(2025, 6, 1));
    });
  });

  group('month and year (widget)', () {
    testWidgets('shows only the month and year wheels', (t) async {
      await t.pumpWidget(wrap(AwesomeDatePicker(
        dateFormat: AwesomeDateFormat.MMy,
        initialDate: d(2025, 6, 15),
      )));
      expect(find.byType(ListWheelScrollView), findsNWidgets(2));
      expect(find.text('June'), findsWidgets);
      expect(find.text('2025'), findsWidgets);
    });

    testWidgets('scrolling reports the first day of the month', (t) async {
      final events = <AwesomeDate>[];
      await t.pumpWidget(wrap(AwesomeDatePicker(
        dateFormat: AwesomeDateFormat.My,
        initialDate: d(2025, 6, 1),
        onChanged: events.add,
      )));
      await t.drag(
          find.byType(ListWheelScrollView).first, const Offset(0, -45));
      await t.pumpAndSettle();
      expect(events, isNotEmpty);
      expect(events.every((e) => e.day == 1), isTrue);
    });

    testWidgets('a controller always holds day 1', (t) async {
      final controller =
          AwesomeDatePickerController(initialValue: d(2025, 6, 15));
      await t.pumpWidget(wrap(AwesomeDatePicker(
          controller: controller, dateFormat: AwesomeDateFormat.yM)));
      await t.pumpAndSettle();
      expect(controller.value, d(2025, 6, 1));

      controller.value = d(2027, 2, 17);
      await t.pumpAndSettle();
      expect(controller.value, d(2027, 2, 1));
    });

    testWidgets(
        'exclusions that would empty a day wheel are not asserted when '
        'there is no day wheel', (t) async {
      await t.pumpWidget(wrap(AwesomeDatePicker(
        dateFormat: AwesomeDateFormat.My,
        excludedWeekdays: const [1, 2, 3, 4, 5, 6, 7],
      )));
      expect(t.takeException(), isNull);
    });

    testWidgets('the date-time picker needs a day wheel', (t) async {
      await t.pumpWidget(
          wrap(AwesomeDateTimePicker(dateFormat: AwesomeDateFormat.My)));
      expect(t.takeException(), isA<AssertionError>());
    });
  });

  group('weekday labels', () {
    testWidgets('are off by default', (t) async {
      await t.pumpWidget(wrap(AwesomePickerHost(initial: d(2025, 6, 15))));
      expect(find.text('15'), findsWidgets);
      expect(find.text('Sun 15'), findsNothing);
    });

    testWidgets('show the weekday and the day, in the picker language',
        (t) async {
      // 2025-06-15 is a Sunday
      await t.pumpWidget(wrap(
          AwesomeDatePicker(showWeekday: true, initialDate: d(2025, 6, 15))));
      expect(find.text('Sun 15'), findsOneWidget);
      expect(find.text('Mon 16'), findsOneWidget);

      await t.pumpWidget(wrap(AwesomeDatePicker(
          showWeekday: true,
          locale: LocaleType.fr,
          initialDate: d(2025, 6, 15))));
      await t.pumpAndSettle();
      expect(find.text('dim. 15'), findsOneWidget);
    });

    testWidgets('the reported value is still the plain date', (t) async {
      final events = <AwesomeDate>[];
      await t.pumpWidget(wrap(AwesomeDatePicker(
        showWeekday: true,
        initialDate: d(2025, 6, 15),
        onChanged: events.add,
      )));
      await t.drag(
          find.byType(ListWheelScrollView).first, const Offset(0, -45));
      await t.pumpAndSettle();
      expect(events.last, d(2025, 6, 16));
    });

    testWidgets('the day wheel is wider to fit the labels', (t) async {
      await t.pumpWidget(wrap(Column(children: [
        AwesomeDatePicker(initialDate: d(2025, 6, 15)),
        AwesomeDatePicker(showWeekday: true, initialDate: d(2025, 6, 15)),
      ])));
      final wheels = find.byType(ListWheelScrollView);
      final plain = t.getSize(wheels.at(0)).width;
      final labelled = t.getSize(wheels.at(3)).width;
      expect(labelled, greaterThan(plain));
    });

    testWidgets('are exposed to screen readers', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(wrap(
          AwesomeDatePicker(showWeekday: true, initialDate: d(2025, 6, 15))));
      expect(find.semantics.byValue('Sun 15'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('work in the date-time picker', (t) async {
      await t.pumpWidget(wrap(AwesomeDateTimePicker(
        showWeekday: true,
        initialDateTime: AwesomeDateTime(
            date: d(2025, 6, 15), time: const AwesomeTime(hour: 9, minute: 0)),
        minDateTime: AwesomeDateTime(
            date: d(2025, 1, 1), time: const AwesomeTime(hour: 0, minute: 0)),
        maxDateTime: AwesomeDateTime(
            date: d(2025, 12, 31),
            time: const AwesomeTime(hour: 23, minute: 59)),
      )));
      expect(find.text('Sun 15'), findsOneWidget);
    });
  });
}

/// A date picker without the weekday option.
class AwesomePickerHost extends StatelessWidget {
  const AwesomePickerHost({super.key, required this.initial});

  final AwesomeDate initial;

  @override
  Widget build(BuildContext context) => AwesomeDatePicker(initialDate: initial);
}
