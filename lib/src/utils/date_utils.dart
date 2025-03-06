import 'package:intl/intl.dart';

List<String> getMonthNames(String locale) {
  return List.generate(12, (index) {
    return DateFormat.MMMM(locale).format(DateTime(2025, index + 1, 1));
  });
}