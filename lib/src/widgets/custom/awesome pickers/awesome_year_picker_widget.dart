import 'package:awesome_datetime_picker/src/models/awesome_date.dart';
import 'package:awesome_datetime_picker/src/theme/item_theme.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/custom_number_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeYearPicker extends StatefulWidget {
  AwesomeYearPicker({
    super.key,
    required this.selectedDate,
    required this.maxDate,
    required this.minDate,
    required this.onSelectedYearChanged,
    this.theme,
  });
  AwesomeDate selectedDate;
  AwesomeDate maxDate;
  AwesomeDate minDate;
  Function(int) onSelectedYearChanged;
  ItemTheme? theme;

  @override
  State<AwesomeYearPicker> createState() => _AwesomeYearPickerState();
}

class _AwesomeYearPickerState extends State<AwesomeYearPicker> {
  @override
  Widget build(BuildContext context) {
    return CustomNumberPicker(
      initialValue: widget.selectedDate.year,
      maxValue: widget.maxDate.year,
      minValue: widget.minDate.year,
      onSelectedItemChanged: widget.onSelectedYearChanged,
      theme: widget.theme,
    );
  }
}
