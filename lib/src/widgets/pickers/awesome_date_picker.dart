import 'package:awesome_datetime_picker/src/data/format.dart';
import 'package:awesome_datetime_picker/src/data/locale.dart';
import 'package:awesome_datetime_picker/src/models/awesome_date.dart';
import 'package:awesome_datetime_picker/src/theme/awesome_date_picker_theme.dart';
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
    this.theme,
    this.onChanged,
    this.backgroundColor,
    this.fadeEffect,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.selectorColor,
  });

  AwesomeDate? minDate;
  AwesomeDate? maxDate;
  AwesomeDate? initialDate;
  LocaleType locale;
  AwesomeDateFormat dateFormat;
  AwesomeDatePickerTheme? theme;
  final ValueChanged<AwesomeDate>? onChanged;
  Color? backgroundColor;
  Color? selectorColor;
  bool? fadeEffect;
  TextStyle? selectedTextStyle;
  TextStyle? unselectedTextStyle;

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
            theme: widget.theme?.dayTheme,
            backgroundColor: widget.backgroundColor,
            selectorColor: widget.selectorColor,
            fadeEffect: widget.fadeEffect,
            selectedTextStyle: widget.selectedTextStyle,
            unselectedTextStyle: widget.unselectedTextStyle,
            onSelectedDayChanged: (value) {
              selectedDate = AwesomeDate(
                  year: selectedDate.year,
                  month: selectedDate.month,
                  day: value);

              DateTime nativeSelectedDate = DateTime(
                  selectedDate.year, selectedDate.month, selectedDate.day);
              if (nativeSelectedDate.isBefore(
                  DateTime(minDate.year, minDate.month, minDate.day))) {
                selectedDate = minDate;
              } else if (nativeSelectedDate.isAfter(
                  DateTime(maxDate.year, maxDate.month, maxDate.day))) {
                selectedDate = maxDate;
              }
              setState(() {});

              widget.onChanged?.call(selectedDate);
            },
          );
        } else if (widget.dateFormat.value[index] == PickerType.year) {
          return AwesomeYearPicker(
            selectedDate: selectedDate,
            maxDate: maxDate,
            minDate: minDate,
            theme: widget.theme?.yearTheme,
            backgroundColor: widget.backgroundColor,
            selectorColor: widget.selectorColor,
            fadeEffect: widget.fadeEffect,
            selectedTextStyle: widget.selectedTextStyle,
            unselectedTextStyle: widget.unselectedTextStyle,
            onSelectedYearChanged: (value) {
              int day = selectedDate.day;
              int daysInMonth =
                  DateUtils.getDaysInMonth(value, selectedDate.month);
              if (selectedDate.day > daysInMonth) {
                day = daysInMonth;
              }
              selectedDate =
                  AwesomeDate(year: value, month: selectedDate.month, day: day);

              DateTime nativeSelectedDate = DateTime(
                  selectedDate.year, selectedDate.month, selectedDate.day);
              if (nativeSelectedDate.isBefore(
                  DateTime(minDate.year, minDate.month, minDate.day))) {
                selectedDate = minDate;
              } else if (nativeSelectedDate.isAfter(
                  DateTime(maxDate.year, maxDate.month, maxDate.day))) {
                selectedDate = maxDate;
              }
              setState(() {});

              widget.onChanged?.call(selectedDate);
            },
          );
        } else if (widget.dateFormat.value[index] == PickerType.month_text) {
          return AwesomeMonthPicker(
            selectedDate: selectedDate,
            maxDate: maxDate,
            minDate: minDate,
            theme: widget.theme?.monthTheme,
            backgroundColor: widget.backgroundColor,
            isNumber: false,
            locale: widget.locale,
            selectorColor: widget.selectorColor,
            fadeEffect: widget.fadeEffect,
            selectedTextStyle: widget.selectedTextStyle,
            unselectedTextStyle: widget.unselectedTextStyle,
            onSelectedMonthChanged: (value) {
              int day = selectedDate.day;
              int daysInMonth =
                  DateUtils.getDaysInMonth(selectedDate.year, value);
              if (selectedDate.day > daysInMonth) {
                day = daysInMonth;
              }
              selectedDate =
                  AwesomeDate(year: selectedDate.year, month: value, day: day);

              DateTime nativeSelectedDate = DateTime(
                  selectedDate.year, selectedDate.month, selectedDate.day);
              if (nativeSelectedDate.isBefore(
                  DateTime(minDate.year, minDate.month, minDate.day))) {
                selectedDate = minDate;
              } else if (nativeSelectedDate.isAfter(
                  DateTime(maxDate.year, maxDate.month, maxDate.day))) {
                selectedDate = maxDate;
              }
              setState(() {});

              widget.onChanged?.call(selectedDate);
            },
          );
        } else if (widget.dateFormat.value[index] == PickerType.month_number) {
          return AwesomeMonthPicker(
            selectedDate: selectedDate,
            maxDate: maxDate,
            minDate: minDate,
            theme: widget.theme?.monthTheme,
            backgroundColor: widget.backgroundColor,
            locale: widget.locale,
            selectorColor: widget.selectorColor,
            fadeEffect: widget.fadeEffect,
            selectedTextStyle: widget.selectedTextStyle,
            unselectedTextStyle: widget.unselectedTextStyle,
            onSelectedMonthChanged: (value) {
              int day = selectedDate.day;
              int daysInMonth =
                  DateUtils.getDaysInMonth(selectedDate.year, value);
              if (selectedDate.day > daysInMonth) {
                day = daysInMonth;
              }
              selectedDate =
                  AwesomeDate(year: selectedDate.year, month: value, day: day);

              DateTime nativeSelectedDate = DateTime(
                  selectedDate.year, selectedDate.month, selectedDate.day);
              if (nativeSelectedDate.isBefore(
                  DateTime(minDate.year, minDate.month, minDate.day))) {
                selectedDate = minDate;
              } else if (nativeSelectedDate.isAfter(
                  DateTime(maxDate.year, maxDate.month, maxDate.day))) {
                selectedDate = maxDate;
              }
              setState(() {});

              widget.onChanged?.call(selectedDate);
            },
          );
        } else {
          return Container();
        }
      }),
    );
  }
}
