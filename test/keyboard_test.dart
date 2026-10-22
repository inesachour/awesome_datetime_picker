import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget w) => MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: Center(child: w))));

AwesomeDate d(int y, int m, int day) =>
    AwesomeDate(year: y, month: m, day: day);

Future<void> key(WidgetTester t, LogicalKeyboardKey k) async {
  await t.sendKeyEvent(k);
  await t.pumpAndSettle();
}

/// Moves the focus to the first wheel, like a user pressing Tab.
Future<void> focusFirstWheel(WidgetTester t) => key(t, LogicalKeyboardKey.tab);

/// A date picker (day, month, year) in June 2025 that records its changes.
Future<List<AwesomeDate>> june(
  WidgetTester t, {
  AwesomeDate? initial,
  bool looping = false,
  bool dimmed = false,
  List<int>? excludedWeekdays,
}) async {
  final events = <AwesomeDate>[];
  await t.pumpWidget(wrap(AwesomeDatePicker(
    initialDate: initial ?? d(2025, 6, 10),
    minDate: d(2024, 1, 1),
    maxDate: d(2026, 12, 31),
    looping: looping,
    excludedWeekdays: excludedWeekdays,
    showDisabledValues: dimmed,
    onChanged: events.add,
  )));
  return events;
}

void main() {
  group('arrow keys', () {
    testWidgets('Tab reaches a wheel and Down moves it forward', (t) async {
      final events = await june(t);
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.arrowDown);
      expect(events.last, d(2025, 6, 11));
    });

    testWidgets('Up moves it backward', (t) async {
      final events = await june(t);
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.arrowUp);
      expect(events.last, d(2025, 6, 9));
    });

    testWidgets('each press moves one item', (t) async {
      final events = await june(t);
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.arrowDown);
      await key(t, LogicalKeyboardKey.arrowDown);
      await key(t, LogicalKeyboardKey.arrowUp);
      expect(events.last, d(2025, 6, 11));
    });

    testWidgets('quick presses add up', (t) async {
      final events = await june(t);
      await focusFirstWheel(t);
      // three presses before the wheel had time to move
      await t.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await t.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
      await t.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await t.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
      await t.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await t.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
      await t.pumpAndSettle();
      expect(events.last, d(2025, 6, 13));
    });

    testWidgets('a key held down repeats', (t) async {
      final events = await june(t);
      await focusFirstWheel(t);
      await t.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await t.sendKeyRepeatEvent(LogicalKeyboardKey.arrowDown);
      await t.sendKeyRepeatEvent(LogicalKeyboardKey.arrowDown);
      await t.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
      await t.pumpAndSettle();
      expect(events.last, d(2025, 6, 13));
    });

    testWidgets('a wheel that does not loop stops at its end', (t) async {
      final events = await june(t, initial: d(2025, 6, 30));
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.arrowDown);
      expect(events, isEmpty);
    });

    testWidgets('a wheel that loops wraps around', (t) async {
      final events = await june(t, initial: d(2025, 6, 30), looping: true);
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.arrowDown);
      expect(events.last, d(2025, 6, 1));
      await key(t, LogicalKeyboardKey.arrowUp);
      expect(events.last, d(2025, 6, 30));
    });

    testWidgets('dimmed values are skipped', (t) async {
      // 2025-06-13 is a Friday; the weekend is dimmed
      final events = await june(t,
          initial: d(2025, 6, 13),
          dimmed: true,
          excludedWeekdays: const [DateTime.saturday, DateTime.sunday]);
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.arrowDown);
      expect(events.last, d(2025, 6, 16));
      await key(t, LogicalKeyboardKey.arrowUp);
      expect(events.last, d(2025, 6, 13));
    });

    testWidgets('Down does not select a value that was removed', (t) async {
      final events = await june(t,
          initial: d(2025, 6, 13),
          excludedWeekdays: const [DateTime.saturday, DateTime.sunday]);
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.arrowDown);
      expect(events.last, d(2025, 6, 16));
    });
  });

  group('between wheels', () {
    testWidgets('Right and Left move the focus', (t) async {
      final events = await june(t);
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.arrowRight); // the month wheel
      await key(t, LogicalKeyboardKey.arrowDown);
      expect(events.last, d(2025, 7, 10));
      await key(t, LogicalKeyboardKey.arrowRight); // the year wheel
      await key(t, LogicalKeyboardKey.arrowDown);
      expect(events.last, d(2026, 7, 10));
      await key(t, LogicalKeyboardKey.arrowLeft);
      await key(t, LogicalKeyboardKey.arrowLeft); // back to the day wheel
      await key(t, LogicalKeyboardKey.arrowDown);
      expect(events.last, d(2026, 7, 11));
    });

    testWidgets('Tab goes through the wheels in order', (t) async {
      final events = await june(t);
      await focusFirstWheel(t); // day
      await key(t, LogicalKeyboardKey.tab); // month
      await key(t, LogicalKeyboardKey.arrowDown);
      expect(events.last, d(2025, 7, 10));
      await key(t, LogicalKeyboardKey.tab); // year
      await key(t, LogicalKeyboardKey.arrowDown);
      expect(events.last, d(2026, 7, 10));
    });

    testWidgets('Left on the first wheel does nothing', (t) async {
      final events = await june(t);
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.arrowLeft);
      await key(t, LogicalKeyboardKey.arrowDown);
      expect(events.last, d(2025, 6, 11)); // still the day wheel
    });
  });

  group('Page Up, Page Down, Home and End', () {
    testWidgets('Page Down and Page Up move a page', (t) async {
      final events = await june(t);
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.pageDown);
      expect(events.last, d(2025, 6, 14)); // 5 visible items: a page is 4
      await key(t, LogicalKeyboardKey.pageUp);
      expect(events.last, d(2025, 6, 10));
    });

    testWidgets('a page jump reports one change, not every item', (t) async {
      final events = await june(t);
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.pageDown);
      expect(events.length, 1);
    });

    testWidgets('Home and End go to the first and the last value', (t) async {
      final events = await june(t);
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.end);
      expect(events.last, d(2025, 6, 30));
      await key(t, LogicalKeyboardKey.home);
      expect(events.last, d(2025, 6, 1));
    });

    testWidgets('a page stops at the end of a wheel that does not loop',
        (t) async {
      final events = await june(t, initial: d(2025, 6, 28));
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.pageDown);
      expect(events.last, d(2025, 6, 30));
    });

    testWidgets('Home and End skip dimmed values', (t) async {
      // June 2025 starts on a Sunday and ends on a Monday
      final events = await june(t,
          initial: d(2025, 6, 13),
          dimmed: true,
          excludedWeekdays: const [DateTime.saturday, DateTime.sunday]);
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.home);
      expect(events.last, d(2025, 6, 2)); // Monday: the 1st is a Sunday
      await key(t, LogicalKeyboardKey.end);
      expect(events.last, d(2025, 6, 30)); // a Monday
    });

    testWidgets('on a wheel that loops, Home and End stay in the cycle',
        (t) async {
      final events = await june(t, looping: true);
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.home);
      expect(events.last, d(2025, 6, 1));
      await key(t, LogicalKeyboardKey.end);
      expect(events.last, d(2025, 6, 30));
    });
  });

  group('other keys', () {
    testWidgets('letters and Enter are left alone', (t) async {
      final events = await june(t);
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.keyA);
      await key(t, LogicalKeyboardKey.enter);
      expect(events, isEmpty);
    });

    testWidgets('without the focus the keys do nothing', (t) async {
      final events = await june(t);
      await key(t, LogicalKeyboardKey.arrowDown);
      expect(events, isEmpty);
    });
  });

  group('focus', () {
    Finder outline() => find.byWidgetPredicate(
        (w) => w is Container && w.foregroundDecoration != null);

    testWidgets('an outline shows on the wheel that has the focus', (t) async {
      await june(t);
      expect(outline(), findsNothing);
      await focusFirstWheel(t);
      expect(outline(), findsOneWidget);
    });

    testWidgets('the outline follows the focus', (t) async {
      await june(t);
      await focusFirstWheel(t);
      final first = t.getCenter(outline());
      await key(t, LogicalKeyboardKey.arrowRight);
      expect(outline(), findsOneWidget);
      expect(t.getCenter(outline()).dx, greaterThan(first.dx));
    });

    testWidgets('its color can be set', (t) async {
      await t.pumpWidget(wrap(AwesomeDatePicker(
        initialDate: d(2025, 6, 10),
        wheelStyle: const AwesomeWheelStyle(focusColor: Colors.red),
      )));
      await focusFirstWheel(t);
      final box =
          t.widget<Container>(outline()).foregroundDecoration! as BoxDecoration;
      expect((box.border! as Border).top.color, Colors.red);
    });

    testWidgets('by default it uses the primary color of the theme', (t) async {
      await june(t);
      await focusFirstWheel(t);
      final box =
          t.widget<Container>(outline()).foregroundDecoration! as BoxDecoration;
      final primary = Theme.of(t.element(find.byType(AwesomeDatePicker)))
          .colorScheme
          .primary;
      expect((box.border! as Border).top.color, primary);
    });

    testWidgets('it follows the shape of the selector', (t) async {
      await t.pumpWidget(wrap(AwesomeDatePicker(
        initialDate: d(2025, 6, 10),
        wheelStyle: const AwesomeWheelStyle.ios(),
      )));
      await focusFirstWheel(t);
      final box =
          t.widget<Container>(outline()).foregroundDecoration! as BoxDecoration;
      expect(box.borderRadius, BorderRadius.circular(8));
    });

    testWidgets('a mouse click focuses the wheel, so the keys work', (t) async {
      final events = await june(t);
      final gesture = await t.startGesture(
          t.getCenter(find.byType(ListWheelScrollView).at(1)),
          kind: PointerDeviceKind.mouse);
      await gesture.up();
      await t.pumpAndSettle();
      await key(t, LogicalKeyboardKey.arrowDown);
      expect(events.last, d(2025, 7, 10)); // the month wheel
    });

    testWidgets('a touch does not take the focus from a text field', (t) async {
      await t.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: [
            const TextField(key: ValueKey('field')),
            AwesomeDatePicker(initialDate: d(2025, 6, 10)),
          ]),
        ),
      ));
      await t.tap(find.byKey(const ValueKey('field')));
      await t.pumpAndSettle();
      final focused = FocusManager.instance.primaryFocus;
      expect(
        focused?.context?.findAncestorWidgetOfExactType<EditableText>(),
        isNotNull,
        reason: 'the text field has the focus',
      );

      await t.drag(
          find.byType(ListWheelScrollView).first, const Offset(0, -45));
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus, focused);
    });

    testWidgets('disposing the picker leaves no listeners behind', (t) async {
      await june(t);
      await focusFirstWheel(t);
      await t.pumpWidget(wrap(const SizedBox()));
      await key(t, LogicalKeyboardKey.arrowDown);
      expect(t.takeException(), isNull);
    });
  });

  group('every picker', () {
    testWidgets('time picker', (t) async {
      final events = <AwesomeTime>[];
      await t.pumpWidget(wrap(AwesomeTimePicker(
        initialTime: const AwesomeTime(hour: 9, minute: 30),
        onChanged: events.add,
      )));
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.arrowDown); // hour
      expect(events.last, const AwesomeTime(hour: 10, minute: 30));
      await key(t, LogicalKeyboardKey.arrowRight);
      await key(t, LogicalKeyboardKey.arrowDown); // minute
      expect(events.last, const AwesomeTime(hour: 10, minute: 31));
    });

    testWidgets('time picker with a minute interval and seconds', (t) async {
      final events = <AwesomeTime>[];
      await t.pumpWidget(wrap(AwesomeTimePicker(
        timeFormat: AwesomeTimeFormat.Hms,
        minuteInterval: 15,
        initialTime: const AwesomeTime(hour: 9, minute: 30),
        onChanged: events.add,
      )));
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.arrowRight);
      await key(t, LogicalKeyboardKey.arrowDown); // minutes go by 15
      expect(events.last, const AwesomeTime(hour: 9, minute: 45));
      await key(t, LogicalKeyboardKey.arrowRight);
      await key(t, LogicalKeyboardKey.arrowDown); // seconds
      expect(events.last, const AwesomeTime(hour: 9, minute: 45, second: 1));
    });

    testWidgets('date-time picker', (t) async {
      final events = <AwesomeDateTime>[];
      await t.pumpWidget(wrap(AwesomeDateTimePicker(
        initialDateTime: AwesomeDateTime(
            date: d(2025, 6, 10), time: const AwesomeTime(hour: 9, minute: 30)),
        onChanged: events.add,
      )));
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.arrowDown); // day
      expect(events.last.date, d(2025, 6, 11));
      // day, month, year, hour: the fourth wheel
      for (var i = 0; i < 3; i++) {
        await key(t, LogicalKeyboardKey.arrowRight);
      }
      await key(t, LogicalKeyboardKey.arrowDown); // hour
      expect(events.last.time, const AwesomeTime(hour: 10, minute: 30));
    });

    testWidgets('date-range picker', (t) async {
      final events = <AwesomeDateRange>[];
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
        initialRange:
            AwesomeDateRange(start: d(2025, 6, 10), end: d(2025, 6, 10)),
        onChanged: events.add,
      )));
      await focusFirstWheel(t);
      await key(t, LogicalKeyboardKey.arrowDown); // start day
      // the end follows the start
      expect(events.last,
          AwesomeDateRange(start: d(2025, 6, 11), end: d(2025, 6, 11)));
    });

    testWidgets('a picker in a modal can be driven by keyboard', (t) async {
      AwesomeDate? result;
      await t.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async => result = await showAwesomeDatePicker(
              context,
              initialDate: d(2025, 6, 10),
            ),
            child: const Text('open'),
          ),
        ),
      ));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      // the sheet focuses its first button; go on to the wheels
      for (var i = 0; i < 6; i++) {
        await key(t, LogicalKeyboardKey.tab);
        if (find
            .byWidgetPredicate(
                (w) => w is Container && w.foregroundDecoration != null)
            .evaluate()
            .isNotEmpty) {
          break;
        }
      }
      await key(t, LogicalKeyboardKey.arrowDown);
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      expect(result, d(2025, 6, 11));
    });
  });
}
