import 'package:awesome_datetime_picker/src/controllers/awesome_time_picker_controller.dart';
import 'package:awesome_datetime_picker/src/data/format.dart';
import 'package:awesome_datetime_picker/src/data/picker_type.dart';
import 'package:awesome_datetime_picker/src/models/awesome_time.dart';
import 'package:awesome_datetime_picker/src/theme/awesome_time_picker_theme.dart';
import 'package:awesome_datetime_picker/src/utils/awesome_time_utils.dart';
import 'package:awesome_datetime_picker/src/utils/validation_utils.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/custom_item_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeTimePicker extends StatefulWidget {
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
  })  : assert(
          ValidationUtils.isValidTimeRange(minTime: minTime, maxTime: maxTime),
          'minTime must be before maxTime',
        ),
        assert(
          ValidationUtils.isValidInitialTime(
              time: initialTime, minTime: minTime, maxTime: maxTime),
          'initialTime must be within minTime and maxTime range',
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

  @override
  State<AwesomeTimePicker> createState() => _AwesomeTimePickerState();
}

class _AwesomeTimePickerState extends State<AwesomeTimePicker> {
  late final AwesomeTimePickerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AwesomeTimePickerController(
      minTime: widget.minTime ?? AwesomeTime(hour: 00, minute: 00),
      maxTime: widget.maxTime ?? AwesomeTime(hour: 23, minute: 59),
      initialTime: widget.initialTime ??
          AwesomeTime(
              hour: TimeOfDay.now().hour, minute: TimeOfDay.now().minute),
    );

