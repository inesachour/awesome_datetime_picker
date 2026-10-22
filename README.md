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
    String? localeName; // Any locale known by intl (e.g. 'pt_BR', 'ja'); replaces locale and localizes digits.
    AwesomeDateFormat dateFormat; // The wheels to display and their order.
    List<int>? excludedWeekdays; // Weekdays that cannot be selected (1 = Monday ... 7 = Sunday).
    List<AwesomeDate>? excludedDates; // Specific dates that cannot be selected (holidays, booked days).
    bool Function(AwesomeDate)? selectableDayPredicate; // Return false to exclude a date.
    bool showWeekday; // Show the weekday on the day wheel, e.g. "Mon 12" (default false).
    bool showDisabledValues; // Keep excluded values visible, dimmed, instead of removing them (default false).
    TextStyle? disabledTextStyle; // Text style of the dimmed values.
    AwesomeDatePickerController? controller; // Read and change the selected date from code (see Controllers).
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
    bool looping; // Wheels wrap around from the last item to the first (default false; year and AM/PM never loop).
    bool enableHapticFeedback; // Light haptic tick while dragging a wheel (default false).
    AwesomeWheelStyle? wheelStyle; // Curvature, magnification and selector shape of the wheels.
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
    AwesomeTimeFormat timeFormat; // 24-hour (Hm) or 12-hour with AM/PM (hm), with or without seconds.
    String? localeName; // Any locale known by intl (e.g. 'ja', 'fa'); localizes AM/PM and digits.
    List<int>? excludedHours; // Hours that cannot be selected (0-23).
    int minuteInterval; // Distance between selectable minutes: a divisor of 60 such as 5, 15 or 30 (default 1).
    int secondInterval; // Distance between selectable seconds (default 1). Only for formats with seconds.
    bool showDisabledValues; // Keep excluded hours visible, dimmed, instead of removing them (default false).
    TextStyle? disabledTextStyle; // Text style of the dimmed values.
    AwesomeTimePickerController? controller; // Read and change the selected time from code (see Controllers).
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
    bool looping; // Wheels wrap around from the last item to the first (default false; year and AM/PM never loop).
    bool enableHapticFeedback; // Light haptic tick while dragging a wheel (default false).
    AwesomeWheelStyle? wheelStyle; // Curvature, magnification and selector shape of the wheels.
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
    String? localeName; // Any locale known by intl (e.g. 'pt_BR', 'ja'); replaces locale and localizes digits.
    AwesomeDateFormat dateFormat; // The date wheels to display and their order.
    AwesomeTimeFormat timeFormat; // 24-hour (Hm) or 12-hour with AM/PM (hm).
    List<int>? excludedWeekdays; // Weekdays that cannot be selected (1 = Monday ... 7 = Sunday).
    List<AwesomeDate>? excludedDates; // Specific dates that cannot be selected (holidays, booked days).
    bool Function(AwesomeDate)? selectableDayPredicate; // Return false to exclude a date.
    List<int>? excludedHours; // Hours that cannot be selected (0-23).
    int minuteInterval; // Distance between selectable minutes: a divisor of 60 such as 5, 15 or 30 (default 1).
    int secondInterval; // Distance between selectable seconds (default 1). Only for formats with seconds.
    bool showWeekday; // Show the weekday on the day wheel, e.g. "Mon 12" (default false).
    bool showDisabledValues; // Keep excluded values visible, dimmed, instead of removing them (default false).
    TextStyle? disabledTextStyle; // Text style of the dimmed values.
    AwesomeDateTimePickerController? controller; // Read and change the selected date-time from code (see Controllers).
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
    bool looping; // Wheels wrap around from the last item to the first (default false; year and AM/PM never loop).
    bool enableHapticFeedback; // Light haptic tick while dragging a wheel (default false).
    AwesomeWheelStyle? wheelStyle; // Curvature, magnification and selector shape of the wheels.
)
```
The selectable times depend on the selected date: on the day of `minDateTime` only times from its time are offered, on the day of `maxDateTime` only times up to its time, and any time on the days in between.

### Date Range Picker
Select a start and an end date. The two pickers stay consistent: the end date is never before the start date, and moving the start past the end moves the end along.

```dart
AwesomeDateRangePicker(
    AwesomeDate? minDate; // The earliest selectable date (default 1/1/1900).
    AwesomeDate? maxDate; // The latest selectable date (default 31/12/2100).
    AwesomeDateRange? initialRange; // The initially selected range (default: today, lasting minLength days).
    AwesomeDateRangePickerController? controller; // Read and change the selected range from code.
    ValueChanged<AwesomeDateRange>? onChanged; // Called when the range changes.
    int minLength; // Minimum days between start and end (default 0: a single day is allowed).
    int? maxLength; // Maximum days between start and end (default unlimited).
    Widget? startLabel; // Shown above the start picker, e.g. Text('Check-in').
    Widget? endLabel; // Shown above the end picker, e.g. Text('Check-out').
    Axis direction; // One above the other (vertical, default) or side by side (horizontal).
    double spacing; // Space between the two pickers (default 8).
    // plus the options of AwesomeDatePicker, applied to both pickers: locale, localeName,
    // dateFormat, excludedWeekdays, excludedDates, selectableDayPredicate, showWeekday,
    // showDisabledValues, disabledTextStyle, theme, backgroundColor, selectorColor, fadeEffect,
    // selectedTextStyle, unselectedTextStyle, visibleItemCount, itemHeight, itemWidth,
    // looping, enableHapticFeedback and wheelStyle.
)
```
`AwesomeDateRange` has a `start` and an `end`, and `lengthInDays` (0 for a single day, 1 for consecutive days, e.g. one night) and `contains(date)`.

```dart
AwesomeDateRangePicker(
  minDate: AwesomeDate(year: 2025, month: 1, day: 1),
  maxDate: AwesomeDate(year: 2025, month: 12, day: 31),
  minLength: 1, // at least one night
  maxLength: 14, // at most two weeks
  startLabel: Text('Check-in'),
  endLabel: Text('Check-out'),
  onChanged: (range) => print('${range.start} to ${range.end} (${range.lengthInDays} nights)'),
)
```
- `minLength` and `maxLength` limit the distance between the two dates. When the start moves so that the end would break a limit, the end follows it.
- The exclusions apply to both dates. If they leave a start date without any selectable end date, the picker moves to the nearest start that has one.
- `onChanged` is called with the whole range whenever the user changes it, including when the end moves because of the start, so the last reported value is always the range shown.
- Like the other pickers it accepts a controller (`AwesomeDateRangePickerController`) and keeps the current range, adjusted, when its rules change.

## Showing a picker in a modal
`showAwesomeDatePicker`, `showAwesomeTimePicker`, `showAwesomeDateTimePicker` and `showAwesomeDateRangePicker` open the picker in a bottom sheet or a dialog with Cancel and Done buttons, and return the value the user confirmed, or `null` if they cancelled or dismissed it:

```dart
final date = await showAwesomeDatePicker(
  context,
  title: Text('Birthday'),
  maxDate: AwesomeDate(year: 2025, month: 12, day: 31),
);
if (date != null) { /* ... */ }

