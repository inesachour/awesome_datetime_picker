import 'package:awesome_datetime_picker/src/data/format.dart';
import 'package:awesome_datetime_picker/src/data/locale.dart';
import 'package:awesome_datetime_picker/src/models/awesome_date.dart';
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
    this.dayWidth,
    this.monthWidth,
    this.yearWidth,
  });

  AwesomeDate? minDate;
  AwesomeDate? maxDate;
  AwesomeDate? initialDate;
  LocaleType locale;
  AwesomeDateFormat dateFormat;
  double? dayWidth;
  double? monthWidth;
  double? yearWidth;

  @override
  State<AwesomeDatePicker> createState() => _AwesomeDatePickerState();
}

class _AwesomeDatePickerState extends State<AwesomeDatePicker> {
  late AwesomeDate selectedDate;
  late AwesomeDate minDate;
  late AwesomeDate maxDate;
  late AwesomeDate initialDate;

  @override
  void initState() {
    minDate = widget.minDate ?? AwesomeDate(year: 1990, month: 1, day: 1);
    maxDate = widget.maxDate ?? AwesomeDate(year: 2100, month: 12, day: 31);
    initialDate = widget.initialDate ??
        AwesomeDate(
            year: DateTime.now().year,
            month: DateTime.now().month,
            day: DateTime.now().day);
    selectedDate = initialDate;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        if (widget.dateFormat.value[index] == PickerType.day) {
          return AwesomeDayPicker(
            selectedDate: selectedDate,
            maxDate: maxDate,
            minDate: minDate,
            width: widget.dayWidth,
            onSelectedDayChanged: (value) {
              setState(() {
                selectedDate = AwesomeDate(
                    year: selectedDate.year,
                    month: selectedDate.month,
                    day: value);
              });
            },
          );
        } else if (widget.dateFormat.value[index] == PickerType.year) {
          return AwesomeYearPicker(
            selectedDate: selectedDate,
            maxDate: maxDate,
            minDate: minDate,
            width: widget.yearWidth,
            onSelectedYearChanged: (value) {
              setState(() {
                int day = selectedDate.day;
                int daysInMonth =
                    DateUtils.getDaysInMonth(value, selectedDate.month);
                if (selectedDate.day > daysInMonth) {
                  day = daysInMonth;
                }
                selectedDate = AwesomeDate(
                    year: value, month: selectedDate.month, day: day);
              });
            },
          );
        } else if (widget.dateFormat.value[index] == PickerType.month_text) {
          return AwesomeMonthPicker(
            selectedDate: selectedDate,
            maxDate: maxDate,
            minDate: minDate,
            width: widget.monthWidth,
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
                selectedDate = AwesomeDate(
                    year: selectedDate.year, month: value, day: day);
              });
            },
          );
        } else if (widget.dateFormat.value[index] == PickerType.month_number) {
          return AwesomeMonthPicker(
            selectedDate: selectedDate,
            maxDate: maxDate,
            minDate: minDate,
            width: widget.monthWidth,
            locale: widget.locale,
            onSelectedMonthChanged: (value) {
              setState(() {
                int day = selectedDate.day;
                int daysInMonth =
                    DateUtils.getDaysInMonth(selectedDate.year, value);
                if (selectedDate.day > daysInMonth) {
                  day = daysInMonth;
                }
                selectedDate = AwesomeDate(
                    year: selectedDate.year, month: value, day: day);
              });
            },
          );
        } else {
          return Container();
        }
      }),
    );
  }
}
