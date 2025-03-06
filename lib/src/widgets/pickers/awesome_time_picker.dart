import 'package:awesome_datetime_picker/src/data/format.dart';
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

  TimeOfDay? minTime;
  TimeOfDay? maxTime;
  TimeOfDay? initialTime;
  AwesomeTimeFormat timeFormat;
  double? hourWidth;
  double? minuteWidth;

  @override
  State<AwesomeTimePicker> createState() => _AwesomeTimePickerState();
}

class _AwesomeTimePickerState extends State<AwesomeTimePicker> {
  late TimeOfDay selectedTime;
  late TimeOfDay minTime;
  late TimeOfDay maxTime;
  late TimeOfDay initialTime;

  @override
  void initState() {
    minTime = widget.minTime ?? TimeOfDay(hour: 00, minute: 00);
    maxTime = widget.maxTime ?? TimeOfDay(hour: 23, minute: 59);
    initialTime = widget.initialTime ?? TimeOfDay.now();
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
                    TimeOfDay(hour: value, minute: selectedTime.minute);
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
                    TimeOfDay(hour: selectedTime.hour, minute: value);
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
