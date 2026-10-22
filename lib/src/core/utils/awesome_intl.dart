// ignore_for_file: public_member_api_docs
// Internal implementation file: it is not exported by the package, so its
// members are documented at class level only.

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Localized texts for the pickers, taken from `package:intl`.
///
/// Used when a picker is given a `localeName`; the built-in `LocaleType`
/// languages keep their own tables. Results are cached per locale.
class AwesomeIntl {
  AwesomeIntl._();

  static bool _initialized = false;

  static final Map<String, List<String>> _months = {};
  static final Map<String, List<String>> _weekdays = {};
  static final Map<String, List<String>> _amPm = {};
  static final Map<String, List<String>> _digits = {};

  /// Loads the date symbols of every locale. They are embedded in the package
  /// `intl`, so they are available as soon as the call returns (the returned
  /// future has nothing left to wait for).
  static void _ensureInitialized() {
    if (_initialized) return;
    initializeDateFormatting();
    _initialized = true;
  }

  /// The locale name known by `intl` that is closest to [name] (e.g. "pt-BR"
  /// becomes "pt_BR", "fr_CH" falls back to "fr"), or "en" when there is none.
  static String resolve(String name) {
    _ensureInitialized();
    final canonical = Intl.canonicalizedLocale(name);
    if (DateFormat.localeExists(canonical)) return canonical;
    final short = Intl.shortLocale(canonical);
    if (DateFormat.localeExists(short)) return short;
    return 'en';
  }

  /// The 12 month names (January first), in the nominative form used on its
  /// own, not inside a date.
  static List<String> monthNames(String locale) {
    return _months.putIfAbsent(locale, () {
      final format = DateFormat('LLLL', locale);
      return [
        for (int m = 1; m <= 12; m++) format.format(DateTime(2000, m, 1))
      ];
    });
  }

  /// Short weekday names starting on Monday, to match `DateTime.weekday - 1`.
  static List<String> weekdayNames(String locale) {
    return _weekdays.putIfAbsent(locale, () {
      final format = DateFormat.E(locale);
      // 2024-01-01 is a Monday.
      return [
        for (int i = 0; i < 7; i++) format.format(DateTime(2024, 1, 1 + i))
      ];
    });
  }

  /// The AM and PM markers, in this order.
  static List<String> amPmLabels(String locale) {
    return _amPm.putIfAbsent(locale, () {
      final format = DateFormat('a', locale);
      return [
        format.format(DateTime(2000, 1, 1, 0)),
        format.format(DateTime(2000, 1, 1, 12)),
      ];
    });
  }

  /// The glyphs of the digits 0 to 9, or null when they are the usual ASCII
  /// ones (so no relabeling is needed).
  static List<String>? digitGlyphs(String locale) {
    final glyphs = _digits.putIfAbsent(locale, () {
      final format = NumberFormat('0', locale);
      return [for (int d = 0; d < 10; d++) format.format(d)];
    });
    return glyphs[0] == '0' ? null : glyphs;
  }

  /// Replaces the ASCII digits of [text] by [glyphs] (see [digitGlyphs]).
  static String localizeDigits(String text, List<String> glyphs) {
    final buffer = StringBuffer();
    for (final unit in text.codeUnits) {
      if (unit >= 0x30 && unit <= 0x39) {
        buffer.write(glyphs[unit - 0x30]);
      } else {
        buffer.writeCharCode(unit);
      }
    }
    return buffer.toString();
  }
}
