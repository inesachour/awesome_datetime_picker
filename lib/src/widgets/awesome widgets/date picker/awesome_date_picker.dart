import 'package:awesome_datetime_picker/src/widgets/awesome%20widgets/date%20picker/awesome_day_picker_widget.dart';
import 'package:awesome_datetime_picker/src/widgets/awesome%20widgets/date%20picker/awesome_month_picker.dart';
import 'package:awesome_datetime_picker/src/widgets/awesome%20widgets/date%20picker/awesome_year_picker_widget.dart';
import 'package:awesome_datetime_picker/src/widgets/awesome%20widgets/timer%20picker/awesome_hour_picker_widget.dart';
import 'package:awesome_datetime_picker/src/widgets/awesome%20widgets/timer%20picker/awesome_minute_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeDatePicker extends StatefulWidget {
  AwesomeDatePicker({super.key, this.minDate, this.maxDate, this.initialDate});
  DateTime? minDate;
  DateTime? maxDate;
  DateTime? initialDate;

  @override
  State<AwesomeDatePicker> createState() => _AwesomeDatePickerState();
}

class _AwesomeDatePickerState extends State<AwesomeDatePicker> {
  late DateTime selectedDate;
  late DateTime minDate;
  late DateTime maxDate;
  late DateTime initialDate;

  @override
  void initState() {
    minDate = widget.minDate ?? DateTime(1990);
    maxDate = widget.minDate ?? DateTime(2100);
    initialDate = widget.initialDate ?? DateTime.now();
    selectedDate = initialDate;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AwesomeDayPicker(
              selectedDay: selectedDate.day,
              maxDay: DateUtils.getDaysInMonth(
                  selectedDate.year, selectedDate.month),
              onSelectedDayChanged: (value) {
                setState(() {
                  selectedDate =
                      DateTime(selectedDate.year, selectedDate.month, value);
                });
              },
            ),
            AwesomeMonthPicker(
              selectedMonth: selectedDate.month,
              onSelectedMonthChanged: (value) {
                setState(() {
                  int day = selectedDate.day;
                  int daysInMonth =
                      DateUtils.getDaysInMonth(selectedDate.year, value);
                  if (selectedDate.day > daysInMonth) {
                    day = daysInMonth;
                  }
                  selectedDate = DateTime(selectedDate.year, value, day);
                });
              },
            ),
            AwesomeYearPicker(
              selectedYear: selectedDate.year,
              maxYear: maxDate.year,
              minYear: minDate.year,
              onSelectedYearChanged: (value) {
                setState(() {
                  int day = selectedDate.day;
                  int daysInMonth =
                      DateUtils.getDaysInMonth(value, selectedDate.month);
                  if (selectedDate.day > daysInMonth) {
                    day = daysInMonth;
                  }
                  selectedDate = DateTime(value, selectedDate.month, day);
                });
              },
            ),
          ],
        ),
        Row(
          children: [
            AwesomeHourPicker(
              selectedHour: selectedDate.hour,
              onSelectedHourChanged: (value) {},
            ),
            AwesomeMinutePicker(
              selectedMinute: selectedDate.minute,
              onSelectedMinuteChanged: (value) {},
            ),
          ],
        ),
      ],
    );
  }
}
