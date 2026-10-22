import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget w) => MaterialApp(home: Scaffold(body: Center(child: w)));

ListWheelScrollView firstWheel(WidgetTester t) =>
    t.widget<ListWheelScrollView>(find.byType(ListWheelScrollView).first);

void main() {
  group('presets', () {
    testWidgets('ios() uses the values of the Cupertino picker', (t) async {
      await t.pumpWidget(
          wrap(AwesomeTimePicker(wheelStyle: const AwesomeWheelStyle.ios())));
      final wheel = firstWheel(t);
      expect(wheel.diameterRatio, 1.07);
      expect(wheel.perspective, 0.003);
      expect(wheel.squeeze, 1.45);
      expect(wheel.useMagnifier, isFalse);
    });

    test('ios() has a rounded selector', () {
      expect(const AwesomeWheelStyle.ios().selectorBorderRadius,
          BorderRadius.circular(8));
    });

    testWidgets('material() is flat with a pill selector', (t) async {
      await t.pumpWidget(wrap(
          AwesomeTimePicker(wheelStyle: const AwesomeWheelStyle.material())));
      final wheel = firstWheel(t);
      expect(wheel.diameterRatio,
          greaterThan(const AwesomeWheelStyle().diameterRatio ?? 1.5));
      expect(const AwesomeWheelStyle.material().selectorBorderRadius,
          BorderRadius.circular(16));
    });

    testWidgets('minimal() draws lines instead of a filled selector',
        (t) async {
      const style = AwesomeWheelStyle.minimal();
      expect(style.selectorDecoration, isA<BoxDecoration>());
      final decoration = style.selectorDecoration! as BoxDecoration;
      expect(decoration.color, isNull);
      expect(decoration.border, isNotNull);

      await t.pumpWidget(wrap(AwesomeTimePicker(wheelStyle: style)));
      expect(t.takeException(), isNull);
    });

    test('the presets are valid styles (they pass the asserts)', () {
      for (final style in const [
        AwesomeWheelStyle.ios(),
        AwesomeWheelStyle.material(),
        AwesomeWheelStyle.minimal(),
      ]) {
        expect(style.diameterRatio, greaterThan(0));
        expect(style.perspective, inInclusiveRange(0.0001, 0.01));
      }
    });

    test('the presets differ from each other and from the default', () {
      final all = {
        const AwesomeWheelStyle(),
        const AwesomeWheelStyle.ios(),
        const AwesomeWheelStyle.material(),
        const AwesomeWheelStyle.minimal(),
      };
      expect(all.length, 4);
    });

    testWidgets('a preset works in every picker', (t) async {
      for (final picker in <Widget>[
        AwesomeDatePicker(wheelStyle: const AwesomeWheelStyle.ios()),
        const AwesomeDateTimePicker(wheelStyle: AwesomeWheelStyle.ios()),
        AwesomeDateRangePicker(wheelStyle: const AwesomeWheelStyle.ios()),
      ]) {
        await t.pumpWidget(wrap(SingleChildScrollView(child: picker)));
        for (final wheel in t.widgetList<ListWheelScrollView>(
            find.byType(ListWheelScrollView))) {
          expect(wheel.diameterRatio, 1.07);
        }
      }
    });
  });

  group('copyWith', () {
    test('changes only the given properties', () {
      final style = const AwesomeWheelStyle.ios().copyWith(magnification: 1.2);
      expect(style.magnification, 1.2);
      expect(style.diameterRatio, 1.07);
      expect(style.squeeze, 1.45);
      expect(style.selectorBorderRadius, BorderRadius.circular(8));
    });

    test('overrides a preset value', () {
      final style = const AwesomeWheelStyle.ios()
          .copyWith(selectorBorderRadius: BorderRadius.zero);
      expect(style.selectorBorderRadius, BorderRadius.zero);
    });

    test('without arguments it is an equal copy', () {
      expect(const AwesomeWheelStyle.minimal().copyWith(),
          const AwesomeWheelStyle.minimal());
    });

    test('keeps the validation of the values', () {
      expect(() => const AwesomeWheelStyle().copyWith(diameterRatio: -1),
          throwsAssertionError);
    });

    testWidgets('a customized preset reaches the wheels', (t) async {
      await t.pumpWidget(wrap(AwesomeTimePicker(
        wheelStyle: const AwesomeWheelStyle.ios().copyWith(magnification: 1.3),
      )));
      final wheel = firstWheel(t);
      expect(wheel.diameterRatio, 1.07);
      expect(wheel.useMagnifier, isTrue);
      expect(wheel.magnification, 1.3);
    });
  });
}
