import 'dart:ui' show SemanticsAction;

import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget w) => MaterialApp(home: Scaffold(body: Center(child: w)));

void phone(WidgetTester t) {
  t.view.physicalSize = const Size(390 * 3, 844 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
}

void main() {
  testWidgets('time wheels show zero-padded minutes', (t) async {
    await t.pumpWidget(wrap(AwesomeTimePicker(
      initialTime: const AwesomeTime(hour: 9, minute: 5),
    )));
    expect(find.text('05'), findsWidgets);
    expect(find.text('09'), findsWidgets);
  });

  testWidgets('month-name wheel is wide enough on a phone', (t) async {
    phone(t);
    await t.pumpWidget(wrap(AwesomeDatePicker(
      dateFormat: AwesomeDateFormat.dMMy,
      initialDate: const AwesomeDate(year: 2025, month: 9, day: 5),
    )));
    final wheels = find.byType(ListWheelScrollView);
    final monthWidth = t.getSize(wheels.at(1)).width;
    final dayWidth = t.getSize(wheels.at(0)).width;
    expect(monthWidth, greaterThanOrEqualTo(110));
    expect(monthWidth, greaterThan(dayWidth));
  });

  testWidgets('default wheel width stays bounded on very wide screens',
      (t) async {
    t.view.physicalSize = const Size(1920, 1080);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(wrap(AwesomeDatePicker()));
    expect(
        t.getSize(find.byType(ListWheelScrollView).first).width, lessThan(100));
  });

  testWidgets('an explicit itemWidth still wins', (t) async {
    await t.pumpWidget(wrap(AwesomeDatePicker(itemWidth: 123)));
    expect(t.getSize(find.byType(ListWheelScrollView).first).width, 123);
  });

  testWidgets('dragging with a mouse scrolls the wheel', (t) async {
    AwesomeDate? last;
    await t.pumpWidget(wrap(AwesomeDatePicker(
      initialDate: const AwesomeDate(year: 2025, month: 6, day: 15),
      onChanged: (d) => last = d,
    )));
    final gesture = await t.startGesture(
        t.getCenter(find.byType(ListWheelScrollView).first),
        kind: PointerDeviceKind.mouse);
    await gesture.moveBy(const Offset(0, -80));
    await gesture.up();
    await t.pumpAndSettle();
    expect(last, isNotNull);
  });

  testWidgets('wheels expose an adjustable value to screen readers', (t) async {
    final handle = t.ensureSemantics();
    AwesomeDate? last;
    await t.pumpWidget(wrap(AwesomeDatePicker(
      initialDate: const AwesomeDate(year: 2025, month: 6, day: 15),
      onChanged: (d) => last = d,
    )));

    final adjustable = find.semantics.byAction(SemanticsAction.increase);
    expect(adjustable, findsNWidgets(3)); // day, month, year wheels

    // The first wheel is the day: "increase" selects the next day.
    t.semantics.increase(adjustable.first);
    await t.pumpAndSettle();
    expect(last, const AwesomeDate(year: 2025, month: 6, day: 16));
    handle.dispose();
  });

  testWidgets('AwesomeDateTimePicker asserts on a reversed range', (t) async {
    await t.pumpWidget(wrap(AwesomeDateTimePicker(
      minDateTime: const AwesomeDateTime(
          date: AwesomeDate(year: 2025, month: 12, day: 31),
          time: AwesomeTime(hour: 0, minute: 0)),
      maxDateTime: const AwesomeDateTime(
          date: AwesomeDate(year: 2025, month: 1, day: 1),
          time: AwesomeTime(hour: 0, minute: 0)),
    )));
    expect(t.takeException(), isA<AssertionError>());
  });
}