final time = await showAwesomeTimePicker(context, timeFormat: AwesomeTimeFormat.hm, minuteInterval: 15);
final range = await showAwesomeDateRangePicker(context, minLength: 1, presentation: AwesomePickerPresentation.dialog);
```
Each function accepts the usual options of its picker (range, formats, locale, exclusions, `looping`, `wheelStyle`, ...) and these modal options:

| Option | Meaning |
|--------|---------|
| `title` | Widget shown between the buttons |
| `confirmText`, `cancelText` | Button texts (default: the localized `MaterialLocalizations` ones) |
| `presentation` | `AwesomePickerPresentation.bottomSheet` (default) or `.dialog` |
| `useRootNavigator`, `barrierDismissible`, `barrierColor`, `routeSettings` | As in `showModalBottomSheet` / `showDialog` |
| `backgroundColor`, `shape` | Appearance of the sheet or dialog |

For any option that is not listed, use the generic `showAwesomePicker`: you create the controller and build the picker, and it provides the sheet or dialog and returns `controller.value` on Done:

```dart
final controller = AwesomeDatePickerController();
final date = await showAwesomePicker<AwesomeDate>(
  context,
  controller: controller,
  builder: (context) => AwesomeDatePicker(
    controller: controller,
    wheelStyle: AwesomeWheelStyle(magnification: 1.1),
  ),
);
controller.dispose();
```
If the user cancels, your controller is set back to the value it had when the modal opened.

## Behavior

### Controllers
Each picker accepts an optional controller, in the same spirit as `TextEditingController`. A controller is a `ValueNotifier`, so you can read `value`, assign it, listen to it, and `dispose` it:

```dart
final controller = AwesomeDatePickerController(
  initialValue: AwesomeDate(year: 2025, month: 6, day: 15),
);

