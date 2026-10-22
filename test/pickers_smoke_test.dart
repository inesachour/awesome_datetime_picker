import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget w) => MaterialApp(home: Scaffold(body: Center(child: w)));

Future<void> scrollAll(WidgetTester t) async {
  final n = find.byType(ListWheelScrollView).evaluate().length;
  for (var i = 0; i < n; i++) {
    await t.drag(find.byType(ListWheelScrollView).at(i), const Offset(0, -60));
    await t.pumpAndSettle();
  }
}

void main() {
  testWidgets('date picker scrolls and reports changes', (t) async {
    AwesomeDate? last;
    await t.pumpWidget(wrap(AwesomeDatePicker(
      minDate: const AwesomeDate(year: 2024, month: 2, day: 15),
      maxDate: const AwesomeDate(year: 2026, month: 10, day: 10),
      initialDate: const AwesomeDate(year: 2025, month: 6, day: 15),
      dateFormat: AwesomeDateFormat.dMMy,
      onChanged: (d) => last = d,
    )));
    await scrollAll(t);
    expect(t.takeException(), isNull);
    expect(last, isNotNull);
  });

  testWidgets('time picker (12h) scrolls and reports changes', (t) async {
    AwesomeTime? last;
    await t.pumpWidget(wrap(AwesomeTimePicker(
      timeFormat: AwesomeTimeFormat.hm,
      minTime: const AwesomeTime(hour: 5, minute: 20),
      maxTime: const AwesomeTime(hour: 15, minute: 15),
      initialTime: const AwesomeTime(hour: 15, minute: 10),
      onChanged: (x) => last = x,
    )));
    await scrollAll(t);
    expect(t.takeException(), isNull);
    expect(last, isNotNull);
  });

  testWidgets('datetime picker stays inside its range', (t) async {
    AwesomeDateTime? last;
    await t.pumpWidget(wrap(AwesomeDateTimePicker(
      initialDateTime: const AwesomeDateTime(
          date: AwesomeDate(year: 2025, month: 12, day: 12),
          time: AwesomeTime(hour: 10, minute: 30)),
      minDateTime: const AwesomeDateTime(
          date: AwesomeDate(year: 2025, month: 12, day: 1),
          time: AwesomeTime(hour: 8, minute: 0)),
      maxDateTime: const AwesomeDateTime(
          date: AwesomeDate(year: 2025, month: 12, day: 31),
          time: AwesomeTime(hour: 18, minute: 0)),
      dateFormat: AwesomeDateFormat.dMMy,
      timeFormat: AwesomeTimeFormat.hm,
      onChanged: (x) => last = x,
    )));
    await scrollAll(t);
    expect(t.takeException(), isNull);
    final dt = last!.toDateTime();
    expect(dt.isBefore(DateTime(2025, 12, 1, 8)), isFalse);
    expect(dt.isAfter(DateTime(2025, 12, 31, 18)), isFalse);
  });
}
