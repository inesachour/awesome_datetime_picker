import 'package:awesome_datetime_picker/src/widgets/custom_number_picker_widget.dart';
import 'package:flutter/material.dart';

class DatePicker extends StatefulWidget {
  const DatePicker({super.key});

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  int selectedDay = DateTime.now().day;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  DateTime minDate = DateTime(1990);
  DateTime maxDate = DateTime(2100);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomNumberPicker(
          initialValue: selectedDay,
          maxValue: 31,
          minValue: 1,
          onSelectedItemChanged: (value) {},
        ),
        CustomNumberPicker(
          initialValue: selectedMonth,
          maxValue: 12,
          minValue: 1,
          onSelectedItemChanged: (value) {},
        ),
        CustomNumberPicker(
          initialValue: selectedYear,
          maxValue: maxDate.year,
          minValue: minDate.year,
          onSelectedItemChanged: (value) {},
        )
      ],
    );
  }
}
