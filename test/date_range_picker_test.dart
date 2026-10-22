import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget w) => MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: Center(child: w))));

AwesomeDate d(int y, int m, int day) =>
    AwesomeDate(year: y, month: m, day: day);

AwesomeDateRange r(AwesomeDate start, AwesomeDate end) =>
    AwesomeDateRange(start: start, end: end);

/// The day wheel of the start picker (wheels: start day/month/year, end ...).
Finder startDay() => find.byType(ListWheelScrollView).at(0);
Finder endDay() => find.byType(ListWheelScrollView).at(3);

void main() {
  group('AwesomeDateRange', () {
    test('length in days', () {
      expect(r(d(2025, 6, 10), d(2025, 6, 10)).lengthInDays, 0);
      expect(r(d(2025, 6, 10), d(2025, 6, 11)).lengthInDays, 1);
      expect(r(d(2025, 2, 27), d(2025, 3, 2)).lengthInDays, 3);
      // across a daylight-saving change
      expect(r(d(2025, 3, 29), d(2025, 3, 31)).lengthInDays, 2);
      expect(r(d(2025, 10, 25), d(2025, 10, 27)).lengthInDays, 2);
    });

    test('contains both ends', () {
      final range = r(d(2025, 6, 10), d(2025, 6, 20));
      expect(range.contains(d(2025, 6, 10)), isTrue);
      expect(range.contains(d(2025, 6, 20)), isTrue);
      expect(range.contains(d(2025, 6, 15)), isTrue);
      expect(range.contains(d(2025, 6, 9)), isFalse);
      expect(range.contains(d(2025, 6, 21)), isFalse);
    });

    test('equality, copyWith and toString', () {
      expect(r(d(2025, 6, 1), d(2025, 6, 2)), r(d(2025, 6, 1), d(2025, 6, 2)));
      expect(r(d(2025, 6, 1), d(2025, 6, 2)).hashCode,
          r(d(2025, 6, 1), d(2025, 6, 2)).hashCode);
      expect(r(d(2025, 6, 1), d(2025, 6, 2)).copyWith(end: d(2025, 6, 5)),
          r(d(2025, 6, 1), d(2025, 6, 5)));
      expect(r(d(2025, 6, 1), d(2025, 6, 2)).toString(), contains('2025-6-1'));
    });
  });

  group('picker', () {
    testWidgets('shows a start and an end picker with labels', (t) async {
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
        initialRange: r(d(2025, 6, 10), d(2025, 6, 20)),
        startLabel: const Text('From'),
        endLabel: const Text('To'),
      )));
      expect(find.byType(ListWheelScrollView), findsNWidgets(6));
      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
    });

    testWidgets('can be laid out side by side', (t) async {
      t.view.physicalSize = const Size(1600, 800);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
        direction: Axis.horizontal,
        initialRange: r(d(2025, 6, 10), d(2025, 6, 20)),
      )));
      final startX = t.getCenter(startDay()).dx;
      final endX = t.getCenter(endDay()).dx;
      expect(endX, greaterThan(startX));
      expect(t.getCenter(startDay()).dy, t.getCenter(endDay()).dy);
    });

    testWidgets('moving the start inside the range keeps the end', (t) async {
      final events = <AwesomeDateRange>[];
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
        initialRange: r(d(2025, 6, 10), d(2025, 6, 20)),
        onChanged: events.add,
      )));
      await t.drag(startDay(), const Offset(0, -45));
      await t.pumpAndSettle();
      expect(events.last, r(d(2025, 6, 11), d(2025, 6, 20)));
    });

    testWidgets('moving the start past the end moves the end along', (t) async {
      final events = <AwesomeDateRange>[];
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
        initialRange: r(d(2025, 6, 10), d(2025, 6, 10)),
        onChanged: events.add,
      )));
      await t.drag(startDay(), const Offset(0, -45));
      await t.pumpAndSettle();
      expect(events.last, r(d(2025, 6, 11), d(2025, 6, 11)));
    });

    testWidgets('the end wheel cannot go before the start', (t) async {
      final events = <AwesomeDateRange>[];
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
        initialRange: r(d(2025, 6, 10), d(2025, 6, 10)),
        onChanged: events.add,
      )));
      // scrolling the end back: nothing before the 10th is offered
      await t.drag(endDay(), const Offset(0, 90));
      await t.pumpAndSettle();
      expect(events, isEmpty);
      expect(find.descendant(of: endDay(), matching: find.text('9')),
          findsNothing);
    });

    testWidgets('minLength keeps the end that far from the start', (t) async {
      final events = <AwesomeDateRange>[];
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
        minLength: 3,
        initialRange: r(d(2025, 6, 10), d(2025, 6, 13)),
        onChanged: events.add,
      )));
      await t.drag(startDay(), const Offset(0, -45));
      await t.pumpAndSettle();
      expect(events.last, r(d(2025, 6, 11), d(2025, 6, 14)));
      expect(events.last.lengthInDays, greaterThanOrEqualTo(3));
    });

    testWidgets('maxLength pulls the end toward a start that moves away',
        (t) async {
      final events = <AwesomeDateRange>[];
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
        maxLength: 5,
        initialRange: r(d(2025, 6, 10), d(2025, 6, 15)),
        onChanged: events.add,
      )));
      // start two days earlier: the end may be at most 5 days after it
      await t.drag(startDay(), const Offset(0, 90));
      await t.pumpAndSettle();
      expect(events.last, r(d(2025, 6, 8), d(2025, 6, 13)));
      expect(events.last.lengthInDays, lessThanOrEqualTo(5));
    });

    testWidgets('the default range starts today and lasts minLength days',
        (t) async {
      final controller = AwesomeDateRangePickerController();
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
        controller: controller,
        minLength: 2,
      )));
      await t.pumpAndSettle();
      final now = DateTime.now();
      final today = d(now.year, now.month, now.day);
      expect(controller.value.start, today);
      expect(controller.value.lengthInDays, 2);
    });

    testWidgets('an initial range that breaks the rules is adjusted',
        (t) async {
      final controller = AwesomeDateRangePickerController();
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
        controller: controller,
        minDate: d(2025, 6, 1),
        maxDate: d(2025, 6, 30),
        minLength: 2,
        maxLength: 4,
      )));
      controller.value = r(d(2025, 6, 20), d(2025, 6, 10)); // end before start
      await t.pumpAndSettle();
      expect(controller.value.start, d(2025, 6, 20));
      expect(controller.value.end, d(2025, 6, 22)); // minLength 2
    });
  });

  group('controller', () {
    testWidgets('starts at its value, silently', (t) async {
      final events = <AwesomeDateRange>[];
      final controller = AwesomeDateRangePickerController(
          initialValue: r(d(2025, 6, 10), d(2025, 6, 20)));
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
          controller: controller, onChanged: events.add)));
      await t.pumpAndSettle();
      expect(controller.value, r(d(2025, 6, 10), d(2025, 6, 20)));
      expect(events, isEmpty);
    });

    testWidgets('setting value moves both pickers without onChanged',
        (t) async {
      final events = <AwesomeDateRange>[];
      final controller = AwesomeDateRangePickerController(
          initialValue: r(d(2025, 6, 10), d(2025, 6, 20)));
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
          controller: controller, onChanged: events.add)));

      controller.value = r(d(2026, 2, 3), d(2026, 2, 9));
      await t.pumpAndSettle();

      expect(controller.value, r(d(2026, 2, 3), d(2026, 2, 9)));
      expect(events, isEmpty);
      expect(find.text('2026'), findsWidgets);
    });

    testWidgets('user changes reach the controller', (t) async {
      final controller = AwesomeDateRangePickerController(
          initialValue: r(d(2025, 6, 10), d(2025, 6, 20)));
      await t.pumpWidget(wrap(AwesomeDateRangePicker(controller: controller)));
      await t.drag(startDay(), const Offset(0, -45));
      await t.pumpAndSettle();
      expect(controller.value, r(d(2025, 6, 11), d(2025, 6, 20)));
    });

    testWidgets('an impossible range is replaced by the nearest valid one',
        (t) async {
      final controller = AwesomeDateRangePickerController(
          initialValue: r(d(2025, 6, 10), d(2025, 6, 12)));
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
        controller: controller,
        minDate: d(2025, 6, 1),
        maxDate: d(2025, 6, 30),
        maxLength: 5,
      )));

      // too long: the end is pulled back to start + 5
      controller.value = r(d(2025, 6, 10), d(2025, 6, 28));
      await t.pumpAndSettle();
      expect(controller.value, r(d(2025, 6, 10), d(2025, 6, 15)));

      // outside the limits
      controller.value = r(d(2030, 1, 1), d(2030, 1, 3));
      await t.pumpAndSettle();
      expect(controller.value.start, d(2025, 6, 30));
      expect(controller.value.end, d(2025, 6, 30));
    });

    testWidgets('reset() goes back to the initial value', (t) async {
      final controller = AwesomeDateRangePickerController(
          initialValue: r(d(2025, 6, 10), d(2025, 6, 20)));
      await t.pumpWidget(wrap(AwesomeDateRangePicker(controller: controller)));
      controller.value = r(d(2026, 1, 1), d(2026, 1, 5));
      await t.pumpAndSettle();
      controller.reset();
      await t.pumpAndSettle();
      expect(controller.value, r(d(2025, 6, 10), d(2025, 6, 20)));
    });

    testWidgets('unmounting and swapping controllers is clean', (t) async {
      final first = AwesomeDateRangePickerController(
          initialValue: r(d(2025, 6, 10), d(2025, 6, 12)));
      final second = AwesomeDateRangePickerController(
          initialValue: r(d(2026, 1, 1), d(2026, 1, 3)));
      await t.pumpWidget(wrap(AwesomeDateRangePicker(controller: first)));
      await t.pumpWidget(wrap(AwesomeDateRangePicker(controller: second)));
      await t.pumpAndSettle();
      expect(find.text('2026'), findsWidgets);
      first.value = r(d(2001, 1, 1), d(2001, 1, 2));
      await t.pumpAndSettle();
      expect(second.value, r(d(2026, 1, 1), d(2026, 1, 3)));

      await t.pumpWidget(wrap(const SizedBox()));
      second.value = r(d(2027, 1, 1), d(2027, 1, 2));
      await t.pump();
      expect(t.takeException(), isNull);
    });
  });

  group('exclusions', () {
    testWidgets('apply to both dates', (t) async {
      final controller = AwesomeDateRangePickerController(
          initialValue: r(d(2025, 6, 13), d(2025, 6, 16))); // Fri to Mon
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
        controller: controller,
        excludedWeekdays: const [DateTime.saturday, DateTime.sunday],
      )));

      // a Saturday start and a Sunday end move to Monday
      controller.value = r(d(2025, 6, 14), d(2025, 6, 15));
      await t.pumpAndSettle();
      expect(controller.value.start, d(2025, 6, 16));
      expect(controller.value.end, d(2025, 6, 16));
    });

    testWidgets(
        'a start without any selectable end moves to the nearest '
        'start that has one', (t) async {
      // Nothing can be picked from the 10th to the 20th; ranges last at most
      // 3 days, so a start on the 12th has no end (12..15 are all excluded).
      bool open(AwesomeDate date) => date.day < 10 || date.day > 20;
      final controller = AwesomeDateRangePickerController(
          initialValue: r(d(2025, 6, 5), d(2025, 6, 6)));
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
        controller: controller,
        minDate: d(2025, 6, 1),
        maxDate: d(2025, 6, 30),
        maxLength: 3,
        selectableDayPredicate: open,
      )));

      controller.value = r(d(2025, 6, 12), d(2025, 6, 13));
      await t.pumpAndSettle();
      expect(controller.value.start, d(2025, 6, 9)); // 6/9..6/12 includes 6/9
      expect(open(controller.value.end), isTrue);
      expect(t.takeException(), isNull);
    });

    testWidgets('the last start leaves room for an end', (t) async {
      final controller = AwesomeDateRangePickerController(
          initialValue: r(d(2025, 6, 5), d(2025, 6, 8)));
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
        controller: controller,
        minDate: d(2025, 6, 1),
        maxDate: d(2025, 6, 30),
        minLength: 3,
      )));
      controller.value = r(d(2025, 6, 30), d(2025, 6, 30));
      await t.pumpAndSettle();
      // the end must be 3 days after the start: the start cannot go past 6/27
      expect(controller.value, r(d(2025, 6, 27), d(2025, 6, 30)));
    });

    testWidgets('excluded values can be shown dimmed', (t) async {
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
        initialRange: r(d(2025, 6, 13), d(2025, 6, 16)),
        excludedWeekdays: const [DateTime.saturday, DateTime.sunday],
        showDisabledValues: true,
      )));
      expect(find.byType(Opacity), findsWidgets);
    });
  });

  group('rules change after the first build', () {
    testWidgets('a smaller maxDate adjusts the range and tells the controller',
        (t) async {
      final controller = AwesomeDateRangePickerController(
          initialValue: r(d(2025, 6, 20), d(2025, 6, 28)));
      Widget build(AwesomeDate max) => wrap(AwesomeDateRangePicker(
            controller: controller,
            minDate: d(2025, 6, 1),
            maxDate: max,
          ));
      await t.pumpWidget(build(d(2025, 6, 30)));
      await t.pumpWidget(build(d(2025, 6, 24)));
      await t.pumpAndSettle();
      expect(controller.value, r(d(2025, 6, 20), d(2025, 6, 24)));
    });

    testWidgets('a new minLength moves the end', (t) async {
      final controller = AwesomeDateRangePickerController(
          initialValue: r(d(2025, 6, 20), d(2025, 6, 21)));
      Widget build(int min) => wrap(AwesomeDateRangePicker(
            controller: controller,
            minLength: min,
          ));
      await t.pumpWidget(build(0));
      await t.pumpWidget(build(5));
      await t.pumpAndSettle();
      expect(controller.value, r(d(2025, 6, 20), d(2025, 6, 25)));
    });
  });

  group('asserts', () {
    test('invalid configurations fail fast in debug mode', () {
      expect(() => AwesomeDateRangePicker(minLength: -1), throwsAssertionError);
      expect(() => AwesomeDateRangePicker(minLength: 3, maxLength: 2),
          throwsAssertionError);
      expect(() => AwesomeDateRangePicker(dateFormat: AwesomeDateFormat.My),
          throwsAssertionError);
      expect(
        () => AwesomeDateRangePicker(
          controller: AwesomeDateRangePickerController(),
          initialRange: r(d(2025, 6, 1), d(2025, 6, 2)),
        ),
        throwsAssertionError,
      );
      expect(
        () => AwesomeDateRangePicker(
            minDate: d(2025, 6, 10), maxDate: d(2025, 6, 1)),
        throwsAssertionError,
      );
    });
  });

  group('styling', () {
    testWidgets('options reach the wheels of both pickers', (t) async {
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
        initialRange: r(d(2025, 6, 10), d(2025, 6, 20)),
        itemWidth: 77,
        wheelStyle: const AwesomeWheelStyle(diameterRatio: 3),
        looping: true,
      )));
      for (final wheel in t
          .widgetList<ListWheelScrollView>(find.byType(ListWheelScrollView))) {
        expect(wheel.diameterRatio, 3);
      }
      expect(t.getSize(find.byType(ListWheelScrollView).first).width, 77);
    });

    testWidgets('localeName and showWeekday work', (t) async {
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
        dateFormat: AwesomeDateFormat.dMMy,
        localeName: 'fr',
        initialRange: r(d(2025, 2, 10), d(2025, 3, 20)),
      )));
      expect(find.text('février'), findsWidgets);
      expect(find.text('mars'), findsWidgets);
    });
  });
}
