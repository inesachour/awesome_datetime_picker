import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/duration/duration_picker_logic.dart';
import 'package:flutter_test/flutter_test.dart';

DurationPickerLogic logic({
  AwesomeDurationFormat format = AwesomeDurationFormat.hm,
  Duration min = Duration.zero,
  Duration max = const Duration(hours: 23, minutes: 59, seconds: 59),
  Duration? initial,
  int minuteInterval = 1,
  int secondInterval = 1,
}) =>
    DurationPickerLogic(
      format: format,
      minDuration: min,
      maxDuration: max,
      initialDuration: initial,
      minuteInterval: minuteInterval,
      secondInterval: secondInterval,
    );

const h1m30 = Duration(hours: 1, minutes: 30);

void main() {
  group('formats', () {
    test('which wheels each format has', () {
      expect(AwesomeDurationFormat.hm.hasHours, isTrue);
      expect(AwesomeDurationFormat.hm.hasSeconds, isFalse);
      expect(AwesomeDurationFormat.ms.hasHours, isFalse);
      expect(AwesomeDurationFormat.ms.hasSeconds, isTrue);
      expect(AwesomeDurationFormat.hms.hasHours, isTrue);
      expect(AwesomeDurationFormat.hms.hasSeconds, isTrue);
    });

    test('the units of the wheels, largest first', () {
      expect(logic().units, [DurationUnit.hours, DurationUnit.minutes]);
      expect(logic(format: AwesomeDurationFormat.ms).units,
          [DurationUnit.minutes, DurationUnit.seconds]);
      expect(logic(format: AwesomeDurationFormat.hms).units, [
        DurationUnit.hours,
        DurationUnit.minutes,
        DurationUnit.seconds,
      ]);
    });
  });

  group('hours and minutes', () {
    test('starts at the minimum (zero) without an initial value', () {
      expect(logic().selected, Duration.zero);
    });

    test('the wheels list the whole range', () {
      final c = logic(initial: h1m30);
      expect(c.itemsOf(0).length, 24); // 0..23
      expect(c.itemsOf(0).first, '0');
      expect(c.itemsOf(0).last, '23');
      expect(c.itemsOf(1).length, 60);
      expect(c.itemsOf(1).first, '00');
      expect(c.itemsOf(1).last, '59');
    });

    test('picking an item changes only that unit', () {
      final c = logic(initial: h1m30);
      c.onSelectedItemChanged(0, '5');
      expect(c.selected, const Duration(hours: 5, minutes: 30));
      c.onSelectedItemChanged(1, '07');
      expect(c.selected, const Duration(hours: 5, minutes: 7));
    });

    test('the selected items', () {
      final c = logic(initial: const Duration(hours: 1, minutes: 5));
      expect(c.selectedItemOf(0), '1');
      expect(c.selectedItemOf(1), '05');
    });

    test('seconds are dropped: the duration is on whole minutes', () {
      expect(logic(initial: const Duration(minutes: 5, seconds: 20)).selected,
          const Duration(minutes: 5));
      expect(logic(initial: const Duration(minutes: 5, seconds: 40)).selected,
          const Duration(minutes: 6));
    });

    test('notifies on a change and not otherwise', () {
      final c = logic(initial: h1m30);
      var calls = 0;
      c.addListener(() => calls++);
      c.onSelectedItemChanged(0, '1');
      expect(calls, 0);
      c.onSelectedItemChanged(0, '2');
      expect(calls, 1);
    });
  });

  group('minutes and seconds', () {
    test('the minutes wheel is not limited to 59 when the max allows it', () {
      final c = logic(
        format: AwesomeDurationFormat.ms,
        max: const Duration(minutes: 120),
        initial: const Duration(minutes: 90, seconds: 15),
      );
      expect(c.itemsOf(0).last, '120');
      expect(c.selected, const Duration(minutes: 90, seconds: 15));
      expect(c.selectedItemOf(0), '90');
      expect(c.selectedItemOf(1), '15');
    });

    test('picking minutes and seconds', () {
      final c = logic(
        format: AwesomeDurationFormat.ms,
        max: const Duration(minutes: 120),
        initial: const Duration(minutes: 3, seconds: 20),
      );
      c.onSelectedItemChanged(0, '45');
      c.onSelectedItemChanged(1, '05');
      expect(c.selected, const Duration(minutes: 45, seconds: 5));
    });

    test('the default maximum of minutes and seconds is 59:59 in the widget',
        () {
      // the logic takes the maximum it is given
      final c = logic(
        format: AwesomeDurationFormat.ms,
        max: const Duration(minutes: 59, seconds: 59),
      );
      expect(c.itemsOf(0).length, 60);
      expect(c.itemsOf(1).length, 60);
    });
  });

  group('hours, minutes and seconds', () {
    test('three wheels', () {
      final c = logic(
        format: AwesomeDurationFormat.hms,
        initial: const Duration(hours: 1, minutes: 2, seconds: 3),
      );
      expect([c.selectedItemOf(0), c.selectedItemOf(1), c.selectedItemOf(2)],
          ['1', '02', '03']);
      c.onSelectedItemChanged(2, '30');
      expect(c.selected, const Duration(hours: 1, minutes: 2, seconds: 30));
    });

    test('the hours can go past 23 when the maximum allows it', () {
      final c = logic(
        format: AwesomeDurationFormat.hms,
        max: const Duration(hours: 99, minutes: 59, seconds: 59),
        initial: const Duration(hours: 48),
      );
      expect(c.itemsOf(0).last, '99');
      c.onSelectedItemChanged(0, '99');
      expect(c.selected, const Duration(hours: 99));
    });
  });

  group('limits', () {
    test('a selection outside is moved to the nearest limit', () {
      final c = logic(
        min: const Duration(minutes: 30),
        max: const Duration(hours: 2),
        initial: const Duration(hours: 5),
      );
      expect(c.selected, const Duration(hours: 2));
      expect(
          logic(
            min: const Duration(minutes: 30),
            max: const Duration(hours: 2),
            initial: const Duration(minutes: 5),
          ).selected,
          const Duration(minutes: 30));
    });

    test('the hours wheel is cut by the limits', () {
      final c = logic(
        min: const Duration(hours: 1, minutes: 30),
        max: const Duration(hours: 4, minutes: 15),
        initial: const Duration(hours: 2),
      );
      expect(c.itemsOf(0), ['1', '2', '3', '4']);
    });

    test('the minutes at the first hour start at the minimum', () {
      final c = logic(
        min: const Duration(hours: 1, minutes: 30),
        max: const Duration(hours: 4, minutes: 15),
        initial: const Duration(hours: 1, minutes: 45),
      );
      expect(c.itemsOf(1).first, '30');
      expect(c.itemsOf(1).last, '59');
    });

    test('the minutes at the last hour end at the maximum', () {
      final c = logic(
        min: const Duration(hours: 1, minutes: 30),
        max: const Duration(hours: 4, minutes: 15),
        initial: const Duration(hours: 4),
      );
      expect(c.itemsOf(1).first, '00');
      expect(c.itemsOf(1).last, '15');
    });

    test('the minutes in between offer all of them', () {
      final c = logic(
        min: const Duration(hours: 1, minutes: 30),
        max: const Duration(hours: 4, minutes: 15),
        initial: const Duration(hours: 2),
      );
      expect(c.itemsOf(1).length, 60);
    });

    test('moving to the first hour clamps the minutes up', () {
      final c = logic(
        min: const Duration(hours: 1, minutes: 30),
        max: const Duration(hours: 4),
        initial: const Duration(hours: 2, minutes: 10),
      );
      c.onSelectedItemChanged(0, '1');
      expect(c.selected, const Duration(hours: 1, minutes: 30));
    });

    test('moving to the last hour clamps the minutes down', () {
      final c = logic(
        max: const Duration(hours: 4, minutes: 15),
        initial: const Duration(hours: 2, minutes: 50),
      );
      c.onSelectedItemChanged(0, '4');
      expect(c.selected, const Duration(hours: 4, minutes: 15));
    });

    test('the seconds are cut at the first and the last minute', () {
      final c = logic(
        format: AwesomeDurationFormat.hms,
        min: const Duration(minutes: 5, seconds: 20),
        max: const Duration(minutes: 9, seconds: 40),
        initial: const Duration(minutes: 5, seconds: 30),
      );
      expect(c.itemsOf(2).first, '20');
      c.onSelectedItemChanged(1, '09');
      expect(c.itemsOf(2).last, '40');
      c.onSelectedItemChanged(1, '07');
      expect(c.itemsOf(2).length, 60);
    });

    test('a duration that does not fit fails fast in debug mode', () {
      expect(
          () => logic(
              min: const Duration(hours: 2), max: const Duration(hours: 1)),
          throwsAssertionError);
      expect(
          () => logic(min: const Duration(seconds: -1)), throwsAssertionError);
    });
  });

  group('intervals', () {
    test('minutes go by the interval', () {
      final c = logic(minuteInterval: 15, initial: h1m30);
      expect(c.itemsOf(1), ['00', '15', '30', '45']);
    });

    test('an off-grid initial value is rounded to the nearest step', () {
      expect(
          logic(minuteInterval: 15, initial: const Duration(minutes: 7))
              .selected,
          Duration.zero);
      expect(
          logic(minuteInterval: 15, initial: const Duration(minutes: 8))
              .selected,
          const Duration(minutes: 15));
    });

    test('the limits are moved onto the grid', () {
      final c = logic(
        minuteInterval: 15,
        min: const Duration(minutes: 20),
        max: const Duration(minutes: 100),
      );
      expect(c.minSeconds, 30 * 60);
      expect(c.maxSeconds, 90 * 60);
    });

    test('with minutes first, the interval applies to the whole count', () {
      final c = logic(
        format: AwesomeDurationFormat.ms,
        minuteInterval: 5,
        max: const Duration(minutes: 30),
        initial: const Duration(minutes: 10),
      );
      expect(c.itemsOf(0), ['0', '5', '10', '15', '20', '25', '30']);
    });

    test('seconds go by their interval', () {
      final c = logic(
        format: AwesomeDurationFormat.ms,
        secondInterval: 15,
        initial: const Duration(minutes: 1),
      );
      expect(c.itemsOf(1), ['00', '15', '30', '45']);
    });

    test('an interval that does not divide 60 fails fast', () {
      expect(() => logic(minuteInterval: 7), throwsAssertionError);
      expect(() => logic(secondInterval: 0), throwsAssertionError);
    });

    test('a second interval is ignored without a seconds wheel', () {
      final c = logic(
          secondInterval: 15, initial: const Duration(minutes: 5, seconds: 20));
      expect(c.selected, const Duration(minutes: 5));
    });
  });

  group('setSelectedDuration', () {
    test('moves onto the grid and into the limits', () {
      final c = logic(minuteInterval: 10, max: const Duration(hours: 1));
      c.setSelectedDuration(const Duration(minutes: 33));
      expect(c.selected, const Duration(minutes: 30));
      c.setSelectedDuration(const Duration(hours: 9));
      expect(c.selected, const Duration(hours: 1));
    });

    test('does nothing when the value is unchanged', () {
      final c = logic(initial: h1m30);
      var calls = 0;
      c.addListener(() => calls++);
      c.setSelectedDuration(h1m30);
      expect(calls, 0);
    });
  });
}
