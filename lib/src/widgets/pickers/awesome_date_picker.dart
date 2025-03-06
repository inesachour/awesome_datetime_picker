import 'package:awesome_datetime_picker/src/data/format.dart';
import 'package:awesome_datetime_picker/src/data/locale.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/awesome%20pickers/awesome_day_picker_widget.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/awesome%20pickers/awesome_month_picker.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/awesome%20pickers/awesome_year_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeDatePicker extends StatefulWidget {
  AwesomeDatePicker({
    super.key,
    this.minDate,
    this.maxDate,
    this.initialDate,
    this.locale = LocaleType.en,
    this.dateFormat = AwesomeDateFormat.dMy,
  });

  DateTime? minDate;
  DateTime? maxDate;
  DateTime? initialDate;
  LocaleType locale;
  AwesomeDateFormat dateFormat;

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
    maxDate = widget.maxDate ?? DateTime(2100);
    initialDate = widget.initialDate ?? DateTime.now();
    selectedDate = initialDate;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            if (widget.dateFormat.value[index] == PickerType.day) {
              return AwesomeDayPicker(
                selectedDay: selectedDate.day,
                maxDay: DateUtils.getDaysInMonth(
                    selectedDate.year, selectedDate.month),
                onSelectedDayChanged: (value) {
                  setState(() {
                    selectedDate =
                        DateTime(selectedDate.year, selectedDate.month, value);
                  });
                },
              );
            } else if (widget.dateFormat.value[index] == PickerType.year) {
              return AwesomeYearPicker(
                selectedYear: selectedDate.year,
                maxYear: maxDate.year,
                minYear: minDate.year,
                onSelectedYearChanged: (value) {
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
              );
            } else if (widget.dateFormat.value[index] ==
                PickerType.month_text) {
              return AwesomeMonthPicker(
                selectedMonth: selectedDate.month,
                isNumber: false,
                locale: widget.locale,
                onSelectedMonthChanged: (value) {
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
              );
            } else if (widget.dateFormat.value[index] ==
                PickerType.month_number) {
              return AwesomeMonthPicker(
                selectedMonth: selectedDate.month,
                locale: widget.locale,
                onSelectedMonthChanged: (value) {
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
              );
            } else {
              return Container();
            }
          }),
        ),
      ],
    );
  }
}
