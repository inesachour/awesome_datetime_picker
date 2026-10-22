import 'dart:ui' show SemanticsAction;

import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/date/date_picker_logic.dart';
import 'package:awesome_datetime_picker/src/time/time_picker_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget w) => MaterialApp(home: Scaffold(body: Center(child: w)));

AwesomeDate d(int y, int m, int day) =>
    AwesomeDate(year: y, month: m, day: day);

/// Index of the item the wheel is currently centered on.
int selectedItem(WidgetTester t, Finder wheel) =>
    (t.widget<ListWheelScrollView>(wheel).controller!
            as FixedExtentScrollController)
        .selectedItem;

bool isDimmed(WidgetTester t, String text) => find
    .ancestor(of: find.text(text), matching: find.byType(Opacity))
    .evaluate()
    .isNotEmpty;

void main() {
  group('logic', () {
    test('allDays lists every day and flags the excluded ones', () {
      final c = DatePickerLogic(
        minDate: d(2025, 1, 1),
        maxDate: d(2025, 12, 31),
        locale: LocaleType.en,
        initialDate: d(2025, 6, 13),
        excludedWeekdays: const [DateTime.saturday, DateTime.sunday],
      );
      expect(c.allDays.length, 30);
      // June 2025: the 1st is a Sunday, so day 1 (index 0) is disabled and so
      // are the 7th/8th (indexes 6, 7).
      expect(c.disabledDayIndices, containsAll([0, 6, 7, 13, 14]));
      expect(c.disabledDayIndices.length, 9);
      expect(c.days.length, 21);
    });

    test('allDays respects the min/max range and excluded dates', () {
      final c = DatePickerLogic(
        minDate: d(2025, 6, 10),
        maxDate: d(2025, 6, 20),
        locale: LocaleType.en,
        initialDate: d(2025, 6, 12),
        excludedDates: [d(2025, 6, 15)],
      );
      expect(c.allDays.first, '10');
      expect(c.allDays.last, '20');
      expect(c.disabledDayIndices, {5});
    });

    test('hours: allHours and disabledHourIndices', () {
      final c = TimePickerLogic(
        minTime: const AwesomeTime(hour: 8, minute: 0),
        maxTime: const AwesomeTime(hour: 18, minute: 0),
        initialTime: const AwesomeTime(hour: 9, minute: 0),
        excludedHours: const [12, 13],
      );
      expect(c.allHours.first, '08');
      expect(c.allHours.last, '18');
      expect(c.disabledHourIndices, {4, 5});
      expect(c.hours, isNot(contains('12')));
    });

    test('12-hour wheel flags the excluded hours of the period', () {
      final c = TimePickerLogic(
        minTime: const AwesomeTime(hour: 0, minute: 0),
        maxTime: const AwesomeTime(hour: 23, minute: 59),
        initialTime: const AwesomeTime(hour: 15, minute: 0),
        excludedHours: const [12, 13],
      );
      // PM: 12, 1, 2, ... -> 12 (noon) and 1 (13h) are disabled
      expect(c.allAmPmHours.take(3), ['12', '1', '2']);
      expect(c.disabledAmPmHourIndices, {0, 1});
    });
  });

  group('rendering', () {
    testWidgets('excluded days are removed by default', (t) async {
      await t.pumpWidget(wrap(AwesomeDatePicker(
        initialDate: d(2025, 6, 13),
        excludedWeekdays: const [DateTime.saturday, DateTime.sunday],
      )));
      expect(find.text('14'), findsNothing);
      expect(find.text('16'), findsOneWidget);
    });

    testWidgets('showDisabledValues keeps them, dimmed', (t) async {
      await t.pumpWidget(wrap(AwesomeDatePicker(
        initialDate: d(2025, 6, 13),
        excludedWeekdays: const [DateTime.saturday, DateTime.sunday],
        showDisabledValues: true,
      )));
      expect(find.text('14'), findsOneWidget);
      expect(isDimmed(t, '14'), isTrue);
      expect(isDimmed(t, '15'), isTrue);
      expect(isDimmed(t, '13'), isFalse);
      expect(isDimmed(t, '12'), isFalse);
    });

    testWidgets('disabledTextStyle replaces the default dimming', (t) async {
      await t.pumpWidget(wrap(AwesomeDatePicker(
        initialDate: d(2025, 6, 13),
        excludedWeekdays: const [DateTime.saturday, DateTime.sunday],
        showDisabledValues: true,
        disabledTextStyle: const TextStyle(color: Colors.red),
      )));
      expect(isDimmed(t, '14'), isFalse);
      expect(t.widget<Text>(find.text('14')).style!.color, Colors.red);
    });

    testWidgets('the wheel theme has priority over the picker option',
        (t) async {
      await t.pumpWidget(wrap(AwesomeDatePicker(
        initialDate: d(2025, 6, 13),
        excludedWeekdays: const [DateTime.saturday, DateTime.sunday],
        showDisabledValues: true,
        disabledTextStyle: const TextStyle(color: Colors.red),
        theme: const AwesomeDatePickerTheme(
          dayTheme: ItemTheme(disabledTextStyle: TextStyle(color: Colors.blue)),
        ),
      )));
      expect(t.widget<Text>(find.text('14')).style!.color, Colors.blue);
    });

    testWidgets('excluded hours are dimmed in both the 24h and 12h wheels',
        (t) async {
      await t.pumpWidget(wrap(Column(children: [
        AwesomeTimePicker(
          initialTime: const AwesomeTime(hour: 12, minute: 0),
          excludedHours: const [11, 12],
          showDisabledValues: true,
          visibleItemCount: 7,
        ),
      ])));
      // the selected value moved off the excluded hour: 13
      expect(isDimmed(t, '11'), isTrue);
      expect(isDimmed(t, '12'), isTrue);
      expect(isDimmed(t, '13'), isFalse);
    });

    testWidgets('the date-time picker passes the option through', (t) async {
      await t.pumpWidget(wrap(AwesomeDateTimePicker(
        initialDateTime: AwesomeDateTime(
            date: d(2025, 6, 13), time: const AwesomeTime(hour: 9, minute: 0)),
        minDateTime: AwesomeDateTime(
            date: d(2025, 1, 1), time: const AwesomeTime(hour: 0, minute: 0)),
        maxDateTime: AwesomeDateTime(
            date: d(2025, 12, 31),
            time: const AwesomeTime(hour: 23, minute: 59)),
        excludedWeekdays: const [DateTime.saturday, DateTime.sunday],
        showDisabledValues: true,
      )));
      expect(isDimmed(t, '14'), isTrue);
    });
  });

  group('snapping', () {
    testWidgets(
        'settling on a disabled day moves to the nearest selectable '
        'one', (t) async {
      final events = <AwesomeDate>[];
      await t.pumpWidget(wrap(AwesomeDatePicker(
        initialDate: d(2025, 6, 13), // Friday
        excludedWeekdays: const [DateTime.saturday, DateTime.sunday],
        showDisabledValues: true,
        onChanged: events.add,
      )));

      // One item forward lands on Saturday 14, whose nearest selectable day is
      // Friday 13 (1 away) rather than Monday 16 (2 away).
      await t.drag(
          find.byType(ListWheelScrollView).first, const Offset(0, -45));
      await t.pumpAndSettle();

      final wheel = find.byType(ListWheelScrollView).first;
      // it passed over Saturday and came back to Friday (index 12 = day 13)
      expect(selectedItem(t, wheel), 12);
      expect(events.every((e) => e == d(2025, 6, 13)), isTrue);
    });

    testWidgets('disabled values are never reported', (t) async {
      final events = <AwesomeDate>[];
      await t.pumpWidget(wrap(AwesomeDatePicker(
        initialDate: d(2025, 6, 13),
        excludedWeekdays: const [DateTime.saturday, DateTime.sunday],
        showDisabledValues: true,
        onChanged: events.add,
      )));
      // fling through a few days
      await t.fling(
          find.byType(ListWheelScrollView).first, const Offset(0, -150), 600);
      await t.pumpAndSettle();
      for (final e in events) {
        expect(e.toDateTime().weekday, lessThan(6), reason: '$e is a weekend');
      }
      expect(events, isNotEmpty);
    });

    testWidgets('an equally close choice goes in the direction of the drag',
        (t) async {
      final events = <AwesomeDate>[];
      await t.pumpWidget(wrap(AwesomeDatePicker(
        initialDate: d(2025, 6, 13),
        excludedDates: [d(2025, 6, 14), d(2025, 6, 15), d(2025, 6, 16)],
        showDisabledValues: true,
        onChanged: events.add,
      )));

      // Two items forward lands on the 15th: the 13th and the 17th are both 2
      // away; the drag went forward so the 17th wins.
      await t.drag(
          find.byType(ListWheelScrollView).first, const Offset(0, -90));
      await t.pumpAndSettle();
      expect(events.last, d(2025, 6, 17));
      expect(selectedItem(t, find.byType(ListWheelScrollView).first), 16);
    });

    testWidgets('dragging backward prefers the previous value on a tie',
        (t) async {
      final events = <AwesomeDate>[];
      await t.pumpWidget(wrap(AwesomeDatePicker(
        initialDate: d(2025, 6, 17),
        excludedDates: [d(2025, 6, 14), d(2025, 6, 15), d(2025, 6, 16)],
        showDisabledValues: true,
        onChanged: events.add,
      )));
      // two items back lands on the 15th; 13th and 17th are 2 away
      await t.drag(find.byType(ListWheelScrollView).first, const Offset(0, 90));
      await t.pumpAndSettle();
      expect(events.last, d(2025, 6, 13));
    });

    testWidgets('looping wheels snap across the wrap-around', (t) async {
      final events = <AwesomeTime>[];
      await t.pumpWidget(wrap(AwesomeTimePicker(
        initialTime: const AwesomeTime(hour: 22, minute: 0),
        excludedHours: const [23, 0],
        showDisabledValues: true,
        looping: true,
        onChanged: events.add,
      )));
      // one item forward lands on 23 (disabled); 22 is 1 away, 1 is 2 away
      await t.drag(
          find.byType(ListWheelScrollView).first, const Offset(0, -45));
      await t.pumpAndSettle();
      expect(events.every((e) => e.hour == 22), isTrue);
      expect(t.takeException(), isNull);
    });

    testWidgets('the controller is not told about passing values', (t) async {
      final controller =
          AwesomeDatePickerController(initialValue: d(2025, 6, 13));
      final seen = <AwesomeDate>[];
      controller.addListener(() => seen.add(controller.value));
      await t.pumpWidget(wrap(AwesomeDatePicker(
        controller: controller,
        excludedWeekdays: const [DateTime.saturday, DateTime.sunday],
        showDisabledValues: true,
      )));
      await t.drag(
          find.byType(ListWheelScrollView).first, const Offset(0, -45));
      await t.pumpAndSettle();
      expect(seen.every((e) => e.toDateTime().weekday < 6), isTrue);
    });
  });

  group('accessibility', () {
    testWidgets('increase skips disabled values', (t) async {
      final handle = t.ensureSemantics();
      AwesomeDate? last;
      await t.pumpWidget(wrap(AwesomeDatePicker(
        initialDate: d(2025, 6, 13), // Friday: 14 and 15 are the weekend
        excludedWeekdays: const [DateTime.saturday, DateTime.sunday],
        showDisabledValues: true,
        onChanged: (v) => last = v,
      )));
      final increase = find.semantics.byAction(SemanticsAction.increase);
      t.semantics.increase(increase.first);
      await t.pumpAndSettle();
      expect(last, d(2025, 6, 16));
      handle.dispose();
    });
  });
}
