import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

AwesomeDate d(int y, int m, int day) =>
    AwesomeDate(year: y, month: m, day: day);

Widget app(Widget picker, {AwesomePickerThemeData? theme, ThemeData? base}) {
  final data = (base ?? ThemeData()).copyWith(
    extensions: theme == null ? null : [theme],
  );
  return MaterialApp(
    theme: data,
    home: Scaffold(body: SingleChildScrollView(child: Center(child: picker))),
  );
}

ListWheelScrollView firstWheel(WidgetTester t) =>
    t.widget<ListWheelScrollView>(find.byType(ListWheelScrollView).first);

Size wheelSize(WidgetTester t) =>
    t.getSize(find.byType(ListWheelScrollView).first);

/// The wheel background: the Container that has a [color] decoration of the
/// size of the wheel.
bool hasBackground(WidgetTester t, Color color) =>
    t.widgetList<Container>(find.byType(Container)).any((c) =>
        (c.decoration is BoxDecoration) &&
        (c.decoration as BoxDecoration).color == color &&
        (c.decoration as BoxDecoration).borderRadius != null);

TextStyle? styleOf(WidgetTester t, String text) =>
    t.widget<Text>(find.text(text).first).style;

void main() {
  group('without a theme', () {
    testWidgets('nothing changes', (t) async {
      await t.pumpWidget(app(AwesomeDatePicker(initialDate: d(2025, 6, 15))));
      // the test screen is 800 wide: 15% of it, at most 90
      expect(wheelSize(t), const Size(90, 200));
      expect(firstWheel(t).diameterRatio, 1.5);
      expect(
          AwesomePickerThemeData.maybeOf(
              t.element(find.byType(AwesomeDatePicker))),
          isNull);
    });

    testWidgets('of() gives an empty theme', (t) async {
      await t.pumpWidget(app(AwesomeDatePicker()));
      final theme =
          AwesomePickerThemeData.of(t.element(find.byType(AwesomeDatePicker)));
      expect(theme, const AwesomePickerThemeData());
    });
  });

  group('what the theme sets', () {
    testWidgets('colors', (t) async {
      await t.pumpWidget(app(
        AwesomeDatePicker(initialDate: d(2025, 6, 15)),
        theme: const AwesomePickerThemeData(
          backgroundColor: Color(0xFF112233),
          selectorColor: Color(0xFF445566),
        ),
      ));
      final containers = t.widgetList<Container>(find.byType(Container));
      bool hasColor(Color c) => containers.any((x) =>
          x.decoration is BoxDecoration &&
          (x.decoration as BoxDecoration).color == c);
      expect(hasColor(const Color(0xFF112233)), isTrue, reason: 'background');
      expect(hasColor(const Color(0xFF445566)), isTrue, reason: 'selector');
    });

    testWidgets('text styles of the selected and the other items', (t) async {
      await t.pumpWidget(app(
        AwesomeDatePicker(initialDate: d(2025, 6, 15)),
        theme: const AwesomePickerThemeData(
          selectedTextStyle: TextStyle(fontSize: 31, color: Colors.red),
          unselectedTextStyle: TextStyle(fontSize: 11, color: Colors.green),
        ),
      ));
      expect(styleOf(t, '15')?.fontSize, 31);
      expect(styleOf(t, '15')?.color, Colors.red);
      expect(styleOf(t, '16')?.fontSize, 11);
      expect(styleOf(t, '16')?.color, Colors.green);
    });

    testWidgets('the text style of dimmed values', (t) async {
      await t.pumpWidget(app(
        AwesomeDatePicker(
          initialDate: d(2025, 6, 13),
          excludedWeekdays: const [DateTime.saturday, DateTime.sunday],
          showDisabledValues: true,
        ),
        theme: const AwesomePickerThemeData(
          disabledTextStyle: TextStyle(color: Colors.purple),
        ),
      ));
      expect(styleOf(t, '14')?.color, Colors.purple);
    });

    testWidgets('sizes', (t) async {
      await t.pumpWidget(app(
        AwesomeDatePicker(initialDate: d(2025, 6, 15)),
        theme: const AwesomePickerThemeData(
            itemHeight: 30, itemWidth: 77, visibleItemCount: 7),
      ));
      expect(wheelSize(t), const Size(77, 210));
    });

    testWidgets('the fade effect', (t) async {
      bool hasFade() => find
          .byWidgetPredicate((w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).gradient != null)
          .evaluate()
          .isNotEmpty;

      await t.pumpWidget(app(AwesomeDatePicker()));
      expect(hasFade(), isTrue);
      await t.pumpWidget(app(AwesomeDatePicker(),
          theme: const AwesomePickerThemeData(fadeEffect: false)));
      await t.pumpAndSettle(); // Flutter animates a theme change
      expect(hasFade(), isFalse);
    });

    testWidgets('the wheel style', (t) async {
      await t.pumpWidget(app(
        AwesomeDatePicker(),
        theme: AwesomePickerThemeData(
          wheelStyle: AwesomeWheelStyle(
            diameterRatio: 3,
            magnification: 1.2,
            selectorBorderRadius: BorderRadius.circular(9),
          ),
        ),
      ));
      expect(firstWheel(t).diameterRatio, 3);
      expect(firstWheel(t).magnification, 1.2);
    });

    testWidgets('a preset as the wheel style', (t) async {
      await t.pumpWidget(app(
        AwesomeDatePicker(),
        theme:
            const AwesomePickerThemeData(wheelStyle: AwesomeWheelStyle.ios()),
      ));
      expect(firstWheel(t).diameterRatio, 1.07);
    });
  });

  group('precedence', () {
    testWidgets('an option of the picker wins over the theme', (t) async {
      await t.pumpWidget(app(
        AwesomeDatePicker(
          initialDate: d(2025, 6, 15),
          itemHeight: 50,
          selectedTextStyle: const TextStyle(fontSize: 40),
          backgroundColor: const Color(0xFFAA0000),
        ),
        theme: const AwesomePickerThemeData(
          itemHeight: 30,
          selectedTextStyle: TextStyle(fontSize: 20),
          backgroundColor: Color(0xFF0000AA),
        ),
      ));
      expect(wheelSize(t).height, 250);
      expect(styleOf(t, '15')?.fontSize, 40);
      expect(
          hasBackground(t, const Color(0xFFAA0000)) ||
              t.widgetList<Container>(find.byType(Container)).any((c) =>
                  c.decoration is BoxDecoration &&
                  (c.decoration as BoxDecoration).color ==
                      const Color(0xFFAA0000)),
          isTrue);
      expect(
          t.widgetList<Container>(find.byType(Container)).any((c) =>
              c.decoration is BoxDecoration &&
              (c.decoration as BoxDecoration).color == const Color(0xFF0000AA)),
          isFalse);
    });

    testWidgets('the theme of a wheel wins over both', (t) async {
      await t.pumpWidget(app(
        AwesomeDatePicker(
          initialDate: d(2025, 6, 15),
          itemWidth: 90,
          theme: const AwesomeDatePickerTheme(dayTheme: ItemTheme(width: 120)),
        ),
        theme: const AwesomePickerThemeData(itemWidth: 70),
      ));
      expect(wheelSize(t).width, 120); // the day wheel
      expect(t.getSize(find.byType(ListWheelScrollView).at(1)).width, 90);
    });

    testWidgets('the wheel style is merged property by property', (t) async {
      await t.pumpWidget(app(
        AwesomeDatePicker(
          wheelStyle: const AwesomeWheelStyle(diameterRatio: 2),
        ),
        theme: const AwesomePickerThemeData(
          wheelStyle: AwesomeWheelStyle(diameterRatio: 3, magnification: 1.2),
        ),
      ));
      expect(firstWheel(t).diameterRatio, 2, reason: 'the picker wins');
      expect(firstWheel(t).magnification, 1.2, reason: 'the theme fills in');
    });

    testWidgets('a theme value applies where the picker sets nothing',
        (t) async {
      await t.pumpWidget(app(
        AwesomeDatePicker(itemHeight: 50),
        theme: const AwesomePickerThemeData(itemHeight: 30, itemWidth: 77),
      ));
      expect(wheelSize(t), const Size(77, 250));
    });
  });

  group('where it applies', () {
    const theme = AwesomePickerThemeData(
        itemWidth: 77, wheelStyle: AwesomeWheelStyle(diameterRatio: 3));

    testWidgets('every picker', (t) async {
      for (final picker in <Widget>[
        AwesomeDatePicker(),
        AwesomeTimePicker(),
        const AwesomeDateTimePicker(),
        AwesomeDateRangePicker(),
      ]) {
        await t.pumpWidget(app(picker, theme: theme));
        for (final wheel in t.widgetList<ListWheelScrollView>(
            find.byType(ListWheelScrollView))) {
          expect(wheel.diameterRatio, 3, reason: '${picker.runtimeType}');
        }
        expect(wheelSize(t).width, 77, reason: '${picker.runtimeType}');
      }
    });

    testWidgets('the pickers in a modal', (t) async {
      await t.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: const [theme]),
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAwesomeDatePicker(context),
            child: const Text('open'),
          ),
        ),
      ));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(firstWheel(t).diameterRatio, 3);
    });

    testWidgets('a nested Theme changes the look of a part of the app',
        (t) async {
      await t.pumpWidget(app(
        Column(children: [
          AwesomeDatePicker(),
          Theme(
            data: ThemeData(extensions: const [
              AwesomePickerThemeData(
                  wheelStyle: AwesomeWheelStyle(diameterRatio: 5)),
            ]),
            child: AwesomeDatePicker(),
          ),
        ]),
        theme: theme,
      ));
      final wheels = t
          .widgetList<ListWheelScrollView>(find.byType(ListWheelScrollView))
          .toList();
      expect(wheels.first.diameterRatio, 3);
      expect(wheels[3].diameterRatio, 5);
    });

    testWidgets('dark mode can have its own look', (t) async {
      Widget build(ThemeMode mode) => MaterialApp(
            themeMode: mode,
            theme: ThemeData(extensions: const [
              AwesomePickerThemeData(
                  wheelStyle: AwesomeWheelStyle(diameterRatio: 2)),
            ]),
            darkTheme:
                ThemeData(brightness: Brightness.dark, extensions: const [
              AwesomePickerThemeData(
                  wheelStyle: AwesomeWheelStyle(diameterRatio: 4)),
            ]),
            home: Scaffold(body: AwesomeDatePicker()),
          );
      await t.pumpWidget(build(ThemeMode.light));
      expect(firstWheel(t).diameterRatio, 2);
      await t.pumpWidget(build(ThemeMode.dark));
      await t.pumpAndSettle();
      expect(firstWheel(t).diameterRatio, 4);
    });
  });

  group('behavior that uses the theme', () {
    testWidgets('Page Down moves a page of the themed wheel', (t) async {
      final events = <AwesomeDate>[];
      await t.pumpWidget(app(
        AwesomeDatePicker(
          initialDate: d(2025, 6, 10),
          onChanged: events.add,
        ),
        theme: const AwesomePickerThemeData(visibleItemCount: 7),
      ));
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await t.pumpAndSettle();
      expect(events.last, d(2025, 6, 16)); // 7 visible: a page is 6
    });

    testWidgets('a height of the theme is not scaled with the text', (t) async {
      await t.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: const [
          AwesomePickerThemeData(itemHeight: 30),
        ]),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(body: Center(child: AwesomeDatePicker())),
      ));
      expect(wheelSize(t).height, 150);
    });
  });

  group('the theme animates', () {
    testWidgets('changing it blends the values', (t) async {
      Widget build(double ratio) => MaterialApp(
            theme: ThemeData(extensions: [
              AwesomePickerThemeData(
                  wheelStyle: AwesomeWheelStyle(diameterRatio: ratio),
                  itemHeight: 20 + ratio * 10),
            ]),
            home: Scaffold(body: Center(child: AwesomeDatePicker())),
          );
      await t.pumpWidget(build(2));
      await t.pumpWidget(build(4));
      await t.pump(const Duration(milliseconds: 100));
      final mid = firstWheel(t).diameterRatio;
      expect(mid, inExclusiveRange(2, 4));
      await t.pumpAndSettle();
      expect(firstWheel(t).diameterRatio, 4);
      expect(t.takeException(), isNull);
    });
  });

  group('AwesomePickerThemeData', () {
    test('lerp blends colors, sizes and text styles', () {
      const a = AwesomePickerThemeData(
        backgroundColor: Color(0xFF000000),
        itemHeight: 40,
        selectedTextStyle: TextStyle(fontSize: 10),
        visibleItemCount: 5,
        fadeEffect: true,
      );
      const b = AwesomePickerThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        itemHeight: 60,
        selectedTextStyle: TextStyle(fontSize: 30),
        visibleItemCount: 7,
        fadeEffect: false,
      );
      final mid = a.lerp(b, 0.5);
      expect(mid.backgroundColor,
          Color.lerp(a.backgroundColor, b.backgroundColor, 0.5));
      expect(mid.itemHeight, 50);
      expect(mid.selectedTextStyle?.fontSize, 20);
      // a count and a flag cannot be blended: they switch halfway
      expect(a.lerp(b, 0.4).visibleItemCount, 5);
      expect(a.lerp(b, 0.6).visibleItemCount, 7);
      expect(a.lerp(b, 0.4).fadeEffect, isTrue);
      expect(a.lerp(b, 0.6).fadeEffect, isFalse);
    });

    test('lerp with something else leaves the theme as it is', () {
      const a = AwesomePickerThemeData(itemHeight: 40);
      expect(a.lerp(null, 0.5), a);
    });

    test('lerp of the wheel style', () {
      final mid = AwesomeWheelStyle.lerp(
        const AwesomeWheelStyle(diameterRatio: 2, squeeze: 1),
        const AwesomeWheelStyle(diameterRatio: 4),
        0.4,
      )!;
      expect(mid.diameterRatio, closeTo(2.8, 0.0001));
      expect(mid.squeeze, 1, reason: 'set in one only: switches halfway');
      expect(AwesomeWheelStyle.lerp(null, null, 0.5), isNull);
    });

    test('copyWith', () {
      const a = AwesomePickerThemeData(itemHeight: 40, itemWidth: 60);
      final b = a.copyWith(itemHeight: 50);
      expect(b.itemHeight, 50);
      expect(b.itemWidth, 60);
    });

    test('equality', () {
      expect(const AwesomePickerThemeData(itemHeight: 40),
          const AwesomePickerThemeData(itemHeight: 40));
      expect(const AwesomePickerThemeData(itemHeight: 40).hashCode,
          const AwesomePickerThemeData(itemHeight: 40).hashCode);
      expect(const AwesomePickerThemeData(itemHeight: 40),
          isNot(const AwesomePickerThemeData(itemHeight: 41)));
    });

    test('mergedOver of the wheel style', () {
      final merged = const AwesomeWheelStyle(diameterRatio: 2)
          .mergedOver(const AwesomeWheelStyle(diameterRatio: 3, squeeze: 1.4));
      expect(merged.diameterRatio, 2);
      expect(merged.squeeze, 1.4);
    });

    test('invalid values fail fast in debug mode', () {
      expect(() => AwesomePickerThemeData(itemHeight: 0), throwsAssertionError);
      expect(() => AwesomePickerThemeData(itemWidth: -1), throwsAssertionError);
      expect(() => AwesomePickerThemeData(visibleItemCount: 4),
          throwsAssertionError);
      expect(() => AwesomePickerThemeData(visibleItemCount: 1),
          throwsAssertionError);
    });
  });
}
