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
* Complete API documentation and README.
* Internal restructuring into feature folders; the public API is unchanged.
