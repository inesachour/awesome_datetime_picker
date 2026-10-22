import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget w) => MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: Center(child: w))));

AwesomeDate d(int y, int m, int day) =>
    AwesomeDate(year: y, month: m, day: day);

/// The labels of the adjustable wheels, in reading order.
List<String> wheelLabels(WidgetTester t) => [
      for (final node
          in find.semantics.byAction(SemanticsAction.increase).evaluate())
        node.label,
    ];

/// The wheel announcing [label], e.g. "Day".
SemanticsNode wheel(WidgetTester t, String label) =>
    find.semantics.byLabel(label).evaluate().single;

void main() {
  group('AwesomeSemanticLabels', () {
    test('every built-in language is complete', () {
      for (final locale in LocaleType.values) {
        final labels = AwesomeSemanticLabels.forLocale(locale);
        for (final word in [
          labels.day,
          labels.month,
          labels.year,
          labels.hour,
          labels.minute,
          labels.second,
          labels.amPm,
          labels.startDate,
          labels.endDate,
        ]) {
          expect(word, isNotNull, reason: '$locale');
          expect(word, isNotEmpty, reason: '$locale');
        }
      }
    });

    test('the languages differ', () {
      final days = {
        for (final l in LocaleType.values)
          AwesomeSemanticLabels.forLocale(l).day,
      };
      expect(days.length, LocaleType.values.length);
    });

    test('forLocaleName follows the language part', () {
      expect(AwesomeSemanticLabels.forLocaleName('fr').day, 'Jour');
      expect(AwesomeSemanticLabels.forLocaleName('fr_CH').day, 'Jour');
      expect(AwesomeSemanticLabels.forLocaleName('de-AT').day, 'Tag');
      expect(AwesomeSemanticLabels.forLocaleName('ES').day, 'Día');
    });

    test('a language that is not built in falls back to English', () {
      expect(AwesomeSemanticLabels.forLocaleName('ja').day, 'Day');
      expect(AwesomeSemanticLabels.forLocaleName('xx_YY').day, 'Day');
    });

    test('prefixed puts a prefix before each wheel label', () {
      final labels =
          AwesomeSemanticLabels.forLocale(LocaleType.en).prefixed('Start date');
      expect(labels.day, 'Start date, Day');
      expect(labels.hour, 'Start date, Hour');
      expect(labels.startDate, 'Start date'); // not a wheel
    });

    test('mergedOver keeps the given words and fills the others', () {
      const custom = AwesomeSemanticLabels(day: 'Dia');
      final merged =
          custom.mergedOver(AwesomeSemanticLabels.forLocale(LocaleType.fr));
      expect(merged.day, 'Dia');
      expect(merged.month, 'Mois');
    });

    test('resolve prefers localeName, then the custom words', () {
      expect(
        AwesomeSemanticLabels.resolve(locale: LocaleType.en, localeName: 'de')
            .day,
        'Tag',
      );
      expect(
        AwesomeSemanticLabels.resolve(
          locale: LocaleType.en,
          localeName: 'de',
          custom: const AwesomeSemanticLabels(day: 'Dia'),
        ).day,
        'Dia',
      );
    });

    test('copyWith and equality', () {
      const a = AwesomeSemanticLabels(day: 'A', month: 'B');
      expect(a.copyWith(month: 'C').month, 'C');
      expect(a.copyWith(month: 'C').day, 'A');
      expect(a, const AwesomeSemanticLabels(day: 'A', month: 'B'));
      expect(a.hashCode,
          const AwesomeSemanticLabels(day: 'A', month: 'B').hashCode);
      expect(a, isNot(const AwesomeSemanticLabels(day: 'A')));
    });
  });

  group('what the wheels announce', () {
    testWidgets('a date picker says Day, Month and Year with the value',
        (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(wrap(AwesomeDatePicker(
          dateFormat: AwesomeDateFormat.dMMy, initialDate: d(2025, 6, 15))));
      expect(wheelLabels(t), ['Day', 'Month', 'Year']);
      expect(wheel(t, 'Day').value, '15');
      expect(wheel(t, 'Month').value, 'June');
      expect(wheel(t, 'Year').value, '2025');
      handle.dispose();
    });

    testWidgets('built-in languages', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(wrap(AwesomeDatePicker(
          locale: LocaleType.fr, initialDate: d(2025, 6, 15))));
      expect(wheelLabels(t), ['Jour', 'Mois', 'Année']);
      handle.dispose();
    });

    testWidgets('localeName follows its language', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(wrap(
          AwesomeDatePicker(localeName: 'de_CH', initialDate: d(2025, 6, 15))));
      expect(wheelLabels(t), ['Tag', 'Monat', 'Jahr']);
      handle.dispose();
    });

    testWidgets('another language is announced in English', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(wrap(
          AwesomeDatePicker(localeName: 'ja', initialDate: d(2025, 6, 15))));
      expect(wheelLabels(t), ['Day', 'Month', 'Year']);
      handle.dispose();
    });

    testWidgets('your own words replace the built-in ones one by one',
        (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(wrap(AwesomeDatePicker(
        initialDate: d(2025, 6, 15),
        semanticLabels: const AwesomeSemanticLabels(day: 'Dia', year: 'Ano'),
      )));
      expect(wheelLabels(t), ['Dia', 'Month', 'Ano']);
      handle.dispose();
    });

    testWidgets('a language that is not built in can be supplied', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(wrap(AwesomeDatePicker(
        localeName: 'pt_BR',
        initialDate: d(2025, 6, 15),
        semanticLabels:
            const AwesomeSemanticLabels(day: 'Dia', month: 'Mês', year: 'Ano'),
      )));
      expect(wheelLabels(t), ['Dia', 'Mês', 'Ano']);
      handle.dispose();
    });

    testWidgets('a time picker says Hour, Minute, Second and AM/PM', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(wrap(AwesomeTimePicker(
        timeFormat: AwesomeTimeFormat.hms,
        initialTime: const AwesomeTime(hour: 9, minute: 5, second: 7),
      )));
      expect(wheelLabels(t), ['Hour', 'Minute', 'Second', 'AM/PM']);
      expect(wheel(t, 'Minute').value, '05');
      handle.dispose();
    });

    testWidgets('a time picker follows localeName', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(wrap(AwesomeTimePicker(
          localeName: 'fr',
          initialTime: const AwesomeTime(hour: 9, minute: 5))));
      expect(wheelLabels(t), ['Heure', 'Minute']);
      handle.dispose();
    });

    testWidgets('both halves of a date-time picker use the same language',
        (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(wrap(AwesomeDateTimePicker(
        locale: LocaleType.es,
        initialDateTime: AwesomeDateTime(
            date: d(2025, 6, 15), time: const AwesomeTime(hour: 9, minute: 5)),
        minDateTime: AwesomeDateTime(
            date: d(2024, 1, 1), time: const AwesomeTime(hour: 0, minute: 0)),
        maxDateTime: AwesomeDateTime(
            date: d(2026, 12, 31),
            time: const AwesomeTime(hour: 23, minute: 59)),
      )));
      expect(wheelLabels(t), ['Día', 'Mes', 'Año', 'Hora', 'Minuto']);
      handle.dispose();
    });

    testWidgets('a date-range picker says which date a wheel belongs to',
        (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
        minDate: d(2024, 1, 1),
        maxDate: d(2026, 12, 31),
        initialRange:
            AwesomeDateRange(start: d(2025, 6, 10), end: d(2025, 6, 20)),
      )));
      expect(wheelLabels(t), [
        'Start date, Day',
        'Start date, Month',
        'Start date, Year',
        'End date, Day',
        'End date, Month',
        'End date, Year',
      ]);
      expect(wheel(t, 'End date, Day').value, '20');
      handle.dispose();
    });

    testWidgets('a date-range picker in French', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(wrap(AwesomeDateRangePicker(
        locale: LocaleType.fr,
        initialRange:
            AwesomeDateRange(start: d(2025, 6, 10), end: d(2025, 6, 20)),
      )));
      expect(wheelLabels(t).first, 'Date de début, Jour');
      expect(wheelLabels(t)[3], 'Date de fin, Jour');
      handle.dispose();
    });

    testWidgets('the modal shortcuts forward the labels', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showAwesomeDatePicker(
              context,
              initialDate: d(2025, 6, 15),
              semanticLabels: const AwesomeSemanticLabels(day: 'Dia'),
            ),
            child: const Text('open'),
          ),
        ),
      ));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(wheelLabels(t).first, 'Dia');
      handle.dispose();
    });

    testWidgets('the label does not change what the wheel reports', (t) async {
      final handle = t.ensureSemantics();
      AwesomeDate? last;
      await t.pumpWidget(wrap(AwesomeDatePicker(
        initialDate: d(2025, 6, 15),
        onChanged: (v) => last = v,
      )));
      t.semantics.increase(find.semantics.byLabel('Day'));
      await t.pumpAndSettle();
      expect(last, d(2025, 6, 16));
      handle.dispose();
    });
  });
}
