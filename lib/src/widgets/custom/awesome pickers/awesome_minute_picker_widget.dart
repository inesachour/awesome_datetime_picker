import 'package:awesome_datetime_picker/src/widgets/custom/custom_number_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeMinutePicker extends StatefulWidget {
  AwesomeMinutePicker({
    super.key,
    required this.selectedMinute,
    required this.onSelectedMinuteChanged,
    this.width,
  });

  int selectedMinute;
  Function(int) onSelectedMinuteChanged;
  double? width;

  @override
  State<AwesomeMinutePicker> createState() => _AwesomeMinutePickerState();
}

class _AwesomeMinutePickerState extends State<AwesomeMinutePicker> {
  @override
  Widget build(BuildContext context) {
    return CustomNumberPicker(
      initialValue: widget.selectedMinute,
      maxValue: 59,
      minValue: 00,
      onSelectedItemChanged: widget.onSelectedMinuteChanged,
      width: widget.width,
    );
  }
}
