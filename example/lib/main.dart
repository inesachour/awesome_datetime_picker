import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: Calendar(),
    );
  }
}

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          AwesomeDatePicker(
            dateFormat: AwesomeDateFormat.dMMy,
            minDate: AwesomeDate(year: 2024, month: 2, day: 15),
            maxDate: AwesomeDate(year: 2026, month: 10, day: 10),
            onChanged: (AwesomeDate date) {
              print(
                  "----Date changed : ${date.day}/${date.month}/${date.year}\n");
            },
            //excludedWeekdays: [1, 2, 3, 4, 5, 6],
          ),
          AwesomeTimePicker(
            timeFormat: AwesomeTimeFormat.hm,
            minTime: const AwesomeTime(hour: 5, minute: 20),
            maxTime: const AwesomeTime(hour: 15, minute: 15),
            initialTime: const AwesomeTime(hour: 15, minute: 10),
            onChanged: (AwesomeTime time) {
              print("----Time changed : ${time.hour}:${time.minute}\n");
            },
          ),
          AwesomeDateTimePicker(
            initialDateTime: AwesomeDateTime(
              date: AwesomeDate(year: 2025, month: 12, day: 12),
              time: const AwesomeTime(hour: 10, minute: 30),
            ),
            minDateTime: AwesomeDateTime(
              date: AwesomeDate(year: 2025, month: 12, day: 1),
              time: const AwesomeTime(hour: 8, minute: 0),
            ),
            maxDateTime: AwesomeDateTime(
              date: AwesomeDate(year: 2025, month: 12, day: 31),
              time: const AwesomeTime(hour: 18, minute: 0),
            ),
            dateFormat: AwesomeDateFormat.dMMy,
            timeFormat: AwesomeTimeFormat.hm,
            onChanged: (dateTime) {
              debugPrint('Selected: $dateTime');
            },
          ),
        ],
      ),
    );
  }
}
