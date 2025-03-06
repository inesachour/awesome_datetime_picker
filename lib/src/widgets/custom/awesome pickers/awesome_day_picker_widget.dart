import 'package:awesome_datetime_picker/src/widgets/custom/custom_number_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeDayPicker extends StatefulWidget {
  AwesomeDayPicker({
    super.key,
    required this.selectedDay,
    required this.maxDay,
    required this.onSelectedDayChanged,
    this.width,
  });
  int selectedDay;
  int maxDay;
  Function(int) onSelectedDayChanged;
  double? width;

  @override
  State<AwesomeDayPicker> createState() => _AwesomeDayPickerState();
}

class _AwesomeDayPickerState extends State<AwesomeDayPicker> {
  @override
  Widget build(BuildContext context) {
    return CustomNumberPicker(
      initialValue: widget.selectedDay,
      maxValue: widget.maxDay,
      minValue: 1,
      onSelectedItemChanged: widget.onSelectedDayChanged,
      width: widget.width,
    );
  }
}
