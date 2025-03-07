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
      appBar: AppBar(
        title: const Center(child: Text("Awesome DateTime Picker")),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              padding: const EdgeInsets.all(5),
              child: AwesomeDatePicker(
                dateFormat: AwesomeDateFormat.dMMy,
                locale: LocaleType.fr,
                maxDate: AwesomeDate(year: 2026, month: 11, day: 25),
                minDate: AwesomeDate(year: 2025, month: 2, day: 2),
                onChanged: (AwesomeDate date) {
                  print(
                      "----Date changed : ${date.day}/${date.month}/${date.year}\n");
                },
                /*theme: AwesomeDatePickerTheme(
                  dayTheme: ItemTheme(
                      width: 50,
                      backgroundColor: Colors.red,
                      selectedTextStyle: TextStyle(color: Colors.amber),
                      unselectedTextStyle: TextStyle(color: Colors.white)),
                  yearTheme: ItemTheme(
                      width: 80,
                      backgroundColor: Colors.black,
                      selectedTextStyle: TextStyle(color: Colors.green),
                      unselectedTextStyle: TextStyle(color: Colors.white)),
                  monthTheme: ItemTheme(
                      width: 100,
                      backgroundColor: Colors.blue,
                      selectedTextStyle: TextStyle(color: Colors.amber),
                      unselectedTextStyle: TextStyle(color: Colors.white)),
                ),*/
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              padding: const EdgeInsets.all(5),
              child: AwesomeTimePicker(
                //fadeEffect: true,
                timeFormat: AwesomeTimeFormat.Hm,
                maxTime: AwesomeTime(hour: 10, minute: 15),
                minTime: AwesomeTime(hour: 01, minute: 54),
                onChanged: (AwesomeTime time) {
                  print("----Time changed : ${time.hour}:${time.minute}\n");
                },
                /*theme: AwesomeTimePickerTheme(
                  hourTheme: ItemTheme(
                    backgroundColor: Colors.grey,
                    selectedTextStyle: TextStyle(color: Colors.amber),
                    unselectedTextStyle: TextStyle(color: Colors.white),
                  ),
                  minuteTheme: ItemTheme(
                    backgroundColor: Colors.blueGrey,
                    selectedTextStyle: TextStyle(color: Colors.amber),
                    unselectedTextStyle: TextStyle(color: Colors.white),
                  ),
                ),*/
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              padding: const EdgeInsets.all(5),
              child: AwesomeDateTimePicker(
                // backgroundColor: Colors.red,
                visibleItemCount: 3,
                fadeEffect: false,
                dateFormat: AwesomeDateFormat.yMMd,
                minDateTime: AwesomeDateTime(
                    date: AwesomeDate(year: 2025, month: 3, day: 2),
                    time: AwesomeTime(hour: 9, minute: 10)),
                maxDateTime: AwesomeDateTime(
                    date: AwesomeDate(year: 2026, month: 3, day: 22),
                    time: AwesomeTime(hour: 19, minute: 20)),
                onChanged: (AwesomeDateTime dateTime) {
                  print(
                      "----Date time changed : ${dateTime.date.year}/${dateTime.date.month}/${dateTime.date.day} ${dateTime.time.hour}:${dateTime.time.minute}\n");
                },
                theme: AwesomeDateTimePickerTheme(
                  datePickerTheme: AwesomeDatePickerTheme(
                    dayTheme: ItemTheme(
                        width: 50,
                        backgroundColor: Colors.red,
                        selectedTextStyle: TextStyle(color: Colors.amber),
                        unselectedTextStyle: TextStyle(color: Colors.white)),
                    yearTheme: ItemTheme(
                        width: 80,
                        backgroundColor: Colors.black,
                        selectedTextStyle: TextStyle(color: Colors.green),
                        unselectedTextStyle: TextStyle(color: Colors.white)),
                    monthTheme: ItemTheme(
                        width: 60,
                        backgroundColor: Colors.blue,
                        selectedTextStyle: TextStyle(color: Colors.amber),
                        unselectedTextStyle: TextStyle(color: Colors.white)),
                  ),
                  timePickerTheme: AwesomeTimePickerTheme(
                    hourTheme: ItemTheme(
                      backgroundColor: Colors.grey,
                      selectedTextStyle: TextStyle(color: Colors.amber),
                      unselectedTextStyle: TextStyle(color: Colors.white),
                    ),
                    minuteTheme: ItemTheme(
                      backgroundColor: Colors.blueGrey,
                      selectedTextStyle: TextStyle(color: Colors.amber),
                      unselectedTextStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
