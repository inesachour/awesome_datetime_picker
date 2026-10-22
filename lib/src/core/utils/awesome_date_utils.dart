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
