import 'package:awesome_datetime_picker/src/core/data/format.dart';
import 'package:awesome_datetime_picker/src/core/data/locale.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_date.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_datetime.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_time.dart';
import 'package:awesome_datetime_picker/src/core/utils/validation_utils.dart';
import 'package:awesome_datetime_picker/src/date/awesome_date_picker.dart';
import 'package:awesome_datetime_picker/src/date/awesome_date_picker_controller.dart';
import 'package:awesome_datetime_picker/src/datetime/awesome_datetime_picker_controller.dart';
import 'package:awesome_datetime_picker/src/datetime/awesome_datetime_picker_theme.dart';
import 'package:awesome_datetime_picker/src/datetime/datetime_picker_logic.dart';
import 'package:awesome_datetime_picker/src/shared/awesome_semantic_labels.dart';
import 'package:awesome_datetime_picker/src/shared/awesome_wheel_style.dart';
import 'package:awesome_datetime_picker/src/time/awesome_time_picker.dart';
import 'package:awesome_datetime_picker/src/time/awesome_time_picker_controller.dart';
import 'package:flutter/material.dart';

/// An iOS-style wheel picker for selecting a date and a time together.
///
/// ```dart
/// AwesomeDateTimePicker(
///   minDateTime: AwesomeDateTime(
///     date: AwesomeDate(year: 2025, month: 12, day: 1),
///     time: const AwesomeTime(hour: 8, minute: 0),
///   ),
///   maxDateTime: AwesomeDateTime(
///     date: AwesomeDate(year: 2025, month: 12, day: 31),
///     time: const AwesomeTime(hour: 18, minute: 0),
///   ),
///   dateFormat: AwesomeDateFormat.dMMy,
///   timeFormat: AwesomeTimeFormat.hm,
///   onChanged: (dateTime) => debugPrint('$dateTime'),
/// )
/// ```
///
/// The selectable times depend on the selected date: on the day of
/// [minDateTime] only times from its time are offered, on the day of
/// [maxDateTime] only times up to its time, and any time on days in between.
///
/// /// ## Styling
///
/// Colors and text styles follow the ambient [Theme] brightness (light or
/// dark) unless overridden. Precedence, highest first: the per-wheel
/// [ItemTheme] given through `theme`, then the options on this widget
/// (`backgroundColor`, `selectorColor`, `selectedTextStyle`, ...), then the
/// built-in defaults.
///
/// ## Changing properties after the first build
///
/// Changing [minDateTime] or [maxDateTime] rebuilds the picker's range and keeps the current selection, clamped into the new range. If the clamping changes the value, [onChanged] is called with the new one.
///
/// The `initial*` value is only read once; to move the selection later, give
/// the picker a new [Key].
class AwesomeDateTimePicker extends StatefulWidget {
  /// Creates a date-time picker. All parameters are optional.
  const AwesomeDateTimePicker({
    super.key,
    this.minDateTime,
    this.maxDateTime,
    this.initialDateTime,
    this.locale = LocaleType.en,
    this.dateFormat = AwesomeDateFormat.dMy,
    this.timeFormat = AwesomeTimeFormat.Hm,
    this.theme,
    this.onChanged,
    this.backgroundColor,
    this.fadeEffect,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.selectorColor,
    this.visibleItemCount,
    this.itemHeight,
    this.itemWidth,
    this.excludedWeekdays,
    this.showWeekday = false,
    this.showDisabledValues = false,
    this.semanticLabels,
    this.localeName,
    this.disabledTextStyle,
    this.excludedDates,
    this.selectableDayPredicate,
    this.excludedHours,
    this.minuteInterval = 1,
    this.secondInterval = 1,
    this.controller,
    this.looping = false,
    this.enableHapticFeedback = false,
    this.wheelStyle,
  })  : assert(
          minuteInterval >= 1 && 60 % minuteInterval == 0,
          'minuteInterval must be a divisor of 60 (e.g. 1, 5, 10, 15, 30)',
        ),
        assert(
          secondInterval >= 1 && 60 % secondInterval == 0,
          'secondInterval must be a divisor of 60 (e.g. 1, 5, 10, 15, 30)',
        ),
        assert(
          controller == null || initialDateTime == null,
          'Pass either controller or initialDateTime, not both: the picker '
          'starts at controller.value',
        );

