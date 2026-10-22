import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/date/date_picker_logic.dart';
import 'package:flutter_test/flutter_test.dart';

DatePickerLogic build({AwesomeDate? initial}) => DatePickerLogic(
      minDate: const AwesomeDate(year: 2024, month: 2, day: 15),
      maxDate: const AwesomeDate(year: 2026, month: 10, day: 10),
      locale: LocaleType.en,
      initialDate: initial,
    );

void main() {
  test('keeps an initial date inside the range even if its day < min day', () {
    final c = build(initial: const AwesomeDate(year: 2024, month: 3, day: 10));
    expect(c.selectedDate, const AwesomeDate(year: 2024, month: 3, day: 10));
  });

  test('keeps an initial date inside the range even if its day > max day', () {
    final c = build(initial: const AwesomeDate(year: 2026, month: 9, day: 20));
    expect(c.selectedDate, const AwesomeDate(year: 2026, month: 9, day: 20));
  });

  test('clamps an out-of-range initial date', () {
    final c = build(initial: const AwesomeDate(year: 2020, month: 1, day: 1));
    expect(c.selectedDate, const AwesomeDate(year: 2024, month: 2, day: 15));
  });

  test('defaults to today (clamped), not minDate', () {
    final c = DatePickerLogic(
      minDate: const AwesomeDate(year: 1900, month: 1, day: 1),
      maxDate: const AwesomeDate(year: 2100, month: 12, day: 31),
      locale: LocaleType.en,
    );
    final now = DateTime.now();
    expect(c.selectedDate,
        AwesomeDate(year: now.year, month: now.month, day: now.day));
  });

  test('does not notify when the selection is unchanged', () {
    final c = build(initial: const AwesomeDate(year: 2024, month: 3, day: 10));
    var calls = 0;
    c.addListener(() => calls++);
    c.onSelectedDayChanged('10');
    expect(calls, 0);
    c.onSelectedDayChanged('11');
    expect(calls, 1);
  });
}