AwesomeDatePicker(controller: controller);

controller.value = AwesomeDate(year: 2025, month: 12, day: 25); // the wheels move
print(controller.value); // always the date shown by the wheels
controller.reset(); // back to the initial value
controller.addListener(() => print(controller.value)); // every change
```

| Picker | Controller | `value` type |
|--------|------------|--------------|
| `AwesomeDatePicker` | `AwesomeDatePickerController` | `AwesomeDate` |
| `AwesomeTimePicker` | `AwesomeTimePickerController` | `AwesomeTime` |
| `AwesomeDateTimePicker` | `AwesomeDateTimePickerController` | `AwesomeDateTime` |

- The picker starts at `controller.value`, so pass either `controller` or `initial*`, not both.
- `value` always matches what the wheels show. If you assign something the picker cannot select (outside the range, on an excluded weekday or hour, off the `minuteInterval`), the closest selectable value is shown and `value` is updated to it.
- `onChanged` is only called for changes made by the user. Changes made through the controller do not call it; listen to the controller to be notified of everything.
- The controller is optional: without one the pickers work exactly as before.

### Changing properties after the first build
Changing `minDate`/`maxDate`/`locale`/`excludedWeekdays` (date picker), `minTime`/`maxTime`/`excludedHours` (time picker) or `minDateTime`/`maxDateTime` (date-time picker) updates the wheels and **keeps the current selection**, clamped into the new range. If the clamping changes the value, `onChanged` is called with the new one.

The `initial*` value is only read once. To move the selection programmatically, give the picker a new `Key`.

### Light and dark mode
Colors and text styles follow the brightness of your app's `Theme`. You can override any of them; the precedence, highest first, is:

1. the per-wheel `ItemTheme` passed through `theme`,
2. the options on the picker (`backgroundColor`, `selectorColor`, `selectedTextStyle`, `unselectedTextStyle`, `itemHeight`, `itemWidth`, `wheelStyle`),
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

### Any language with `intl`
For every other language, pass the name of any locale known by [`intl`](https://pub.dev/packages/intl) as `localeName`:

```dart
AwesomeDatePicker(localeName: 'pt_BR')
AwesomeTimePicker(timeFormat: AwesomeTimeFormat.hm, localeName: 'ja')
AwesomeDateTimePicker(localeName: Localizations.localeOf(context).toString()) // follow the app
```
`localeName` replaces `locale` and localizes:

- the month names (`janvier`, `1月`, ...) and, with `showWeekday`, the weekday names,
- the AM/PM markers of the 12-hour formats (`午前` / `午後`),
- the digits of the wheels, for the locales that do not use 0-9 (for example `'fa'`, `'bn'`, `'mr'` or `'ar_EG'` show `۱۵` or `١٥`).

The values returned by the pickers and the controllers are always plain numbers (`AwesomeDate`, `AwesomeTime`); only what is displayed changes. A name `intl` has no data for falls back to the closest language (`fr_CH` to `fr`) and to English if there is none. `LocaleType` keeps working and its names are unchanged.

Using `localeName` needs no setup (no `initializeDateFormatting` call). Note that the package depends on `intl` (`>=0.19.0 <1.0.0`, which includes the version pinned by `flutter_localizations`) and includes its embedded date data for every locale in your app.

### AwesomeDateFormat
The date format only changes how the date is displayed. The value returned by the pickers is always an `AwesomeDate`.

| Date Format | Example           |
|-------------|-------------------|
| dMy         | 1/1/2025          |
| dMMy        | 1 January 2025    |
| yMd         | 2025/1/1          |
| yMMd        | 2025 January 1    |
| My          | 1/2025            |
| MMy         | January 2025      |
| yM          | 2025/1            |
| yMM         | 2025 January      |

The last four formats have no day wheel, so they select a whole month: the returned `AwesomeDate` is the first day of the chosen month, `minDate` and `maxDate` count as whole months, and day exclusions (`excludedWeekdays`, `excludedDates`, `selectableDayPredicate`, `showWeekday`) do not apply. `AwesomeDateTimePicker` needs a format with a day wheel.

```dart
    dateFormat: AwesomeDateFormat.dMMy,