  /// The minimum selectable date and time for the date-time picker (default 1/1/1900 00:00).
  final AwesomeDateTime? minDateTime;

  /// The maximum selectable date and time for the date-time picker (default 31/12/2100 23:59).
  final AwesomeDateTime? maxDateTime;

  /// The initial date and time displayed when the picker is first shown (default current date and time).
  final AwesomeDateTime? initialDateTime;

  /// The locale to use for displaying the date format (default [LocaleType.en].
  final LocaleType locale;

  /// The format of the date to be displayed in the picker (default [AwesomeDateFormat.dMy]).
  final AwesomeDateFormat dateFormat;

  /// The format of the time to be displayed in the picker (default [AwesomeTimeFormat.Hm]).
  final AwesomeTimeFormat timeFormat;

  /// The theme for customizing the appearance of the date-time picker (year, month, day, hour, minute themes).
  final AwesomeDateTimePickerTheme? theme;

  /// A callback function that is triggered when the selected date or time changes.
  final ValueChanged<AwesomeDateTime>? onChanged;

  /// The background color of the date-time picker.
  /// This value is overridden by the value passed in the theme's backgroundColor property.
  final Color? backgroundColor;

  /// The color of the selector (highlight) used in the date-time picker.
  final Color? selectorColor;

  /// A flag to indicate whether to apply a fade effect on the edges of the picker (default true).
  final bool? fadeEffect;

  /// The text style for the selected date and time.
  /// This value is overridden by the value passed in the theme's selectedTextStyle property.
  final TextStyle? selectedTextStyle;

  /// The text style for the unselected date and time.
  /// This value is overridden by the value passed in the theme's unselectedTextStyle property.
  final TextStyle? unselectedTextStyle;

  /// The number of visible items in the date-time picker at once.
  final int? visibleItemCount;

  /// The height of each item in the date-time picker.
  /// This value is overridden by the value passed in the theme's height property.
  final double? itemHeight;

  /// The width of each item in the pickers.
  /// This value is overridden by the value passed in the theme's width property.
  final double? itemWidth;

  /// Whether the wheels wrap around from the last item to the first, like the
  /// iOS picker (default false). Within the date part the year wheel never loops, and the AM/PM wheel never loops.
  final bool looping;

  /// Whether to play a light haptic tick each time dragging moves a wheel to
  /// another item (default false). Has no effect on platforms without haptics.
  final bool enableHapticFeedback;

  /// Advanced appearance of the wheels: curvature, magnification, selector
  /// shape and more. See [AwesomeWheelStyle].
  final AwesomeWheelStyle? wheelStyle;

  /// List of weekdays to exclude (1 = Monday, 7 = Sunday).
  final List<int>? excludedWeekdays;

  /// Whether the day wheel also shows the weekday, e.g. "Mon 12" (default
  /// false). The names follow [locale].
  final bool showWeekday;

  /// Whether values that cannot be selected (excluded weekdays, dates and
  /// hours) stay visible, dimmed, instead of being removed from the wheels
  /// (default false).
  ///
  /// When a drag settles on a dimmed value, the wheel moves to the nearest
  /// selectable one. Style them with [disabledTextStyle].
  final bool showDisabledValues;

  /// Text style of the dimmed values shown with [showDisabledValues]
  /// (default: the unselected style at reduced opacity). Overridden by the
  /// theme's `disabledTextStyle` of the wheel.
  final TextStyle? disabledTextStyle;

