import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/theme/item_theme.dart';
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
    this.theme,
    this.backgroundColor,
  });

  AwesomeDate selectedDate;
  AwesomeDate maxDate;
  AwesomeDate minDate;
  Function(int) onSelectedMonthChanged;
  bool isNumber;
  LocaleType locale;
  ItemTheme? theme;
  Color? backgroundColor;

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
    int maxValue = 12, minValue = 1;
    if (widget.selectedDate.year == widget.maxDate.year) {
      maxValue = widget.maxDate.month;
    }
    if (widget.selectedDate.year == widget.minDate.year) {
      minValue = widget.minDate.month;
    }

    return widget.isNumber
        ? CustomNumberPicker(
            initialValue: widget.selectedDate.month,
            maxValue: maxValue,
            minValue: minValue,
            onSelectedItemChanged: widget.onSelectedMonthChanged,
            theme: widget.theme,
            backgroundColor: widget.backgroundColor,
          )
        : CustomTextPicker(
            items: months,
            initialValue: months[widget.selectedDate.month - 1],
            minIndex: minValue - 1,
            maxIndex: maxValue - 1,
            onSelectedItemChanged: widget.onSelectedMonthChanged,
            theme: widget.theme,
            backgroundColor: widget.backgroundColor,
          );
  }
}
