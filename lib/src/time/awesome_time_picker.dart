import 'package:awesome_datetime_picker/src/time/awesome_time_picker_controller.dart';
import 'package:awesome_datetime_picker/src/time/time_picker_logic.dart';
import 'package:awesome_datetime_picker/src/core/data/format.dart';
import 'package:awesome_datetime_picker/src/core/data/locale.dart';
import 'package:awesome_datetime_picker/src/core/data/picker_type.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_time.dart';
import 'package:awesome_datetime_picker/src/time/awesome_time_picker_theme.dart';
import 'package:awesome_datetime_picker/src/shared/item_theme.dart';
import 'package:awesome_datetime_picker/src/core/utils/awesome_intl.dart';
import 'package:awesome_datetime_picker/src/core/utils/awesome_time_utils.dart';
import 'package:awesome_datetime_picker/src/core/utils/validation_utils.dart';
import 'package:awesome_datetime_picker/src/shared/awesome_semantic_labels.dart';
import 'package:awesome_datetime_picker/src/shared/awesome_wheel_style.dart';
import 'package:awesome_datetime_picker/src/shared/custom_item_picker_style.dart';
import 'package:awesome_datetime_picker/src/shared/picker_wheel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// An iOS-style wheel picker for selecting a time of day.
///
/// ```dart
/// AwesomeTimePicker(
///   timeFormat: AwesomeTimeFormat.hm, // 12-hour clock with AM/PM
///   minTime: const AwesomeTime(hour: 8, minute: 0),
///   maxTime: const AwesomeTime(hour: 18, minute: 30),
///   excludedHours: [12, 13], // lunch break
///   onChanged: (time) => debugPrint('$time'),
/// )
/// ```
///
/// The value reported to [onChanged] is always on a 24-hour clock, whatever
/// [timeFormat] displays. The wheels only offer times between [minTime] and
/// [maxTime] that are not in [excludedHours].
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
/// Changing [minTime], [maxTime] or [excludedHours] rebuilds the picker's rules and keeps the current selection, clamped into the new range. If the clamping changes the value, [onChanged] is called with the new one.
///
/// The `initial*` value is only read once; to move the selection later, give
/// the picker a new [Key].
///
/// Throws an [AssertionError] in debug mode if [minTime] is after [maxTime].
class AwesomeTimePicker extends StatefulWidget {
  /// Creates a time picker. All parameters are optional.
  AwesomeTimePicker({
    super.key,
    this.minTime,
    this.maxTime,
    this.initialTime,
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
    this.excludedHours,
    this.minuteInterval = 1,
    this.showDisabledValues = false,
    this.semanticLabels,
    this.localeName,
    this.disabledTextStyle,
    this.secondInterval = 1,
    this.controller,
    this.looping = false,
    this.enableHapticFeedback = false,
    this.wheelStyle,
  })  : assert(
          ValidationUtils.isValidTimeRange(minTime: minTime, maxTime: maxTime),
          'minTime must be before maxTime',
        ),
        assert(
          ValidationUtils.hasSelectableTime(
              minTime: minTime, maxTime: maxTime, excludedHours: excludedHours),
          'excludedHours excludes every hour between minTime and maxTime',
        ),
        assert(
          minuteInterval >= 1 && 60 % minuteInterval == 0,
          'minuteInterval must be a divisor of 60 (e.g. 1, 5, 10, 15, 30)',
        ),
        assert(
          secondInterval >= 1 && 60 % secondInterval == 0,
          'secondInterval must be a divisor of 60 (e.g. 1, 5, 10, 15, 30)',
        ),
        assert(
          controller == null || initialTime == null,
          'Pass either controller or initialTime, not both: the picker starts '
          'at controller.value',
        );

  /// The minimum selectable time for the time picker (default 00:00).
  final AwesomeTime? minTime;

  /// The maximum selectable time for the time picker (default 23:59).
  final AwesomeTime? maxTime;

  /// The initial time displayed when the picker is first shown (default current time).
  final AwesomeTime? initialTime;

  /// The format of the time to be displayed in the picker (default [AwesomeTimeFormat.Hm]).
  final AwesomeTimeFormat timeFormat;

  /// The theme for customizing the appearance of the time picker (hour, minute themes).
  final AwesomeTimePickerTheme? theme;

  /// A callback function that is triggered when the selected time changes.
  final ValueChanged<AwesomeTime>? onChanged;

  /// The background color of the time picker.
  /// This value is overridden by the value passed in the theme's backgroundColor property.
  final Color? backgroundColor;

