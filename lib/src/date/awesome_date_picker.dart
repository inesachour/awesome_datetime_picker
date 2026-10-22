import 'package:awesome_datetime_picker/src/date/awesome_date_picker_controller.dart';
import 'package:awesome_datetime_picker/src/core/data/format.dart';
import 'package:awesome_datetime_picker/src/core/data/locale.dart';
import 'package:awesome_datetime_picker/src/core/data/picker_type.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_date.dart';
import 'package:awesome_datetime_picker/src/date/awesome_date_picker_theme.dart';
import 'package:awesome_datetime_picker/src/shared/item_theme.dart';
import 'package:awesome_datetime_picker/src/core/utils/awesome_date_utils.dart';
import 'package:awesome_datetime_picker/src/core/utils/validation_utils.dart';
import 'package:awesome_datetime_picker/src/shared/custom_item_picker_style.dart';
import 'package:awesome_datetime_picker/src/shared/picker_wheel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// An iOS-style wheel picker for selecting a date.
///
/// ```dart
/// AwesomeDatePicker(
///   minDate: AwesomeDate(year: 2024, month: 2, day: 15),
///   maxDate: AwesomeDate(year: 2026, month: 10, day: 10),
///   dateFormat: AwesomeDateFormat.dMMy,
///   excludedWeekdays: [DateTime.saturday, DateTime.sunday],
///   onChanged: (date) => debugPrint('$date'),
/// )
/// ```
///
/// The wheels only offer dates between [minDate] and [maxDate] that are not
/// on an excluded weekday, and the day wheel adapts to the length of the
/// selected month (including leap years).
///
/// /// ## Styling
///
/// Colors and text styles follow the ambient [Theme] brightness (light or
/// dark) unless overridden. Precedence, highest first: the per-wheel
/// [ItemTheme] given through `theme`, then the options on this widget
/// (`backgroundColor`, `selectorColor`, `selectedTextStyle`, ...), then the
/// built-in defaults.
///
/// ## Changing properties after the first build
///
/// Changing [minDate], [maxDate], [locale] or [excludedWeekdays] rebuilds the picker's rules and keeps the current selection, clamped into the new range. If the clamping changes the value, [onChanged] is called with the new one.
///
/// The `initial*` value is only read once; to move the selection later, give
/// the picker a new [Key].
///
/// Throws an [AssertionError] in debug mode if [minDate] is after [maxDate]
/// or [initialDate] is outside that range.
class AwesomeDatePicker extends StatefulWidget {
  /// Creates a date picker. All parameters are optional.
  AwesomeDatePicker({
    super.key,
    this.minDate,
    this.maxDate,
    this.initialDate,
    this.locale = LocaleType.en,
    this.dateFormat = AwesomeDateFormat.dMy,
    this.theme,
    this.onChanged,
    this.backgroundColor,
    this.fadeEffect,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.selectorColor,
    this.visibleItemCount,
    this.itemHeight,
    this.itemWidth,
    this.excludedWeekdays,
  })  : assert(
          ValidationUtils.isValidDateRange(minDate: minDate, maxDate: maxDate),
          'minDate must be before maxDate',
        ),
        assert(
          ValidationUtils.isValidInitialDate(
              date: initialDate, minDate: minDate, maxDate: maxDate),
          'initialDate must be within minDate and maxDate range',
        );

  /// The minimum selectable date for the date picker (default 1/1/1900).
  final AwesomeDate? minDate;

  /// The maximum selectable date for the date picker (default 31/12/2100).
  final AwesomeDate? maxDate;

  /// The initial date displayed when the picker is first shown (default current date).
  final AwesomeDate? initialDate;

  /// The locale to use for displaying the date format (default [LocaleType.en]).
  final LocaleType locale;

  /// The format of the date to be displayed in the picker (default [AwesomeDateFormat.dMy]).
  final AwesomeDateFormat dateFormat;

  /// The theme for customizing the appearance of the date picker (year, month, day themes).
  final AwesomeDatePickerTheme? theme;

  /// A callback function that is triggered when the selected date changes.
  final ValueChanged<AwesomeDate>? onChanged;

  /// The background color of the date picker.
  /// This value is overridden by the value passed in the theme's backgroundColor property.
  final Color? backgroundColor;

  /// The color of the selector (highlight) used in the date picker.
  final Color? selectorColor;

  /// A flag to indicate whether to apply a fade effect on the edges of the picker (default true).
  final bool? fadeEffect;

