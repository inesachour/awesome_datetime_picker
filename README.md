# Awesome DatetTime Picker

## Overview
The "Awesome DateTime Picker" is a Flutter package that offers customizable date, time, and date-time pickers widgets with a sliding style inspired by the "CupertinoDatePicker".

## Pickers

### Date Picker
<p align="center" width="100%">
    <img src="https://github.com/inesachour/awesome_datetime_picker/blob/master/images/date_picker.jpg?raw=true" height="200">
</p>

```dart
AwesomeDatePicker(
    AwesomeDate? minDate; // The minimum selectable date.
    AwesomeDate? maxDate; // The maximum selectable date.
    AwesomeDate? initialDate; // The initially selected date.
    LocaleType locale; // The locale used for date formatting.
    AwesomeDateFormat dateFormat; // The format for displaying the date.
    AwesomeDatePickerTheme? theme; // Custom theme for the date picker.
    final ValueChanged<AwesomeDate>? onChanged; // Callback triggered when the date is changed.
    Color? backgroundColor; // Background color of the picker.
    Color? selectorColor; // Color of the selected item indicator.
    bool? fadeEffect; // Whether to apply a fade effect on non-selected items.
    TextStyle? selectedTextStyle; // Text style for the selected item.
    TextStyle? unselectedTextStyle; // Text style for unselected items.
    int? visibleItemCount; // Number of items visible at a time in the picker.
    double? itemHeight; // Height of each item in the picker.
    double? itemWidth; // Width of each item in the picker.
)
```


### Time Picker
<p align="center" width="100%">
    <img src="https://github.com/inesachour/awesome_datetime_picker/blob/master/images/time_picker.jpg?raw=true" height="200">
</p>

```dart
AwesomeTimePicker(
    AwesomeTime? minTime; // The minimum selectable time.
    AwesomeTime? maxTime; // The maximum selectable time.
    AwesomeTime? initialTime; // The initially selected time.
    AwesomeTimeFormat timeFormat; // The format for displaying the time (12-hour or 24-hour).
    AwesomeTimePickerTheme? theme; // Custom theme for the time picker.
    final ValueChanged<AwesomeTime>? onChanged; // Callback triggered when the time is changed.
    Color? backgroundColor; // Background color of the picker.
    Color? selectorColor; // Color of the selected item indicator.
    bool? fadeEffect; // Whether to apply a fade effect on non-selected items.
    TextStyle? selectedTextStyle; // Text style for the selected item.
    TextStyle? unselectedTextStyle; // Text style for unselected items.
    int? visibleItemCount; // Number of items visible at a time in the picker.
    double? itemHeight; // Height of each item in the picker.
    double? itemWidth; // Width of each item in the picker.
)
```


### DateTime Picker
<p align="center" width="100%">
    <img src="https://github.com/inesachour/awesome_datetime_picker/blob/master/images/datetime_picker.jpg?raw=true" height="200">
</p>

```dart
AwesomeDateTimePicker(
    AwesomeDateTime? minDateTime; // The minimum selectable date and time.
    AwesomeDateTime? maxDateTime; // The maximum selectable date and time.
    AwesomeDateTime? initialDateTime; // The initially selected date and time.
    LocaleType locale; // The locale used for date and time formatting.
    AwesomeDateFormat dateFormat; // The format for displaying the date.
    AwesomeTimeFormat timeFormat; // The format for displaying the time.
    AwesomeDateTimePickerTheme? theme; // Custom theme for the picker.
    final ValueChanged<AwesomeDateTime>? onChanged; // Callback triggered when the date/time is changed.
    Color? backgroundColor; // Background color of the picker.
    Color? selectorColor; // Color of the selected item indicator.
    bool? fadeEffect; // Whether to apply a fade effect on non-selected items.
    TextStyle? selectedTextStyle; // Text style for the selected item.
    TextStyle? unselectedTextStyle; // Text style for unselected items.
    int? visibleItemCount; // Number of items visible at a time in the picker.
    double? itemHeight; // Height of each item in the picker.
    double? itemWidth; // Width of each item in the picker.
)
```

## Customization
### LocaleType
The following table lists the currently supported locales for the date and datetimer pickers:

| Locale Code | Language         |
|-------------|------------------|
| en          | English          |
| fr          | French           |
| es          | Spanish          |
| de          | German           |
| it          | Italian          |
| ar          | Arabic           |

To use a locale, set it as follows:
```dart
    locale: LocaleType.en
```
### AwesomeDateFormat
The following date format values are only for the display of the date and do not affect the returned value from the date or datetime picker (which stays as the default):

| Date Format | Example           |
|-------------|-------------------|
| dMy         | 1/1/2025          |
| dMMy        | 1 January 2025    |
| yMd         | 2025/1/1          |
| yMMd        | 2025 January 1    |

To use a date format, set it as follows:
```dart
    dateFormat: AwesomeDateFormat.dMMy,
```

### AwesomeTimeFormat
The following time format values are only for the display of the time and do not affect the returned value from the timr or datetime picker (which stays as the default):

| Time Format | Example        |
|-------------|----------------|
| dMy         | 13:00          |

To use a date format, set it as follows:
```dart
    timeFormat: AwesomeTimeFormat.Hm,
```

### AwesomeDateTimePickerTheme