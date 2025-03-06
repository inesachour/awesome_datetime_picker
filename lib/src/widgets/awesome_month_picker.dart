import 'package:awesome_datetime_picker/src/widgets/custom_number_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeMonthPicker extends StatefulWidget {
  AwesomeMonthPicker({
    super.key,
    required this.selectedMonth,
    required this.onSelectedMonthChanged,
  });
  int selectedMonth;
  Function(int) onSelectedMonthChanged;

  @override
  State<AwesomeMonthPicker> createState() => _AwesomeMonthPickerState();
}

class _AwesomeMonthPickerState extends State<AwesomeMonthPicker> {
  @override
  Widget build(BuildContext context) {
    return CustomNumberPicker(
      initialValue: widget.selectedMonth,
      maxValue: 12,
      minValue: 1,
      onSelectedItemChanged: widget.onSelectedMonthChanged,
    );
  }
}