  /// The text style for the selected date.
  /// This value is overridden by the value passed in the theme's selectedTextStyle property.
  final TextStyle? selectedTextStyle;

  /// The text style for the unselected dates
  /// This value is overridden by the value passed in the theme's unselectedTextStyle property.
  final TextStyle? unselectedTextStyle;

  /// The number of visible items in the date picker at once.
  final int? visibleItemCount;

  /// The height of each item in the date picker.
  /// This value is overridden by the value passed in the theme's height property.
  final double? itemHeight;

  /// The width of each item in the date picker.
  /// This value is overridden by the value passed in the theme's width property.
  final double? itemWidth;

  /// List of weekdays to exclude (1 = Monday, 7 = Sunday).
  final List<int>? excludedWeekdays;

  @override
  State<AwesomeDatePicker> createState() => _AwesomeDatePickerState();
}

class _AwesomeDatePickerState extends State<AwesomeDatePicker> {
  late AwesomeDatePickerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _createController(initialDate: widget.initialDate);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(AwesomeDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    final configChanged = oldWidget.minDate != widget.minDate ||
        oldWidget.maxDate != widget.maxDate ||
        oldWidget.locale != widget.locale ||
        !listEquals(oldWidget.excludedWeekdays, widget.excludedWeekdays);
    if (!configChanged) return;

    // Rebuild the controller with the new rules, keeping the current
    // selection (it is clamped into the new range if needed).
    final previous = _controller.selectedDate;
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _controller = _createController(initialDate: previous);
    _controller.addListener(_onControllerChanged);

    if (_controller.selectedDate != previous) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onChanged?.call(_controller.selectedDate);
      });
    }
  }

  AwesomeDatePickerController _createController({AwesomeDate? initialDate}) {
    return AwesomeDatePickerController(
      minDate: widget.minDate ?? AwesomeDate(year: 1900, month: 1, day: 1),
      maxDate: widget.maxDate ?? AwesomeDate(year: 2100, month: 12, day: 31),
      locale: widget.locale,
      initialDate: initialDate,
      excludedWeekdays: widget.excludedWeekdays,
    );
  }

  void _onControllerChanged() {
    widget.onChanged?.call(_controller.selectedDate);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.dateFormat.value.length, (index) {
        final type = widget.dateFormat.value[index];
        return _buildPicker(type);
      }),
    );
  }

  Widget _buildPicker(PickerType type) {
    switch (type) {
      case PickerType.year:
        return _buildItemPicker(
          items: _controller.years,
          initialValue: _controller.selectedDate.year.toString(),
          theme: widget.theme?.yearTheme,
          onChanged: _controller.onSelectedYearChanged,
        );
      case PickerType.month_number:
        return _buildItemPicker(
          items: _controller.monthsNumbers,
          initialValue: _controller.selectedDate.month.toString(),
          theme: widget.theme?.monthTheme,
          onChanged: _controller.onSelectedMonthNumberChanged,
        );
      case PickerType.month_text:
        return _buildItemPicker(
          items: _controller.monthsNames,
          initialValue: AwesomeDateUtils.getMonthNames(
              widget.locale)[_controller.selectedDate.month - 1],
          theme: widget.theme?.monthTheme,
          onChanged: _controller.onSelectedMonthNameChanged,
        );
      case PickerType.day:
        return _buildItemPicker(
          key: ValueKey(
              _controller.selectedDate.month == _controller.minDate.month
                  ? "day_picker 1"
                  : _controller.selectedDate.month == _controller.maxDate.month
                      ? "day_picker 2"
                      : "day_picker 3"),
          items: _controller.days,
          initialValue: _controller.selectedDate.day.toString(),
          theme: widget.theme?.dayTheme,
          onChanged: _controller.onSelectedDayChanged,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildItemPicker({
    Key? key,
    required List<String> items,
    required String initialValue,
    required ItemTheme? theme,
    required ValueChanged<String> onChanged,
  }) {
    return buildPickerWheel(
      key: key,
      items: items,
      value: initialValue,
      theme: theme,
      style: CustomItemPickerStyle(
        backgroundColor: widget.backgroundColor,
        selectorColor: widget.selectorColor,
        fadeEffect: widget.fadeEffect,
        selectedTextStyle: widget.selectedTextStyle,
        unselectedTextStyle: widget.unselectedTextStyle,
        itemHeight: widget.itemHeight,
        itemWidth: widget.itemWidth,
      ),
      visibleItemCount: widget.visibleItemCount,
      onChanged: onChanged,
    );
  }
}
