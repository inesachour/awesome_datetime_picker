# Awesome DateTime Picker

## Overview
"Awesome DateTime Picker" is a Flutter package that offers customizable date, time, and date-time wheel pickers with a sliding style inspired by the `CupertinoDatePicker`. It works on every Flutter platform (iOS, Android, web, desktop) and follows the light or dark appearance of your app.

## Installation
```yaml
dependencies:
  awesome_datetime_picker: ^0.1.1
```
```dart
import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
```

## Quick start
```dart
AwesomeDatePicker(
  onChanged: (AwesomeDate date) => print(date),
)
```
Every parameter is optional. The pickers start on the current date/time, clamped into the `min*`/`max*` range if you set one.

## Pickers

### Date Picker
<p align="center" width="100%">
    <img src="https://github.com/inesachour/awesome_datetime_picker/blob/master/images/date_picker.jpg?raw=true" height="200">
</p>

```dart
AwesomeDatePicker(
    AwesomeDate? minDate; // The minimum selectable date (default 1/1/1900).
    AwesomeDate? maxDate; // The maximum selectable date (default 31/12/2100).
    AwesomeDate? initialDate; // The initially selected date (default today).
    LocaleType locale; // The language of the month names (default en).
    AwesomeDateFormat dateFormat; // The wheels to display and their order.
    List<int>? excludedWeekdays; // Weekdays that cannot be selected (1 = Monday ... 7 = Sunday).
    AwesomeDatePickerTheme? theme; // Per-wheel customization.
    ValueChanged<AwesomeDate>? onChanged; // Called when the selected date changes.
    Color? backgroundColor; // Background color of the wheels.
    Color? selectorColor; // Color of the selected item indicator.
    bool? fadeEffect; // Whether to fade the items at the top and bottom edges (default true).
    TextStyle? selectedTextStyle; // Text style for the selected item.
    TextStyle? unselectedTextStyle; // Text style for unselected items.
    int? visibleItemCount; // Number of items visible at a time (odd number, at least 3; default 5).
    double? itemHeight; // Height of each item.
    double? itemWidth; // Width of each wheel.
)
```

### Time Picker
<p align="center" width="100%">
    <img src="https://github.com/inesachour/awesome_datetime_picker/blob/master/images/time_picker.jpg?raw=true" height="200">
</p>

```dart
AwesomeTimePicker(
    AwesomeTime? minTime; // The minimum selectable time (default 00:00).
    AwesomeTime? maxTime; // The maximum selectable time (default 23:59).
    AwesomeTime? initialTime; // The initially selected time (default now).
    AwesomeTimeFormat timeFormat; // 24-hour (Hm) or 12-hour with AM/PM (hm).
    List<int>? excludedHours; // Hours that cannot be selected (0-23).
    AwesomeTimePickerTheme? theme; // Per-wheel customization.
    ValueChanged<AwesomeTime>? onChanged; // Called when the selected time changes (always 24-hour).
    Color? backgroundColor; // Background color of the wheels.
    Color? selectorColor; // Color of the selected item indicator.
    bool? fadeEffect; // Whether to fade the items at the top and bottom edges (default true).
    TextStyle? selectedTextStyle; // Text style for the selected item.
    TextStyle? unselectedTextStyle; // Text style for unselected items.
    int? visibleItemCount; // Number of items visible at a time (odd number, at least 3; default 5).
    double? itemHeight; // Height of each item.
    double? itemWidth; // Width of each wheel.
)
```

### DateTime Picker
<p align="center" width="100%">
    <img src="https://github.com/inesachour/awesome_datetime_picker/blob/master/images/datetime_picker.jpg?raw=true" height="200">
</p>

```dart
AwesomeDateTimePicker(
    AwesomeDateTime? minDateTime; // The minimum selectable date and time (default 1/1/1900 00:00).
    AwesomeDateTime? maxDateTime; // The maximum selectable date and time (default 31/12/2100 23:59).
    AwesomeDateTime? initialDateTime; // The initially selected date and time (default now).
    LocaleType locale; // The language of the month names (default en).
    AwesomeDateFormat dateFormat; // The date wheels to display and their order.
    AwesomeTimeFormat timeFormat; // 24-hour (Hm) or 12-hour with AM/PM (hm).
    List<int>? excludedWeekdays; // Weekdays that cannot be selected (1 = Monday ... 7 = Sunday).
    List<int>? excludedHours; // Hours that cannot be selected (0-23).
    AwesomeDateTimePickerTheme? theme; // Per-wheel customization.
    ValueChanged<AwesomeDateTime>? onChanged; // Called when the date or time changes.
    Color? backgroundColor; // Background color of the wheels.
    Color? selectorColor; // Color of the selected item indicator.
    bool? fadeEffect; // Whether to fade the items at the top and bottom edges (default true).
    TextStyle? selectedTextStyle; // Text style for the selected item.
    TextStyle? unselectedTextStyle; // Text style for unselected items.
    int? visibleItemCount; // Number of items visible at a time (odd number, at least 3; default 5).
    double? itemHeight; // Height of each item.
    double? itemWidth; // Width of each wheel.
)
```
The selectable times depend on the selected date: on the day of `minDateTime` only times from its time are offered, on the day of `maxDateTime` only times up to its time, and any time on the days in between.