    _controller.addListener(() {
      widget.onChanged?.call(_controller.selectedTime);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.timeFormat.value.length, (index) {
        if (widget.timeFormat.value[index] == PickerType.hour_12) {
          return CustomItemPicker(
            key: ValueKey(_controller.selectedAmPm == AwesomeTimeUtils.amPm[0]
                ? "hour_picker 1"
                : "hour_picker 2"),
            items: _controller.amPmHours,
            initialIndex: _controller.amPmHours.indexOf(
                AwesomeTimeUtils.convertTo12HourFormat(
                        _controller.selectedTime.hour)
                    .toString()),
            theme: widget.theme?.minuteTheme,
            backgroundColor: widget.backgroundColor,
            selectorColor: widget.selectorColor,
            fadeEffect: widget.fadeEffect,
            selectedTextStyle: widget.selectedTextStyle,
            unselectedTextStyle: widget.unselectedTextStyle,
            visibleItemCount: widget.visibleItemCount,
            itemHeight: widget.itemHeight,
            itemWidth: widget.itemWidth,
            onSelectedItemChanged: (index) {
              _controller.selectedTime = AwesomeTime(
                  hour: AwesomeTimeUtils.convertTo24HourFormat(
                      index == 0 ? 12 : index, _controller.selectedAmPm),
                  minute: _controller.selectedTime.minute);

              DateTime nativeSelectedTime = DateTime(
                  2025,
                  1,
                  1,
                  _controller.selectedTime.hour,
                  _controller.selectedTime.minute);
              if (nativeSelectedTime.isBefore(DateTime(2025, 1, 1,
                  _controller.minTime.hour, _controller.minTime.minute))) {
                _controller.selectedTime = _controller.minTime;
              } else if (nativeSelectedTime.isAfter(DateTime(2025, 1, 1,
                  _controller.maxTime.hour, _controller.maxTime.minute))) {
                _controller.selectedTime = _controller.maxTime;
              }
              setState(() {});

              widget.onChanged?.call(_controller.selectedTime);
            },
          );
        } else if (widget.timeFormat.value[index] == PickerType.hour_24) {
          return CustomItemPicker(
            items: _controller.hours,
            initialIndex: _controller.hours
                .indexOf(_controller.selectedTime.hour.toString()),
            theme: widget.theme?.hourTheme,
            backgroundColor: widget.backgroundColor,
            selectorColor: widget.selectorColor,
            fadeEffect: widget.fadeEffect,
            selectedTextStyle: widget.selectedTextStyle,
            unselectedTextStyle: widget.unselectedTextStyle,
            visibleItemCount: widget.visibleItemCount,
            itemHeight: widget.itemHeight,
            itemWidth: widget.itemWidth,
            onSelectedItemChanged: (index) {
              _controller.selectedTime = AwesomeTime(
                  hour: index, minute: _controller.selectedTime.minute);

              DateTime nativeSelectedTime = DateTime(
                  2025,
                  1,
                  1,
                  _controller.selectedTime.hour,
                  _controller.selectedTime.minute);
              if (nativeSelectedTime.isBefore(DateTime(2025, 1, 1,
                  _controller.minTime.hour, _controller.minTime.minute))) {
                _controller.selectedTime = _controller.minTime;
              } else if (nativeSelectedTime.isAfter(DateTime(2025, 1, 1,
                  _controller.maxTime.hour, _controller.maxTime.minute))) {
                _controller.selectedTime = _controller.maxTime;
              }
              setState(() {});

              widget.onChanged?.call(_controller.selectedTime);
            },
          );
        } else if (widget.timeFormat.value[index] == PickerType.minute) {
          return CustomItemPicker(
            key: ValueKey(
                _controller.selectedTime.hour == _controller.minTime.hour
                    ? "minute_picker 1"
                    : _controller.selectedTime.hour == _controller.maxTime.hour
                        ? "minute_picker 2"
                        : "minute_picker 3"),
            items: _controller.minutes,
            initialIndex: _controller.minutes
                .indexOf(_controller.selectedTime.minute.toString()),
            theme: widget.theme?.minuteTheme,
            backgroundColor: widget.backgroundColor,
            selectorColor: widget.selectorColor,
            fadeEffect: widget.fadeEffect,
            selectedTextStyle: widget.selectedTextStyle,
            unselectedTextStyle: widget.unselectedTextStyle,
            visibleItemCount: widget.visibleItemCount,
            itemHeight: widget.itemHeight,
            itemWidth: widget.itemWidth,
            onSelectedItemChanged: (index) {
              _controller.selectedTime = AwesomeTime(
                  hour: _controller.selectedTime.hour, minute: index);

              DateTime nativeSelectedTime = DateTime(
                  2025,
                  1,
                  1,
                  _controller.selectedTime.hour,
                  _controller.selectedTime.minute);
              if (nativeSelectedTime.isBefore(DateTime(2025, 1, 1,
                  _controller.minTime.hour, _controller.minTime.minute))) {
                _controller.selectedTime = _controller.minTime;
              } else if (nativeSelectedTime.isAfter(DateTime(2025, 1, 1,
                  _controller.maxTime.hour, _controller.maxTime.minute))) {
                _controller.selectedTime = _controller.maxTime;
              }
              setState(() {});

              widget.onChanged?.call(_controller.selectedTime);
            },
          );
        } else if (widget.timeFormat.value[index] == PickerType.am_pm) {
          return CustomItemPicker(
            items: AwesomeTimeUtils.amPm,
            initialIndex:
                AwesomeTimeUtils.amPm.indexOf(_controller.selectedAmPm),
            theme: widget.theme?.minuteTheme,
            backgroundColor: widget.backgroundColor,
            selectorColor: widget.selectorColor,
            fadeEffect: widget.fadeEffect,
            selectedTextStyle: widget.selectedTextStyle,
            unselectedTextStyle: widget.unselectedTextStyle,
            visibleItemCount: widget.visibleItemCount,
            itemHeight: widget.itemHeight,
            itemWidth: widget.itemWidth,
            onSelectedItemChanged: (index) {
              _controller.selectedAmPm = AwesomeTimeUtils.amPm[index];
              _controller.selectedTime.hour =
                  AwesomeTimeUtils.toggleAmPm(_controller.selectedTime.hour);
              setState(() {});

              widget.onChanged?.call(_controller.selectedTime);
            },
          );
        } else {
          return Container();
        }
      }),
    );
  }
}
