import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/utils/awesome_date_utils.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/custom_number_picker_widget.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/custom_text_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeMonthPicker extends StatefulWidget {
  AwesomeMonthPicker({
    super.key,
    required this.selectedDate,
    required this.maxDate,
    required this.minDate,
    required this.onSelectedMonthChanged,
    required this.locale,
    this.isNumber = true,
    this.width,
  });

  AwesomeDate selectedDate;
  AwesomeDate maxDate;
  AwesomeDate minDate;
  Function(int) onSelectedMonthChanged;
  bool isNumber;
  LocaleType locale;
  double? width;

  @override
  State<AwesomeMonthPicker> createState() => _AwesomeMonthPickerState();
}

class _AwesomeMonthPickerState extends State<AwesomeMonthPicker> {
  late List<String> months;

  @override
  void initState() {
    months = AwesomeDateUtils.getMonthNames(widget.locale);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isNumber
        ? CustomNumberPicker(
            initialValue: widget.selectedDate.month,
            maxValue: widget.selectedDate.year < widget.maxDate.year
                ? 12
                : widget.maxDate.month,
            minValue: widget.selectedDate.year > widget.minDate.year
                ? 1
                : widget.minDate.month,
            onSelectedItemChanged: widget.onSelectedMonthChanged,
            width: widget.width,
          )
        : CustomTextPicker(
            items: months,
            initialValue: months[widget.selectedDate.month - 1],
            onSelectedItemChanged: widget.onSelectedMonthChanged,
            width: widget.width,
          );
  }
}
