import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/time/time_picker_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('exclusions', () {
    test('never move the selection past maxTime', () {
      final c = TimePickerLogic(
        minTime: const AwesomeTime(hour: 5, minute: 0),
        maxTime: const AwesomeTime(hour: 15, minute: 0),
        initialTime: const AwesomeTime(hour: 14, minute: 0),
        excludedHours: const [14, 15],
      );
      expect(c.selectedTime, const AwesomeTime(hour: 13, minute: 0));
    });

    test('never move the selection before minTime', () {
      final c = TimePickerLogic(
        minTime: const AwesomeTime(hour: 5, minute: 30),
        maxTime: const AwesomeTime(hour: 8, minute: 0),
        initialTime: const AwesomeTime(hour: 6, minute: 0),
        excludedHours: const [6, 7, 8],
      );
      expect(c.selectedTime, const AwesomeTime(hour: 5, minute: 30));
    });

    test('prefer the following hour and keep the minute', () {
      final c = TimePickerLogic(
        minTime: const AwesomeTime(hour: 0, minute: 0),
        maxTime: const AwesomeTime(hour: 23, minute: 59),
        initialTime: const AwesomeTime(hour: 12, minute: 45),
        excludedHours: const [12],
      );
      expect(c.selectedTime, const AwesomeTime(hour: 13, minute: 45));
    });

    test('excluded hours are removed from the 24h and 12h wheels', () {
      final c = TimePickerLogic(
        minTime: const AwesomeTime(hour: 0, minute: 0),
        maxTime: const AwesomeTime(hour: 23, minute: 59),
        initialTime: const AwesomeTime(hour: 9, minute: 0),
        excludedHours: const [12, 13],
      );
      expect(c.hours, isNot(contains('12')));
      expect(c.hours, isNot(contains('13')));
      expect(c.amPmHours, isNotEmpty);
    });

    test('excluding every hour of the range fails fast in debug mode', () {
      expect(
        () => TimePickerLogic(
          minTime: const AwesomeTime(hour: 9, minute: 0),
          maxTime: const AwesomeTime(hour: 10, minute: 0),
          excludedHours: const [9, 10],
        ),
        throwsAssertionError,
      );
    });
  });

  group('wheel labels', () {
    test('minutes and 24h hours are zero-padded', () {
      final c = TimePickerLogic(
        minTime: const AwesomeTime(hour: 0, minute: 0),
        maxTime: const AwesomeTime(hour: 23, minute: 59),
        initialTime: const AwesomeTime(hour: 9, minute: 5),
      );
      expect(c.minutes.take(3), ['00', '01', '02']);
      expect(c.hours.take(3), ['00', '01', '02']);
    });

    test('padded labels are parsed back correctly', () {
      final c = TimePickerLogic(
        minTime: const AwesomeTime(hour: 0, minute: 0),
        maxTime: const AwesomeTime(hour: 23, minute: 59),
        initialTime: const AwesomeTime(hour: 9, minute: 5),
      );
      c.onSelectedMinuteChanged('07');
      c.onSelectedHourChanged('08');
      expect(c.selectedTime, const AwesomeTime(hour: 8, minute: 7));
    });

    test('12h hours are not padded', () {
      final c = TimePickerLogic(
        minTime: const AwesomeTime(hour: 0, minute: 0),
        maxTime: const AwesomeTime(hour: 23, minute: 59),
        initialTime: const AwesomeTime(hour: 9, minute: 0),
      );
      expect(c.amPmHours.take(3), ['12', '1', '2']);
    });
  });

  group('12h conversion', () {
    TimePickerLogic at(int h, [int m = 0]) => TimePickerLogic(
          minTime: const AwesomeTime(hour: 0, minute: 0),
          maxTime: const AwesomeTime(hour: 23, minute: 59),
          initialTime: AwesomeTime(hour: h, minute: m),
        );

    test('noon and midnight', () {
      final c = at(12);
      expect(c.selectedAmPm, 'PM');
      c.onSelectedAmPmChanged('AM');
      expect(c.selectedTime.hour, 0);
      c.onSelectedAmPmChanged('PM');
      expect(c.selectedTime.hour, 12);
    });

    test('hour wheel keeps the period', () {
      final c = at(15, 30);
      c.onSelectedAmPmHourChanged('4');
      expect(c.selectedTime, const AwesomeTime(hour: 16, minute: 30));
    });
  });
}