  /// The words a screen reader announces for each wheel before its value,
  /// such as "Day, 15". By default they are in the language of [locale] (or
  /// [localeName]) when it is one of the built-in languages, and in English
  /// otherwise. The properties you give replace the built-in words. See
  /// [AwesomeSemanticLabels].
  final AwesomeSemanticLabels? semanticLabels;

  /// Name of any locale known by `package:intl` (e.g. `'pt_BR'`, `'ja'`,
  /// `'ar_EG'`). It replaces [locale] and localizes the month names, the
  /// weekday names of [showWeekday], the AM/PM markers and the digits of the
  /// wheels (for locales that do not use 0-9, such as `'fa'` or `'ar_EG'`).
  ///
  /// A name `intl` has no data for falls back to the closest language, and to
  /// English if there is none. To follow the language of the app, pass
  /// `Localizations.localeOf(context).toString()`.
  final String? localeName;

  /// Specific dates that cannot be selected, e.g. public holidays or days
  /// that are fully booked. Combines with [excludedWeekdays] and
  /// [selectableDayPredicate].
  final List<AwesomeDate>? excludedDates;

  /// Decides whether a date can be selected: return false to exclude it, for
  /// example for holidays loaded from an API. Combines with
  /// [excludedWeekdays] and [excludedDates].
  ///
  /// It is called for many dates while the wheels are built, so keep it
  /// fast. Pass a stable function (a method or a top-level function rather
  /// than a new closure on every build): a different function replaces the
  /// rules and rebuilds the wheels.
  final bool Function(AwesomeDate date)? selectableDayPredicate;

  /// List of hours to exclude (0-23).
  final List<int>? excludedHours;

  /// Distance in minutes between two selectable minutes (default 1). Must be
  /// a divisor of 60, e.g. 5, 10, 15 or 30. The minimum and maximum times are
  /// moved onto this grid, and the initial time is rounded to the nearest
  /// step.
  final int minuteInterval;

  /// Distance in seconds between two selectable seconds (default 1). Must be
  /// a divisor of 60, e.g. 5, 10, 15 or 30. Only used by time formats that
  /// show a seconds wheel ([AwesomeTimeFormat.Hms] and
  /// [AwesomeTimeFormat.hms]).
  final int secondInterval;

  /// Optional controller to read and change the selected date-time from code.
  ///
  /// When given, the picker starts at `controller.value` instead of
  /// `initialDateTime` (passing both is an error), and keeps
  /// `controller.value` in sync with the wheels. See
  /// [AwesomeDateTimePickerController].
  final AwesomeDateTimePickerController? controller;

  @override
  State<AwesomeDateTimePicker> createState() => _AwesomeDateTimePickerState();
}

class _AwesomeDateTimePickerState extends State<AwesomeDateTimePicker> {
  late DateTimePickerLogic _logic;

  /// Drive the two inner pickers. Changes made by the user in a wheel travel
  /// up through these controllers into [_logic], and changes made by the
  /// public controller travel down through them.
  late final AwesomeDatePickerController _dateController;
  late AwesomeTimePickerController _timeController;

  /// Identifies the time range allowed for the selected date. The inner time
  /// picker is rebuilt (with a fresh controller) whenever it changes.
  late String _timeRangeKey;

  /// True while applying a change that did not come from the user (the public
  /// controller or an adjustment): `onChanged` stays silent.
  bool _programmatic = false;

