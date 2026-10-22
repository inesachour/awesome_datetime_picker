import 'package:awesome_datetime_picker/src/time/awesome_time_picker_controller.dart';
import 'package:awesome_datetime_picker/src/core/data/format.dart';
import 'package:awesome_datetime_picker/src/core/data/picker_type.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_time.dart';
import 'package:awesome_datetime_picker/src/time/awesome_time_picker_theme.dart';
import 'package:awesome_datetime_picker/src/shared/item_theme.dart';
import 'package:awesome_datetime_picker/src/core/utils/awesome_time_utils.dart';
import 'package:awesome_datetime_picker/src/core/utils/validation_utils.dart';
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
  }) : assert(
          ValidationUtils.isValidTimeRange(minTime: minTime, maxTime: maxTime),
          'minTime must be before maxTime',
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

  @override
  State<AwesomeTimePicker> createState() => _AwesomeTimePickerState();
}

class _AwesomeTimePickerState extends State<AwesomeTimePicker> {
  late AwesomeTimePickerController _controller;

  AwesomeTime get _minTime =>
      widget.minTime ?? const AwesomeTime(hour: 0, minute: 0);
  AwesomeTime get _maxTime =>
      widget.maxTime ?? const AwesomeTime(hour: 23, minute: 59);

  @override
  void initState() {
    super.initState();

    final initialTime = widget.initialTime ??
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

    _controller = _createController(initialTime: initialTime);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(AwesomeTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    final configChanged = oldWidget.minTime != widget.minTime ||
        oldWidget.maxTime != widget.maxTime ||
        !listEquals(oldWidget.excludedHours, widget.excludedHours);
    if (!configChanged) return;

    // Rebuild the controller with the new rules, keeping the current
    // selection (it is clamped into the new range if needed).
    final previous = _controller.selectedTime;
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _controller = _createController(initialTime: previous);
    _controller.addListener(_onControllerChanged);

    if (_controller.selectedTime != previous) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onChanged?.call(_controller.selectedTime);
      });
    }
  }

  AwesomeTimePickerController _createController(
      {required AwesomeTime initialTime}) {
    return AwesomeTimePickerController(
      minTime: _minTime,
      maxTime: _maxTime,
      initialTime: initialTime,
      excludedHours: widget.excludedHours,
    );
  }

  void _onControllerChanged() {
    widget.onChanged?.call(_controller.selectedTime);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
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
          key: ValueKey(_controller.selectedAmPm == AwesomeTimeUtils.amPm[0]
              ? "hour_picker 1"
              : "hour_picker 2"),
          items: _controller.amPmHours,
          initialValue: AwesomeTimeUtils.convertTo12HourFormat(
                  _controller.selectedTime.hour)
              .toString(),
          theme: widget.theme?.hourTheme,
          onChanged: _controller.onSelectedAmPmHourChanged,
        );
      case PickerType.hour_24:
        return _buildItemPicker(
          items: _controller.hours,
          initialValue: _controller.selectedTime.hour.toString(),
          theme: widget.theme?.hourTheme,
          onChanged: _controller.onSelectedHourChanged,
        );
      case PickerType.minute:
        return _buildItemPicker(
          key:
              ValueKey(_controller.selectedTime.hour == _controller.minTime.hour
                  ? "minute_picker 1"
                  : _controller.selectedTime.hour == _controller.maxTime.hour
                      ? "minute_picker 2"
                      : "minute_picker 3"),
          items: _controller.minutes,
          initialValue: _controller.selectedTime.minute.toString(),
          theme: widget.theme?.minuteTheme,
          onChanged: _controller.onSelectedMinuteChanged,
        );
      case PickerType.am_pm:
        return _buildItemPicker(
          items: _controller.amPm,
          initialValue: _controller.selectedAmPm,
          // Falls back to the hour theme so existing styling keeps applying.
          theme: widget.theme?.ampmTheme ?? widget.theme?.hourTheme,
          onChanged: _controller.onSelectedAmPmChanged,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildItemPicker({
    Key? key,
    required List<String> items,
    required String initialValue,
    required ItemTheme? theme,
    required ValueChanged<String> onChanged,
  }) {
    return buildPickerWheel(
      key: key,
      items: items,
      value: initialValue,
      theme: theme,
      style: CustomItemPickerStyle(
        backgroundColor: widget.backgroundColor,
        selectorColor: widget.selectorColor,
        fadeEffect: widget.fadeEffect,
        selectedTextStyle: widget.selectedTextStyle,
        unselectedTextStyle: widget.unselectedTextStyle,
        itemHeight: widget.itemHeight,
        itemWidth: widget.itemWidth,
      ),
      visibleItemCount: widget.visibleItemCount,
      onChanged: onChanged,
    );
  }
}
