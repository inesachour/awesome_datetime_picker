import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/datetime/awesome_datetime_picker_controller.dart';
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
    this.excludedHours,
  });

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

  /// List of weekdays to exclude (1 = Monday, 7 = Sunday).
  final List<int>? excludedWeekdays;

  /// List of hours to exclude (0-23).
  final List<int>? excludedHours;

  @override
  State<AwesomeDateTimePicker> createState() => _AwesomeDateTimePickerState();
}

class _AwesomeDateTimePickerState extends State<AwesomeDateTimePicker> {
  late final AwesomeDateTimePickerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _createController(initialDateTime: widget.initialDateTime);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(AwesomeDateTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.minDateTime == widget.minDateTime &&
        oldWidget.maxDateTime == widget.maxDateTime) {
      return;
    }

    // Rebuild the controller with the new range, keeping the current
    // selection (it is clamped into the new range if needed).
    final previous = _controller.selectedDateTime;
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _controller = _createController(initialDateTime: previous);
    _controller.addListener(_onControllerChanged);

    if (_controller.selectedDateTime != previous) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onChanged?.call(_controller.selectedDateTime);
      });
    }
  }

  AwesomeDateTimePickerController _createController(
      {AwesomeDateTime? initialDateTime}) {
    return AwesomeDateTimePickerController(
      minDateTime: widget.minDateTime ??
          AwesomeDateTime(
              date: AwesomeDate(year: 1900, month: 1, day: 1),
              time: const AwesomeTime(hour: 0, minute: 0)),
      maxDateTime: widget.maxDateTime ??
          AwesomeDateTime(
              date: AwesomeDate(year: 2100, month: 12, day: 31),
              time: const AwesomeTime(hour: 23, minute: 59)),
      initialDateTime: initialDateTime,
    );
  }

  void _onControllerChanged() {
    widget.onChanged?.call(_controller.selectedDateTime);
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
      children: [
        AwesomeDatePicker(
          initialDate: _controller.selectedDateTime.date,
          minDate: _controller.minDateTime.date,
          maxDate: _controller.maxDateTime.date,
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
          onChanged: (date) {
            _controller.setDate(date);
          },
        ),
        AwesomeTimePicker(
          // Add a key that changes when min/max time changes to force rebuild
          key: ValueKey(
              "${_controller.minTime.toString()}_${_controller.maxTime.toString()}"),
          initialTime: _controller.selectedDateTime.time,
          minTime: _controller.minTime,
          maxTime: _controller.maxTime,
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
          onChanged: (time) {
            _controller.setTime(time);
          },
        ),
      ],
    );
  }
}