## Behavior

### Changing properties after the first build
Changing `minDate`/`maxDate`/`locale`/`excludedWeekdays` (date picker), `minTime`/`maxTime`/`excludedHours` (time picker) or `minDateTime`/`maxDateTime` (date-time picker) updates the wheels and **keeps the current selection**, clamped into the new range. If the clamping changes the value, `onChanged` is called with the new one.

The `initial*` value is only read once. To move the selection programmatically, give the picker a new `Key`.

### Light and dark mode
Colors and text styles follow the brightness of your app's `Theme`. You can override any of them; the precedence, highest first, is:

1. the per-wheel `ItemTheme` passed through `theme`,
2. the options on the picker (`backgroundColor`, `selectorColor`, `selectedTextStyle`, `unselectedTextStyle`, `itemHeight`, `itemWidth`),
3. the built-in light/dark defaults.

## Customization
### LocaleType
The following table lists the currently supported locales for the month names of the date and date-time pickers:

| Locale Code | Language         |
|-------------|------------------|
| en          | English          |
| fr          | French           |
| es          | Spanish          |
| de          | German           |
| it          | Italian          |
| ar          | Arabic           |

```dart
    locale: LocaleType.fr
```

### AwesomeDateFormat
The date format only changes how the date is displayed. The value returned by the pickers is always an `AwesomeDate`.

| Date Format | Example           |
|-------------|-------------------|
| dMy         | 1/1/2025          |
| dMMy        | 1 January 2025    |
| yMd         | 2025/1/1          |
| yMMd        | 2025 January 1    |

```dart
    dateFormat: AwesomeDateFormat.dMMy,
```

### AwesomeTimeFormat
The time format only changes how the time is displayed. The value returned by the pickers is always on a 24-hour clock.

| Time Format | Example        |
|-------------|----------------|
| Hm          | 13:00          |
| hm          | 1:00 PM        |

```dart
    timeFormat: AwesomeTimeFormat.hm,
```

### Excluding values
```dart
AwesomeDatePicker(excludedWeekdays: [DateTime.saturday, DateTime.sunday])
AwesomeTimePicker(excludedHours: [12, 13])
```
If the selected value lands on an excluded one, the picker moves to the next valid value.

### Themes
Themes customize each wheel separately (year, month, day, hour, minute and AM/PM).

#### AwesomeDatePickerTheme
```dart
class AwesomeDatePickerTheme {
    ItemTheme? yearTheme; // Theme for the year wheel.
    ItemTheme? monthTheme; // Theme for the month wheel.
    ItemTheme? dayTheme; // Theme for the day wheel.
}
```

#### AwesomeTimePickerTheme
```dart
class AwesomeTimePickerTheme {
    ItemTheme? hourTheme; // Theme for the hour wheel.
    ItemTheme? minuteTheme; // Theme for the minute wheel.
    ItemTheme? ampmTheme; // Theme for the AM/PM wheel (defaults to hourTheme).
}
```

#### AwesomeDateTimePickerTheme
```dart
class AwesomeDateTimePickerTheme {
    AwesomeDatePickerTheme? datePickerTheme; // Theme for the date wheels.
    AwesomeTimePickerTheme? timePickerTheme; // Theme for the time wheels.
}
```

#### ItemTheme
`ItemTheme` describes one wheel.
```dart
class ItemTheme {
    double? width; // Width of the wheel.
    double? height; // Height of one item.
    Color? backgroundColor; // Background color of the wheel.
    TextStyle? selectedTextStyle; // Text style of the selected item.
    TextStyle? unselectedTextStyle; // Text style of the other items.
    Widget? title; // Widget shown above the wheel (e.g. a label).
    EdgeInsets? padding; // Padding inside the wheel.
    EdgeInsets? margin; // Margin around the wheel.
}
```

Example: a labelled, wider year wheel.
```dart
AwesomeDatePicker(
  theme: AwesomeDatePickerTheme(
    yearTheme: ItemTheme(
      width: 120,
      title: Text('Year'),
      selectedTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
  ),
)
```

## Contributing
The code lives in `lib/src`, grouped by feature:

| Folder      | Content |
|-------------|---------|
| `core/`     | Models (`AwesomeDate`, `AwesomeTime`, `AwesomeDateTime`), formats, locales, utils and validation |
| `shared/`   | The wheel widget, `ItemTheme` and the helper that builds a wheel |
| `date/`     | `AwesomeDatePicker`, its controller and theme |
| `time/`     | `AwesomeTimePicker`, its controller and theme |
| `datetime/` | `AwesomeDateTimePicker`, its controller and theme |

Controllers hold all the logic (clamping, exclusions, the items of each wheel) and have no widget code, so they can be unit-tested directly. Run `flutter test` and `flutter analyze` before opening a pull request; every public member must have a doc comment.
