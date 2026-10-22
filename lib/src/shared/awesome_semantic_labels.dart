import 'package:awesome_datetime_picker/src/core/data/locale.dart';
import 'package:flutter/foundation.dart';

/// The words a screen reader announces for each wheel of a picker, before the
/// selected value: "Day, 15", "Hour, 09", and so on.
///
/// Every picker announces its wheels in the language of its `locale` or
/// `localeName` when it is one of the built-in languages ([LocaleType]:
/// English, French, German, Spanish, Italian and Arabic), and in English for
/// any other language. To use other words, or another language, pass your own
/// labels as the picker's `semanticLabels`: the properties you leave null keep
/// the built-in words.
///
/// ```dart
/// AwesomeDatePicker(
///   semanticLabels: AwesomeSemanticLabels(day: 'Dia', month: 'Mês', year: 'Ano'),
/// )
/// ```
@immutable
class AwesomeSemanticLabels {
  /// The label of the day wheel.
  final String? day;

  /// The label of the month wheel.
  final String? month;

  /// The label of the year wheel.
  final String? year;

  /// The label of the hour wheel.
  final String? hour;

  /// The label of the minute wheel.
  final String? minute;

  /// The label of the second wheel.
  final String? second;

  /// The label of the AM/PM wheel.
  final String? amPm;

  /// Said before the label of every wheel of the start date of a date-range
  /// picker, e.g. "Start date, Day".
  final String? startDate;

  /// Said before the label of every wheel of the end date of a date-range
  /// picker, e.g. "End date, Day".
  final String? endDate;

  /// Creates labels. A label that is not given keeps the built-in word of the
  /// picker's language.
  const AwesomeSemanticLabels({
    this.day,
    this.month,
    this.year,
    this.hour,
    this.minute,
    this.second,
    this.amPm,
    this.startDate,
    this.endDate,
  });

  /// The built-in labels of [locale].
  factory AwesomeSemanticLabels.forLocale(LocaleType locale) {
    switch (locale) {
      case LocaleType.en:
        return _en;
      case LocaleType.fr:
        return _fr;
      case LocaleType.de:
        return _de;
      case LocaleType.es:
        return _es;
      case LocaleType.it:
        return _it;
      case LocaleType.ar:
        return _ar;
    }
  }

  /// The built-in labels for the language of [localeName] (e.g. `'fr_CH'` or
  /// `'de'`), or the English ones when the language is not built in.
  factory AwesomeSemanticLabels.forLocaleName(String localeName) {
    final language = localeName.split(RegExp('[_-]')).first.toLowerCase();
    for (final locale in LocaleType.values) {
      if (locale.name == language) {
        return AwesomeSemanticLabels.forLocale(locale);
      }
    }
    return _en;
  }

  /// Copy of these labels where the label of each prefixed wheel starts with
  /// [prefix], e.g. "Start date, Day". Used for the two dates of a range.
  AwesomeSemanticLabels prefixed(String prefix) {
    String? add(String? label) => label == null ? null : '$prefix, $label';
    return AwesomeSemanticLabels(
      day: add(day),
      month: add(month),
      year: add(year),
      hour: add(hour),
      minute: add(minute),
      second: add(second),
      amPm: add(amPm),
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// These labels, with the ones that are null taken from [base].
  AwesomeSemanticLabels mergedOver(AwesomeSemanticLabels base) {
    return AwesomeSemanticLabels(
      day: day ?? base.day,
      month: month ?? base.month,
      year: year ?? base.year,
      hour: hour ?? base.hour,
      minute: minute ?? base.minute,
      second: second ?? base.second,
      amPm: amPm ?? base.amPm,
      startDate: startDate ?? base.startDate,
      endDate: endDate ?? base.endDate,
    );
  }

  /// Creates a copy of these labels with the given properties replaced.
  AwesomeSemanticLabels copyWith({
    String? day,
    String? month,
    String? year,
    String? hour,
    String? minute,
    String? second,
    String? amPm,
    String? startDate,
    String? endDate,
  }) {
    return AwesomeSemanticLabels(
      day: day ?? this.day,
      month: month ?? this.month,
      year: year ?? this.year,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
      amPm: amPm ?? this.amPm,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  /// The labels a picker announces: [custom] over the built-in labels of
  /// [localeName] if there is one, else of [locale].
  static AwesomeSemanticLabels resolve({
    required LocaleType locale,
    String? localeName,
    AwesomeSemanticLabels? custom,
  }) {
    final base = localeName != null
        ? AwesomeSemanticLabels.forLocaleName(localeName)
        : AwesomeSemanticLabels.forLocale(locale);
    return custom == null ? base : custom.mergedOver(base);
  }

  static const _en = AwesomeSemanticLabels(
    day: 'Day',
    month: 'Month',
    year: 'Year',
    hour: 'Hour',
    minute: 'Minute',
    second: 'Second',
    amPm: 'AM/PM',
    startDate: 'Start date',
    endDate: 'End date',
  );

  static const _fr = AwesomeSemanticLabels(
    day: 'Jour',
    month: 'Mois',
    year: 'Année',
    hour: 'Heure',
    minute: 'Minute',
    second: 'Seconde',
    amPm: 'AM/PM',
    startDate: 'Date de début',
    endDate: 'Date de fin',
  );

  static const _de = AwesomeSemanticLabels(
    day: 'Tag',
    month: 'Monat',
    year: 'Jahr',
    hour: 'Stunde',
    minute: 'Minute',
    second: 'Sekunde',
    amPm: 'AM/PM',
    startDate: 'Startdatum',
    endDate: 'Enddatum',
  );

  static const _es = AwesomeSemanticLabels(
    day: 'Día',
    month: 'Mes',
    year: 'Año',
    hour: 'Hora',
    minute: 'Minuto',
    second: 'Segundo',
    amPm: 'a. m./p. m.',
    startDate: 'Fecha de inicio',
    endDate: 'Fecha de fin',
  );

  static const _it = AwesomeSemanticLabels(
    day: 'Giorno',
    month: 'Mese',
    year: 'Anno',
    hour: 'Ora',
    minute: 'Minuto',
    second: 'Secondo',
    amPm: 'AM/PM',
    startDate: 'Data di inizio',
    endDate: 'Data di fine',
  );

  static const _ar = AwesomeSemanticLabels(
    day: 'اليوم',
    month: 'الشهر',
    year: 'السنة',
    hour: 'الساعة',
    minute: 'الدقيقة',
    second: 'الثانية',
    amPm: 'ص/م',
    startDate: 'تاريخ البدء',
    endDate: 'تاريخ الانتهاء',
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AwesomeSemanticLabels &&
          other.day == day &&
          other.month == month &&
          other.year == year &&
          other.hour == hour &&
          other.minute == minute &&
          other.second == second &&
          other.amPm == amPm &&
          other.startDate == startDate &&
          other.endDate == endDate;

  @override
  int get hashCode => Object.hash(
        day,
        month,
        year,
        hour,
        minute,
        second,
        amPm,
        startDate,
        endDate,
      );
}
