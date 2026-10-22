import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/shared/custom_item_picker_style.dart';
import 'package:awesome_datetime_picker/src/shared/custom_item_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AwesomeDate d(int y, int m, int day) =>
    AwesomeDate(year: y, month: m, day: day);

/// Like a typical app: the screen listens to the controller and calls
/// setState, and has switches that change the options of the picker.
class _Demo extends StatefulWidget {
  const _Demo({required this.controller, required this.options});

  final AwesomeDatePickerController controller;
  final ValueNotifier<_Options> options;

  @override
  State<_Demo> createState() => _DemoState();
}

class _Options {
  const _Options({this.showDisabled = false, this.weekdays = false});

  final bool showDisabled;
  final bool weekdays;
}

class _DemoState extends State<_Demo> {
  AwesomeDate? shown;
  int builds = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {
          shown = widget.controller.value;
        }));
    widget.options.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    builds++;
    final options = widget.options.value;
    return Scaffold(
      body: Column(children: [
        Text('shown: $shown'),
        AwesomeDatePicker(
          controller: widget.controller,
          minDate: d(2025, 1, 1),
          maxDate: d(2025, 12, 31),
          excludedWeekdays: options.weekdays
              ? const [DateTime.saturday, DateTime.sunday]
              : null,
          showDisabledValues: options.showDisabled,
        ),
      ]),
    );
  }
}

void main() {
  wheelTests();

  testWidgets(
      'changing an option that lengthens a wheel keeps the selection and '
      'never reports during the build', (t) async {
    final controller =
        AwesomeDatePickerController(initialValue: d(2025, 6, 30));
    final options = ValueNotifier(const _Options(weekdays: true));
    addTearDown(controller.dispose);
    addTearDown(options.dispose);

    await t.pumpWidget(
        MaterialApp(home: _Demo(controller: controller, options: options)));
    await t.pumpAndSettle();
    expect(controller.value, d(2025, 6, 30));

    // 21 weekdays become 30 days: the selected day moves from the 21st item
    // of the wheel to the 30th.
    options.value = const _Options(weekdays: true, showDisabled: true);
    await t.pumpAndSettle();

    expect(t.takeException(), isNull);
    expect(controller.value, d(2025, 6, 30));
  });

  testWidgets('and back again', (t) async {
    final controller =
        AwesomeDatePickerController(initialValue: d(2025, 6, 30));
    final options =
        ValueNotifier(const _Options(weekdays: true, showDisabled: true));
    addTearDown(controller.dispose);
    addTearDown(options.dispose);

    await t.pumpWidget(
        MaterialApp(home: _Demo(controller: controller, options: options)));
    await t.pumpAndSettle();

    options.value = const _Options(weekdays: true);
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(controller.value, d(2025, 6, 30));
  });

  testWidgets('removing the exclusions lengthens the day wheel', (t) async {
    final controller =
        AwesomeDatePickerController(initialValue: d(2025, 6, 30));
    final options = ValueNotifier(const _Options(weekdays: true));
    addTearDown(controller.dispose);
    addTearDown(options.dispose);

    await t.pumpWidget(
        MaterialApp(home: _Demo(controller: controller, options: options)));
    await t.pumpAndSettle();

    options.value = const _Options();
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(controller.value, d(2025, 6, 30));
  });

  testWidgets('a rebuild never calls onChanged', (t) async {
    final events = <AwesomeDate>[];
    final options = ValueNotifier(const _Options(weekdays: true));
    addTearDown(options.dispose);
    await t.pumpWidget(MaterialApp(
      home: ValueListenableBuilder<_Options>(
        valueListenable: options,
        builder: (context, value, _) => Scaffold(
          body: AwesomeDatePicker(
            initialDate: d(2025, 6, 30),
            minDate: d(2025, 1, 1),
            maxDate: d(2025, 12, 31),
            excludedWeekdays: value.weekdays
                ? const [DateTime.saturday, DateTime.sunday]
                : null,
            showDisabledValues: value.showDisabled,
            onChanged: events.add,
          ),
        ),
      ),
    ));
    options.value = const _Options(weekdays: true, showDisabled: true);
    await t.pumpAndSettle();
    options.value = const _Options();
    await t.pumpAndSettle();
    expect(events, isEmpty);
    expect(t.takeException(), isNull);
  });

  testWidgets('the same for a time picker whose hours get dimmed', (t) async {
    final events = <AwesomeTime>[];
    final options = ValueNotifier(false);
    addTearDown(options.dispose);
    await t.pumpWidget(MaterialApp(
      home: ValueListenableBuilder<bool>(
        valueListenable: options,
        builder: (context, dimmed, _) => Scaffold(
          body: AwesomeTimePicker(
            initialTime: const AwesomeTime(hour: 23, minute: 0),
            excludedHours: const [3, 4, 5, 6, 7, 8],
            showDisabledValues: dimmed,
            onChanged: events.add,
          ),
        ),
      ),
    ));
    options.value = true;
    await t.pumpAndSettle();
    expect(events, isEmpty);
    expect(t.takeException(), isNull);
  });
}

