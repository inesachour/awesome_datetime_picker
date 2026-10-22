import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/shared/custom_item_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget w, {ThemeData? theme}) => MaterialApp(
    theme: theme, home: Scaffold(body: Center(child: w)));

void main() {
  testWidgets('date picker clamps selection when the range shrinks',
      (t) async {
    final events = <AwesomeDate>[];
    // initialDate only seeds the first build; later builds just change the range.
    Widget build(AwesomeDate max, {AwesomeDate? initial}) =>
        wrap(AwesomeDatePicker(
          minDate: const AwesomeDate(year: 2024, month: 1, day: 1),
          maxDate: max,
          initialDate: initial,
          onChanged: events.add,
        ));

    await t.pumpWidget(build(const AwesomeDate(year: 2026, month: 1, day: 1),
        initial: const AwesomeDate(year: 2025, month: 6, day: 15)));
    await t.pumpWidget(build(const AwesomeDate(year: 2025, month: 3, day: 10)));
    await t.pumpAndSettle();

    expect(events.last, const AwesomeDate(year: 2025, month: 3, day: 10));
    expect(t.takeException(), isNull);
  });

  testWidgets('date picker keeps its selection when nothing relevant changes',
      (t) async {
    final events = <AwesomeDate>[];
    Widget build() => wrap(AwesomeDatePicker(
          initialDate: const AwesomeDate(year: 2025, month: 6, day: 15),
          onChanged: events.add,
        ));
    await t.pumpWidget(build());
    await t.pumpWidget(build());
    await t.pumpAndSettle();
    expect(events, isEmpty);
  });

  testWidgets('time picker clamps selection when the range shrinks',
      (t) async {
    final events = <AwesomeTime>[];
    Widget build(AwesomeTime max) => wrap(AwesomeTimePicker(
          minTime: const AwesomeTime(hour: 0, minute: 0),
          maxTime: max,
          initialTime: const AwesomeTime(hour: 16, minute: 30),
          onChanged: events.add,
        ));

    await t.pumpWidget(build(const AwesomeTime(hour: 23, minute: 59)));
    await t.pumpWidget(build(const AwesomeTime(hour: 12, minute: 0)));
    await t.pumpAndSettle();

    expect(events.last, const AwesomeTime(hour: 12, minute: 0));
  });

  testWidgets('datetime picker defaults to now, not the minimum', (t) async {
    AwesomeDateTime? last;
    await t.pumpWidget(wrap(AwesomeDateTimePicker(onChanged: (v) => last = v)));
    // Nudge one wheel so onChanged reports the current selection.
    await t.drag(find.byType(ListWheelScrollView).first, const Offset(0, -40));
    await t.pumpAndSettle();
    expect(last!.date.year, greaterThanOrEqualTo(DateTime.now().year));
  });

  testWidgets('wheel defaults follow the theme brightness', (t) async {
    Color? backgroundOf(WidgetTester t) {
      final container = t.widget<Container>(find
          .descendant(
              of: find.byType(CustomItemPicker),
              matching: find.byType(Container))
          .first);
      return (container.decoration as BoxDecoration?)?.color;
    }

    await t.pumpWidget(wrap(AwesomeTimePicker(),
        theme: ThemeData(brightness: Brightness.light)));
    await t.pumpAndSettle();
    expect(backgroundOf(t), Colors.white);

    await t.pumpWidget(wrap(AwesomeTimePicker(),
        theme: ThemeData(brightness: Brightness.dark)));
    await t.pumpAndSettle();
    expect(backgroundOf(t), const Color(0xFF1C1C1E));
  });

  testWidgets('explicit backgroundColor still wins in dark mode', (t) async {
    await t.pumpWidget(wrap(
        AwesomeTimePicker(backgroundColor: Colors.red),
        theme: ThemeData(brightness: Brightness.dark)));
    final container = t.widget<Container>(find
        .descendant(
            of: find.byType(CustomItemPicker),
            matching: find.byType(Container))
        .first);
    expect((container.decoration as BoxDecoration).color, Colors.red);
  });
}
