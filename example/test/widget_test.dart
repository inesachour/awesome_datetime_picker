import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The demo has a screen listening to a controller and switches that change
/// the options of the pickers while they are on screen: flipping each of them
/// must neither throw nor overflow.
void main() {
  testWidgets('every switch can be flipped, twice, without errors',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 3200 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    const switches = [
      'Global picker theme (ThemeExtension)',
      'Dark mode',
      'Exclude weekends (changes props at runtime)',
      'Looping wheels',
      'Haptic feedback',
      '15-minute interval',
      'Show excluded values dimmed',
      'Weekday labels',
      'Seconds',
    ];
    for (var round = 0; round < 2; round++) {
      for (final label in switches) {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: 'after flipping "$label"');
      }
    }
  });

  testWidgets('the language can be changed', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 3200 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Français').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    // some month name around the selected one is now French
    const french = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août',
      'septembre', 'octobre', 'novembre', 'décembre', //
    ];
    expect(
      find.byWidgetPredicate((w) => w is Text && french.contains(w.data)),
      findsWidgets,
    );
  });
}
