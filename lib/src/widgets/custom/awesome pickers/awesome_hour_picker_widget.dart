import 'package:awesome_datetime_picker/src/widgets/custom/custom_number_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeHourPicker extends StatefulWidget {
  AwesomeHourPicker({
    super.key,
    required this.selectedHour,
    required this.onSelectedHourChanged,
  });

  int selectedHour;
  Function(int) onSelectedHourChanged;

  @override
  State<AwesomeHourPicker> createState() => _AwesomeHourPickerState();
}

class _AwesomeHourPickerState extends State<AwesomeHourPicker> {
  @override
  Widget build(BuildContext context) {
    return CustomNumberPicker(
      initialValue: widget.selectedHour,
      maxValue: 23,
      minValue: 00,
      onSelectedItemChanged: widget.onSelectedHourChanged,
    );
  }
}
