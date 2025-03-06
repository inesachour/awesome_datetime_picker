import 'package:awesome_datetime_picker/src/widgets/custom/custom_number_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeDayPicker extends StatefulWidget {
  AwesomeDayPicker({
    super.key,
    required this.selectedDate,
    required this.maxDate,
    required this.minDate,
    required this.onSelectedDayChanged,
    this.width,
  });
  DateTime selectedDate;
  DateTime maxDate;
  DateTime minDate;
  Function(int) onSelectedDayChanged;
  double? width;

  @override
  State<AwesomeDayPicker> createState() => _AwesomeDayPickerState();
}

class _AwesomeDayPickerState extends State<AwesomeDayPicker> {
  @override
  Widget build(BuildContext context) {
    return CustomNumberPicker(
      initialValue: widget.selectedDate.day,
      maxValue: widget.selectedDate.year < widget.maxDate.year ||
              widget.selectedDate.month < widget.maxDate.month
          ? DateUtils.getDaysInMonth(
              widget.selectedDate.year, widget.selectedDate.month)
          : widget.maxDate.day,
      minValue: widget.selectedDate.year > widget.maxDate.year ||
              widget.selectedDate.month > widget.maxDate.month
          ? DateUtils.getDaysInMonth(
              widget.selectedDate.year, widget.selectedDate.month)
          : widget.minDate.day,
      onSelectedItemChanged: widget.onSelectedDayChanged,
      width: widget.width,
    );
  }
}
