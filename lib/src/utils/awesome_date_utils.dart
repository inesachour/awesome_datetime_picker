import 'package:intl/intl.dart';

class AwesomeDateUtils {
  static List<String> getMonthNames(String locale) {
    return List.generate(12, (index) {
      return DateFormat.MMMM(locale).format(DateTime(2025, index + 1, 1));
    });
  }
}
