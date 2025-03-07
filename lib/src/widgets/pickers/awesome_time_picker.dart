import 'package:awesome_datetime_picker/src/data/format.dart';
import 'package:awesome_datetime_picker/src/models/awesome_time.dart';
import 'package:awesome_datetime_picker/src/theme/awesome_time_picker_theme.dart';
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
    this.theme,
    this.onChanged,
    this.backgroundColor,
    this.fadeEffect,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.selectorColor,
  });

  AwesomeTime? minTime;
  AwesomeTime? maxTime;
  AwesomeTime? initialTime;
  AwesomeTimeFormat timeFormat;
  AwesomeTimePickerTheme? theme;
  final ValueChanged<AwesomeTime>? onChanged;
  Color? backgroundColor;
  Color? selectorColor;
  bool? fadeEffect;
  TextStyle? selectedTextStyle;
  TextStyle? unselectedTextStyle;

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
            selectedTime: selectedTime,
            maxTime: maxTime,
            minTime: minTime,
            theme: widget.theme?.hourTheme,
            backgroundColor: widget.backgroundColor,
            selectorColor: widget.selectorColor,
            fadeEffect: widget.fadeEffect,
            selectedTextStyle: widget.selectedTextStyle,
            unselectedTextStyle: widget.unselectedTextStyle,
            onSelectedHourChanged: (value) {
              selectedTime =
                  AwesomeTime(hour: value, minute: selectedTime.minute);

              DateTime nativeSelectedTime =
                  DateTime(2025, 1, 1, selectedTime.hour, selectedTime.minute);
              if (nativeSelectedTime.isBefore(
                  DateTime(2025, 1, 1, minTime.hour, minTime.minute))) {
                selectedTime = minTime;
              } else if (nativeSelectedTime.isAfter(
                  DateTime(2025, 1, 1, maxTime.hour, maxTime.minute))) {
                selectedTime = maxTime;
              }
              setState(() {});

              widget.onChanged?.call(selectedTime);
            },
          );
        } else if (widget.timeFormat.value[index] == PickerType.minute) {
          return AwesomeMinutePicker(
            selectedTime: selectedTime,
            maxTime: maxTime,
            minTime: minTime,
            theme: widget.theme?.minuteTheme,
            backgroundColor: widget.backgroundColor,
            selectorColor: widget.selectorColor,
            fadeEffect: widget.fadeEffect,
            selectedTextStyle: widget.selectedTextStyle,
            unselectedTextStyle: widget.unselectedTextStyle,
            onSelectedMinuteChanged: (value) {
              selectedTime =
                  AwesomeTime(hour: selectedTime.hour, minute: value);

              DateTime nativeSelectedTime =
                  DateTime(2025, 1, 1, selectedTime.hour, selectedTime.minute);
              if (nativeSelectedTime.isBefore(
                  DateTime(2025, 1, 1, minTime.hour, minTime.minute))) {
                selectedTime = minTime;
              } else if (nativeSelectedTime.isAfter(
                  DateTime(2025, 1, 1, maxTime.hour, maxTime.minute))) {
                selectedTime = maxTime;
              }
              setState(() {});

              widget.onChanged?.call(selectedTime);
            },
          );
        } else {
          return Container();
        }
      }),
    );
  }
}
