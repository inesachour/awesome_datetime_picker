import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/data/format.dart';
import 'package:awesome_datetime_picker/src/data/locale.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/awesome%20pickers/awesome_day_picker_widget.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/awesome%20pickers/awesome_month_picker.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/awesome%20pickers/awesome_year_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeDateTimePicker extends StatefulWidget {
  AwesomeDateTimePicker({
    super.key,
    this.minDate,
    this.maxDate,
    this.initialDate,
    this.locale = LocaleType.en,
    this.dayWidth,
    this.monthWidth,
    this.yearWidth,
    this.hourWidth,
    this.minuteWidth,
    this.dateFormat = AwesomeDateFormat.dMy,
    this.timeFormat = AwesomeTimeFormat.Hm,
  });

  DateTime? minDate;
  DateTime? maxDate;
  DateTime? initialDate;
  LocaleType locale;
  AwesomeDateFormat dateFormat;
  AwesomeTimeFormat timeFormat;
  double? dayWidth;
  double? monthWidth;
  double? yearWidth;
  double? hourWidth;
  double? minuteWidth;

  @override
  State<AwesomeDateTimePicker> createState() => _AwesomeDateTimePickerState();
}

class _AwesomeDateTimePickerState extends State<AwesomeDateTimePicker> {
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AwesomeDatePicker(
          dayWidth: widget.dayWidth ?? MediaQuery.of(context).size.width * 0.16,
          monthWidth: widget.monthWidth ??
              (widget.dateFormat ==
                      AwesomeDateFormat.values.contains(PickerType.month_text)
                  ? MediaQuery.of(context).size.width * 0.18
                  : MediaQuery.of(context).size.width * 0.16),
          yearWidth:
              widget.yearWidth ?? MediaQuery.of(context).size.width * 0.16,
          dateFormat: widget.dateFormat,
          locale: widget.locale,
          maxDate: widget.maxDate,
          minDate: widget.minDate,
          initialDate: widget.initialDate,
        ),
        SizedBox(
          width: 10,
        ),
        AwesomeTimePicker(
          hourWidth:
              widget.hourWidth ?? MediaQuery.of(context).size.width * 0.16,
          minuteWidth:
              widget.minuteWidth ?? MediaQuery.of(context).size.width * 0.16,
          timeFormat: widget.timeFormat,
          maxTime: widget.maxDate,
          minTime: widget.minDate,
          initialTime: widget.initialDate,
        ),
      ],
    );
  }
}
