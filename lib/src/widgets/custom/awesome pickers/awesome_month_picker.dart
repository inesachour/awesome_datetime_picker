import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/utils/awesome_date_utils.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/custom_number_picker_widget.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/custom_text_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeMonthPicker extends StatefulWidget {
  AwesomeMonthPicker({
    super.key,
    required this.selectedMonth,
    required this.onSelectedMonthChanged,
    required this.locale,
    this.isNumber = true,
    this.width,
  });

  int selectedMonth;
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
            initialValue: widget.selectedMonth,
            maxValue: 12,
            minValue: 1,
            onSelectedItemChanged: widget.onSelectedMonthChanged,
            width: widget.width,
          )
        : CustomTextPicker(
            items: months,
            initialValue: months[widget.selectedMonth - 1],
            onSelectedItemChanged: widget.onSelectedMonthChanged,
            width: widget.width,
          );
  }
}
