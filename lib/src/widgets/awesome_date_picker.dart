import 'package:awesome_datetime_picker/src/widgets/custom_number_picker_widget.dart';
import 'package:flutter/material.dart';
export 'package:awesome_datetime_picker/src/widgets/awesome_date_picker.dart';

class AwesomeDatePicker extends StatefulWidget {
  AwesomeDatePicker({super.key, this.minDate, this.maxDate, this.initialDate});
  DateTime? minDate;
  DateTime? maxDate;
  DateTime? initialDate;

  @override
  State<AwesomeDatePicker> createState() => _AwesomeDatePickerState();
}

class _AwesomeDatePickerState extends State<AwesomeDatePicker> {
  late DateTime selectedDate;
  late DateTime minDate;
  late DateTime maxDate;
  late DateTime initialDate;

  @override
  void initState() {
    minDate = widget.minDate ?? DateTime(1990);
    maxDate = widget.minDate ?? DateTime(2100);
    initialDate = widget.initialDate ?? DateTime.now();
    selectedDate = initialDate;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomNumberPicker(
          initialValue: selectedDate.day,
          maxValue:
              DateUtils.getDaysInMonth(selectedDate.year, selectedDate.month),
          minValue: 1,
          onSelectedItemChanged: (value) {
            setState(() {
              selectedDate =
                  DateTime(selectedDate.year, selectedDate.month, value);
            });
          },
        ),
        CustomNumberPicker(
          initialValue: selectedDate.month,
          maxValue: 12,
          minValue: 1,
          onSelectedItemChanged: (value) {
            setState(() {
              int day = selectedDate.day;
              int daysInMonth =
                  DateUtils.getDaysInMonth(selectedDate.year, value);
              if (selectedDate.day > daysInMonth) {
                day = daysInMonth;
              }
              selectedDate = DateTime(selectedDate.year, value, day);
            });
          },
        ),
        CustomNumberPicker(
          initialValue: selectedDate.year,
          maxValue: maxDate.year,
          minValue: minDate.year,
          onSelectedItemChanged: (value) {
            setState(() {
              int day = selectedDate.day;
              int daysInMonth =
                  DateUtils.getDaysInMonth(value, selectedDate.month);
              if (selectedDate.day > daysInMonth) {
                day = daysInMonth;
              }
              selectedDate = DateTime(value, selectedDate.month, day);
            });
          },
        )
      ],
    );
  }
}
