import 'package:awesome_datetime_picker/src/models/awesome_time.dart';
import 'package:awesome_datetime_picker/src/theme/item_theme.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/custom_number_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeHourPicker extends StatefulWidget {
  AwesomeHourPicker({
    super.key,
    required this.selectedTime,
    required this.maxTime,
    required this.minTime,
    required this.onSelectedHourChanged,
    this.theme,
    this.backgroundColor,
    this.fadeEffect,
  });

  AwesomeTime selectedTime;
  AwesomeTime maxTime;
  AwesomeTime minTime;
  Function(int) onSelectedHourChanged;
  ItemTheme? theme;
  Color? backgroundColor;
  bool? fadeEffect;

  @override
  State<AwesomeHourPicker> createState() => _AwesomeHourPickerState();
}

class _AwesomeHourPickerState extends State<AwesomeHourPicker> {
  @override
  Widget build(BuildContext context) {
    return CustomNumberPicker(
      initialValue: widget.selectedTime.hour,
      maxValue: widget.maxTime.hour,
      minValue: widget.minTime.hour,
      onSelectedItemChanged: widget.onSelectedHourChanged,
      theme: widget.theme,
      backgroundColor: widget.backgroundColor,
      fadeEffect: widget.fadeEffect,
    );
  }
}
