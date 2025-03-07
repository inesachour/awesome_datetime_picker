import 'package:awesome_datetime_picker/src/models/awesome_date.dart';
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
  AwesomeDate selectedDate;
  AwesomeDate maxDate;
  AwesomeDate minDate;
  Function(int) onSelectedDayChanged;
  double? width;

  @override
  State<AwesomeDayPicker> createState() => _AwesomeDayPickerState();
}

class _AwesomeDayPickerState extends State<AwesomeDayPicker> {
  @override
  Widget build(BuildContext context) {
    int maxValue = DateUtils.getDaysInMonth(
            widget.selectedDate.year, widget.selectedDate.month),
        minValue = 1;
    if (widget.selectedDate.year == widget.maxDate.year &&
        widget.selectedDate.month == widget.maxDate.month) {
      maxValue = widget.maxDate.day;
    }
    if (widget.selectedDate.year == widget.minDate.year &&
        widget.selectedDate.month == widget.minDate.month) {
      minValue = widget.minDate.day;
    }

    return CustomNumberPicker(
      initialValue: widget.selectedDate.day,
      maxValue: maxValue,
      minValue: minValue,
      onSelectedItemChanged: widget.onSelectedDayChanged,
      width: widget.width,
    );
  }
}