  /// The color of the selector (highlight) used in the time picker.
  final Color? selectorColor;

  /// A flag to indicate whether to apply a fade effect on the edges of the time picker (default true).
  final bool? fadeEffect;

  /// The text style for the selected time (customize font, size, color, etc.).
  /// This value is overridden by the value passed in the theme's selectedTextStyle property.
  final TextStyle? selectedTextStyle;

  /// The text style for the unselected times (customize font, size, color, etc.).
  /// This value is overridden by the value passed in the theme's unselectedTextStyle property.
  final TextStyle? unselectedTextStyle;

  /// The number of visible items in the time picker at once.
  final int? visibleItemCount;

  /// The height of each item in the time picker.
  /// This value is overridden by the value passed in the theme's height property.
  final double? itemHeight;

  /// The width of each item in the time picker.
  /// This value is overridden by the value passed in the theme's width property.
  final double? itemWidth;

  /// List of hours to exclude (0-23).
  final List<int>? excludedHours;

  /// Whether values that cannot be selected (excluded hours) stay visible, dimmed,
  /// instead of being removed from the wheels (default false).
  ///
  /// When a drag settles on a dimmed value, the wheel moves to the nearest
  /// selectable one. Style them with [disabledTextStyle].
  final bool showDisabledValues;

  /// Text style of the dimmed values shown with [showDisabledValues]
  /// (default: the unselected style at reduced opacity). Overridden by the
  /// theme's `disabledTextStyle` of the wheel.
  final TextStyle? disabledTextStyle;

  /// The words a screen reader announces for each wheel before its value,
  /// such as "Day, 15". By default they are in the language of [localeName] when
  /// it is one of the built-in languages, and in English otherwise. The
  /// properties you give replace the built-in words. See
  /// [AwesomeSemanticLabels].
  final AwesomeSemanticLabels? semanticLabels;

  /// Name of any locale known by `package:intl` (e.g. `'ja'`, `'ar'`,
  /// `'fa'`). It localizes the AM/PM markers of the 12-hour formats and the
  /// digits of the wheels (for locales that do not use 0-9, such as `'fa'` or
  /// `'ar_EG'`).
  ///
  /// A name `intl` has no data for falls back to the closest language, and to
  /// English if there is none. To follow the language of the app, pass
  /// `Localizations.localeOf(context).toString()`.
  final String? localeName;

  /// Distance in minutes between two selectable minutes (default 1). Must be
  /// a divisor of 60, e.g. 5, 10, 15 or 30. The minimum and maximum times are
  /// moved onto this grid, and the initial time is rounded to the nearest
  /// step.
  final int minuteInterval;

  /// Distance in seconds between two selectable seconds (default 1). Must be
  /// a divisor of 60, e.g. 5, 10, 15 or 30. Only used by formats that show a
  /// seconds wheel ([AwesomeTimeFormat.Hms] and [AwesomeTimeFormat.hms]).
  final int secondInterval;

  /// Optional controller to read and change the selected time from code.
  ///
  /// When given, the picker starts at `controller.value` instead of `initialTime`
  /// (passing both is an error), and keeps `controller.value` in sync with
  /// the wheels. See [AwesomeTimePickerController].
  final AwesomeTimePickerController? controller;

  /// Whether the wheels wrap around from the last item to the first, like the
  /// iOS picker (default false). The AM/PM wheel never loops.
  final bool looping;

  /// Whether to play a light haptic tick each time dragging moves a wheel to
  /// another item (default false). Has no effect on platforms without haptics.
  final bool enableHapticFeedback;

  /// Advanced appearance of the wheels: curvature, magnification, selector
  /// shape and more. See [AwesomeWheelStyle].
  final AwesomeWheelStyle? wheelStyle;

  @override
  State<AwesomeTimePicker> createState() => _AwesomeTimePickerState();
}

class _AwesomeTimePickerState extends State<AwesomeTimePicker> {
  late TimePickerLogic _logic;

  /// True while applying a change that came from the public controller: the
  /// user did not edit anything, so `onChanged` stays silent.
  bool _applyingController = false;

  /// The `intl` locale used for [AwesomeTimePicker.localeName], if any, and
  /// the glyphs of its digits when they are not 0-9.
  String? _intlLocale;
  List<String>? _digitGlyphs;

  void _resolveLocale() {
    final name = widget.localeName;
    _intlLocale = name == null ? null : AwesomeIntl.resolve(name);
    _digitGlyphs =
        _intlLocale == null ? null : AwesomeIntl.digitGlyphs(_intlLocale!);
  }

