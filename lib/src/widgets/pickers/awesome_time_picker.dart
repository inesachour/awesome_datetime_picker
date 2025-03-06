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

  DateTime? minTime;
  DateTime? maxTime;
  DateTime? initialTime;
  AwesomeTimeFormat timeFormat;
  double? hourWidth;
  double? minuteWidth;

  @override
  State<AwesomeTimePicker> createState() => _AwesomeTimePickerState();
}

class _AwesomeTimePickerState extends State<AwesomeTimePicker> {
  late DateTime selectedTime;
  late DateTime minTime;
  late DateTime maxTime;
  late DateTime initialTime;

  @override
  void initState() {
    minTime = widget.minTime ?? DateTime(1990);
    maxTime = widget.maxTime ?? DateTime(2100);
    initialTime = widget.initialTime ?? DateTime.now();
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
            selectedHour: selectedTime.hour,
            width: widget.hourWidth,
            onSelectedHourChanged: (value) {
              setState(() {
                selectedTime = DateTime(selectedTime.year, selectedTime.month,
                    selectedTime.day, value, selectedTime.minute);
              });
            },
          );
        } else if (widget.timeFormat.value[index] == PickerType.minute) {
          return AwesomeMinutePicker(
            selectedMinute: selectedTime.minute,
            width: widget.minuteWidth,
            onSelectedMinuteChanged: (value) {
              setState(() {
                selectedTime = DateTime(selectedTime.year, selectedTime.month,
                    selectedTime.day, selectedTime.hour, value);
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
