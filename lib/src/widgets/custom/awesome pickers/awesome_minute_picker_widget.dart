import 'package:awesome_datetime_picker/src/models/awesome_time.dart';
import 'package:awesome_datetime_picker/src/theme/item_theme.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/custom_number_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeMinutePicker extends StatefulWidget {
  AwesomeMinutePicker({
    super.key,
    required this.selectedTime,
    required this.maxTime,
    required this.minTime,
    required this.onSelectedMinuteChanged,
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

  AwesomeTime selectedTime;
  AwesomeTime maxTime;
  AwesomeTime minTime;
  Function(int) onSelectedMinuteChanged;
  ItemTheme? theme;
  Color? backgroundColor;
  Color? selectorColor;
  bool? fadeEffect;
  TextStyle? selectedTextStyle;
  TextStyle? unselectedTextStyle;
  int? visibleItemCount;
  double? itemHeight;
  double? itemWidth;

  @override
  State<AwesomeMinutePicker> createState() => _AwesomeMinutePickerState();
}

class _AwesomeMinutePickerState extends State<AwesomeMinutePicker> {
  @override
  Widget build(BuildContext context) {
    int maxValue = 59, minValue = 0;
    if (widget.selectedTime.hour == widget.maxTime.hour) {
      maxValue = widget.maxTime.minute;
    }
    if (widget.selectedTime.hour == widget.minTime.hour) {
      minValue = widget.minTime.minute;
    }

    return CustomNumberPicker(
      initialValue: widget.selectedTime.minute,
      maxValue: maxValue,
      minValue: minValue,
      onSelectedItemChanged: widget.onSelectedMinuteChanged,
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
