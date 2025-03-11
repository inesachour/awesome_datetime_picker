import 'package:awesome_datetime_picker/src/data/format.dart';
import 'package:awesome_datetime_picker/src/data/locale.dart';
import 'package:awesome_datetime_picker/src/data/picker_type.dart';
import 'package:awesome_datetime_picker/src/models/awesome_date.dart';
import 'package:awesome_datetime_picker/src/theme/awesome_date_picker_theme.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/awesome%20pickers/awesome_day_picker_widget.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/awesome%20pickers/awesome_month_picker.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/awesome%20pickers/awesome_year_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeDatePicker extends StatefulWidget {
  const AwesomeDatePicker({
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
    this.visibleItemCount,
    this.itemHeight,
    this.itemWidth,
  });

  /// The minimum selectable date for the date picker (default 1/1/1900).
  final AwesomeDate? minDate;

  /// The maximum selectable date for the date picker (default 31/12/2100).
  final AwesomeDate? maxDate;

  /// The initial date displayed when the picker is first shown (default current date).
  final AwesomeDate? initialDate;

  /// The locale to use for displaying the date format (default [LocaleType.en]).
  final LocaleType locale;

  /// The format of the date to be displayed in the picker (default [AwesomeDateFormat.dMy]).
  final AwesomeDateFormat dateFormat;

  /// The theme for customizing the appearance of the date picker (year, month, day themes).
  final AwesomeDatePickerTheme? theme;

  /// A callback function that is triggered when the selected date changes.
  final ValueChanged<AwesomeDate>? onChanged;

  /// The background color of the date picker.
  /// This value is overridden by the value passed in the theme's backgroundColor property.
  final Color? backgroundColor;

  /// The color of the selector (highlight) used in the date picker.
  final Color? selectorColor;

  /// A flag to indicate whether to apply a fade effect on the edges of the picker (default true).
  final bool? fadeEffect;

  /// The text style for the selected date.
  /// This value is overridden by the value passed in the theme's selectedTextStyle property.
  final TextStyle? selectedTextStyle;

  /// The text style for the unselected dates
  /// This value is overridden by the value passed in the theme's unselectedTextStyle property.
  final TextStyle? unselectedTextStyle;

  /// The number of visible items in the date picker at once.
  final int? visibleItemCount;

  /// The height of each item in the date picker.
  /// This value is overridden by the value passed in the theme's height property.
  final double? itemHeight;

  /// The width of each item in the date picker.
  /// This value is overridden by the value passed in the theme's width property.
  final double? itemWidth;

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
    minDate = widget.minDate ?? AwesomeDate(year: 1900, month: 1, day: 1);
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
            key: ValueKey(selectedDate.year == minDate.year &&
                    selectedDate.month == minDate.month
                ? "day_picker 1"
                : selectedDate.year == maxDate.year &&
                        selectedDate.month == maxDate.month
                    ? "day_picker 2"
                    : "day_picker 3"),
            selectedDate: selectedDate,
            maxDate: maxDate,
            minDate: minDate,
            theme: widget.theme?.dayTheme,
            backgroundColor: widget.backgroundColor,
            selectorColor: widget.selectorColor,
            fadeEffect: widget.fadeEffect,
            selectedTextStyle: widget.selectedTextStyle,
            unselectedTextStyle: widget.unselectedTextStyle,
            visibleItemCount: widget.visibleItemCount,
            itemHeight: widget.itemHeight,
            itemWidth: widget.itemWidth,
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
            visibleItemCount: widget.visibleItemCount,
            itemHeight: widget.itemHeight,
            itemWidth: widget.itemWidth,
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
            key: ValueKey(selectedDate.year == minDate.year
                ? "text_month_picker 1"
                : selectedDate.year == maxDate.year
                    ? "text_month_picker 2"
                    : "text_month_picker 3"),
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
            visibleItemCount: widget.visibleItemCount,
            itemHeight: widget.itemHeight,
            itemWidth: widget.itemWidth,
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
            key: ValueKey(selectedDate.year == minDate.year
                ? "number_month_picker 1"
                : selectedDate.year == maxDate.year
                    ? "number_month_picker 2"
                    : "number_month_picker 3"),
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
            visibleItemCount: widget.visibleItemCount,
            itemHeight: widget.itemHeight,
            itemWidth: widget.itemWidth,
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
