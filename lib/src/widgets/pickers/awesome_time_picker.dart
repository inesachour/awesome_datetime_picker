import 'package:awesome_datetime_picker/src/data/format.dart';
import 'package:awesome_datetime_picker/src/models/awesome_time.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/awesome%20pickers/awesome_hour_picker_widget.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/awesome%20pickers/awesome_minute_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeTimePicker extends StatefulWidget {
  AwesomeTimePicker({
    super.key,
    this.minTime,
    this.maxTime,
    this.initialTime,
    this.timeFormat = AwesomeTimeFormat.Hm,
    this.hourWidth,
    this.minuteWidth,
  });

  AwesomeTime? minTime;
  AwesomeTime? maxTime;
  AwesomeTime? initialTime;
  AwesomeTimeFormat timeFormat;
  double? hourWidth;
  double? minuteWidth;

  @override
  State<AwesomeTimePicker> createState() => _AwesomeTimePickerState();
}

class _AwesomeTimePickerState extends State<AwesomeTimePicker> {
  late AwesomeTime selectedTime;
  late AwesomeTime minTime;
  late AwesomeTime maxTime;
  late AwesomeTime initialTime;

  @override
  void initState() {
    minTime = widget.minTime ?? AwesomeTime(hour: 00, minute: 00);
    maxTime = widget.maxTime ?? AwesomeTime(hour: 23, minute: 59);
    initialTime = widget.initialTime ??
        AwesomeTime(hour: TimeOfDay.now().hour, minute: TimeOfDay.now().minute);
    selectedTime = initialTime;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        if (widget.timeFormat.value[index] == PickerType.hour_12) {
          //TODO
          return Container();
        } else if (widget.timeFormat.value[index] == PickerType.hour_24) {
          return AwesomeHourPicker(
            selectedTime: initialTime,
            maxTime: maxTime,
            minTime: minTime,
            width: widget.hourWidth,
            onSelectedHourChanged: (value) {
              setState(() {
                selectedTime =
                    AwesomeTime(hour: value, minute: selectedTime.minute);
              });
            },
          );
        } else if (widget.timeFormat.value[index] == PickerType.minute) {
          return AwesomeMinutePicker(
            selectedTime: initialTime,
            maxTime: maxTime,
            minTime: minTime,
            width: widget.minuteWidth,
            onSelectedMinuteChanged: (value) {
              setState(() {
                selectedTime =
                    AwesomeTime(hour: selectedTime.hour, minute: value);
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
