// ignore_for_file: public_member_api_docs
// Internal implementation file: it is not exported by the package, so its
// members are documented at class level only.

import 'package:awesome_datetime_picker/src/core/data/format.dart';
import 'package:awesome_datetime_picker/src/core/utils/awesome_time_utils.dart';
import 'package:flutter/foundation.dart';

/// What a wheel of a duration picker counts.
enum DurationUnit { hours, minutes, seconds }

/// Logic behind [AwesomeDurationPicker]: holds the selected duration, keeps it
/// inside the limits and on the minute and second intervals, and builds the
/// items of each wheel.
///
/// The wheels are the "levels" of the duration: from the largest unit shown
/// (not limited to 59: it counts the whole duration) down to the smallest (0
/// to 59). Every level has the size of one of its steps in seconds, and the
/// same code serves every [AwesomeDurationFormat].
class DurationPickerLogic extends ChangeNotifier {
  /// The wheels to show, from the largest unit to the smallest.
  final AwesomeDurationFormat format;

  final int minuteInterval;
  final int secondInterval;

  /// Shortest and longest selectable durations, in seconds, moved onto the
  /// minute and second grid.
  final int minSeconds;
  final int maxSeconds;

  final List<DurationUnit> units;

  /// Size of one unit of each level, in seconds.
  final List<int> _unitSeconds;

  /// Distance between two values of each level.
  final List<int> _steps;

  int _selected;

  DurationPickerLogic({
    required this.format,
    required Duration minDuration,
    required Duration maxDuration,
    Duration? initialDuration,
    this.minuteInterval = 1,
    this.secondInterval = 1,
  })  : assert(minuteInterval >= 1 && 60 % minuteInterval == 0,
            'minuteInterval must be a divisor of 60'),
        assert(secondInterval >= 1 && 60 % secondInterval == 0,
            'secondInterval must be a divisor of 60'),
        assert(!minDuration.isNegative, 'minDuration cannot be negative'),
        assert(maxDuration >= minDuration,
            'maxDuration must not be shorter than minDuration'),
        units = _unitsOf(format),
        _unitSeconds = _unitSecondsOf(format),
        _steps = _stepsOf(format, minuteInterval, secondInterval),
        minSeconds = AwesomeTimeUtils.snapSecondsUp(minDuration.inSeconds,
            minuteInterval, _snapSecond(format, secondInterval)),
        maxSeconds = AwesomeTimeUtils.snapSecondsDown(maxDuration.inSeconds,
            minuteInterval, _snapSecond(format, secondInterval)),
        _selected = 0 {
    assert(minSeconds <= maxSeconds,
        'no duration is selectable between minDuration and maxDuration with these intervals');
    _selected = _clamp(initialDuration == null
        ? minSeconds
        : AwesomeTimeUtils.snapSecondsNearest(initialDuration.inSeconds,
            minuteInterval, _snapSecond(format, secondInterval)));
  }

  static List<DurationUnit> _unitsOf(AwesomeDurationFormat format) {
    switch (format) {
      case AwesomeDurationFormat.hm:
        return const [DurationUnit.hours, DurationUnit.minutes];
      case AwesomeDurationFormat.ms:
        return const [DurationUnit.minutes, DurationUnit.seconds];
      case AwesomeDurationFormat.hms:
        return const [
          DurationUnit.hours,
          DurationUnit.minutes,
          DurationUnit.seconds
        ];
    }
  }

  static List<int> _unitSecondsOf(AwesomeDurationFormat format) => [
        for (final unit in _unitsOf(format))
          switch (unit) {
            DurationUnit.hours => 3600,
            DurationUnit.minutes => 60,
            DurationUnit.seconds => 1,
          },
      ];

  static List<int> _stepsOf(AwesomeDurationFormat format, int minuteInterval,
          int secondInterval) =>
      [
        for (final unit in _unitsOf(format))
          switch (unit) {
            DurationUnit.hours => 1,
            DurationUnit.minutes => minuteInterval,
            DurationUnit.seconds => secondInterval,
          },
      ];

  /// The second grid used to snap durations: [secondInterval], or 60 (whole
  /// minutes only) when seconds are not shown.
  static int _snapSecond(AwesomeDurationFormat format, int secondInterval) =>
      format.hasSeconds ? secondInterval : 60;

  Duration get selected => Duration(seconds: _selected);

  int _clamp(int seconds) => seconds < minSeconds
      ? minSeconds
      : (seconds > maxSeconds ? maxSeconds : seconds);

  /// The value of [level] in [seconds]: the first level counts everything
  /// above its unit; the others are 0 to 59.
  int _component(int seconds, int level) {
    final count = seconds ~/ _unitSeconds[level];
    return level == 0 ? count : count % 60;
  }

  /// Whether [a] and [b] have the same values on every level above [level].
  bool _samePrefix(int a, int b, int level) {
    for (var i = 0; i < level; i++) {
      if (_component(a, i) != _component(b, i)) return false;
    }
    return true;
  }

  /// The values the wheel of [level] offers, given the other levels of the
  /// selected duration.
  List<int> valuesOf(int level) {
    final step = _steps[level];
    int lower;
    int upper;
    if (level == 0) {
      lower = _component(minSeconds, 0);
      upper = _component(maxSeconds, 0);
    } else {
      lower = _samePrefix(_selected, minSeconds, level)
          ? _component(minSeconds, level)
          : 0;
      upper = _samePrefix(_selected, maxSeconds, level)
          ? _component(maxSeconds, level)
          : ((59 ~/ step) * step);
    }
    return [for (var v = lower; v <= upper; v += step) v];
  }

  /// The labels of the wheel of [level]: the first one is not padded, the
  /// others have two digits.
  List<String> itemsOf(int level) => [
        for (final v in valuesOf(level))
          level == 0 ? '$v' : AwesomeTimeUtils.twoDigits(v),
      ];

  /// The item of the wheel of [level] that is selected.
  String selectedItemOf(int level) {
    final v = _component(_selected, level);
    return level == 0 ? '$v' : AwesomeTimeUtils.twoDigits(v);
  }

  /// Called when the user picks [item] on the wheel of [level].
  void onSelectedItemChanged(int level, String item) {
    final value = int.parse(item);
    final old = _component(_selected, level);
    _set(_selected + (value - old) * _unitSeconds[level]);
  }

  /// Selects [duration], moved onto the minute and second grid and into the
  /// limits. Does nothing if the selection is unchanged.
  void setSelectedDuration(Duration duration) {
    _set(AwesomeTimeUtils.snapSecondsNearest(duration.inSeconds, minuteInterval,
        _snapSecond(format, secondInterval)));
  }

  void _set(int seconds) {
    final next = _clamp(seconds);
    if (next == _selected) return;
    _selected = next;
    notifyListeners();
  }
}