  @override
  void initState() {
    super.initState();
    assert(
      widget.dateFormat.hasDay && widget.dateFormat.hasYear,
      'AwesomeDateTimePicker needs a date format with a day and a year wheel; '
      'use AwesomeDatePicker for formats without one',
    );
    assert(
      ValidationUtils.isValidDateTimeRange(
          minDateTime: widget.minDateTime, maxDateTime: widget.maxDateTime),
      'minDateTime must be before maxDateTime',
    );
    assert(
      ValidationUtils.isValidInitialDateTime(
          dateTime: widget.initialDateTime,
          minDateTime: widget.minDateTime,
          maxDateTime: widget.maxDateTime),
      'initialDateTime must be within minDateTime and maxDateTime range',
    );
    assert(
      ValidationUtils.hasSelectableDate(
          minDate: widget.minDateTime?.date,
          maxDate: widget.maxDateTime?.date,
          excludedWeekdays: widget.excludedWeekdays,
          excludedDates: widget.excludedDates,
          selectableDayPredicate: widget.selectableDayPredicate),
      'the exclusions leave no selectable date between minDateTime and maxDateTime',
    );
    assert(
      ValidationUtils.hasSelectableTime(excludedHours: widget.excludedHours),
      'excludedHours excludes every hour of the day',
    );
    _logic = _createLogic(
        initialDateTime: widget.controller?.value ?? widget.initialDateTime);
    _dateController =
        AwesomeDatePickerController(initialValue: _logic.selectedDateTime.date);
    _timeController =
        AwesomeTimePickerController(initialValue: _logic.selectedDateTime.time);
    _timeRangeKey = _currentTimeRangeKey;

    _logic.addListener(_onLogicChanged);
    _dateController.addListener(_onDateChanged);
    _timeController.addListener(_onTimeChanged);
    widget.controller?.addListener(_onControllerChanged);
    _publishAfterFrame();
  }

  String get _currentTimeRangeKey => '${_logic.minTime}_${_logic.maxTime}';

