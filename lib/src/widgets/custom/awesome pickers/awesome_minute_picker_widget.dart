import 'package:awesome_datetime_picker/src/models/awesome_time.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/custom_number_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeMinutePicker extends StatefulWidget {
  AwesomeMinutePicker({
    super.key,
    required this.selectedTime,
    required this.maxTime,
    required this.minTime,
    required this.onSelectedMinuteChanged,
    this.width,
  });

  AwesomeTime selectedTime;
  AwesomeTime maxTime;
  AwesomeTime minTime;
  Function(int) onSelectedMinuteChanged;
  double? width;

  @override
  State<AwesomeMinutePicker> createState() => _AwesomeMinutePickerState();
}

class _AwesomeMinutePickerState extends State<AwesomeMinutePicker> {
  @override
  Widget build(BuildContext context) {
    return CustomNumberPicker(
      initialValue: widget.selectedTime.minute,
      maxValue: widget.selectedTime.hour < widget.selectedTime.hour
          ? 59
          : widget.maxTime.minute,
      minValue: widget.selectedTime.hour > widget.minTime.hour
          ? 59
          : widget.minTime.minute,
      onSelectedItemChanged: widget.onSelectedMinuteChanged,
      width: widget.width,
    );
  }
}
