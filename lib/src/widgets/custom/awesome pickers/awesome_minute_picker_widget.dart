import 'package:awesome_datetime_picker/src/models/awesome_time.dart';
import 'package:awesome_datetime_picker/src/theme/item_theme.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/custom_item_picker_widget.dart';
import 'package:flutter/material.dart';

/*class AwesomeMinutePicker extends StatefulWidget {
  const AwesomeMinutePicker({
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

  final AwesomeTime selectedTime;
  final AwesomeTime maxTime;
  final AwesomeTime minTime;
  final Function(int) onSelectedMinuteChanged;
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
  State<AwesomeMinutePicker> createState() => _AwesomeMinutePickerState();
}

class _AwesomeMinutePickerState extends State<AwesomeMinutePicker> {
  late List<String> minutes;

  @override
  void initState() {
    minutes = List.generate(60, (index) => index.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int maxValue = 59, minValue = 0;
    if (widget.selectedTime.hour == widget.maxTime.hour) {
      maxValue = widget.maxTime.minute;
    }
    if (widget.selectedTime.hour == widget.minTime.hour) {
      minValue = widget.minTime.minute;
    }

    return CustomItemPicker(
      items: minutes,
      initialIndex: minutes.indexOf((widget.selectedTime.minute).toString()),
      maxIndex: maxValue,
      minIndex: minValue,
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
}*/
