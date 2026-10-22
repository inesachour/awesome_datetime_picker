import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/core/utils/awesome_time_utils.dart';
import 'package:awesome_datetime_picker/src/time/time_picker_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget w) => MaterialApp(home: Scaffold(body: Center(child: w)));

AwesomeTime t(int h, int m, [int s = 0]) =>
    AwesomeTime(hour: h, minute: m, second: s);

TimePickerLogic logic({
  AwesomeTime? min,
  AwesomeTime? max,
  AwesomeTime? initial,
  int minuteInterval = 1,
  int secondInterval = 1,
  bool showSeconds = true,
}) =>
    TimePickerLogic(
      minTime: min ?? t(0, 0),
      maxTime: max ?? t(23, 59, 59),
      initialTime: initial,
      minuteInterval: minuteInterval,
      showSeconds: showSeconds,
      secondInterval: secondInterval,
    );

void main() {
  group('AwesomeTime with seconds', () {
    test('seconds default to 0 and take part in equality and ordering', () {
      expect(t(9, 30), t(9, 30, 0));
      expect(t(9, 30, 1), isNot(t(9, 30)));
      expect(t(9, 30, 1).isAfter(t(9, 30)), isTrue);
      expect(t(9, 30, 59).isBefore(t(9, 31)), isTrue);
      expect(t(9, 30, 5).hashCode, t(9, 30, 5).hashCode);
    });

    test('copyWith, toDateTime and toString', () {
      expect(t(9, 30).copyWith(second: 5), t(9, 30, 5));
      expect(t(9, 30, 5).toDateTime().second, 5);
      expect(t(9, 30).toString(), 'AwesomeTime(9:30)');
      expect(t(9, 30, 5).toString(), 'AwesomeTime(9:30:5)');
    });

    test('an impossible second is rejected', () {
      expect(() => AwesomeTime(hour: 0, minute: 0, second: 60),
          throwsAssertionError);
    });

    test('AwesomeDateTime.toDateTime keeps the seconds', () {
      final dt = AwesomeDateTime(
        date: const AwesomeDate(year: 2025, month: 6, day: 15),
        time: t(9, 30, 45),
      ).toDateTime();
      expect(dt.second, 45);
    });
  });

  group('time formats', () {
    test('only the formats with a seconds wheel report it', () {
      expect(AwesomeTimeFormat.Hm.hasSeconds, isFalse);
      expect(AwesomeTimeFormat.hm.hasSeconds, isFalse);
      expect(AwesomeTimeFormat.Hms.hasSeconds, isTrue);
      expect(AwesomeTimeFormat.hms.hasSeconds, isTrue);
    });
  });

  group('snapping', () {
    int up(int s, int mi, int si) => AwesomeTimeUtils.snapSecondsUp(s, mi, si);
    int down(int s, int mi, int si) =>
        AwesomeTimeUtils.snapSecondsDown(s, mi, si);

    test('a minute interval alone behaves like before', () {
      // 10:07:00 on a 15-minute grid
      expect(up(10 * 3600 + 7 * 60, 15, 60), 10 * 3600 + 15 * 60);
      expect(down(10 * 3600 + 7 * 60, 15, 60), 10 * 3600);
    });

    test('hidden seconds are dropped: up carries to the next minute', () {
      expect(up(10 * 3600 + 30, 1, 60), 10 * 3600 + 60);
      expect(down(10 * 3600 + 30, 1, 60), 10 * 3600);
    });

    test('a second interval snaps within the minute', () {
      expect(up(10 * 3600 + 7, 1, 15), 10 * 3600 + 15);
      expect(down(10 * 3600 + 29, 1, 15), 10 * 3600 + 15);
    });

    test('a second past the last grid second carries to the next valid minute',
        () {
      // 10:00:50, seconds every 15 (last is :45), minutes every 15
      expect(up(10 * 3600 + 50, 15, 15), 10 * 3600 + 15 * 60);
    });

    test('rounding down from an off-grid minute ends on the last grid second',
        () {
      // 10:07:20 on a 15 minute grid with seconds every 10 -> 10:00:50
      expect(down(10 * 3600 + 7 * 60 + 20, 15, 10), 10 * 3600 + 50);
    });

    test('nearest picks the closer valid time, ties round up', () {
      int nearest(int s, int mi, int si) =>
          AwesomeTimeUtils.snapSecondsNearest(s, mi, si);
      // seconds every 15: 7 is closer to 0, 8 is closer to 15
      expect(nearest(10 * 3600 + 7, 1, 15), 10 * 3600);
      expect(nearest(10 * 3600 + 8, 1, 15), 10 * 3600 + 15);
      // 10:07:30 is exactly between 10:00 and 10:15 on a 15-minute grid
      expect(nearest(10 * 3600 + 7 * 60 + 30, 15, 60), 10 * 3600 + 15 * 60);
    });

    test('times never leave the day', () {
      expect(AwesomeTimeUtils.snapNearest(t(23, 59, 59), 30, 60), t(23, 30));
      expect(AwesomeTimeUtils.snapUp(t(23, 59, 30), 1), t(23, 59));
    });
  });

  group('TimePickerLogic with seconds', () {
    test('the seconds wheel lists every step', () {
      final c = logic(initial: t(9, 30, 10), secondInterval: 15);
      expect(c.seconds, ['00', '15', '30', '45']);
      expect(c.selectedTime, t(9, 30, 15)); // 10s rounds to 15
    });

    test('the first and last minutes respect the second bounds', () {
      final c = logic(
        min: t(8, 0, 30),
        max: t(17, 45, 20),
        initial: t(8, 0, 40),
      );
      expect(c.seconds.first, '30');
      expect(c.seconds.last, '59');
      c.onSelectedHourChanged('17');
      c.onSelectedMinuteChanged('45');
      expect(c.seconds.last, '20');
      expect(c.seconds.first, '00');
    });

    test('changing hour or minute keeps the seconds', () {
      final c = logic(initial: t(9, 30, 45));
      c.onSelectedHourChanged('10');
      c.onSelectedMinuteChanged('05');
      expect(c.selectedTime, t(10, 5, 45));
    });

    test('selecting a second updates the time', () {
      final c = logic(initial: t(9, 30));
      c.onSelectedSecondChanged('07');
      expect(c.selectedTime, t(9, 30, 7));
    });

    test('a second below the minimum is clamped', () {
      final c = logic(min: t(8, 0, 30), initial: t(8, 0, 40));
      c.onSelectedSecondChanged('10');
      expect(c.selectedTime, t(8, 0, 30));
    });

    test('without a seconds wheel the seconds stay 0', () {
      final c = logic(showSeconds: false, initial: t(9, 30, 45));
      expect(c.selectedTime, t(9, 31)); // 45s rounds to the next minute
      c.onSelectedMinuteChanged('40');
      expect(c.selectedTime, t(9, 40));
    });

    test('combined with a minute interval', () {
      final c =
          logic(minuteInterval: 15, secondInterval: 30, initial: t(9, 7, 20));
      expect(c.selectedTime.minute % 15, 0);
      expect(c.selectedTime.second % 30, 0);
      expect(c.minutes, ['00', '15', '30', '45']);
      expect(c.seconds, ['00', '30']);
    });

    test('an interval that does not divide 60 is rejected', () {
      expect(() => logic(secondInterval: 7), throwsAssertionError);
    });
  });

  group('widgets', () {
    testWidgets('Hms shows hour, minute and second wheels', (t) async {
      AwesomeTime? last;
      await t.pumpWidget(wrap(AwesomeTimePicker(
        timeFormat: AwesomeTimeFormat.Hms,
        initialTime: const AwesomeTime(hour: 9, minute: 5, second: 7),
        onChanged: (v) => last = v,
      )));
      expect(find.byType(ListWheelScrollView), findsNWidgets(3));
      expect(find.text('09'), findsWidgets);
      expect(find.text('05'), findsWidgets);
      expect(find.text('07'), findsWidgets);

      await t.drag(
          find.byType(ListWheelScrollView).at(2), const Offset(0, -45));
      await t.pumpAndSettle();
      expect(last!.second, 8);
      expect(last!.minute, 5);
    });

    testWidgets('hms shows four wheels including AM/PM', (t) async {
      await t.pumpWidget(wrap(AwesomeTimePicker(
        timeFormat: AwesomeTimeFormat.hms,
        initialTime: const AwesomeTime(hour: 15, minute: 5, second: 30),
      )));
      expect(find.byType(ListWheelScrollView), findsNWidgets(4));
      expect(find.text('PM'), findsWidgets);
      expect(find.text('3'), findsWidgets);
    });

    testWidgets('secondInterval limits the second wheel', (t) async {
      await t.pumpWidget(wrap(AwesomeTimePicker(
        timeFormat: AwesomeTimeFormat.Hms,
        secondInterval: 15,
        initialTime: const AwesomeTime(hour: 9, minute: 5, second: 30),
      )));
      expect(find.text('30'), findsWidgets);
      expect(find.text('31'), findsNothing);
    });

    testWidgets('a controller carries the seconds', (t) async {
      final controller = AwesomeTimePickerController(
          initialValue: const AwesomeTime(hour: 9, minute: 5, second: 7));
      await t.pumpWidget(wrap(AwesomeTimePicker(
          controller: controller, timeFormat: AwesomeTimeFormat.Hms)));

      controller.value = const AwesomeTime(hour: 14, minute: 20, second: 45);
      await t.pumpAndSettle();
      expect(controller.value,
          const AwesomeTime(hour: 14, minute: 20, second: 45));
      expect(find.text('45'), findsWidgets);
    });

    testWidgets('the default latest time is 23:59:59 when seconds are shown',
        (t) async {
      final controller = AwesomeTimePickerController(
          initialValue: const AwesomeTime(hour: 23, minute: 59, second: 58));
      await t.pumpWidget(wrap(AwesomeTimePicker(
          controller: controller, timeFormat: AwesomeTimeFormat.Hms)));
      controller.value = const AwesomeTime(hour: 23, minute: 59, second: 59);
      await t.pumpAndSettle();
      expect(controller.value,
          const AwesomeTime(hour: 23, minute: 59, second: 59));
    });

    testWidgets('the second wheel falls back to the minute theme', (t) async {
      await t.pumpWidget(wrap(AwesomeTimePicker(
        timeFormat: AwesomeTimeFormat.Hms,
        theme: const AwesomeTimePickerTheme(minuteTheme: ItemTheme(width: 111)),
      )));
      expect(t.getSize(find.byType(ListWheelScrollView).at(1)).width, 111);
      expect(t.getSize(find.byType(ListWheelScrollView).at(2)).width, 111);
    });

    testWidgets('a format without seconds ignores the seconds of its inputs',
        (t) async {
      final controller = AwesomeTimePickerController(
          initialValue: const AwesomeTime(hour: 9, minute: 5, second: 10));
      await t.pumpWidget(wrap(AwesomeTimePicker(controller: controller)));
      await t.pumpAndSettle();
      expect(controller.value.second, 0);
    });

    testWidgets('the date-time picker keeps seconds inside its range',
        (t) async {
      final controller = AwesomeDateTimePickerController(
        initialValue: const AwesomeDateTime(
          date: AwesomeDate(year: 2025, month: 12, day: 31),
          time: AwesomeTime(hour: 17, minute: 59, second: 30),
        ),
      );
      await t.pumpWidget(wrap(AwesomeDateTimePicker(
        controller: controller,
        timeFormat: AwesomeTimeFormat.Hms,
        minDateTime: const AwesomeDateTime(
          date: AwesomeDate(year: 2025, month: 12, day: 1),
          time: AwesomeTime(hour: 8, minute: 0, second: 30),
        ),
        maxDateTime: const AwesomeDateTime(
          date: AwesomeDate(year: 2025, month: 12, day: 31),
          time: AwesomeTime(hour: 18, minute: 0, second: 15),
        ),
      )));

      controller.value = const AwesomeDateTime(
        date: AwesomeDate(year: 2025, month: 12, day: 31),
        time: AwesomeTime(hour: 18, minute: 0, second: 50),
      );
      await t.pumpAndSettle();
      expect(controller.value.time,
          const AwesomeTime(hour: 18, minute: 0, second: 15));

      controller.value = const AwesomeDateTime(
        date: AwesomeDate(year: 2025, month: 12, day: 1),
        time: AwesomeTime(hour: 8, minute: 0, second: 5),
      );
      await t.pumpAndSettle();
      expect(controller.value.time,
          const AwesomeTime(hour: 8, minute: 0, second: 30));
    });

    testWidgets('the date-time picker reports user changes to the seconds',
        (t) async {
      AwesomeDateTime? last;
      await t.pumpWidget(wrap(AwesomeDateTimePicker(
        timeFormat: AwesomeTimeFormat.Hms,
        initialDateTime: const AwesomeDateTime(
          date: AwesomeDate(year: 2025, month: 6, day: 15),
          time: AwesomeTime(hour: 9, minute: 5, second: 7),
        ),
        onChanged: (v) => last = v,
      )));
      final wheels = find.byType(ListWheelScrollView);
      expect(wheels, findsNWidgets(6));
      await t.drag(wheels.at(5), const Offset(0, -45));
      await t.pumpAndSettle();
      expect(last!.time, const AwesomeTime(hour: 9, minute: 5, second: 8));
    });
  });
}
