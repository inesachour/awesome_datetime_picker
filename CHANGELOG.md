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

## 0.2.0

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
* Add conversions: `AwesomeDate.today()` / `fromDateTime`, `AwesomeTime.now()` / `fromDateTime` / `fromTimeOfDay` / `toTimeOfDay()`, `AwesomeDateTime.now()` / `fromDateTime`.
* Large-text support: the default item height follows the system text size (up to 2x); text too big for its wheel shrinks to fit instead of being cut.
* Add wheel style presets `AwesomeWheelStyle.ios()`, `.material()` and `.minimal()`, and `AwesomeWheelStyle.copyWith`.
* Add date formats without a year wheel (`AwesomeDateFormat.dM`, `dMM`, `Md`, `MMd`) for birthdays and repeating dates; 29 February is selectable.
* Accessibility: every wheel announces a label before its value ("Day, 15") for screen readers, in English, French, German, Spanish, Italian or Arabic following `locale` / `localeName`; `semanticLabels` (`AwesomeSemanticLabels`) overrides any word or adds another language. The range picker prefixes "Start date" / "End date".
* Keyboard navigation: Tab between wheels, Up/Down, Page Up/Page Down, Home/End, Left/Right, with a focus outline (`AwesomeWheelStyle.focusColor`). A mouse click focuses a wheel; a touch does not.
* Fix a wheel reporting a wrong selection, in the middle of the parent's build, when its list changed length in a rebuild (e.g. toggling `showDisabledValues`): the app's `setState` in a controller listener threw "setState() called during build" and the selected value could change. The wheel now moves to its new item after layout and does not report it.
* A picker wider than its parent (many or wide wheels on a narrow screen) now shrinks to fit instead of overflowing. As a consequence a picker is exactly as wide as its wheels; it used to fill the width of a bounded parent with the wheels centered.
* Add `AwesomePickerThemeData`, a `ThemeExtension` that sets the colors, text styles, sizes and `AwesomeWheelStyle` of every picker once in `ThemeData` (with `lerp`, so theme changes animate). Precedence: per-wheel `ItemTheme`, then picker options, then the theme, then the defaults; `wheelStyle` is merged property by property. Add `AwesomeWheelStyle.mergedOver` and `AwesomeWheelStyle.lerp`.
* Add `AwesomeDurationPicker`, `AwesomeDurationPickerController` and `AwesomeDurationPickerTheme`: pick a `Duration` in hours and minutes, minutes and seconds, or all three (`AwesomeDurationFormat`), with `minDuration`/`maxDuration` (the first wheel is not limited to 59), minute and second intervals, looping, semantic labels, localized digits and the usual styling. `showAwesomeDurationPicker` shows it in a bottom sheet or a dialog.
* Internal restructuring into feature folders; the public API is unchanged.

## 0.2.1

* Fix the README images not showing on pub.dev: pub.dev drops relative image paths inside HTML, so the images now use absolute URLs.

## 0.2.2

* Documentation: the README is now only for people who use the package. The sections for contributors (code layout, release checks, screenshots, the live demo setup) moved to `CONTRIBUTING.md` on GitHub.
