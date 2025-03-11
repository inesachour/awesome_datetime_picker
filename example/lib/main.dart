import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
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
      appBar: AppBar(
        title: const Center(child: Text("Awesome DateTime Picker")),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            /*AwesomeDatePicker(
              dateFormat: AwesomeDateFormat.dMMy,
              minDate: AwesomeDate(year: 2025, month: 2, day: 15),
              maxDate: AwesomeDate(year: 2026, month: 10, day: 10),
              onChanged: (AwesomeDate date) {
                print(
                    "----Date changed : ${date.day}/${date.month}/${date.year}\n");
              },
            ),*/
            const SizedBox(
              height: 10,
            ),
            AwesomeTimePicker(
              timeFormat: AwesomeTimeFormat.hm,
              //minTime: AwesomeTime(hour: 9, minute: 20),
              //maxTime: AwesomeTime(hour: 20, minute: 15),
              onChanged: (AwesomeTime time) {
                print("----Time changed : ${time.hour}:${time.minute}\n");
              },
            ),
            const SizedBox(
              height: 10,
            ),
            /*AwesomeDateTimePicker(
              dateFormat: AwesomeDateFormat.dMMy,
              timeFormat: AwesomeTimeFormat.Hm,
              onChanged: (AwesomeDateTime dateTime) {
                print(
                    "----Date time changed : ${dateTime.date.year}/${dateTime.date.month}/${dateTime.date.day} ${dateTime.time.hour}:${dateTime.time.minute}\n");
              },
            ),*/
          ],
        ),
      ),
    );
  }
}
