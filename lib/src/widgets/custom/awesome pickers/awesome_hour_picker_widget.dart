import 'package:awesome_datetime_picker/src/widgets/custom/custom_number_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeHourPicker extends StatefulWidget {
  AwesomeHourPicker({
    super.key,
    required this.selectedTime,
    required this.maxTime,
    required this.minTime,
    required this.onSelectedHourChanged,
    this.width,
  });

  TimeOfDay selectedTime;
  TimeOfDay maxTime;
  TimeOfDay minTime;
  Function(int) onSelectedHourChanged;
  double? width;

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
      width: widget.width,
    );
  }
}