  @override
  void didUpdateWidget(AwesomeDateTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
      if (widget.controller != null) {
        // Adopt the value of the new controller once this frame is built.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _onControllerChanged();
        });
      }
    }

    if (oldWidget.minDateTime == widget.minDateTime &&
        oldWidget.maxDateTime == widget.maxDateTime &&
        oldWidget.minuteInterval == widget.minuteInterval &&
        oldWidget.secondInterval == widget.secondInterval &&
        oldWidget.timeFormat.hasSeconds == widget.timeFormat.hasSeconds) {
      return;
    }

    // Rebuild the logic with the new range, keeping the current selection
    // (it is clamped into the new range if needed).
    final previous = _logic.selectedDateTime;
    _logic.removeListener(_onLogicChanged);
    _logic.dispose();
    _logic = _createLogic(initialDateTime: previous);
    _logic.addListener(_onLogicChanged);
    _syncChildren();

    if (_logic.selectedDateTime != previous) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onChanged?.call(_logic.selectedDateTime);
        _publish();
      });
    }
  }

  DateTimePickerLogic _createLogic({AwesomeDateTime? initialDateTime}) {
    return DateTimePickerLogic(
      minDateTime: widget.minDateTime ??
          const AwesomeDateTime(
              date: AwesomeDate(year: 1900, month: 1, day: 1),
              time: AwesomeTime(hour: 0, minute: 0)),
      maxDateTime: widget.maxDateTime ??
          AwesomeDateTime(
              date: const AwesomeDate(year: 2100, month: 12, day: 31),
              time: AwesomeTime(
                  hour: 23,
                  minute: 59,
                  second: widget.timeFormat.hasSeconds ? 59 : 0)),
      initialDateTime: initialDateTime,
      minuteInterval: widget.minuteInterval,
      showSeconds: widget.timeFormat.hasSeconds,
      secondInterval: widget.secondInterval,
    );
  }

  /// Moves the inner pickers to the selection of [_logic].
  void _syncChildren() {
    final selected = _logic.selectedDateTime;
    final wasProgrammatic = _programmatic;
    _programmatic = true;
    try {
      _dateController.value = selected.date;

      if (_currentTimeRangeKey != _timeRangeKey) {
        // The allowed times changed, so the inner time picker is rebuilt. Give
        // it a fresh controller: pushing the time into the old one would clamp
        // it against the previous range first.
        final old = _timeController;
        old.removeListener(_onTimeChanged);
        _timeController =
            AwesomeTimePickerController(initialValue: selected.time)
              ..addListener(_onTimeChanged);
        _timeRangeKey = _currentTimeRangeKey;
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      } else {
        _timeController.value = selected.time;
      }
    } finally {
      _programmatic = wasProgrammatic;
    }
  }

  /// Writes the selection back to the public controller: it can differ from
  /// the value that was requested (clamped, rounded, moved off an exclusion).
  void _publish() {
    final controller = widget.controller;
    if (controller != null && controller.value != _logic.selectedDateTime) {
      controller.value = _logic.selectedDateTime;
    }
  }

  void _publishAfterFrame() {
    if (widget.controller == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _publish();
    });
  }

  void _onControllerChanged() {
    final value = widget.controller!.value;
    if (value == _logic.selectedDateTime) return;
    final wasProgrammatic = _programmatic;
    _programmatic = true;
    _logic.setDateTime(value);
    _programmatic = wasProgrammatic;
    _publish();
  }

  void _onDateChanged() => _logic.setDate(_dateController.value);

  void _onTimeChanged() => _logic.setTime(_timeController.value);

  void _onLogicChanged() {
    if (!_programmatic) widget.onChanged?.call(_logic.selectedDateTime);
    _syncChildren();
    _publish();
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    _logic.removeListener(_onLogicChanged);
    _logic.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Resolved here, once, so that both halves announce the same language.
    final semanticLabels = AwesomeSemanticLabels.resolve(
      locale: widget.locale,
      localeName: widget.localeName,
      custom: widget.semanticLabels,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AwesomeDatePicker(
          controller: _dateController,
          minDate: _logic.minDateTime.date,
          maxDate: _logic.maxDateTime.date,
          locale: widget.locale,
          dateFormat: widget.dateFormat,
          theme: widget.theme?.datePickerTheme,
          backgroundColor: widget.backgroundColor,
          selectorColor: widget.selectorColor,
          fadeEffect: widget.fadeEffect,
          selectedTextStyle: widget.selectedTextStyle,
          unselectedTextStyle: widget.unselectedTextStyle,
          visibleItemCount: widget.visibleItemCount,
          itemHeight: widget.itemHeight,
          itemWidth: widget.itemWidth,
          excludedWeekdays: widget.excludedWeekdays,
          showWeekday: widget.showWeekday,
          showDisabledValues: widget.showDisabledValues,
          disabledTextStyle: widget.disabledTextStyle,
          localeName: widget.localeName,
          semanticLabels: semanticLabels,
          excludedDates: widget.excludedDates,
          selectableDayPredicate: widget.selectableDayPredicate,
          looping: widget.looping,
          enableHapticFeedback: widget.enableHapticFeedback,
          wheelStyle: widget.wheelStyle,
        ),
        AwesomeTimePicker(
          // The key changes when the allowed times change, to force a rebuild
          key: ValueKey(_timeRangeKey),
          controller: _timeController,
          minTime: _logic.minTime,
          maxTime: _logic.maxTime,
          timeFormat: widget.timeFormat,
          theme: widget.theme?.timePickerTheme,
          backgroundColor: widget.backgroundColor,
          selectorColor: widget.selectorColor,
          fadeEffect: widget.fadeEffect,
          selectedTextStyle: widget.selectedTextStyle,
          unselectedTextStyle: widget.unselectedTextStyle,
          visibleItemCount: widget.visibleItemCount,
          itemHeight: widget.itemHeight,
          itemWidth: widget.itemWidth,
          excludedHours: widget.excludedHours,
          minuteInterval: widget.minuteInterval,
          secondInterval: widget.secondInterval,
          showDisabledValues: widget.showDisabledValues,
          disabledTextStyle: widget.disabledTextStyle,
          localeName: widget.localeName,
          semanticLabels: semanticLabels,
          looping: widget.looping,
          enableHapticFeedback: widget.enableHapticFeedback,
          wheelStyle: widget.wheelStyle,
        ),
      ],
    );
  }
}
