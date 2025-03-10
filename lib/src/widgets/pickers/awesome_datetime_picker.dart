import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/material.dart';

class AwesomeDateTimePicker extends StatefulWidget {
  const AwesomeDateTimePicker({
    super.key,
    this.minDateTime,
    this.maxDateTime,
    this.initialDateTime,
    this.locale = LocaleType.en,
    this.dateFormat = AwesomeDateFormat.dMy,
    this.timeFormat = AwesomeTimeFormat.Hm,
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

  final AwesomeDateTime? minDateTime;
  final AwesomeDateTime? maxDateTime;
  final AwesomeDateTime? initialDateTime;
  final LocaleType locale;
  final AwesomeDateFormat dateFormat;
  final AwesomeTimeFormat timeFormat;
  final AwesomeDateTimePickerTheme? theme;
  final ValueChanged<AwesomeDateTime>? onChanged;
  final Color? backgroundColor;
  final Color? selectorColor;
  final bool? fadeEffect;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final int? visibleItemCount;
  final double? itemHeight;
  final double? itemWidth;

  @override
  State<AwesomeDateTimePicker> createState() => _AwesomeDateTimePickerState();
}

class _AwesomeDateTimePickerState extends State<AwesomeDateTimePicker> {
  late AwesomeDateTime minDateTime;
  late AwesomeDateTime maxDateTime;
  late AwesomeDateTime initialDateTime;
  late AwesomeDateTime selectedDateTime;

  @override
  void initState() {
    minDateTime = widget.minDateTime ??
        AwesomeDateTime(
            date: AwesomeDate(year: 1990, month: 1, day: 1),
            time: AwesomeTime(hour: 00, minute: 00));
    maxDateTime = widget.maxDateTime ??
        AwesomeDateTime(
            date: AwesomeDate(year: 2100, month: 12, day: 31),
            time: AwesomeTime(hour: 23, minute: 59));
    initialDateTime = widget.initialDateTime ??
        AwesomeDateTime(
            date: AwesomeDate(
                year: DateTime.now().year,
                month: DateTime.now().month,
                day: DateTime.now().day),
            time: AwesomeTime(
                hour: TimeOfDay.now().hour, minute: TimeOfDay.now().minute));
    selectedDateTime = initialDateTime;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AwesomeDatePicker(
          theme: widget.theme?.datePickerTheme,
          backgroundColor: widget.backgroundColor,
          dateFormat: widget.dateFormat,
          locale: widget.locale,
          maxDate: maxDateTime.date,
          minDate: minDateTime.date,
          initialDate: initialDateTime.date,
          selectorColor: widget.selectorColor,
          fadeEffect: widget.fadeEffect,
          selectedTextStyle: widget.selectedTextStyle,
          unselectedTextStyle: widget.unselectedTextStyle,
          visibleItemCount: widget.visibleItemCount,
          itemHeight: widget.itemHeight,
          itemWidth: widget.itemWidth,
          onChanged: (AwesomeDate date) {
            setState(() {
              selectedDateTime.date = date;
            });
            widget.onChanged?.call(
                AwesomeDateTime(date: date, time: selectedDateTime.time));
          },
        ),
        AwesomeTimePicker(
          theme: widget.theme?.timePickerTheme,
          backgroundColor: widget.backgroundColor,
          timeFormat: widget.timeFormat,
          maxTime: maxDateTime.time,
          minTime: minDateTime.time,
          initialTime: initialDateTime.time,
          selectorColor: widget.selectorColor,
          fadeEffect: widget.fadeEffect,
          selectedTextStyle: widget.selectedTextStyle,
          unselectedTextStyle: widget.unselectedTextStyle,
          visibleItemCount: widget.visibleItemCount,
          itemHeight: widget.itemHeight,
          itemWidth: widget.itemWidth,
          onChanged: (AwesomeTime time) {
            setState(() {
              selectedDateTime.time = time;
            });
            widget.onChanged?.call(
                AwesomeDateTime(date: selectedDateTime.date, time: time));
          },
        ),
      ],
    );
  }
}
