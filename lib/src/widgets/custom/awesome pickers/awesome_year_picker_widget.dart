import 'package:awesome_datetime_picker/src/widgets/custom/custom_number_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeYearPicker extends StatefulWidget {
  AwesomeYearPicker({
    super.key,
    required this.selectedYear,
    required this.maxYear,
    required this.minYear,
    required this.onSelectedYearChanged,
    this.width,
  });
  int selectedYear;
  int maxYear;
  int minYear;
  Function(int) onSelectedYearChanged;
  double? width;

  @override
  State<AwesomeYearPicker> createState() => _AwesomeYearPickerState();
}

class _AwesomeYearPickerState extends State<AwesomeYearPicker> {
  @override
  Widget build(BuildContext context) {
    return CustomNumberPicker(
      initialValue: widget.selectedYear,
      maxValue: widget.maxYear,
      minValue: widget.minYear,
      onSelectedItemChanged: widget.onSelectedYearChanged,
      width: widget.width,
    );
  }
}