  AwesomeTime get _minTime =>
      widget.minTime ?? const AwesomeTime(hour: 0, minute: 0);
  AwesomeTime get _maxTime =>
      widget.maxTime ??
      AwesomeTime(
          hour: 23, minute: 59, second: widget.timeFormat.hasSeconds ? 59 : 0);

  @override
  void initState() {
    super.initState();
    _resolveLocale();

    final initialTime = widget.controller?.value ??
        widget.initialTime ??
        AwesomeTime(hour: TimeOfDay.now().hour, minute: TimeOfDay.now().minute);

    // Debug warning for invalid initial time
    assert(() {
      if (!ValidationUtils.isValidInitialTime(
          time: initialTime, minTime: _minTime, maxTime: _maxTime)) {
        debugPrint(
          '⚠️ AwesomeTimePicker: initialTime ($initialTime) is outside the valid range '
          '(minTime: $_minTime, maxTime: $_maxTime). '
          'The time will be automatically clamped to the valid range.',
        );
      }
      return true;
    }());

    _logic = _createLogic(initialTime: initialTime);
    _logic.addListener(_onLogicChanged);
    widget.controller?.addListener(_onControllerChanged);
    _publishAfterFrame();
  }

  @override
  void didUpdateWidget(AwesomeTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localeName != widget.localeName) _resolveLocale();

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

    final configChanged = oldWidget.minTime != widget.minTime ||
        oldWidget.maxTime != widget.maxTime ||
        oldWidget.minuteInterval != widget.minuteInterval ||
        oldWidget.secondInterval != widget.secondInterval ||
        oldWidget.timeFormat.hasSeconds != widget.timeFormat.hasSeconds ||
        !listEquals(oldWidget.excludedHours, widget.excludedHours);
    if (!configChanged) return;

    // Rebuild the logic with the new rules, keeping the current selection
    // (it is clamped into the new range if needed).
    final previous = _logic.selectedTime;
    _logic.removeListener(_onLogicChanged);
    _logic.dispose();
    _logic = _createLogic(initialTime: previous);
    _logic.addListener(_onLogicChanged);

