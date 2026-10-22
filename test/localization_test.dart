import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/core/utils/awesome_intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget w) => MaterialApp(home: Scaffold(body: Center(child: w)));

AwesomeDate d(int y, int m, int day) =>
    AwesomeDate(year: y, month: m, day: day);

void main() {
  group('AwesomeIntl', () {
    test('resolves a locale to the closest one intl knows', () {
      expect(AwesomeIntl.resolve('fr'), 'fr');
      expect(AwesomeIntl.resolve('pt-BR'), 'pt_BR');
      expect(AwesomeIntl.resolve('fr_CH'), 'fr_CH');
      expect(AwesomeIntl.resolve('xx'), 'en');
      expect(AwesomeIntl.resolve('zz_ZZ'), 'en');
    });

    test('month names start in January and are standalone', () {
      final fr = AwesomeIntl.monthNames('fr');
      expect(fr.length, 12);
      expect(fr.first, 'janvier');
      expect(fr.last, 'décembre');
      expect(AwesomeIntl.monthNames('ja').first, '1月');
      // Russian standalone, not the genitive used inside a date
      expect(AwesomeIntl.monthNames('ru').first, 'январь');
    });

    test('weekday names start on Monday', () {
      expect(AwesomeIntl.weekdayNames('en').first, 'Mon');
      expect(AwesomeIntl.weekdayNames('en').last, 'Sun');
      // the exact abbreviation (with or without a dot) depends on the intl
      // version, the language does not
      expect(AwesomeIntl.weekdayNames('de').first, startsWith('Mo'));
      expect(AwesomeIntl.weekdayNames('de').last, startsWith('So'));
    });

    test('AM/PM markers', () {
      expect(AwesomeIntl.amPmLabels('en'), ['AM', 'PM']);
      expect(AwesomeIntl.amPmLabels('ja'), ['午前', '午後']);
    });

    test('digit glyphs are null for ASCII digits', () {
      expect(AwesomeIntl.digitGlyphs('en'), isNull);
      expect(AwesomeIntl.digitGlyphs('fr'), isNull);
    });

    test('digits of other numbering systems', () {
      final fa = AwesomeIntl.digitGlyphs('fa')!;
      expect(fa.length, 10);
      expect(AwesomeIntl.localizeDigits('2025 09:05', fa), '۲۰۲۵ ۰۹:۰۵');
      final arEg = AwesomeIntl.digitGlyphs('ar_EG')!;
      expect(AwesomeIntl.localizeDigits('15', arEg), '١٥');
    });

    test('localizeDigits leaves other characters alone', () {
      final fa = AwesomeIntl.digitGlyphs('fa')!;
      expect(AwesomeIntl.localizeDigits('Mon 12', fa), 'Mon ۱۲');
    });
  });

  group('date picker', () {
    testWidgets('localeName localizes the month names', (t) async {
      await t.pumpWidget(wrap(AwesomeDatePicker(
        dateFormat: AwesomeDateFormat.dMMy,
        localeName: 'fr',
        initialDate: d(2025, 2, 15),
      )));
      expect(find.text('février'), findsOneWidget);
      expect(find.text('janvier'), findsWidgets);
    });

    testWidgets('localeName takes priority over locale', (t) async {
      await t.pumpWidget(wrap(AwesomeDatePicker(
        dateFormat: AwesomeDateFormat.dMMy,
        locale: LocaleType.de,
        localeName: 'es',
        initialDate: d(2025, 2, 15),
      )));
      expect(find.text('febrero'), findsOneWidget);
      expect(find.text('Februar'), findsNothing);
    });

    testWidgets('without localeName the built-in languages are unchanged',
        (t) async {
      await t.pumpWidget(wrap(AwesomeDatePicker(
        dateFormat: AwesomeDateFormat.dMMy,
        locale: LocaleType.fr,
        initialDate: d(2025, 2, 15),
      )));
      expect(find.text('Février'), findsOneWidget); // capitalised, as before
    });

    testWidgets('scrolling the month wheel reports the right month', (t) async {
      final events = <AwesomeDate>[];
      await t.pumpWidget(wrap(AwesomeDatePicker(
        dateFormat: AwesomeDateFormat.dMMy,
        localeName: 'ja',
        initialDate: d(2025, 2, 15),
        onChanged: events.add,
      )));
      // wheels: day, month, year
      await t.drag(
          find.byType(ListWheelScrollView).at(1), const Offset(0, -45));
      await t.pumpAndSettle();
      expect(events.last, d(2025, 3, 15));
    });

    testWidgets('digits follow the locale while the value stays numeric',
        (t) async {
      final events = <AwesomeDate>[];
      await t.pumpWidget(wrap(AwesomeDatePicker(
        localeName: 'fa',
        initialDate: d(2025, 6, 15),
        onChanged: events.add,
      )));
      expect(find.text('۱۵'), findsOneWidget);
      expect(find.text('۲۰۲۵'), findsOneWidget);
      expect(find.text('15'), findsNothing);

      await t.drag(
          find.byType(ListWheelScrollView).first, const Offset(0, -45));
      await t.pumpAndSettle();
      expect(events.last, d(2025, 6, 16));
      expect(find.text('۱۶'), findsOneWidget);
    });

    testWidgets('weekday labels use the locale and its digits', (t) async {
      await t.pumpWidget(wrap(AwesomeDatePicker(
        showWeekday: true,
        localeName: 'de',
        initialDate: d(2025, 6, 15), // a Sunday
      )));
      // 2025-06-15 is a Sunday: the last name of the Monday-first list
      final sunday = AwesomeIntl.weekdayNames('de').last;
      expect(find.text('$sunday 15'), findsOneWidget);

      await t.pumpWidget(wrap(AwesomeDatePicker(
        showWeekday: true,
        localeName: 'fa',
        initialDate: d(2025, 6, 15),
      )));
      await t.pumpAndSettle();
      expect(find.textContaining('۱۵'), findsOneWidget);
    });

    testWidgets('an unknown locale falls back to English', (t) async {
      await t.pumpWidget(wrap(AwesomeDatePicker(
        dateFormat: AwesomeDateFormat.dMMy,
        localeName: 'xx',
        initialDate: d(2025, 2, 15),
      )));
      expect(find.text('February'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('changing localeName updates the wheels and keeps the date',
        (t) async {
      final events = <AwesomeDate>[];
      Widget build(String name, {AwesomeDate? initial}) =>
          wrap(AwesomeDatePicker(
            dateFormat: AwesomeDateFormat.dMMy,
            localeName: name,
            initialDate: initial,
            onChanged: events.add,
          ));
      await t.pumpWidget(build('fr', initial: d(2025, 2, 15)));
      expect(find.text('février'), findsOneWidget);

      await t.pumpWidget(build('de'));
      await t.pumpAndSettle();
      expect(find.text('Februar'), findsOneWidget);
      expect(find.text('février'), findsNothing);
      expect(events, isEmpty);
    });

    testWidgets('month and year formats are localized too', (t) async {
      await t.pumpWidget(wrap(AwesomeDatePicker(
        dateFormat: AwesomeDateFormat.MMy,
        localeName: 'es',
        initialDate: d(2025, 3, 1),
      )));
      expect(find.text('marzo'), findsOneWidget);
    });

    testWidgets('a controller keeps working with localized labels', (t) async {
      final controller =
          AwesomeDatePickerController(initialValue: d(2025, 6, 15));
      await t.pumpWidget(
          wrap(AwesomeDatePicker(controller: controller, localeName: 'fa')));
      controller.value = d(2025, 7, 20);
      await t.pumpAndSettle();
      expect(controller.value, d(2025, 7, 20));
      expect(find.text('۲۰'), findsOneWidget);
    });

    testWidgets('screen readers get the localized label', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(wrap(
          AwesomeDatePicker(localeName: 'fa', initialDate: d(2025, 6, 15))));
      expect(find.semantics.byValue('۱۵'), findsOneWidget);
      handle.dispose();
    });
  });

  group('time picker', () {
    testWidgets('AM/PM markers are localized, values stay AM/PM', (t) async {
      AwesomeTime? last;
      await t.pumpWidget(wrap(AwesomeTimePicker(
        timeFormat: AwesomeTimeFormat.hm,
        localeName: 'ja',
        initialTime: const AwesomeTime(hour: 9, minute: 30),
        onChanged: (v) => last = v,
      )));
      expect(find.text('午前'), findsOneWidget);
      expect(find.text('午後'), findsWidgets);
      expect(find.text('AM'), findsNothing);

      // wheels: hour, minute, am/pm
      await t.drag(
          find.byType(ListWheelScrollView).at(2), const Offset(0, -45));
      await t.pumpAndSettle();
      expect(last, const AwesomeTime(hour: 21, minute: 30));
    });

    testWidgets('digits follow the locale', (t) async {
      await t.pumpWidget(wrap(AwesomeTimePicker(
        localeName: 'fa',
        timeFormat: AwesomeTimeFormat.Hms,
        initialTime: const AwesomeTime(hour: 9, minute: 5, second: 7),
      )));
      expect(find.text('۰۹'), findsWidgets);
      expect(find.text('۰۵'), findsWidgets);
      expect(find.text('۰۷'), findsWidgets);
      expect(find.text('09'), findsNothing);
    });

    testWidgets('without localeName nothing changes', (t) async {
      await t.pumpWidget(wrap(AwesomeTimePicker(
        timeFormat: AwesomeTimeFormat.hm,
        initialTime: const AwesomeTime(hour: 9, minute: 30),
      )));
      expect(find.text('AM'), findsOneWidget);
    });

    testWidgets('changing localeName relabels the wheels', (t) async {
      Widget build(String name) => wrap(AwesomeTimePicker(
            timeFormat: AwesomeTimeFormat.hm,
            localeName: name,
            initialTime: const AwesomeTime(hour: 9, minute: 30),
          ));
      await t.pumpWidget(build('en'));
      expect(find.text('AM'), findsOneWidget);
      await t.pumpWidget(build('ja'));
      await t.pumpAndSettle();
      expect(find.text('午前'), findsOneWidget);
    });
  });

  group('date-time picker', () {
    testWidgets('passes the locale to both parts', (t) async {
      await t.pumpWidget(wrap(AwesomeDateTimePicker(
        localeName: 'fr',
        dateFormat: AwesomeDateFormat.dMMy,
        timeFormat: AwesomeTimeFormat.hm,
        initialDateTime: AwesomeDateTime(
            date: d(2025, 2, 15), time: const AwesomeTime(hour: 9, minute: 30)),
        minDateTime: AwesomeDateTime(
            date: d(2025, 1, 1), time: const AwesomeTime(hour: 0, minute: 0)),
        maxDateTime: AwesomeDateTime(
            date: d(2025, 12, 31),
            time: const AwesomeTime(hour: 23, minute: 59)),
      )));
      expect(find.text('février'), findsOneWidget);
    });

    testWidgets('digits are localized in the date and the time', (t) async {
      await t.pumpWidget(wrap(AwesomeDateTimePicker(
        localeName: 'fa',
        initialDateTime: AwesomeDateTime(
            date: d(2025, 2, 15), time: const AwesomeTime(hour: 9, minute: 30)),
        minDateTime: AwesomeDateTime(
            date: d(2025, 1, 1), time: const AwesomeTime(hour: 0, minute: 0)),
        maxDateTime: AwesomeDateTime(
            date: d(2025, 12, 31),
            time: const AwesomeTime(hour: 23, minute: 59)),
      )));
      expect(find.text('۱۵'), findsOneWidget);
      expect(find.text('۰۹'), findsWidgets);
    });
  });
}
