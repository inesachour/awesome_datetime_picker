import 'package:awesome_datetime_picker/src/controllers/awesome_time_picker_controller.dart';
import 'package:awesome_datetime_picker/src/data/format.dart';
import 'package:awesome_datetime_picker/src/data/picker_type.dart';
import 'package:awesome_datetime_picker/src/models/awesome_time.dart';
import 'package:awesome_datetime_picker/src/theme/awesome_time_picker_theme.dart';
import 'package:awesome_datetime_picker/src/utils/awesome_time_utils.dart';
import 'package:awesome_datetime_picker/src/utils/validation_utils.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/custom_item_picker_style.dart';
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
  late final AwesomeTimePickerController _controller;

  @override
  void initState() {
    super.initState();

    final minTime = widget.minTime ?? const AwesomeTime(hour: 0, minute: 0);
    final maxTime = widget.maxTime ?? const AwesomeTime(hour: 23, minute: 59);
    final initialTime = widget.initialTime ??
        AwesomeTime(hour: TimeOfDay.now().hour, minute: TimeOfDay.now().minute);

    // Debug warning for invalid initial time
    assert(() {
      if (!ValidationUtils.isValidInitialTime(
          time: initialTime, minTime: minTime, maxTime: maxTime)) {
        debugPrint(
          '⚠️ AwesomeTimePicker: initialTime ($initialTime) is outside the valid range '
          '(minTime: $minTime, maxTime: $maxTime). '
          'The time will be automatically clamped to the valid range.',
        );
      }
      return true;
    }());

    _controller = AwesomeTimePickerController(
      minTime: minTime,
      maxTime: maxTime,
      initialTime: initialTime,
      excludedHours: widget.excludedHours,
    );

    _controller.addListener(() {
      widget.onChanged?.call(_controller.selectedTime);
      // setState(() {}); // Removed redundant setState
    });
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
        return _buildHour12Picker();
      case PickerType.hour_24:
        return _buildHour24Picker();
      case PickerType.minute:
        return _buildMinutePicker();
      case PickerType.am_pm:
        return _buildAmPmPicker();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHour12Picker() {
    return CustomItemPicker(
      key: ValueKey(_controller.selectedAmPm == AwesomeTimeUtils.amPm[0]
          ? "hour_picker 1"
          : "hour_picker 2"),
      items: _controller.amPmHours,
      initialIndex: _controller.amPmHours.indexOf(
          AwesomeTimeUtils.convertTo12HourFormat(_controller.selectedTime.hour)
              .toString()),
      style: CustomItemPickerStyle(
        theme: widget.theme?.minuteTheme,
        backgroundColor: widget.backgroundColor,
        selectorColor: widget.selectorColor,
        fadeEffect: widget.fadeEffect,
        selectedTextStyle: widget.selectedTextStyle,
        unselectedTextStyle: widget.unselectedTextStyle,
        itemHeight: widget.itemHeight,
        itemWidth: widget.itemWidth,
      ),
      visibleItemCount: widget.visibleItemCount,
      onSelectedItemChanged: (newValue) {
        _controller.onSelectedAmPmHourChanged(newValue);
      },
    );
  }

  Widget _buildHour24Picker() {
    return CustomItemPicker(
      items: _controller.hours,
      initialIndex:
          _controller.hours.indexOf(_controller.selectedTime.hour.toString()),
      style: CustomItemPickerStyle(
        theme: widget.theme?.hourTheme,
        backgroundColor: widget.backgroundColor,
        selectorColor: widget.selectorColor,
        fadeEffect: widget.fadeEffect,
        selectedTextStyle: widget.selectedTextStyle,
        unselectedTextStyle: widget.unselectedTextStyle,
        itemHeight: widget.itemHeight,
        itemWidth: widget.itemWidth,
      ),
      visibleItemCount: widget.visibleItemCount,
      onSelectedItemChanged: (newValue) {
        _controller.onSelectedHourChanged(newValue);
      },
    );
  }

  Widget _buildMinutePicker() {
    return CustomItemPicker(
      key: ValueKey(_controller.selectedTime.hour == _controller.minTime.hour
          ? "minute_picker 1"
          : _controller.selectedTime.hour == _controller.maxTime.hour
              ? "minute_picker 2"
              : "minute_picker 3"),
      items: _controller.minutes,
      initialIndex: _controller.minutes
          .indexOf(_controller.selectedTime.minute.toString()),
      style: CustomItemPickerStyle(
        theme: widget.theme?.minuteTheme,
        backgroundColor: widget.backgroundColor,
        selectorColor: widget.selectorColor,
        fadeEffect: widget.fadeEffect,
        selectedTextStyle: widget.selectedTextStyle,
        unselectedTextStyle: widget.unselectedTextStyle,
        itemHeight: widget.itemHeight,
        itemWidth: widget.itemWidth,
      ),
      visibleItemCount: widget.visibleItemCount,
      onSelectedItemChanged: (newValue) {
        _controller.onSelectedMinuteChanged(newValue);
      },
    );
  }

  Widget _buildAmPmPicker() {
    return CustomItemPicker(
      items: _controller.amPm,
      initialIndex: AwesomeTimeUtils.amPm.indexOf(_controller.selectedAmPm),
      style: CustomItemPickerStyle(
        theme: widget.theme?.minuteTheme,
        backgroundColor: widget.backgroundColor,
        selectorColor: widget.selectorColor,
        fadeEffect: widget.fadeEffect,
        selectedTextStyle: widget.selectedTextStyle,
        unselectedTextStyle: widget.unselectedTextStyle,
        itemHeight: widget.itemHeight,
        itemWidth: widget.itemWidth,
      ),
      visibleItemCount: widget.visibleItemCount,
      onSelectedItemChanged: (newValue) {
        _controller.onSelectedAmPmChanged(newValue);
      },
    );
  }
}
