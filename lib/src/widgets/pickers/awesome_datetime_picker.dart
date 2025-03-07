import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/theme/awesome_datetime_picker_theme.dart';
import 'package:flutter/material.dart';

class AwesomeDateTimePicker extends StatefulWidget {
  AwesomeDateTimePicker({
    super.key,
    this.minDate,
    this.maxDate,
    this.initialDate,
    this.minTime,
    this.maxTime,
    this.initialTime,
    this.locale = LocaleType.en,
    this.dateFormat = AwesomeDateFormat.dMy,
    this.timeFormat = AwesomeTimeFormat.Hm,
    this.theme,
  });

  AwesomeDate? minDate;
  AwesomeDate? maxDate;
  AwesomeDate? initialDate;
  AwesomeTime? minTime;
  AwesomeTime? maxTime;
  AwesomeTime? initialTime;
  LocaleType locale;
  AwesomeDateFormat dateFormat;
  AwesomeTimeFormat timeFormat;
  AwesomeDateTimePickerTheme? theme;

  @override
  State<AwesomeDateTimePicker> createState() => _AwesomeDateTimePickerState();
}

class _AwesomeDateTimePickerState extends State<AwesomeDateTimePicker> {
  late AwesomeDate minDate;
  late AwesomeDate maxDate;
  late AwesomeDate initialDate;

  late AwesomeTime minTime;
  late AwesomeTime maxTime;
  late AwesomeTime initialTime;

  @override
  void initState() {
    minDate = widget.minDate ?? AwesomeDate(year: 1990, month: 1, day: 1);
    maxDate = widget.maxDate ?? AwesomeDate(year: 2100, month: 12, day: 31);
    initialDate = widget.initialDate ??
        AwesomeDate(
            year: DateTime.now().year,
            month: DateTime.now().month,
            day: DateTime.now().day);
    minTime = widget.minTime ?? AwesomeTime(hour: 00, minute: 00);
    maxTime = widget.maxTime ?? AwesomeTime(hour: 23, minute: 59);
    initialTime = widget.initialTime ??
        AwesomeTime(hour: TimeOfDay.now().hour, minute: TimeOfDay.now().minute);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AwesomeDatePicker(
          theme: widget.theme?.datePickerTheme,
          dateFormat: widget.dateFormat,
          locale: widget.locale,
          maxDate: widget.maxDate,
          minDate: widget.minDate,
          initialDate: widget.initialDate,
        ),
        const SizedBox(
          width: 10,
        ),
        AwesomeTimePicker(
          theme: widget.theme?.timePickerTheme,
          timeFormat: widget.timeFormat,
          maxTime: widget.maxTime,
          minTime: widget.minTime,
          initialTime: widget.initialTime,
        ),
      ],
    );
  }
}