// ---- the wheel itself ----

List<String> numbers(int count) => [for (var i = 0; i < count; i++) '$i'];

Widget wheel(
  List<String> items,
  int initialIndex,
  List<String> reports,
) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: CustomItemPicker(
          items: items,
          initialIndex: initialIndex,
          visibleItemCount: 5,
          style: const CustomItemPickerStyle(),
          onSelectedItemChanged: reports.add,
        ),
      ),
    ),
  );
}

int selectedItem(WidgetTester t) =>
    (t.widget<ListWheelScrollView>(find.byType(ListWheelScrollView)).controller!
            as FixedExtentScrollController)
        .selectedItem;

void wheelTests() {
  group('the wheel when its items change', () {
    testWidgets('a longer list moves to the new index without reporting',
        (t) async {
      final reports = <String>[];
      await t.pumpWidget(wheel(numbers(5), 3, reports));
      // the list grows by two items and the selected one moves from 3 to 5
      await t.pumpWidget(wheel(numbers(7), 5, reports));
      await t.pumpAndSettle();

      expect(reports, isEmpty, reason: 'a rebuild is not a user selection');
      expect(selectedItem(t), 5);
      expect(t.takeException(), isNull);
    });

    testWidgets('a much longer list', (t) async {
      final reports = <String>[];
      await t.pumpWidget(wheel(numbers(21), 20, reports));
      await t.pumpWidget(wheel(numbers(30), 29, reports));
      await t.pumpAndSettle();
      expect(reports, isEmpty);
      expect(selectedItem(t), 29);
    });

    testWidgets('a shorter list', (t) async {
      final reports = <String>[];
      await t.pumpWidget(wheel(numbers(30), 29, reports));
      await t.pumpWidget(wheel(numbers(21), 20, reports));
      await t.pumpAndSettle();
      expect(reports, isEmpty);
      expect(selectedItem(t), 20);
    });

    testWidgets('the highlighted item is the new one', (t) async {
      final reports = <String>[];
      await t.pumpWidget(wheel(numbers(5), 3, reports));
      await t.pumpWidget(wheel(numbers(7), 5, reports));
      await t.pumpAndSettle();
      final selectedStyle = t.widget<Text>(find.text('5')).style;
      final other = t.widget<Text>(find.text('4')).style;
      expect(selectedStyle?.fontWeight, isNot(other?.fontWeight));
    });

    testWidgets('the user can still scroll afterwards, and is reported',
        (t) async {
      final reports = <String>[];
      await t.pumpWidget(wheel(numbers(5), 3, reports));
      await t.pumpWidget(wheel(numbers(7), 5, reports));
      await t.pumpAndSettle();
      await t.drag(find.byType(ListWheelScrollView), const Offset(0, -45));
      await t.pumpAndSettle();
      expect(reports, ['6']);
    });

    testWidgets('several rebuilds in a row end on the last index', (t) async {
      final reports = <String>[];
      await t.pumpWidget(wheel(numbers(5), 3, reports));
      await t.pumpWidget(wheel(numbers(7), 5, reports));
      await t.pumpWidget(wheel(numbers(9), 8, reports));
      await t.pumpAndSettle();
      expect(reports, isEmpty);
      expect(selectedItem(t), 8);
    });
  });
}
