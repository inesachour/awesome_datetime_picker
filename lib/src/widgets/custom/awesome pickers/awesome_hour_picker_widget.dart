import 'package:awesome_datetime_picker/src/models/awesome_time.dart';
import 'package:awesome_datetime_picker/src/theme/item_theme.dart';
import 'package:awesome_datetime_picker/src/utils/awesome_time_utils.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/custom_item_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeHourPicker extends StatefulWidget {
  const AwesomeHourPicker({
    super.key,
    required this.selectedTime,
    required this.maxTime,
    required this.minTime,
    required this.onSelectedHourChanged,
    required this.selectedAmPm,
    this.theme,
    this.backgroundColor,
    this.fadeEffect,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.selectorColor,
    this.visibleItemCount,
    this.itemHeight,
    this.itemWidth,
  });

  final AwesomeTime selectedTime;
  final AwesomeTime maxTime;
  final AwesomeTime minTime;
  final Function(int) onSelectedHourChanged;
  final String? selectedAmPm;
  final ItemTheme? theme;
  final Color? backgroundColor;
  final Color? selectorColor;
  final bool? fadeEffect;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final int? visibleItemCount;
  final double? itemHeight;
  final double? itemWidth;

  @override
  State<AwesomeHourPicker> createState() => _AwesomeHourPickerState();
}

class _AwesomeHourPickerState extends State<AwesomeHourPicker> {
  late List<String> hours;

  @override
  void initState() {
    super.initState();
    hours = widget.selectedAmPm != null
        ? List.generate(12, (index) => (index == 0 ? 12 : index).toString())
        : List.generate(24, (index) => (index).toString());
  }

  @override
  Widget build(BuildContext context) {
    int initialIndex = hours.indexOf(widget.selectedAmPm != null
        ? AwesomeTimeUtils.convertTo12HourFormat(widget.selectedTime.hour)
            .toString()
        : widget.selectedTime.hour.toString());

    int maxIndex = widget.selectedAmPm != null
        ? AwesomeTimeUtils.getAmPm(widget.maxTime.hour) != widget.selectedAmPm
            ? 11
            : hours.indexOf(
                AwesomeTimeUtils.convertTo12HourFormat(widget.maxTime.hour)
                    .toString())
        : widget.maxTime.hour;

    int minIndex = widget.selectedAmPm != null
        ? AwesomeTimeUtils.getAmPm(widget.minTime.hour) != widget.selectedAmPm
            ? 0
            : hours.indexOf(
                AwesomeTimeUtils.convertTo12HourFormat(widget.minTime.hour)
                    .toString())
        : widget.minTime.hour;

    return CustomItemPicker(
      items: hours,
      initialIndex: initialIndex,
      maxIndex: maxIndex,
      minIndex: minIndex,
      onSelectedItemChanged: widget.onSelectedHourChanged,
      theme: widget.theme,
      backgroundColor: widget.backgroundColor,
      fadeEffect: widget.fadeEffect,
      selectedTextStyle: widget.selectedTextStyle,
      unselectedTextStyle: widget.unselectedTextStyle,
      selectorColor: widget.selectorColor,
      visibleItemCount: widget.visibleItemCount,
      itemHeight: widget.itemHeight,
      itemWidth: widget.itemWidth,
    );
  }
}
