import 'dart:ui' show SemanticsAction;

import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/datetime/datetime_picker_logic.dart';
import 'package:awesome_datetime_picker/src/time/time_picker_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget w) => MaterialApp(home: Scaffold(body: Center(child: w)));

TimePickerLogic timeController({
  int interval = 1,
  AwesomeTime min = const AwesomeTime(hour: 0, minute: 0),
  AwesomeTime max = const AwesomeTime(hour: 23, minute: 59),
  AwesomeTime? initial,
}) =>
    TimePickerLogic(
      minTime: min,
      maxTime: max,
      initialTime: initial,
      minuteInterval: interval,
    );

void main() {
  group('minuteInterval (controller)', () {
    test('minutes only contain steps of the interval', () {
      final c = timeController(
          interval: 15, initial: const AwesomeTime(hour: 9, minute: 0));
      expect(c.minutes, ['00', '15', '30', '45']);
    });

    test('min and max are moved onto the grid', () {
      final c = timeController(
        interval: 15,
        min: const AwesomeTime(hour: 8, minute: 7),
        max: const AwesomeTime(hour: 17, minute: 52),
        initial: const AwesomeTime(hour: 8, minute: 30),
      );
      expect(c.minTime, const AwesomeTime(hour: 8, minute: 15));
      expect(c.maxTime, const AwesomeTime(hour: 17, minute: 45));
      c.onSelectedHourChanged('08');
      expect(c.minutes, ['15', '30', '45']);
      c.onSelectedHourChanged('17');
      expect(c.minutes, ['00', '15', '30', '45']);
    });

    test('the last hour offers only minutes up to the snapped max', () {
      final c = timeController(
        interval: 10,
        max: const AwesomeTime(hour: 10, minute: 25),
        initial: const AwesomeTime(hour: 10, minute: 0),
      );
      expect(c.minutes, ['00', '10', '20']);
    });

    test('an off-grid initial time is rounded to the nearest step', () {
      expect(
        timeController(
                interval: 15, initial: const AwesomeTime(hour: 10, minute: 7))
            .selectedTime,
        const AwesomeTime(hour: 10, minute: 0),
      );
      expect(
        timeController(
                interval: 15, initial: const AwesomeTime(hour: 10, minute: 8))
            .selectedTime,
        const AwesomeTime(hour: 10, minute: 15),
      );
    });

    test('rounding never leaves the day', () {
      final c = timeController(
          interval: 30, initial: const AwesomeTime(hour: 23, minute: 59));
      expect(c.selectedTime, const AwesomeTime(hour: 23, minute: 30));
    });

    test('an interval that does not divide 60 is rejected', () {
      expect(() => timeController(interval: 7), throwsAssertionError);
      expect(() => timeController(interval: 0), throwsAssertionError);
    });

    test('date-time controller snaps its selection and carries over midnight',
        () {
      final c = DateTimePickerLogic(
        minDateTime: const AwesomeDateTime(
            date: AwesomeDate(year: 2025, month: 1, day: 1),
            time: AwesomeTime(hour: 23, minute: 50)),
        maxDateTime: const AwesomeDateTime(
            date: AwesomeDate(year: 2025, month: 12, day: 31),
            time: AwesomeTime(hour: 18, minute: 7)),
        initialDateTime: const AwesomeDateTime(
            date: AwesomeDate(year: 2025, month: 6, day: 1),
            time: AwesomeTime(hour: 10, minute: 7)),
        minuteInterval: 15,
      );
      expect(
          c.minDateTime.date, const AwesomeDate(year: 2025, month: 1, day: 2));
      expect(c.minDateTime.time, const AwesomeTime(hour: 0, minute: 0));
      expect(c.maxDateTime.time, const AwesomeTime(hour: 18, minute: 0));
      expect(c.selectedDateTime.time, const AwesomeTime(hour: 10, minute: 0));
    });
  });

  group('minuteInterval (widget)', () {
    testWidgets('the minute wheel shows only the steps', (t) async {
      await t.pumpWidget(wrap(AwesomeTimePicker(
        minuteInterval: 15,
        initialTime: const AwesomeTime(hour: 9, minute: 30),
        visibleItemCount: 5,
      )));
      expect(find.text('30'), findsWidgets);
      expect(find.text('31'), findsNothing);
      expect(find.text('05'), findsNothing);
    });

    testWidgets('the date-time picker reports on-grid times', (t) async {
      AwesomeDateTime? last;
      await t.pumpWidget(wrap(AwesomeDateTimePicker(
        minuteInterval: 30,
        initialDateTime: const AwesomeDateTime(
            date: AwesomeDate(year: 2025, month: 6, day: 15),
            time: AwesomeTime(hour: 10, minute: 0)),
        onChanged: (v) => last = v,
      )));
      final n = find.byType(ListWheelScrollView).evaluate().length;
      for (var i = 0; i < n; i++) {
        await t.drag(
            find.byType(ListWheelScrollView).at(i), const Offset(0, -45));
        await t.pumpAndSettle();
      }
      expect(last, isNotNull);
      expect(last!.time.minute % 30, 0);
    });

    testWidgets('an invalid interval asserts', (t) async {
      expect(() => AwesomeTimePicker(minuteInterval: 7), throwsAssertionError);
      expect(
          () => AwesomeDateTimePicker(minuteInterval: 7), throwsAssertionError);
    });
  });

  group('looping', () {
    Widget picker(
            {required bool looping, ValueChanged<AwesomeTime>? onChanged}) =>
        wrap(AwesomeTimePicker(
          looping: looping,
          initialTime: const AwesomeTime(hour: 10, minute: 59),
          onChanged: onChanged,
        ));

    testWidgets('a looping minute wheel wraps from 59 to 00', (t) async {
      AwesomeTime? last;
      await t.pumpWidget(picker(looping: true, onChanged: (v) => last = v));
      await t.drag(
          find.byType(ListWheelScrollView).at(1), const Offset(0, -40));
      await t.pumpAndSettle();
      expect(last, const AwesomeTime(hour: 10, minute: 0));
      expect(t.takeException(), isNull);
    });

    testWidgets('a regular minute wheel stops at 59', (t) async {
      AwesomeTime? last;
      await t.pumpWidget(picker(looping: false, onChanged: (v) => last = v));
      await t.drag(
          find.byType(ListWheelScrollView).at(1), const Offset(0, -40));
      await t.pumpAndSettle();
      expect(last, isNull);
    });

    testWidgets('looping works backwards too', (t) async {
      AwesomeTime? last;
      await t.pumpWidget(wrap(AwesomeTimePicker(
        looping: true,
        initialTime: const AwesomeTime(hour: 10, minute: 0),
        onChanged: (v) => last = v,
      )));
      await t.drag(find.byType(ListWheelScrollView).at(1), const Offset(0, 40));
      await t.pumpAndSettle();
      expect(last, const AwesomeTime(hour: 10, minute: 59));
    });

    testWidgets('the year and AM/PM wheels never loop', (t) async {
      await t.pumpWidget(wrap(Column(children: [
        AwesomeDatePicker(
            looping: true,
            initialDate: const AwesomeDate(year: 2100, month: 12, day: 31)),
        AwesomeTimePicker(
            looping: true,
            timeFormat: AwesomeTimeFormat.hm,
            initialTime: const AwesomeTime(hour: 23, minute: 0)),
      ])));
      final wheels = t
          .widgetList<ListWheelScrollView>(find.byType(ListWheelScrollView))
          .toList();
      // date: day, month, year; time: hour, minute, am/pm
      final loops = wheels
          .map((w) => w.childDelegate is ListWheelChildLoopingListDelegate)
          .toList();
      expect(loops, [true, true, false, true, true, false]);
    });

    testWidgets('screen-reader "increase" wraps around too', (t) async {
      final handle = t.ensureSemantics();
      AwesomeTime? last;
      await t.pumpWidget(picker(looping: true, onChanged: (v) => last = v));
      final adjustable = find.semantics.byAction(SemanticsAction.increase);
      t.semantics.increase(adjustable.at(1)); // minute wheel
      await t.pumpAndSettle();
      expect(last, const AwesomeTime(hour: 10, minute: 0));
      handle.dispose();
    });
  });

  group('haptic feedback', () {
    late List<String> haptics;

    setUp(() {
      haptics = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments as String);
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    testWidgets('ticks while the user drags a wheel', (t) async {
      await t.pumpWidget(wrap(AwesomeTimePicker(
        enableHapticFeedback: true,
        initialTime: const AwesomeTime(hour: 10, minute: 30),
      )));
      await t.drag(
          find.byType(ListWheelScrollView).at(1), const Offset(0, -80));
      await t.pumpAndSettle();
      expect(haptics, isNotEmpty);
      expect(haptics.toSet(), {'HapticFeedbackType.selectionClick'});
    });

    testWidgets('is off by default', (t) async {
      await t.pumpWidget(wrap(AwesomeTimePicker(
        initialTime: const AwesomeTime(hour: 10, minute: 30),
      )));
      await t.drag(
          find.byType(ListWheelScrollView).at(1), const Offset(0, -80));
      await t.pumpAndSettle();
      expect(haptics, isEmpty);
    });

    testWidgets('stays silent for screen-reader steps', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(wrap(AwesomeTimePicker(
        enableHapticFeedback: true,
        initialTime: const AwesomeTime(hour: 10, minute: 30),
      )));
      t.semantics
          .increase(find.semantics.byAction(SemanticsAction.increase).at(1));
      await t.pumpAndSettle();
      expect(haptics, isEmpty);
      handle.dispose();
    });
  });

  group('AwesomeWheelStyle', () {
    BoxDecoration selectorOf(WidgetTester t) {
      // The selector is the Container of height == itemHeight inside the wheel.
      final selector = t
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.constraints?.maxHeight == 40)
          .first;
      return selector.decoration! as BoxDecoration;
    }

    testWidgets('curvature options reach the wheel', (t) async {
      await t.pumpWidget(wrap(AwesomeTimePicker(
        wheelStyle: const AwesomeWheelStyle(
          diameterRatio: 3,
          perspective: 0.004,
          magnification: 1.3,
          squeeze: 1.2,
          overAndUnderCenterOpacity: 0.5,
        ),
      )));
      final wheel =
          t.widget<ListWheelScrollView>(find.byType(ListWheelScrollView).first);
      expect(wheel.diameterRatio, 3);
      expect(wheel.perspective, 0.004);
      expect(wheel.useMagnifier, isTrue);
      expect(wheel.magnification, 1.3);
      expect(wheel.squeeze, 1.2);
      expect(wheel.overAndUnderCenterOpacity, 0.5);
    });

    testWidgets('defaults are unchanged', (t) async {
      await t.pumpWidget(wrap(AwesomeTimePicker()));
      final wheel =
          t.widget<ListWheelScrollView>(find.byType(ListWheelScrollView).first);
      expect(wheel.diameterRatio, 1.5);
      expect(wheel.perspective, 0.01);
      expect(wheel.useMagnifier, isFalse);
      expect(wheel.squeeze, 1.0);
      expect(wheel.overAndUnderCenterOpacity, 1.0);
    });

    testWidgets('selector border radius is applied', (t) async {
      await t.pumpWidget(wrap(AwesomeTimePicker(
        selectorColor: Colors.red,
        wheelStyle:
            AwesomeWheelStyle(selectorBorderRadius: BorderRadius.circular(12)),
      )));
      final decoration = selectorOf(t);
      expect(decoration.color, Colors.red);
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('selectorDecoration replaces selectorColor and radius',
        (t) async {
      const custom = BoxDecoration(
        color: Colors.green,
        border: Border.fromBorderSide(BorderSide(color: Colors.black)),
      );
      await t.pumpWidget(wrap(AwesomeTimePicker(
        selectorColor: Colors.red,
        wheelStyle: const AwesomeWheelStyle(
          selectorBorderRadius: BorderRadius.zero,
          selectorDecoration: custom,
        ),
      )));
      expect(selectorOf(t), custom);
    });

    testWidgets('is passed through by the date-time picker', (t) async {
      await t.pumpWidget(wrap(AwesomeDateTimePicker(
        wheelStyle: const AwesomeWheelStyle(diameterRatio: 4),
      )));
      for (final wheel in t
          .widgetList<ListWheelScrollView>(find.byType(ListWheelScrollView))) {
        expect(wheel.diameterRatio, 4);
      }
    });

    test('invalid values are rejected in debug mode', () {
      expect(() => AwesomeWheelStyle(diameterRatio: 0), throwsAssertionError);
      expect(() => AwesomeWheelStyle(perspective: 0.5), throwsAssertionError);
      expect(() => AwesomeWheelStyle(magnification: -1), throwsAssertionError);
      expect(() => AwesomeWheelStyle(overAndUnderCenterOpacity: 2),
          throwsAssertionError);
    });

    test('has value equality', () {
      expect(const AwesomeWheelStyle(diameterRatio: 2),
          const AwesomeWheelStyle(diameterRatio: 2));
      expect(const AwesomeWheelStyle(diameterRatio: 2),
          isNot(const AwesomeWheelStyle(diameterRatio: 3)));
    });
  });
}
