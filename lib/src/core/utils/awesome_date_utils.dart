// ignore_for_file: public_member_api_docs
// Internal implementation file: it is not exported by the package, so its
// members are documented at class level only.

import 'package:awesome_datetime_picker/src/core/data/locale.dart';
import 'package:flutter/material.dart';

/// Date helpers: localized month names and days-in-month lookups.
class AwesomeDateUtils {
  static List<String> getMonthNames(LocaleType locale) {
    switch (locale) {
      case LocaleType.en:
        return [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
      case LocaleType.fr:
        return [
          'Janvier',
          'Février',
          'Mars',
          'Avril',
          'Mai',
          'Juin',
          'Juillet',
          'Août',
          'Septembre',
          'Octobre',
          'Novembre',
          'Décembre'
        ];
      case LocaleType.de:
        return [
          'Januar',
          'Februar',
          'März',
          'April',
          'Mai',
          'Juni',
          'Juli',
          'August',
          'September',
          'Oktober',
          'November',
          'Dezember'
        ];
      case LocaleType.es:
        return [
          'Enero',
          'Febrero',
          'Marzo',
          'Abril',
          'Mayo',
          'Junio',
          'Julio',
          'Agosto',
          'Septiembre',
          'Octubre',
          'Noviembre',
          'Diciembre'
        ];
      case LocaleType.it:
        return [
          'Gennaio',
          'Febbraio',
          'Marzo',
          'Aprile',
          'Maggio',
          'Giugno',
          'Luglio',
          'Agosto',
          'Settembre',
          'Ottobre',
          'Novembre',
          'Dicembre'
        ];
      case LocaleType.ar:
        return [
          'يناير',
          'فبراير',
          'مارس',
          'أبريل',
          'مايو',
          'يونيو',
          'يوليو',
          'أغسطس',
          'سبتمبر',
          'أكتوبر',
          'نوفمبر',
          'ديسمبر'
        ];
    }
  }

  /// Short weekday names for [locale], starting on Monday (index 0) to match
  /// [DateTime.weekday] - 1.
  static List<String> getWeekdayNames(LocaleType locale) {
    switch (locale) {
      case LocaleType.en:
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case LocaleType.fr:
        return ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'];
      case LocaleType.de:
        return ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
      case LocaleType.es:
        return ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
      case LocaleType.it:
        return ['lun', 'mar', 'mer', 'gio', 'ven', 'sab', 'dom'];
      case LocaleType.ar:
        return [
          'الاثنين',
          'الثلاثاء',
          'الأربعاء',
          'الخميس',
          'الجمعة',
          'السبت',
          'الأحد'
        ];
    }
  }

  static List<String> getMonthDays(int year, int month) {
    return List.generate(
      DateUtils.getDaysInMonth(year, month),
      (index) => (index + 1).toString(),
    );
  }

  static int getDaysInMonth(int year, int month) {
    return DateUtils.getDaysInMonth(year, month);
  }
}
