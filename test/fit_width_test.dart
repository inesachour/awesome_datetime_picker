import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AwesomeDate d(int y, int m, int day) =>
    AwesomeDate(year: y, month: m, day: day);

void phone(WidgetTester t, {double width = 390}) {
  t.view.physicalSize = Size(width * 3, 844 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
}

Widget app(Widget picker) =>
    MaterialApp(home: Scaffold(body: Center(child: picker)));

/// The left and right edges of the wheels as drawn on screen. Unlike
/// `getSize`, these include the scaling of a picker that was shrunk to fit.
({double left, double right}) drawnEdges(WidgetTester t) {
  final wheels = find.byType(ListWheelScrollView);
  return (
    left: t.getTopLeft(wheels.first).dx,
    right: t.getBottomRight(wheels.last).dx,
  );
}

/// Fails unless every wheel is drawn inside the screen.
void expectDrawnInside(WidgetTester t, double screenWidth, {String? reason}) {
  final edges = drawnEdges(t);
  expect(edges.left, greaterThanOrEqualTo(-0.5), reason: reason);
  expect(edges.right, lessThanOrEqualTo(screenWidth + 0.5), reason: reason);
}

void main() {
  group('a picker wider than the space it has', () {
    testWidgets('six wheels with weekday labels fit a phone', (t) async {
      phone(t);
      // day (wide, weekday), month, year, hour, minute, second
      await t.pumpWidget(app(AwesomeDateTimePicker(
        showWeekday: true,
        timeFormat: AwesomeTimeFormat.Hms,
        initialDateTime: AwesomeDateTime(
            date: d(2025, 6, 15), time: const AwesomeTime(hour: 9, minute: 5)),
      )));
      expect(t.takeException(), isNull, reason: 'no overflow');
      expectDrawnInside(t, 390);
    });

    testWidgets('month names, weekday labels and a time fit a phone',
        (t) async {
      phone(t);
      await t.pumpWidget(app(const AwesomeDateTimePicker(
        dateFormat: AwesomeDateFormat.dMMy,
        showWeekday: true,
        timeFormat: AwesomeTimeFormat.hm,
      )));
      expect(t.takeException(), isNull);
      expectDrawnInside(t, 390);
    });

    testWidgets('a narrow phone and large text', (t) async {
      phone(t, width: 320);
      await t.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const Scaffold(
          body: Center(
            child: AwesomeDateTimePicker(
              dateFormat: AwesomeDateFormat.dMMy,
              timeFormat: AwesomeTimeFormat.Hms,
            ),
          ),
        ),
      ));
      expect(t.takeException(), isNull);
      expectDrawnInside(t, 320);
    });

    testWidgets('the date picker, time picker and range picker too', (t) async {
      phone(t, width: 200);
      for (final picker in <Widget>[
        AwesomeDatePicker(
            dateFormat: AwesomeDateFormat.dMMy, showWeekday: true),
        AwesomeTimePicker(timeFormat: AwesomeTimeFormat.hms),
        AwesomeDateRangePicker(
          direction: Axis.horizontal,
          dateFormat: AwesomeDateFormat.dMMy,
        ),
      ]) {
        await t.pumpWidget(app(picker));
        expect(t.takeException(), isNull, reason: '${picker.runtimeType}');
        expectDrawnInside(t, 200, reason: '${picker.runtimeType}');
      }
    });

    testWidgets('a shrunk picker can still be scrolled', (t) async {
      phone(t, width: 200);
      final events = <AwesomeDate>[];
      await t.pumpWidget(app(AwesomeDatePicker(
        dateFormat: AwesomeDateFormat.dMMy,
        showWeekday: true,
        initialDate: d(2025, 6, 15),
        onChanged: events.add,
      )));
      expectDrawnInside(t, 200);
      await t.drag(
          find.byType(ListWheelScrollView).first, const Offset(0, -45));
      await t.pumpAndSettle();
      expect(events, isNotEmpty);
    });

    testWidgets('the text is smaller, not cut', (t) async {
      phone(t, width: 200);
      await t.pumpWidget(app(AwesomeDatePicker(
        dateFormat: AwesomeDateFormat.dMMy,
        initialDate: d(2025, 9, 15),
      )));
      expect(find.text('September'), findsOneWidget);
      expect(find.textContaining('…'), findsNothing);
    });
  });

  group('a picker that fits', () {
    testWidgets('is not scaled', (t) async {
      phone(t);
      await t.pumpWidget(app(AwesomeDatePicker()));
      // three wheels of 58.5 and the usual 200 px height
      expect(
          t.getSize(find.byType(AwesomeDatePicker)), const Size(58.5 * 3, 200));
    });

    testWidgets('keeps explicit wheel widths', (t) async {
      phone(t);
      await t.pumpWidget(app(AwesomeDatePicker(itemWidth: 90)));
      expect(t.getSize(find.byType(AwesomeDatePicker)), const Size(270, 200));
    });

    testWidgets('an unbounded parent is not an error', (t) async {
      phone(t);
      await t.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: AwesomeDateTimePicker(
              dateFormat: AwesomeDateFormat.dMMy,
              timeFormat: AwesomeTimeFormat.Hms,
              itemWidth: 120,
            ),
          ),
        ),
      ));
      expect(t.takeException(), isNull);
      // not squeezed: it is wider than the screen and scrolls
      expect(t.getSize(find.byType(AwesomeDateTimePicker)).width,
          greaterThan(390));
    });
  });
}