```

### AwesomeTimeFormat
The time format only changes how the time is displayed. The value returned by the pickers is always on a 24-hour clock.

| Time Format | Example        |
|-------------|----------------|
| Hm          | 13:00          |
| hm          | 1:00 PM        |
| Hms         | 13:00:30       |
| hms         | 1:00:30 PM     |

```dart
    timeFormat: AwesomeTimeFormat.hm,
```

### Minute interval
Offer only every 5, 10, 15 or 30 minutes (any divisor of 60):
```dart
AwesomeTimePicker(minuteInterval: 15) // 00, 15, 30, 45
```
`minTime` and `maxTime` are moved onto the grid (the minimum up, the maximum down) and the initial time is rounded to the nearest step, so the picker never shows or reports an off-grid time.

### Looping wheels
```dart
AwesomeTimePicker(looping: true) // 59 -> 00 -> 01 ...
```
Looping applies to the day, month, hour and minute wheels. It does not carry over: going from minute 59 to 00 keeps the same hour. The year and AM/PM wheels never loop.

### Haptic feedback
```dart
AwesomeDatePicker(enableHapticFeedback: true)
```
A light tick plays each time dragging moves a wheel to another item. It stays silent for programmatic changes and screen-reader actions.

### Wheel style
`AwesomeWheelStyle` customizes the look of the wheels of a picker:

```dart
class AwesomeWheelStyle {
    double? diameterRatio; // Wheel diameter relative to its height; larger is flatter (default 1.5).
    double? perspective; // Curvature, from 0 (flat) to 0.01 (default 0.01).
    double? magnification; // Scale of the selected item (default 1).
    double? squeeze; // Packing of the items; above 1 shows more items (default 1).
    double? overAndUnderCenterOpacity; // Opacity of the items around the selected one, 0 to 1 (default 1).
    BorderRadius? selectorBorderRadius; // Corner radius of the selector highlight.
    Decoration? selectorDecoration; // Fully custom selector; replaces selectorColor and the radius.
}
```
```dart
AwesomeTimePicker(
  wheelStyle: AwesomeWheelStyle(
    diameterRatio: 2.5,
    magnification: 1.15,
    selectorBorderRadius: BorderRadius.circular(12),
  ),
)
```
The style applies to every wheel of the picker; use `ItemTheme` to style one wheel.

### Seconds
Use `AwesomeTimeFormat.Hms` (24-hour) or `AwesomeTimeFormat.hms` (12-hour) to add a seconds wheel:
```dart
AwesomeTimePicker(
  timeFormat: AwesomeTimeFormat.Hms,
  secondInterval: 15, // 00, 15, 30, 45
  onChanged: (AwesomeTime time) => print('${time.hour}:${time.minute}:${time.second}'),
)
```
`AwesomeTime` has an optional `second` (default 0), so existing code is unaffected. Without a seconds wheel the seconds are always 0: an input such as `10:07:45` is rounded to the nearest minute. `minTime` and `maxTime` may have seconds when the format shows them. The `secondTheme` of `AwesomeTimePickerTheme` styles the seconds wheel (it falls back to `minuteTheme`).

### Weekday labels
```dart
AwesomeDatePicker(showWeekday: true) // "Mon 12", "Tue 13", ...
```
The weekday names follow `locale`. The value returned by the picker is still a plain `AwesomeDate`.

### Excluding values
```dart
AwesomeDatePicker(excludedWeekdays: [DateTime.saturday, DateTime.sunday])
AwesomeTimePicker(excludedHours: [12, 13])
```
If the selected value lands on an excluded one, the picker moves to the nearest valid value, never leaving the min/max range. Excluding everything fails an assert in debug mode.

#### Excluding specific dates
Holidays, booked days or any other rule, alone or combined with `excludedWeekdays`:
```dart
AwesomeDatePicker(
  excludedWeekdays: [DateTime.saturday, DateTime.sunday],
  excludedDates: [AwesomeDate(year: 2025, month: 12, day: 25)],
  selectableDayPredicate: (date) => !holidays.contains(date), // e.g. loaded from an API
)
```
The predicate is called for many dates while the wheels are built, so keep it fast. Pass a stable function (a method or a top-level function) rather than a new closure on every build: a different function re-applies the rules and rebuilds the wheels.

#### Showing excluded values dimmed
By default excluded values are removed from the wheels. With `showDisabledValues: true` they stay visible but dimmed, so users can see why a value is missing:
```dart
AwesomeDatePicker(
  excludedWeekdays: [DateTime.saturday, DateTime.sunday],
  showDisabledValues: true,
  disabledTextStyle: TextStyle(color: Colors.grey), // optional
)
```
Dimmed values cannot be selected: when a drag settles on one, the wheel moves to the nearest selectable value (in the direction of the drag if two are equally close), and `onChanged` is never called for a dimmed value. A wheel can also be styled through `ItemTheme.disabledTextStyle`.

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
    ItemTheme? secondTheme; // Theme for the second wheel (defaults to minuteTheme).
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
    TextStyle? disabledTextStyle; // Text style of the dimmed values (see showDisabledValues).
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
| `core/`     | Models (`AwesomeDate`, `AwesomeTime`, `AwesomeDateTime`, `AwesomeDateRange`), formats, locales, utils and validation |
| `shared/`   | The wheel widget, `ItemTheme`, `AwesomeWheelStyle` and the helper that builds a wheel |
| `date/`     | `AwesomeDatePicker`, its public controller, its theme and `DatePickerLogic` |
| `time/`     | `AwesomeTimePicker`, its public controller, its theme and `TimePickerLogic` |
| `datetime/` | `AwesomeDateTimePicker`, its public controller, its theme and `DateTimePickerLogic` |
| `range/`    | `AwesomeDateRangePicker` and its public controller |
| `modal/`    | `showAwesomePicker` and the `showAwesome...Picker` functions |

The `*PickerLogic` classes hold all the logic (clamping, exclusions, the items of each wheel) and have no widget code, so they can be unit-tested directly. The public `Awesome*PickerController` classes are the small, stable API for users. Run `flutter test` and `flutter analyze` before opening a pull request; every public member must have a doc comment.
