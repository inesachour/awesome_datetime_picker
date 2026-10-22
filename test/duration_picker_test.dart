import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget w) => MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: Center(child: w))));

const h1m30 = Duration(hours: 1, minutes: 30);

Finder wheels() => find.byType(ListWheelScrollView);

Future<void> drag(WidgetTester t, int wheel, double dy) async {
  await t.drag(wheels().at(wheel), Offset(0, dy));
  await t.pumpAndSettle();
}

void main() {
  group('wheels', () {
    testWidgets('hours and minutes by default, with their values', (t) async {
      await t.pumpWidget(wrap(AwesomeDurationPicker(initialDuration: h1m30)));
      expect(wheels(), findsNWidgets(2));
      expect(find.text('1'), findsWidgets); // hours, not padded
      expect(find.text('30'), findsWidgets);
    });

    testWidgets('minutes and seconds', (t) async {
      await t.pumpWidget(wrap(AwesomeDurationPicker(
        format: AwesomeDurationFormat.ms,
        initialDuration: const Duration(minutes: 5, seconds: 7),
      )));
      expect(wheels(), findsNWidgets(2));
      expect(find.text('5'), findsWidgets);
      expect(find.text('07'), findsWidgets);
    });

    testWidgets('hours, minutes and seconds', (t) async {
      await t.pumpWidget(wrap(AwesomeDurationPicker(
        format: AwesomeDurationFormat.hms,
        initialDuration: const Duration(hours: 2, minutes: 3, seconds: 4),
      )));
      expect(wheels(), findsNWidgets(3));
      expect(find.text('2'), findsWidgets);
      expect(find.text('03'), findsWidgets);
      expect(find.text('04'), findsWidgets);
    });

    testWidgets('it starts at zero, not at the current time', (t) async {
      final controller = AwesomeDurationPickerController();
      await t.pumpWidget(wrap(AwesomeDurationPicker(controller: controller)));
      await t.pumpAndSettle();
      expect(controller.value, Duration.zero);
    });

    testWidgets('it starts at minDuration when there is one', (t) async {
      final controller = AwesomeDurationPickerController(
          initialValue: const Duration(minutes: 5));
      await t.pumpWidget(wrap(AwesomeDurationPicker(
        controller: controller,
        minDuration: const Duration(minutes: 20),
      )));
      await t.pumpAndSettle();
      expect(controller.value, const Duration(minutes: 20));
    });
  });

  group('user input', () {
    testWidgets('scrolling the hours', (t) async {
      final events = <Duration>[];
      await t.pumpWidget(wrap(AwesomeDurationPicker(
          initialDuration: h1m30, onChanged: events.add)));
      await drag(t, 0, -45);
      expect(events.last, const Duration(hours: 2, minutes: 30));
    });

    testWidgets('scrolling the minutes', (t) async {
      final events = <Duration>[];
      await t.pumpWidget(wrap(AwesomeDurationPicker(
          initialDuration: h1m30, onChanged: events.add)));
      await drag(t, 1, -45);
      expect(events.last, const Duration(hours: 1, minutes: 31));
    });

    testWidgets('scrolling the seconds', (t) async {
      final events = <Duration>[];
      await t.pumpWidget(wrap(AwesomeDurationPicker(
        format: AwesomeDurationFormat.hms,
        initialDuration: h1m30,
        onChanged: events.add,
      )));
      await drag(t, 2, -45);
      expect(events.last, const Duration(hours: 1, minutes: 30, seconds: 1));
    });

    testWidgets('a duration longer than 59 minutes with minutes first',
        (t) async {
      final controller = AwesomeDurationPickerController();
      await t.pumpWidget(wrap(AwesomeDurationPicker(
        controller: controller,
        format: AwesomeDurationFormat.ms,
        maxDuration: const Duration(minutes: 120),
      )));
      controller.value = const Duration(minutes: 90, seconds: 15);
      await t.pumpAndSettle();
      expect(controller.value, const Duration(minutes: 90, seconds: 15));
      expect(find.text('90'), findsWidgets);
    });

    testWidgets('onChanged is not called at the start', (t) async {
      final events = <Duration>[];
      await t.pumpWidget(wrap(AwesomeDurationPicker(
          initialDuration: h1m30, onChanged: events.add)));
      await t.pumpAndSettle();
      expect(events, isEmpty);
    });
  });

  group('limits and intervals', () {
    testWidgets('the hours wheel is cut by the limits', (t) async {
      await t.pumpWidget(wrap(AwesomeDurationPicker(
        minDuration: const Duration(hours: 1),
        maxDuration: const Duration(hours: 3),
        initialDuration: const Duration(hours: 2),
        visibleItemCount: 7,
      )));
      expect(find.text('0'), findsNothing);
      expect(find.text('4'), findsNothing);
    });

    testWidgets('minutes go by the interval', (t) async {
      await t.pumpWidget(wrap(AwesomeDurationPicker(
        minuteInterval: 15,
        initialDuration: h1m30,
      )));
      expect(find.text('45'), findsWidgets);
      expect(find.text('31'), findsNothing);
    });

    testWidgets('seconds go by their interval', (t) async {
      await t.pumpWidget(wrap(AwesomeDurationPicker(
        format: AwesomeDurationFormat.ms,
        secondInterval: 15,
        initialDuration: const Duration(minutes: 1, seconds: 30),
      )));
      expect(find.text('45'), findsWidgets);
      expect(find.text('31'), findsNothing);
    });

    testWidgets('looping wheels wrap, the first one never does', (t) async {
      await t.pumpWidget(wrap(AwesomeDurationPicker(
        format: AwesomeDurationFormat.hms,
        looping: true,
        initialDuration: const Duration(hours: 23, minutes: 59, seconds: 59),
      )));
      final loops = t
          .widgetList<ListWheelScrollView>(wheels())
          .map((w) => w.childDelegate is ListWheelChildLoopingListDelegate)
          .toList();
      expect(loops, [false, true, true]);
    });

    testWidgets('a looping minutes wheel wraps without carrying', (t) async {
      final events = <Duration>[];
      await t.pumpWidget(wrap(AwesomeDurationPicker(
        looping: true,
        initialDuration: const Duration(hours: 2, minutes: 59),
        onChanged: events.add,
      )));
      await drag(t, 1, -45);
      expect(events.last, const Duration(hours: 2));
    });
  });

  group('controller', () {
    testWidgets('setting the value moves the wheels without onChanged',
        (t) async {
      final events = <Duration>[];
      final controller = AwesomeDurationPickerController(initialValue: h1m30);
      await t.pumpWidget(wrap(AwesomeDurationPicker(
          controller: controller, onChanged: events.add)));
      controller.value = const Duration(hours: 5, minutes: 10);
      await t.pumpAndSettle();
      expect(events, isEmpty);
      expect(find.text('5'), findsWidgets);
      expect(find.text('10'), findsWidgets);
    });

    testWidgets('user changes reach the controller', (t) async {
      final controller = AwesomeDurationPickerController(initialValue: h1m30);
      await t.pumpWidget(wrap(AwesomeDurationPicker(controller: controller)));
      await drag(t, 0, -45);
      expect(controller.value, const Duration(hours: 2, minutes: 30));
    });

    testWidgets('an impossible value is replaced by the nearest one',
        (t) async {
      final controller = AwesomeDurationPickerController(initialValue: h1m30);
      await t.pumpWidget(wrap(AwesomeDurationPicker(
        controller: controller,
        maxDuration: const Duration(hours: 3),
        minuteInterval: 15,
      )));
      controller.value = const Duration(hours: 9);
      await t.pumpAndSettle();
      expect(controller.value, const Duration(hours: 3));
      controller.value = const Duration(hours: 1, minutes: 8);
      await t.pumpAndSettle();
      expect(controller.value, const Duration(hours: 1, minutes: 15));
    });

    testWidgets('seconds are dropped by a format without seconds', (t) async {
      final controller = AwesomeDurationPickerController(
          initialValue: const Duration(minutes: 5, seconds: 20));
      await t.pumpWidget(wrap(AwesomeDurationPicker(controller: controller)));
      await t.pumpAndSettle();
      expect(controller.value, const Duration(minutes: 5));
    });

    testWidgets('reset() goes back to the initial value', (t) async {
      final controller = AwesomeDurationPickerController(initialValue: h1m30);
      await t.pumpWidget(wrap(AwesomeDurationPicker(controller: controller)));
      controller.value = const Duration(hours: 8);
      await t.pumpAndSettle();
      controller.reset();
      await t.pumpAndSettle();
      expect(controller.value, h1m30);
    });

    testWidgets('a controller can be swapped, and removed cleanly', (t) async {
      final first = AwesomeDurationPickerController(initialValue: h1m30);
      final second = AwesomeDurationPickerController(
          initialValue: const Duration(hours: 7));
      await t.pumpWidget(wrap(AwesomeDurationPicker(controller: first)));
      await t.pumpWidget(wrap(AwesomeDurationPicker(controller: second)));
      await t.pumpAndSettle();
      expect(find.text('7'), findsWidgets);
      first.value = const Duration(hours: 3);
      await t.pumpAndSettle();
      expect(second.value, const Duration(hours: 7));

      await t.pumpWidget(wrap(const SizedBox()));
      second.value = const Duration(hours: 9);
      await t.pump();
      expect(t.takeException(), isNull);
    });

    test('defaults to zero', () {
      expect(AwesomeDurationPickerController().value, Duration.zero);
    });
  });

  group('changing the rules afterwards', () {
    testWidgets('a smaller maximum moves the selection and tells the app',
        (t) async {
      final controller = AwesomeDurationPickerController(
          initialValue: const Duration(hours: 8));
      final events = <Duration>[];
      Widget build(Duration max) => wrap(AwesomeDurationPicker(
            controller: controller,
            maxDuration: max,
            onChanged: events.add,
          ));
      await t.pumpWidget(build(const Duration(hours: 12)));
      await t.pumpWidget(build(const Duration(hours: 5)));
      await t.pumpAndSettle();
      expect(controller.value, const Duration(hours: 5));
      expect(events.last, const Duration(hours: 5));
    });

    testWidgets('a new format changes the wheels and keeps the duration',
        (t) async {
      Widget build(AwesomeDurationFormat f) => wrap(AwesomeDurationPicker(
            format: f,
            initialDuration: h1m30,
          ));
      await t.pumpWidget(build(AwesomeDurationFormat.hm));
      expect(wheels(), findsNWidgets(2));
      await t.pumpWidget(build(AwesomeDurationFormat.hms));
      await t.pumpAndSettle();
      expect(wheels(), findsNWidgets(3));
      expect(t.takeException(), isNull);
    });
  });

  group('look', () {
    testWidgets('a theme per unit, whichever wheel it is on', (t) async {
      await t.pumpWidget(wrap(AwesomeDurationPicker(
        format: AwesomeDurationFormat.ms,
        theme: const AwesomeDurationPickerTheme(
          minuteTheme: ItemTheme(width: 111),
          secondTheme: ItemTheme(width: 66),
        ),
      )));
      expect(t.getSize(wheels().at(0)).width, 111);
      expect(t.getSize(wheels().at(1)).width, 66);
    });

    testWidgets('options of the picker', (t) async {
      await t.pumpWidget(wrap(AwesomeDurationPicker(
        itemWidth: 80,
        itemHeight: 30,
        wheelStyle: const AwesomeWheelStyle(diameterRatio: 3),
      )));
      expect(t.getSize(wheels().first), const Size(80, 150));
      expect(t.widget<ListWheelScrollView>(wheels().first).diameterRatio, 3);
    });

    testWidgets('the theme of the app', (t) async {
      await t.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: const [
          AwesomePickerThemeData(
              itemWidth: 77, wheelStyle: AwesomeWheelStyle.ios()),
        ]),
        home: Scaffold(body: Center(child: AwesomeDurationPicker())),
      ));
      expect(t.getSize(wheels().first).width, 77);
      expect(t.widget<ListWheelScrollView>(wheels().first).diameterRatio, 1.07);
    });

    testWidgets('digits follow the locale while the value stays numeric',
        (t) async {
      final controller = AwesomeDurationPickerController(
          initialValue: const Duration(hours: 1, minutes: 5));
      await t.pumpWidget(wrap(
          AwesomeDurationPicker(controller: controller, localeName: 'fa')));
      expect(find.text('۱'), findsWidgets);
      expect(find.text('۰۵'), findsWidgets);
      expect(find.text('05'), findsNothing);
      expect(controller.value, const Duration(hours: 1, minutes: 5));
    });

    testWidgets('a picker too wide for its parent shrinks', (t) async {
      t.view.physicalSize = const Size(150 * 3, 844 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(wrap(AwesomeDurationPicker(
          format: AwesomeDurationFormat.hms, itemWidth: 90)));
      expect(t.takeException(), isNull);
      expect(t.getBottomRight(wheels().last).dx, lessThanOrEqualTo(150.5));
    });

    testWidgets('it is only as tall as its wheels', (t) async {
      t.view.physicalSize = const Size(390 * 3, 844 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
          home: Scaffold(body: Center(child: AwesomeDurationPicker()))));
      expect(t.getSize(find.byType(AwesomeDurationPicker)).height, 200);
    });
  });

  group('accessibility', () {
    testWidgets('the wheels announce a label and the value', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(wrap(AwesomeDurationPicker(
        format: AwesomeDurationFormat.hms,
        initialDuration: const Duration(hours: 1, minutes: 5, seconds: 9),
      )));
      final labels = [
        for (final node
            in find.semantics.byAction(SemanticsAction.increase).evaluate())
          '${node.label}=${node.value}',
      ];
      expect(labels, ['Hour=1', 'Minute=05', 'Second=09']);
      handle.dispose();
    });

    testWidgets('in the language of localeName, or your own words', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(wrap(AwesomeDurationPicker(localeName: 'fr')));
      expect([
        for (final n
            in find.semantics.byAction(SemanticsAction.increase).evaluate())
          n.label
      ], [
        'Heure',
        'Minute'
      ]);
      await t.pumpWidget(wrap(AwesomeDurationPicker(
        semanticLabels: const AwesomeSemanticLabels(hour: 'Horas'),
      )));
      expect([
        for (final n
            in find.semantics.byAction(SemanticsAction.increase).evaluate())
          n.label
      ], [
        'Horas',
        'Minute'
      ]);
      handle.dispose();
    });

    testWidgets('screen-reader actions change the duration', (t) async {
      final handle = t.ensureSemantics();
      final events = <Duration>[];
      await t.pumpWidget(wrap(AwesomeDurationPicker(
          initialDuration: h1m30, onChanged: events.add)));
      t.semantics.increase(find.semantics.byLabel('Hour'));
      await t.pumpAndSettle();
      expect(events.last, const Duration(hours: 2, minutes: 30));
      handle.dispose();
    });
  });

  group('keyboard', () {
    Future<void> key(WidgetTester t, LogicalKeyboardKey k) async {
      await t.sendKeyEvent(k);
      await t.pumpAndSettle();
    }

    testWidgets('arrows, pages and Home/End work on the wheels', (t) async {
      final events = <Duration>[];
      await t.pumpWidget(wrap(AwesomeDurationPicker(
          initialDuration: h1m30, onChanged: events.add)));
      await key(t, LogicalKeyboardKey.tab);
      await key(t, LogicalKeyboardKey.arrowDown);
      expect(events.last, const Duration(hours: 2, minutes: 30));
      await key(t, LogicalKeyboardKey.end);
      expect(events.last, const Duration(hours: 23, minutes: 30));
      await key(t, LogicalKeyboardKey.home);
      expect(events.last, const Duration(minutes: 30));
      await key(t, LogicalKeyboardKey.arrowRight);
      await key(t, LogicalKeyboardKey.pageDown);
      expect(events.last, const Duration(minutes: 34));
    });
  });

  group('modal', () {
    testWidgets('showAwesomeDurationPicker returns the confirmed duration',
        (t) async {
      Duration? result;
      await t.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async => result = await showAwesomeDurationPicker(
              context,
              initialDuration: h1m30,
              minuteInterval: 15,
            ),
            child: const Text('open'),
          ),
        ),
      ));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await t.drag(wheels().first, const Offset(0, -45));
      await t.pumpAndSettle();
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      expect(result, const Duration(hours: 2, minutes: 30));
    });

    testWidgets('cancel returns null', (t) async {
      Duration? result = const Duration(seconds: 1);
      await t.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async =>
                result = await showAwesomeDurationPicker(context),
            child: const Text('open'),
          ),
        ),
      ));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await t.tap(find.text('Cancel'));
      await t.pumpAndSettle();
      expect(result, isNull);
    });

    testWidgets('it starts at zero, or at the minimum', (t) async {
      Duration? result;
      await t.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async => result = await showAwesomeDurationPicker(
                context,
                minDuration: const Duration(minutes: 10)),
            child: const Text('open'),
          ),
        ),
      ));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      expect(result, const Duration(minutes: 10));
    });
  });

  group('asserts', () {
    test('invalid configurations fail fast in debug mode', () {
      expect(
          () => AwesomeDurationPicker(minDuration: const Duration(seconds: -1)),
          throwsAssertionError);
      expect(
          () => AwesomeDurationPicker(
              minDuration: const Duration(hours: 2),
              maxDuration: const Duration(hours: 1)),
          throwsAssertionError);
      expect(
          () => AwesomeDurationPicker(minuteInterval: 7), throwsAssertionError);
      expect(
          () => AwesomeDurationPicker(secondInterval: 0), throwsAssertionError);
      expect(
          () => AwesomeDurationPicker(
                controller: AwesomeDurationPickerController(),
                initialDuration: h1m30,
              ),
          throwsAssertionError);
    });
  });
}
