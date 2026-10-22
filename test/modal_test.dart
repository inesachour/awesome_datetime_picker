import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AwesomeDate d(int y, int m, int day) =>
    AwesomeDate(year: y, month: m, day: day);

/// Pumps an app with a button that runs [open] and records its result.
class _Host {
  _Host(this.t);

  final WidgetTester t;
  Object? result;
  bool completed = false;

  Future<void> open(Future<Object?> Function(BuildContext context) open) async {
    result = null;
    completed = false;
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                result = await open(context);
                completed = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
  }
}

void main() {
  group('showAwesomeDatePicker', () {
    testWidgets('Done returns the date', (t) async {
      final host = _Host(t);
      await host.open((c) => showAwesomeDatePicker(c,
          initialDate: d(2025, 6, 15),
          minDate: d(2025, 1, 1),
          maxDate: d(2025, 12, 31)));
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
      expect(find.byType(AwesomeDatePicker), findsOneWidget);

      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      expect(host.completed, isTrue);
      expect(host.result, d(2025, 6, 15));
      expect(find.byType(AwesomeDatePicker), findsNothing);
    });

    testWidgets('returns what the user scrolled to', (t) async {
      final host = _Host(t);
      await host.open((c) => showAwesomeDatePicker(c,
          initialDate: d(2025, 6, 15),
          minDate: d(2025, 1, 1),
          maxDate: d(2025, 12, 31)));
      await t.drag(
          find.byType(ListWheelScrollView).first, const Offset(0, -45));
      await t.pumpAndSettle();
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      expect(host.result, d(2025, 6, 16));
    });

    testWidgets('Cancel returns null', (t) async {
      final host = _Host(t);
      await host
          .open((c) => showAwesomeDatePicker(c, initialDate: d(2025, 6, 15)));
      await t.drag(
          find.byType(ListWheelScrollView).first, const Offset(0, -45));
      await t.pumpAndSettle();
      await t.tap(find.text('Cancel'));
      await t.pumpAndSettle();
      expect(host.completed, isTrue);
      expect(host.result, isNull);
    });

    testWidgets('tapping outside returns null', (t) async {
      final host = _Host(t);
      await host
          .open((c) => showAwesomeDatePicker(c, initialDate: d(2025, 6, 15)));
      await t.tapAt(const Offset(10, 10));
      await t.pumpAndSettle();
      expect(host.completed, isTrue);
      expect(host.result, isNull);
    });

    testWidgets('barrierDismissible: false keeps it open', (t) async {
      final host = _Host(t);
      await host.open((c) => showAwesomeDatePicker(c,
          initialDate: d(2025, 6, 15), barrierDismissible: false));
      await t.tapAt(const Offset(10, 10));
      await t.pumpAndSettle();
      expect(host.completed, isFalse);
      expect(find.byType(AwesomeDatePicker), findsOneWidget);
    });

    testWidgets('title and button texts can be customized', (t) async {
      final host = _Host(t);
      await host.open((c) => showAwesomeDatePicker(c,
          initialDate: d(2025, 6, 15),
          title: const Text('Birthday'),
          confirmText: 'Save',
          cancelText: 'Close'));
      expect(find.text('Birthday'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('OK'), findsNothing);
    });

    testWidgets('can be shown as a dialog', (t) async {
      final host = _Host(t);
      await host.open((c) => showAwesomeDatePicker(c,
          initialDate: d(2025, 6, 15),
          presentation: AwesomePickerPresentation.dialog));
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      expect(host.result, d(2025, 6, 15));
    });

    testWidgets('picker options are forwarded', (t) async {
      final host = _Host(t);
      await host.open((c) => showAwesomeDatePicker(c,
          initialDate: d(2025, 2, 15),
          dateFormat: AwesomeDateFormat.dMMy,
          localeName: 'fr',
          showWeekday: true,
          wheelStyle: const AwesomeWheelStyle(diameterRatio: 4)));
      expect(find.text('février'), findsWidgets);
      expect(
          t
              .widget<ListWheelScrollView>(
                  find.byType(ListWheelScrollView).first)
              .diameterRatio,
          4);
    });

    testWidgets('an excluded initial date is moved before it is returned',
        (t) async {
      final host = _Host(t);
      await host.open((c) => showAwesomeDatePicker(c,
          initialDate: d(2025, 12, 25), excludedDates: [d(2025, 12, 25)]));
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      expect(host.result, d(2025, 12, 26));
    });

    testWidgets('closing leaves nothing behind', (t) async {
      final host = _Host(t);
      await host
          .open((c) => showAwesomeDatePicker(c, initialDate: d(2025, 6, 15)));
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  });

  group('the other shortcuts', () {
    testWidgets('showAwesomeTimePicker', (t) async {
      final host = _Host(t);
      await host.open((c) => showAwesomeTimePicker(c,
          initialTime: const AwesomeTime(hour: 9, minute: 30),
          minuteInterval: 15,
          timeFormat: AwesomeTimeFormat.hm));
      expect(find.text('PM'), findsWidgets);
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      expect(host.result, const AwesomeTime(hour: 9, minute: 30));
    });

    testWidgets('showAwesomeTimePicker with seconds', (t) async {
      final host = _Host(t);
      await host.open((c) => showAwesomeTimePicker(c,
          initialTime: const AwesomeTime(hour: 9, minute: 30, second: 20),
          timeFormat: AwesomeTimeFormat.Hms));
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      expect(host.result, const AwesomeTime(hour: 9, minute: 30, second: 20));
    });

    testWidgets('showAwesomeDateTimePicker', (t) async {
      final host = _Host(t);
      final initial = AwesomeDateTime(
          date: d(2025, 6, 15), time: const AwesomeTime(hour: 10, minute: 30));
      await host.open((c) => showAwesomeDateTimePicker(c,
          initialDateTime: initial,
          minDateTime: AwesomeDateTime(
              date: d(2025, 1, 1), time: const AwesomeTime(hour: 0, minute: 0)),
          maxDateTime: AwesomeDateTime(
              date: d(2025, 12, 31),
              time: const AwesomeTime(hour: 23, minute: 59))));
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      expect(host.result, initial);
    });

    testWidgets('showAwesomeDateRangePicker', (t) async {
      final host = _Host(t);
      await host.open((c) => showAwesomeDateRangePicker(c,
          initialRange:
              AwesomeDateRange(start: d(2025, 6, 10), end: d(2025, 6, 20)),
          startLabel: const Text('Check-in'),
          endLabel: const Text('Check-out')));
      expect(find.text('Check-in'), findsOneWidget);
      expect(find.text('Check-out'), findsOneWidget);
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      expect(host.result,
          AwesomeDateRange(start: d(2025, 6, 10), end: d(2025, 6, 20)));
    });

    testWidgets('the range shortcut follows the range rules', (t) async {
      final host = _Host(t);
      await host.open((c) => showAwesomeDateRangePicker(c,
          minLength: 3,
          initialRange:
              AwesomeDateRange(start: d(2025, 6, 10), end: d(2025, 6, 10))));
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      final range = host.result! as AwesomeDateRange;
      expect(range.lengthInDays, 3);
    });
  });

  group('showAwesomePicker', () {
    testWidgets('returns the controller value on Done', (t) async {
      final host = _Host(t);
      final controller =
          AwesomeDatePickerController(initialValue: d(2025, 6, 15));
      addTearDown(controller.dispose);
      await host.open((c) => showAwesomePicker<AwesomeDate>(
            c,
            controller: controller,
            builder: (_) => AwesomeDatePicker(controller: controller),
          ));
      // the app can also drive the open picker through its controller
      controller.value = d(2026, 2, 3);
      await t.pumpAndSettle();
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      expect(host.result, d(2026, 2, 3));
      expect(controller.value, d(2026, 2, 3));
    });

    testWidgets('Cancel puts the controller back to its previous value',
        (t) async {
      final host = _Host(t);
      final controller =
          AwesomeDatePickerController(initialValue: d(2025, 6, 15));
      addTearDown(controller.dispose);
      await host.open((c) => showAwesomePicker<AwesomeDate>(
            c,
            controller: controller,
            builder: (_) => AwesomeDatePicker(controller: controller),
          ));
      await t.drag(
          find.byType(ListWheelScrollView).first, const Offset(0, -45));
      await t.pumpAndSettle();
      expect(controller.value, d(2025, 6, 16));

      await t.tap(find.text('Cancel'));
      await t.pumpAndSettle();
      expect(host.result, isNull);
      expect(controller.value, d(2025, 6, 15));
    });

    testWidgets('works with any picker, including a styled one', (t) async {
      final host = _Host(t);
      final controller = AwesomeTimePickerController(
          initialValue: const AwesomeTime(hour: 8, minute: 15));
      addTearDown(controller.dispose);
      await host.open((c) => showAwesomePicker<AwesomeTime>(
            c,
            controller: controller,
            title: const Text('Alarm'),
            presentation: AwesomePickerPresentation.dialog,
            builder: (_) => AwesomeTimePicker(
              controller: controller,
              minuteInterval: 15,
              wheelStyle: const AwesomeWheelStyle(magnification: 1.2),
            ),
          ));
      expect(find.text('Alarm'), findsOneWidget);
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      expect(host.result, const AwesomeTime(hour: 8, minute: 15));
    });
  });
}
