import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget picker, {TextScaler scaler = TextScaler.noScaling}) {
  return MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: scaler),
      child: child!,
    ),
    home: Scaffold(body: Center(child: picker)),
  );
}

Size wheelSize(WidgetTester t) =>
    t.getSize(find.byType(ListWheelScrollView).first);

void main() {
  testWidgets('the normal text size keeps the default 40 px items', (t) async {
    await t.pumpWidget(app(AwesomeDatePicker()));
    expect(t.getSize(find.byType(AwesomeDatePicker)).height, 200);
  });

  testWidgets('larger text makes the wheels taller but not wider', (t) async {
    await t.pumpWidget(app(AwesomeDatePicker()));
    final normal = wheelSize(t);

    await t.pumpWidget(
        app(AwesomeDatePicker(), scaler: const TextScaler.linear(1.5)));
    final large = wheelSize(t);
    expect(large.height, closeTo(normal.height * 1.5, 0.01));
    // several wheels have to keep fitting the screen
    expect(large.width, normal.width);
  });

  testWidgets('the growth stops at 2x', (t) async {
    await t.pumpWidget(
        app(AwesomeDatePicker(), scaler: const TextScaler.linear(3)));
    expect(t.getSize(find.byType(AwesomeDatePicker)).height, 400);
  });

  testWidgets('a text size below normal does not shrink the wheels', (t) async {
    await t.pumpWidget(
        app(AwesomeDatePicker(), scaler: const TextScaler.linear(0.8)));
    expect(t.getSize(find.byType(AwesomeDatePicker)).height, 200);
  });

  testWidgets('non-linear text scaling is followed', (t) async {
    // a scaler like Android 14's: growth is not proportional to the size
    await t
        .pumpWidget(app(AwesomeDatePicker(), scaler: const _HalfwayScaler()));
    final scaled = wheelSize(t);
    // 20px text -> 1.3x = 26px: 1.3x taller wheels
    expect(scaled.height, closeTo(40 * 1.3 * 5, 0.5));
  });

  testWidgets('an explicit itemHeight and itemWidth are used as they are',
      (t) async {
    await t.pumpWidget(app(
      AwesomeDatePicker(itemHeight: 30, itemWidth: 70),
      scaler: const TextScaler.linear(2),
    ));
    expect(wheelSize(t), const Size(70, 150));
  });

  testWidgets('an ItemTheme size is used as it is', (t) async {
    await t.pumpWidget(app(
      AwesomeDatePicker(
        theme: const AwesomeDatePickerTheme(
            dayTheme: ItemTheme(height: 50, width: 80)),
      ),
      scaler: const TextScaler.linear(2),
    ));
    expect(wheelSize(t), const Size(80, 250));
  });

  testWidgets('a five-wheel picker still fits a phone at large text sizes',
      (t) async {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    for (final scale in [1.0, 1.5, 2.0, 3.0]) {
      await t.pumpWidget(
          app(const AwesomeDateTimePicker(), scaler: TextScaler.linear(scale)));
      expect(t.takeException(), isNull, reason: 'text scale $scale');
      // the wheels are drawn inside the screen (a picker too wide for it is
      // shrunk, which raises no error, so the position is what to check)
      final wheels = find.byType(ListWheelScrollView);
      expect(t.getTopLeft(wheels.first).dx, greaterThanOrEqualTo(-0.5),
          reason: 'text scale $scale');
      expect(t.getBottomRight(wheels.last).dx, lessThanOrEqualTo(390.5),
          reason: 'text scale $scale');
    }
  });

  testWidgets('text that does not fit its wheel shrinks instead of being cut',
      (t) async {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(app(
      AwesomeDatePicker(
        initialDate: const AwesomeDate(year: 2025, month: 6, day: 15),
      ),
      scaler: const TextScaler.linear(2),
    ));
    final wheelWidth = wheelSize(t).width;
    final year = find.text('2025');
    expect(year, findsOneWidget);
    // The text is laid out at its full size (40 px font) but drawn scaled
    // down: its FittedBox is not wider than the wheel.
    expect(t.getSize(year).width, greaterThan(wheelWidth));
    final box = find.ancestor(of: year, matching: find.byType(FittedBox));
    expect(t.getSize(box.first).width, lessThanOrEqualTo(wheelWidth));
    expect(find.textContaining('…'), findsNothing);
  });

  testWidgets('every picker follows the text size', (t) async {
    const scaler = TextScaler.linear(2);
    await t.pumpWidget(app(AwesomeTimePicker(), scaler: scaler));
    expect(t.getSize(find.byType(AwesomeTimePicker)).height, 400);
    await t.pumpWidget(app(const AwesomeDateTimePicker(), scaler: scaler));
    expect(t.getSize(find.byType(AwesomeDateTimePicker)).height, 400);
  });
}

/// Grows 20 px text by 30% (and other sizes by half as much as linear).
class _HalfwayScaler extends TextScaler {
  const _HalfwayScaler();

  @override
  double scale(double fontSize) => fontSize * 1.3;

  @override
  double get textScaleFactor => 1.3;

  @override
  TextScaler clamp(
          {double minScaleFactor = 0,
          double maxScaleFactor = double.infinity}) =>
      this;

  @override
  bool operator ==(Object other) => other is _HalfwayScaler;

  @override
  int get hashCode => 13;
}