    if (_logic.selectedTime != previous) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onChanged?.call(_logic.selectedTime);
        _publish();
      });
    }
  }

  TimePickerLogic _createLogic({required AwesomeTime initialTime}) {
    return TimePickerLogic(
      minTime: _minTime,
      maxTime: _maxTime,
      initialTime: initialTime,
      excludedHours: widget.excludedHours,
      minuteInterval: widget.minuteInterval,
      showSeconds: widget.timeFormat.hasSeconds,
      secondInterval: widget.secondInterval,
    );
  }

  /// Writes the selection back to the controller: it can differ from the value
  /// that was requested (clamped into the range, moved off an excluded hour,
  /// rounded to the minute interval).
  void _publish() {
    final controller = widget.controller;
    if (controller != null && controller.value != _logic.selectedTime) {
      controller.value = _logic.selectedTime;
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
    if (value == _logic.selectedTime) return;
    _applyingController = true;
    _logic.setSelectedTime(value);
    _applyingController = false;
    _publish();
  }

  void _onLogicChanged() {
    if (!_applyingController) widget.onChanged?.call(_logic.selectedTime);
    _publish();
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    _logic.removeListener(_onLogicChanged);
    _logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.timeFormat.value.length, (index) {
        final type = widget.timeFormat.value[index];
        return _buildPicker(type);
      }),
    );
  }

  Widget _buildPicker(PickerType type) {
    switch (type) {
      case PickerType.hour_12:
        return _buildItemPicker(
          key: ValueKey(_logic.selectedAmPm == AwesomeTimeUtils.amPm[0]
              ? "hour_picker 1"
              : "hour_picker 2"),
          items: widget.showDisabledValues
              ? _logic.allAmPmHours
              : _logic.amPmHours,
          disabledIndices: widget.showDisabledValues
              ? _logic.disabledAmPmHourIndices
              : const {},
          initialValue:
              AwesomeTimeUtils.convertTo12HourFormat(_logic.selectedTime.hour)
                  .toString(),
          theme: widget.theme?.hourTheme,
          onChanged: _logic.onSelectedAmPmHourChanged,
          canLoop: true,
          semanticLabel: _semanticLabels.hour,
        );
      case PickerType.hour_24:
        return _buildItemPicker(
          items: widget.showDisabledValues ? _logic.allHours : _logic.hours,
          disabledIndices:
              widget.showDisabledValues ? _logic.disabledHourIndices : const {},
          initialValue: AwesomeTimeUtils.twoDigits(_logic.selectedTime.hour),
          theme: widget.theme?.hourTheme,
          onChanged: _logic.onSelectedHourChanged,
          canLoop: true,
          semanticLabel: _semanticLabels.hour,
        );
      case PickerType.minute:
        return _buildItemPicker(
          key: ValueKey(_logic.selectedTime.hour == _logic.minTime.hour
              ? "minute_picker 1"
              : _logic.selectedTime.hour == _logic.maxTime.hour
                  ? "minute_picker 2"
                  : "minute_picker 3"),
          items: _logic.minutes,
          initialValue: AwesomeTimeUtils.twoDigits(_logic.selectedTime.minute),
          theme: widget.theme?.minuteTheme,
          onChanged: _logic.onSelectedMinuteChanged,
          canLoop: true,
          semanticLabel: _semanticLabels.minute,
        );
      case PickerType.second:
        return _buildItemPicker(
          key: ValueKey(_logic.selectedTime.hour == _logic.minTime.hour &&
                  _logic.selectedTime.minute == _logic.minTime.minute
              ? "second_picker 1"
              : _logic.selectedTime.hour == _logic.maxTime.hour &&
                      _logic.selectedTime.minute == _logic.maxTime.minute
                  ? "second_picker 2"
                  : "second_picker 3"),
          items: _logic.seconds,
          initialValue: AwesomeTimeUtils.twoDigits(_logic.selectedTime.second),
          // Falls back to the minute theme so one theme styles both.
          theme: widget.theme?.secondTheme ?? widget.theme?.minuteTheme,
          onChanged: _logic.onSelectedSecondChanged,
          canLoop: true,
          semanticLabel: _semanticLabels.second,
        );
      case PickerType.am_pm:
        return _buildItemPicker(
          items: _logic.amPm,
          labels: _amPmLabels(_logic.amPm),
          initialValue: _logic.selectedAmPm,
          // Falls back to the hour theme so existing styling keeps applying.
          theme: widget.theme?.ampmTheme ?? widget.theme?.hourTheme,
          onChanged: _logic.onSelectedAmPmChanged,
          semanticLabel: _semanticLabels.amPm,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  AwesomeSemanticLabels get _semanticLabels => AwesomeSemanticLabels.resolve(
        locale: LocaleType.en,
        localeName: widget.localeName,
        custom: widget.semanticLabels,
      );

  /// Localized AM/PM markers for the AM/PM wheel items, or null without a
  /// `localeName`.
  List<String>? _amPmLabels(List<String> items) {
    final locale = _intlLocale;
    if (locale == null) return null;
    final labels = AwesomeIntl.amPmLabels(locale);
    return [for (final item in items) item == 'AM' ? labels[0] : labels[1]];
  }

  /// Labels showing the digits of [items] in the locale's own digits, or null
  /// when they are the usual 0-9.
  List<String>? _localizedDigits(List<String> items) {
    final glyphs = _digitGlyphs;
    if (glyphs == null) return null;
    return [for (final item in items) AwesomeIntl.localizeDigits(item, glyphs)];
  }

  Widget _buildItemPicker({
    Key? key,
    required List<String> items,
    List<String>? labels,
    required String initialValue,
    required ItemTheme? theme,
    required ValueChanged<String> onChanged,
    bool canLoop = false,
    Set<int> disabledIndices = const {},
    String? semanticLabel,
  }) {
    return buildPickerWheel(
      key: key,
      items: items,
      labels: labels ?? _localizedDigits(items),
      disabledIndices: disabledIndices,
      value: initialValue,
      theme: theme,
      style: CustomItemPickerStyle(
        backgroundColor: widget.backgroundColor,
        selectorColor: widget.selectorColor,
        fadeEffect: widget.fadeEffect,
        selectedTextStyle: widget.selectedTextStyle,
        unselectedTextStyle: widget.unselectedTextStyle,
        disabledTextStyle: widget.disabledTextStyle,
        itemHeight: widget.itemHeight,
        itemWidth: widget.itemWidth,
        wheelStyle: widget.wheelStyle,
      ),
      visibleItemCount: widget.visibleItemCount,
      onChanged: onChanged,
      looping: canLoop && widget.looping,
      hapticFeedback: widget.enableHapticFeedback,
      semanticLabel: semanticLabel,
    );
  }
}
