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
    int maxValue = 59, minValue = 0;
    if (widget.selectedTime.hour < widget.maxTime.hour &&
        widget.selectedTime.hour > widget.minTime.hour) {
      maxValue = 59;
      minValue = 0;
    } else if (widget.selectedTime.hour == widget.maxTime.hour) {
      minValue = 0;
      maxValue = widget.maxTime.minute;
    } else if (widget.selectedTime.hour == widget.minTime.hour) {
      minValue = widget.minTime.minute;
      maxValue = 59;
    }

    return CustomNumberPicker(
      initialValue: widget.selectedTime.minute,
      maxValue: maxValue,
      minValue: minValue,
      onSelectedItemChanged: widget.onSelectedMinuteChanged,
      width: widget.width,
    );
  }
}
