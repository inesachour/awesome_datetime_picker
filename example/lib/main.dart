import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Awesome DateTime Picker',
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: _themeMode,
      home: Demo(
        isDark: _themeMode == ThemeMode.dark,
        onThemeChanged: (dark) => setState(
            () => _themeMode = dark ? ThemeMode.dark : ThemeMode.light),
      ),
    );
  }
}

class Demo extends StatefulWidget {
  const Demo({super.key, required this.isDark, required this.onThemeChanged});

  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  String _date = '-';
  String _time = '-';
  String _dateTime = '-';
  bool _weekdaysOnly = false;
  bool _looping = false;
  bool _haptics = false;
  bool _fifteenMinutes = false;
  bool _showDisabled = false;
  bool _weekdays = false;
  bool _seconds = false;
  String? _localeName;
  String _modalResult = '-';
  final _dateController = AwesomeDatePickerController();

  @override
  void initState() {
    super.initState();
    // The controller reports every change, including the ones made by the
    // buttons below; `onChanged` only reports changes made by the user.
    _dateController.addListener(() {
      final d = _dateController.value;
      setState(() => _date = '${d.day}/${d.month}/${d.year}');
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Awesome DateTime Picker')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            title: const Text('Language (intl localeName)'),
            trailing: DropdownButton<String?>(
              value: _localeName,
              items: const [
                DropdownMenuItem(value: null, child: Text('Default (en)')),
                DropdownMenuItem(value: 'fr', child: Text('Français')),
                DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                DropdownMenuItem(value: 'ja', child: Text('日本語')),
                DropdownMenuItem(value: 'ar_EG', child: Text('العربية (مصر)')),
                DropdownMenuItem(value: 'fa', child: Text('فارسی')),
              ],
              onChanged: (v) => setState(() => _localeName = v),
            ),
          ),
          SwitchListTile(
            title: const Text('Dark mode'),
            value: widget.isDark,
            onChanged: widget.onThemeChanged,
          ),
          SwitchListTile(
            title: const Text('Exclude weekends (changes props at runtime)'),
            value: _weekdaysOnly,
            onChanged: (v) => setState(() => _weekdaysOnly = v),
          ),
          SwitchListTile(
            title: const Text('Looping wheels'),
            value: _looping,
            onChanged: (v) => setState(() => _looping = v),
          ),
          SwitchListTile(
            title: const Text('Haptic feedback'),
            value: _haptics,
            onChanged: (v) => setState(() => _haptics = v),
          ),
          SwitchListTile(
            title: const Text('15-minute interval'),
            value: _fifteenMinutes,
            onChanged: (v) => setState(() => _fifteenMinutes = v),
          ),
          SwitchListTile(
            title: const Text('Show excluded values dimmed'),
            value: _showDisabled,
            onChanged: (v) => setState(() => _showDisabled = v),
          ),
          SwitchListTile(
            title: const Text('Weekday labels'),
            value: _weekdays,
            onChanged: (v) => setState(() => _weekdays = v),
          ),
          SwitchListTile(
            title: const Text('Seconds'),
            value: _seconds,
            onChanged: (v) => setState(() => _seconds = v),
          ),
          _Section(
            title: 'Modals and range picker',
            value: _modalResult,
            child: Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final date = await showAwesomeDatePicker(
                      context,
                      title: const Text('Pick a date'),
                      localeName: _localeName,
                      excludedWeekdays: _weekdaysOnly
                          ? [DateTime.saturday, DateTime.sunday]
                          : null,
                    );
                    setState(
                        () => _modalResult = date?.toString() ?? 'cancelled');
                  },
                  child: const Text('Date sheet'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final time = await showAwesomeTimePicker(
                      context,
                      timeFormat: AwesomeTimeFormat.hm,
                      minuteInterval: 15,
                      presentation: AwesomePickerPresentation.dialog,
                    );
                    setState(
                        () => _modalResult = time?.toString() ?? 'cancelled');
                  },
                  child: const Text('Time dialog'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final range = await showAwesomeDateRangePicker(
                      context,
                      minLength: 1,
                      maxLength: 14,
                      startLabel: const Text('Check-in'),
                      endLabel: const Text('Check-out'),
                      localeName: _localeName,
                    );
                    setState(
                        () => _modalResult = range?.toString() ?? 'cancelled');
                  },
                  child: const Text('Range sheet'),
                ),
              ],
            ),
          ),
          _Section(
            title: 'Date picker',
            value: _date,
            extra: Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => _dateController.value =
                      AwesomeDate(year: 2026, month: 12, day: 25),
                  child: const Text('Go to 25/12/2026'),
                ),
                TextButton(
                  onPressed: _dateController.reset,
                  child: const Text('Reset'),
                ),
              ],
            ),
            child: AwesomeDatePicker(
              controller: _dateController,
              localeName: _localeName,
              showDisabledValues: _showDisabled,
              showWeekday: _weekdays,
              excludedDates: [
                AwesomeDate(year: 2026, month: 12, day: 25),
                AwesomeDate(year: 2027, month: 1, day: 1),
              ],
              looping: _looping,
              enableHapticFeedback: _haptics,
              wheelStyle: const AwesomeWheelStyle(
                  selectorBorderRadius: BorderRadius.all(Radius.circular(10))),
              dateFormat: AwesomeDateFormat.dMMy,
              minDate: AwesomeDate(year: 2024, month: 2, day: 15),
              maxDate: AwesomeDate(year: 2030, month: 10, day: 10),
              excludedWeekdays:
                  _weekdaysOnly ? [DateTime.saturday, DateTime.sunday] : null,
            ),
          ),
          _Section(
            title: 'Time picker (12h, lunch break excluded)',
            value: _time,
            child: AwesomeTimePicker(
              looping: _looping,
              enableHapticFeedback: _haptics,
              minuteInterval: _fifteenMinutes ? 15 : 1,
              localeName: _localeName,
              timeFormat:
                  _seconds ? AwesomeTimeFormat.hms : AwesomeTimeFormat.hm,
              showDisabledValues: _showDisabled,
              minTime: const AwesomeTime(hour: 8, minute: 0),
              maxTime: const AwesomeTime(hour: 18, minute: 30),
              excludedHours: const [12, 13],
              theme: const AwesomeTimePickerTheme(
                hourTheme: ItemTheme(title: Text('Hour')),
                minuteTheme: ItemTheme(title: Text('Min')),
              ),
              onChanged: (t) => setState(() => _time =
                  '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}'),
            ),
          ),
          _Section(
            title: 'Date-time picker',
            value: _dateTime,
            child: AwesomeDateTimePicker(
              looping: _looping,
              enableHapticFeedback: _haptics,
              minuteInterval: _fifteenMinutes ? 15 : 1,
              localeName: _localeName,
              dateFormat: AwesomeDateFormat.dMMy,
              timeFormat:
                  _seconds ? AwesomeTimeFormat.Hms : AwesomeTimeFormat.Hm,
              showDisabledValues: _showDisabled,
              showWeekday: _weekdays,
              minDateTime: AwesomeDateTime(
                date: AwesomeDate(year: 2025, month: 12, day: 1),
                time: const AwesomeTime(hour: 8, minute: 0),
              ),
              maxDateTime: AwesomeDateTime(
                date: AwesomeDate(year: 2030, month: 12, day: 31),
                time: const AwesomeTime(hour: 18, minute: 0),
              ),
              excludedWeekdays:
                  _weekdaysOnly ? [DateTime.saturday, DateTime.sunday] : null,
              onChanged: (v) =>
                  setState(() => _dateTime = v.toDateTime().toString()),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.value,
    required this.child,
    this.extra,
  });

  final String title;
  final String value;
  final Widget child;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Selected: $value'),
          if (extra != null) extra!,
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
