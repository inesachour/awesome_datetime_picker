import 'package:awesome_datetime_picker/src/utils/awesome_date_utils.dart';
import 'package:awesome_datetime_picker/src/widgets/custom%20pickers/custom_number_picker_widget.dart';
import 'package:awesome_datetime_picker/src/widgets/custom%20pickers/custom_text_picker_widget.dart';
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
  late List<String> months;

  @override
  void initState() {
    months = AwesomeDateUtils.getMonthNames('en_US');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return /*CustomNumberPicker(
      initialValue: widget.selectedMonth,
      maxValue: 12,
      minValue: 1,
      onSelectedItemChanged: widget.onSelectedMonthChanged,
    );*/
        CustomTextPicker(
      items: months,
      initialValue: months[0],
      onSelectedItemChanged: widget.onSelectedMonthChanged,
    );
  }
}
