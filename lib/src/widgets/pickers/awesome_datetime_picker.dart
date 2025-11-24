import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/controllers/awesome_datetime_picker_controller.dart';
import 'package:flutter/material.dart';

class AwesomeDateTimePicker extends StatefulWidget {
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

    _controller = AwesomeDateTimePickerController(
      minDateTime: widget.minDateTime ??
          AwesomeDateTime(
              date: AwesomeDate(year: 1900, month: 1, day: 1),
              time: const AwesomeTime(hour: 0, minute: 0)),
      maxDateTime: widget.maxDateTime ??
          AwesomeDateTime(
              date: AwesomeDate(year: 2100, month: 12, day: 31),
              time: const AwesomeTime(hour: 23, minute: 59)),
      initialDateTime: widget.initialDateTime,
    );

    _controller.addListener(() {
      widget.onChanged?.call(_controller.selectedDateTime);
      setState(() {});
    });
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
