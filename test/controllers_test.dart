import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget w) => MaterialApp(home: Scaffold(body: Center(child: w)));

const jun15 = AwesomeDate(year: 2025, month: 6, day: 15);

void main() {
  group('AwesomeDatePickerController', () {
    testWidgets('the picker starts at the controller value, silently',
        (t) async {
      final events = <AwesomeDate>[];
      final controller = AwesomeDatePickerController(initialValue: jun15);
      await t.pumpWidget(wrap(
          AwesomeDatePicker(controller: controller, onChanged: events.add)));
      await t.pumpAndSettle();
      expect(controller.value, jun15);
      expect(events, isEmpty);
      expect(find.text('15'), findsWidgets);
    });

    testWidgets('setting value moves the wheels and does not call onChanged',
        (t) async {
      final events = <AwesomeDate>[];
      final controller = AwesomeDatePickerController(initialValue: jun15);
      await t.pumpWidget(wrap(
          AwesomeDatePicker(controller: controller, onChanged: events.add)));

      controller.value = const AwesomeDate(year: 2030, month: 11, day: 3);
      await t.pumpAndSettle();

      expect(find.text('2030'), findsWidgets);
      expect(events, isEmpty);
      expect(
          controller.value, const AwesomeDate(year: 2030, month: 11, day: 3));
    });

    testWidgets('user scrolling updates the controller and onChanged',
        (t) async {
      final events = <AwesomeDate>[];
      final controller = AwesomeDatePickerController(initialValue: jun15);
      await t.pumpWidget(wrap(
          AwesomeDatePicker(controller: controller, onChanged: events.add)));

      await t.drag(
          find.byType(ListWheelScrollView).first, const Offset(0, -45));
      await t.pumpAndSettle();

      expect(events, isNotEmpty);
      expect(controller.value, events.last);
      expect(controller.value, isNot(jun15));
    });

    testWidgets('an unselectable value is replaced by the nearest one',
        (t) async {
      final controller = AwesomeDatePickerController(initialValue: jun15);
      await t.pumpWidget(wrap(AwesomeDatePicker(
        controller: controller,
        minDate: const AwesomeDate(year: 2025, month: 1, day: 1),
        maxDate: const AwesomeDate(year: 2025, month: 12, day: 31),
      )));

      controller.value = const AwesomeDate(year: 2090, month: 1, day: 1);
      await t.pumpAndSettle();
      expect(
          controller.value, const AwesomeDate(year: 2025, month: 12, day: 31));

      controller.value = const AwesomeDate(year: 1990, month: 1, day: 1);
      await t.pumpAndSettle();
      expect(controller.value, const AwesomeDate(year: 2025, month: 1, day: 1));
    });

    testWidgets('an excluded weekday is moved to the next valid day',
        (t) async {
      final controller = AwesomeDatePickerController(initialValue: jun15);
      await t.pumpWidget(wrap(AwesomeDatePicker(
        controller: controller,
        excludedWeekdays: const [DateTime.saturday, DateTime.sunday],
      )));

      // 2025-06-14 is a Saturday -> Monday the 16th
      controller.value = const AwesomeDate(year: 2025, month: 6, day: 14);
      await t.pumpAndSettle();
      expect(
          controller.value, const AwesomeDate(year: 2025, month: 6, day: 16));
    });

    testWidgets('an out-of-range initial value is written back', (t) async {
      final controller = AwesomeDatePickerController(
          initialValue: const AwesomeDate(year: 2090, month: 1, day: 1));
      await t.pumpWidget(wrap(AwesomeDatePicker(
        controller: controller,
        maxDate: const AwesomeDate(year: 2030, month: 1, day: 1),
      )));
      await t.pumpAndSettle();
      expect(controller.value, const AwesomeDate(year: 2030, month: 1, day: 1));
    });

    testWidgets('reset() goes back to the initial value', (t) async {
      final controller = AwesomeDatePickerController(initialValue: jun15);
      await t.pumpWidget(wrap(AwesomeDatePicker(controller: controller)));
      controller.value = const AwesomeDate(year: 2030, month: 11, day: 3);
      await t.pumpAndSettle();
      controller.reset();
      await t.pumpAndSettle();
      expect(controller.value, jun15);
      expect(find.text('2025'), findsWidgets);
    });

    testWidgets('a controller can be swapped', (t) async {
      final first = AwesomeDatePickerController(initialValue: jun15);
      final second = AwesomeDatePickerController(
          initialValue: const AwesomeDate(year: 2040, month: 2, day: 2));
      await t.pumpWidget(wrap(AwesomeDatePicker(controller: first)));
      await t.pumpWidget(wrap(AwesomeDatePicker(controller: second)));
      await t.pumpAndSettle();
      expect(find.text('2040'), findsWidgets);

      // the old controller no longer drives the picker
      first.value = const AwesomeDate(year: 2001, month: 1, day: 1);
      await t.pumpAndSettle();
      expect(find.text('2040'), findsWidgets);
      expect(second.value, const AwesomeDate(year: 2040, month: 2, day: 2));
    });

    testWidgets('removing the picker stops listening', (t) async {
      final controller = AwesomeDatePickerController(initialValue: jun15);
      await t.pumpWidget(wrap(AwesomeDatePicker(controller: controller)));
      await t.pumpWidget(wrap(const SizedBox()));
      controller.value = const AwesomeDate(year: 2030, month: 1, day: 1);
      await t.pump();
      expect(t.takeException(), isNull);
    });

    testWidgets('controller and initialDate together is rejected', (t) async {
      expect(
        () => AwesomeDatePicker(
            controller: AwesomeDatePickerController(), initialDate: jun15),
        throwsAssertionError,
      );
    });

    test('defaults to today', () {
      final now = DateTime.now();
      expect(AwesomeDatePickerController().value,
          AwesomeDate(year: now.year, month: now.month, day: now.day));
    });
  });

  group('AwesomeTimePickerController', () {
    const nine30 = AwesomeTime(hour: 9, minute: 30);

    testWidgets('setting value moves the wheels without onChanged', (t) async {
      final events = <AwesomeTime>[];
      final controller = AwesomeTimePickerController(initialValue: nine30);
      await t.pumpWidget(wrap(
          AwesomeTimePicker(controller: controller, onChanged: events.add)));

      controller.value = const AwesomeTime(hour: 17, minute: 45);
      await t.pumpAndSettle();

      expect(find.text('17'), findsWidgets);
      expect(find.text('45'), findsWidgets);
      expect(events, isEmpty);
    });

    testWidgets('works with the 12-hour format', (t) async {
      final controller = AwesomeTimePickerController(initialValue: nine30);
      await t.pumpWidget(wrap(AwesomeTimePicker(
          controller: controller, timeFormat: AwesomeTimeFormat.hm)));

      controller.value = const AwesomeTime(hour: 17, minute: 45);
      await t.pumpAndSettle();
      expect(find.text('PM'), findsWidgets);
      expect(find.text('5'), findsWidgets);
      expect(controller.value, const AwesomeTime(hour: 17, minute: 45));
    });

    testWidgets('user scrolling updates the controller', (t) async {
      final controller = AwesomeTimePickerController(initialValue: nine30);
      AwesomeTime? last;
      await t.pumpWidget(wrap(AwesomeTimePicker(
          controller: controller, onChanged: (v) => last = v)));
      await t.drag(
          find.byType(ListWheelScrollView).at(1), const Offset(0, -45));
      await t.pumpAndSettle();
      expect(last, isNotNull);
      expect(controller.value, last);
    });

    testWidgets('the value is rounded to the minute interval', (t) async {
      final controller = AwesomeTimePickerController(initialValue: nine30);
      await t.pumpWidget(
          wrap(AwesomeTimePicker(controller: controller, minuteInterval: 15)));
      controller.value = const AwesomeTime(hour: 10, minute: 8);
      await t.pumpAndSettle();
      expect(controller.value, const AwesomeTime(hour: 10, minute: 15));
    });

    testWidgets('an excluded or out-of-range time is replaced', (t) async {
      final controller = AwesomeTimePickerController(initialValue: nine30);
      await t.pumpWidget(wrap(AwesomeTimePicker(
        controller: controller,
        minTime: const AwesomeTime(hour: 8, minute: 0),
        maxTime: const AwesomeTime(hour: 18, minute: 0),
        excludedHours: const [12],
      )));

      controller.value = const AwesomeTime(hour: 23, minute: 0);
      await t.pumpAndSettle();
      expect(controller.value, const AwesomeTime(hour: 18, minute: 0));

      controller.value = const AwesomeTime(hour: 12, minute: 20);
      await t.pumpAndSettle();
      expect(controller.value, const AwesomeTime(hour: 13, minute: 20));
    });

    testWidgets('controller and initialTime together is rejected', (t) async {
      expect(
        () => AwesomeTimePicker(
            controller: AwesomeTimePickerController(), initialTime: nine30),
        throwsAssertionError,
      );
    });

    testWidgets('reset() goes back to the initial value', (t) async {
      final controller = AwesomeTimePickerController(initialValue: nine30);
      await t.pumpWidget(wrap(AwesomeTimePicker(controller: controller)));
      controller.value = const AwesomeTime(hour: 20, minute: 5);
      await t.pumpAndSettle();
      controller.reset();
      await t.pumpAndSettle();
      expect(controller.value, nine30);
    });
  });

  group('AwesomeDateTimePickerController', () {
    const min = AwesomeDateTime(
        date: AwesomeDate(year: 2025, month: 12, day: 1),
        time: AwesomeTime(hour: 8, minute: 0));
    const max = AwesomeDateTime(
        date: AwesomeDate(year: 2025, month: 12, day: 31),
        time: AwesomeTime(hour: 18, minute: 0));
    const start = AwesomeDateTime(
        date: AwesomeDate(year: 2025, month: 12, day: 12),
        time: AwesomeTime(hour: 10, minute: 30));

    Widget picker(AwesomeDateTimePickerController c,
            {ValueChanged<AwesomeDateTime>? onChanged, int interval = 1}) =>
        wrap(AwesomeDateTimePicker(
          controller: c,
          minDateTime: min,
          maxDateTime: max,
          minuteInterval: interval,
          onChanged: onChanged,
        ));

    testWidgets('setting value moves both parts without onChanged', (t) async {
      final events = <AwesomeDateTime>[];
      final controller = AwesomeDateTimePickerController(initialValue: start);
      await t.pumpWidget(picker(controller, onChanged: events.add));

      const target = AwesomeDateTime(
          date: AwesomeDate(year: 2025, month: 12, day: 20),
          time: AwesomeTime(hour: 15, minute: 45));
      controller.value = target;
      await t.pumpAndSettle();

      expect(controller.value, target);
      expect(events, isEmpty);
      expect(find.text('20'), findsWidgets);
      expect(find.text('15'), findsWidgets);
      expect(find.text('45'), findsWidgets);
    });

    testWidgets(
        'a time that is only valid on the target day is not clamped by the '
        'previous day\'s range', (t) async {
      // On the first day times start at 08:00, on the last day they end at
      // 18:00: jump from one to the other with a time valid only on the last.
      final controller = AwesomeDateTimePickerController(
          initialValue: const AwesomeDateTime(
              date: AwesomeDate(year: 2025, month: 12, day: 1),
              time: AwesomeTime(hour: 9, minute: 0)));
      await t.pumpWidget(picker(controller));

      const target = AwesomeDateTime(
          date: AwesomeDate(year: 2025, month: 12, day: 31),
          time: AwesomeTime(hour: 7, minute: 0));
      controller.value = target;
      await t.pumpAndSettle();
      expect(controller.value, target);

      controller.value = const AwesomeDateTime(
          date: AwesomeDate(year: 2025, month: 12, day: 1),
          time: AwesomeTime(hour: 17, minute: 0));
      await t.pumpAndSettle();
      expect(controller.value.time, const AwesomeTime(hour: 17, minute: 0));
      expect(controller.value.date,
          const AwesomeDate(year: 2025, month: 12, day: 1));
    });

    testWidgets(
        'user scrolling updates the controller and calls onChanged '
        'once per change', (t) async {
      final events = <AwesomeDateTime>[];
      final controller = AwesomeDateTimePickerController(initialValue: start);
      await t.pumpWidget(picker(controller, onChanged: events.add));

      await t.drag(
          find.byType(ListWheelScrollView).at(0), const Offset(0, -45));
      await t.pumpAndSettle();

      expect(events, isNotEmpty);
      expect(controller.value, events.last);
      expect(events.toSet().length, events.length,
          reason: 'no duplicate events');
    });

    testWidgets('a value outside the range is clamped and written back',
        (t) async {
      final controller = AwesomeDateTimePickerController(initialValue: start);
      await t.pumpWidget(picker(controller));

      controller.value = const AwesomeDateTime(
          date: AwesomeDate(year: 2099, month: 1, day: 1),
          time: AwesomeTime(hour: 3, minute: 0));
      await t.pumpAndSettle();
      expect(controller.value, max);

      controller.value = const AwesomeDateTime(
          date: AwesomeDate(year: 1999, month: 1, day: 1),
          time: AwesomeTime(hour: 3, minute: 0));
      await t.pumpAndSettle();
      expect(controller.value, min);
    });

    testWidgets('the value is rounded to the minute interval', (t) async {
      final controller = AwesomeDateTimePickerController(
          initialValue:
              start.copyWith(time: const AwesomeTime(hour: 10, minute: 30)));
      await t.pumpWidget(picker(controller, interval: 15));
      controller.value =
          start.copyWith(time: const AwesomeTime(hour: 11, minute: 8));
      await t.pumpAndSettle();
      expect(controller.value.time, const AwesomeTime(hour: 11, minute: 15));
    });

    testWidgets('reset() goes back to the initial value', (t) async {
      final controller = AwesomeDateTimePickerController(initialValue: start);
      await t.pumpWidget(picker(controller));
      controller.value = max;
      await t.pumpAndSettle();
      controller.reset();
      await t.pumpAndSettle();
      expect(controller.value, start);
    });

    testWidgets('controller and initialDateTime together is rejected',
        (t) async {
      expect(
        () => AwesomeDateTimePicker(
            controller: AwesomeDateTimePickerController(),
            initialDateTime: start),
        throwsAssertionError,
      );
    });

    testWidgets('unmounting disposes cleanly', (t) async {
      final controller = AwesomeDateTimePickerController(initialValue: start);
      await t.pumpWidget(picker(controller));
      controller.value = max;
      await t.pumpAndSettle();
      await t.pumpWidget(wrap(const SizedBox()));
      controller.value = min;
      await t.pump();
      expect(t.takeException(), isNull);
    });

    testWidgets('works without a controller as before', (t) async {
      AwesomeDateTime? last;
      await t.pumpWidget(wrap(AwesomeDateTimePicker(
        initialDateTime: start,
        minDateTime: min,
        maxDateTime: max,
        onChanged: (v) => last = v,
      )));
      await t.drag(
          find.byType(ListWheelScrollView).at(0), const Offset(0, -45));
      await t.pumpAndSettle();
      expect(last, isNotNull);
      expect(t.takeException(), isNull);
    });
  });
}
