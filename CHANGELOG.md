## 0.0.1

* Initial date, time and datetime pickers.

## 0.0.2

* Small performance improvements.

## 0.0.3

* Fix minDate and minTime associated selected date bug.

## 0.0.4

* Documentation and small performance improvements.

## 0.1.0

* Add AM/PM format for time and datetime pickers.

## 0.1.1

* Add asserts.

## Unreleased

* Dark mode: default colors follow the app theme brightness; explicit colors still take precedence.
* The pickers react to changed `min*`, `max*`, `locale` and excluded values and keep the selection (clamped).
* The date, time and date-time pickers now default to the current date/time as documented, instead of the minimum.
* Fix a valid `initialDate` being reset to `minDate` when its day was lower than the day of `minDate`.
* Fix `initialTime` outside the range being reset to `minTime` instead of the nearest bound.
* Fix `onChanged` being called when the selection did not change.
* `AwesomeTimePickerTheme.ampmTheme` is now applied to the AM/PM wheel (falls back to `hourTheme`).
* Fix excluded hours moving the selected time outside `minTime`..`maxTime`.
* Month-name wheels are wider by default and default wheel widths are bounded (no truncated "September" on phones, no huge wheels on desktop/web).
* Minutes and 24-hour hours are zero-padded ("09:05").
* Mouse and trackpad dragging now works on web and desktop.
* Wheels expose an adjustable value to screen readers.
* Asserts (debug mode) for impossible `AwesomeDate`/`AwesomeTime` values, for exclusions that leave nothing selectable, and for invalid `AwesomeDateTimePicker` ranges.
* Calendar-based day stepping so weekday exclusions are correct around daylight-saving changes.
* Add `minuteInterval` to the time and date-time pickers (e.g. 5, 15, 30).
* Add `looping` wheels (day, month, hour and minute).
* Add opt-in haptic feedback (`enableHapticFeedback`).
* Add `AwesomeWheelStyle` (`wheelStyle`): diameter ratio, perspective, magnification, squeeze, opacity around the selection and a custom selector shape or decoration.
* Add public controllers (`AwesomeDatePickerController`, `AwesomeTimePickerController`, `AwesomeDateTimePickerController`): `ValueNotifier`s to read, set and `reset()` the selection from code. `onChanged` stays reserved for user edits.
* Add `excludedDates` and `selectableDayPredicate` to exclude holidays and any other date (date and date-time pickers).
* Add `showDisabledValues` and `disabledTextStyle` to keep excluded values visible, dimmed, with snapping to the nearest selectable value.
* Add month and year only formats (`AwesomeDateFormat.My`, `MMy`, `yM`, `yMM`): the picker returns the first day of the month.
* Add `showWeekday` to show the weekday on the day wheel ("Mon 12").
* Add a seconds wheel: `AwesomeTimeFormat.Hms` and `hms`, `secondInterval`, `AwesomeTime.second` (default 0, existing code is unaffected) and `AwesomeTimePickerTheme.secondTheme`.
* The nearest-selectable-date search for exclusions now covers the whole min/max range instead of 30 days.
* Add `localeName` to every picker: any locale known by `intl` localizes the month names, the weekday names (`showWeekday`), the AM/PM markers and the digits (e.g. `fa`, `ar_EG`). `LocaleType` is unchanged. The package now depends on `intl` (`>=0.19.0 <1.0.0`).
* Add `AwesomeDateRangePicker` and `AwesomeDateRange`: pick a start and an end date, with `minLength`/`maxLength`, the exclusions applying to both dates, labels, a controller (`AwesomeDateRangePickerController`) and the usual styling options.
* Add `showAwesomePicker`, `showAwesomeDatePicker`, `showAwesomeTimePicker`, `showAwesomeDateTimePicker` and `showAwesomeDateRangePicker` to show a picker in a bottom sheet or a dialog with Cancel and Done buttons and get the confirmed value.
* Fix pickers stretching to the full height of a bounded parent (e.g. `Center(child: AwesomeDatePicker())` showed the picker at the top): a picker is now only as tall as its wheels.
* Documentation: README reorganized (demo, feature list, gallery, quick start, one options table, upgrade notes), new screenshots and an animated demo regenerated from the real widgets by `tool/generate_screenshots_test.dart`, screenshot gallery on pub.dev, complete API documentation.
* Internal restructuring into feature folders; the public API is unchanged.
