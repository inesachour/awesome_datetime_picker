# Awesome DatetTime Picker

## Overview
The "Awesome DateTime Picker" is a Flutter package that offers customizable date, time, and date-time pickers widgets with a sliding style inspired by the "CupertinoDatePicker".

## Pickers

### Date Picker
```dart
AwesomeDatePicker(
    dateFormat: AwesomeDateFormat.dMMy,
    onChanged: (AwesomeDate date) {},
),
```
<p align="center" width="100%">
    <img src="https://github.com/inesachour/awesome_datetime_picker/blob/master/images/date_picker.jpg?raw=true" height="200">
</p>

```dart
AwesomeDatePicker(
    AwesomeDate? minDate;
    AwesomeDate? maxDate;
    AwesomeDate? initialDate;
    LocaleType locale;
    AwesomeDateFormat dateFormat;
    AwesomeDatePickerTheme? theme;
    final ValueChanged<AwesomeDate>? onChanged;
    Color? backgroundColor;
    Color? selectorColor;
    bool? fadeEffect;
    TextStyle? selectedTextStyle;
    TextStyle? unselectedTextStyle;
    int? visibleItemCount;
    double? itemHeight;
    double? itemWidth;
)
```


### Time Picker
```dart
AwesomeTimePicker(
    timeFormat: AwesomeTimeFormat.Hm,
    onChanged: (AwesomeDate date) {},
),
```
<p align="center" width="100%">
    <img src="https://github.com/inesachour/awesome_datetime_picker/blob/master/images/time_picker.jpg?raw=true" height="200">
</p>

```dart
AwesomeTimePicker(
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
    int? visibleItemCount;
    double? itemHeight;
    double? itemWidth;
)
```


### DateTime Picker
```dart
AwesomeDateTimePicker(
    dateFormat: AwesomeDateFormat.dMMy,
    onChanged: (AwesomeDate date) {},
),
```
<p align="center" width="100%">
    <img src="https://github.com/inesachour/awesome_datetime_picker/blob/master/images/datetime_picker.jpg?raw=true" height="200">
</p>

```dart
AwesomeDateTimePicker(
    AwesomeDateTime? minDateTime; // this is min datetime
    AwesomeDateTime? maxDateTime;
    AwesomeDateTime? initialDateTime;
    LocaleType locale;
    AwesomeDateFormat dateFormat;
    AwesomeTimeFormat timeFormat;
    AwesomeDateTimePickerTheme? theme;
    final ValueChanged<AwesomeDateTime>? onChanged;
    Color? backgroundColor;
    Color? selectorColor;
    bool? fadeEffect;
    TextStyle? selectedTextStyle;
    TextStyle? unselectedTextStyle;
    int? visibleItemCount;
    double? itemHeight;
    double? itemWidth;
)
```

## Customization
###