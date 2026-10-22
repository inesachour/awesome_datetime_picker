import 'package:awesome_datetime_picker/src/date/awesome_date_picker_controller.dart';
import 'package:awesome_datetime_picker/src/date/date_picker_logic.dart';
import 'package:awesome_datetime_picker/src/core/data/format.dart';
import 'package:awesome_datetime_picker/src/core/data/locale.dart';
import 'package:awesome_datetime_picker/src/core/data/picker_type.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_date.dart';
import 'package:awesome_datetime_picker/src/date/awesome_date_picker_theme.dart';
import 'package:awesome_datetime_picker/src/shared/item_theme.dart';
import 'package:awesome_datetime_picker/src/core/utils/awesome_date_utils.dart';
import 'package:awesome_datetime_picker/src/core/utils/awesome_intl.dart';
import 'package:awesome_datetime_picker/src/core/utils/validation_utils.dart';
import 'package:awesome_datetime_picker/src/shared/awesome_wheel_style.dart';
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
    this.localeName,
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
    this.looping = false,
    this.enableHapticFeedback = false,
    this.wheelStyle,
    this.excludedWeekdays,
    this.showWeekday = false,
    this.showDisabledValues = false,
    this.disabledTextStyle,
    this.excludedDates,
    this.selectableDayPredicate,
    this.controller,
  })  : assert(
          ValidationUtils.isValidDateRange(minDate: minDate, maxDate: maxDate),
          'minDate must be before maxDate',
        ),
        assert(
          ValidationUtils.isValidInitialDate(
              date: initialDate, minDate: minDate, maxDate: maxDate),
          'initialDate must be within minDate and maxDate range',
        ),
        assert(
          !dateFormat.hasDay ||
              ValidationUtils.hasSelectableDate(
                  minDate: minDate,
                  maxDate: maxDate,
                  excludedWeekdays: excludedWeekdays,
                  excludedDates: excludedDates,
                  selectableDayPredicate: selectableDayPredicate),
          'the exclusions leave no selectable date between minDate and maxDate',
        ),
        assert(
          controller == null || initialDate == null,
          'Pass either controller or initialDate, not both: the picker starts '
          'at controller.value',
        );

  /// The minimum selectable date for the date picker (default 1/1/1900).
  final AwesomeDate? minDate;

  /// The maximum selectable date for the date picker (default 31/12/2100).
  final AwesomeDate? maxDate;

  /// The initial date displayed when the picker is first shown (default current date).
  final AwesomeDate? initialDate;

  /// The locale to use for displaying the date format (default [LocaleType.en]).
  final LocaleType locale;

  /// Name of any locale known by `package:intl` (e.g. `'pt_BR'`, `'ja'`,
  /// `'ar_EG'`). It replaces [locale] and localizes the month names, the
  /// weekday names of [showWeekday] and the digits of the wheels (for locales
  /// that do not use 0-9, such as `'fa'` or `'ar_EG'`).
  ///
  /// A name `intl` has no data for falls back to the closest language, and to
  /// English if there is none. To follow the language of the app, pass
  /// `Localizations.localeOf(context).toString()`.
  final String? localeName;

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

  /// Whether the wheels wrap around from the last item to the first, like the
  /// iOS picker (default false). The year wheel never loops.
  final bool looping;

  /// Whether to play a light haptic tick each time dragging moves a wheel to
  /// another item (default false). Has no effect on platforms without haptics.
  final bool enableHapticFeedback;

  /// Advanced appearance of the wheels: curvature, magnification, selector
  /// shape and more. See [AwesomeWheelStyle].
  final AwesomeWheelStyle? wheelStyle;

  /// List of weekdays to exclude (1 = Monday, 7 = Sunday).
  final List<int>? excludedWeekdays;

  /// Whether the day wheel also shows the weekday, e.g. "Mon 12" (default
  /// false). The names follow [locale]. Only applies to formats that have a
  /// day wheel.
  final bool showWeekday;

  /// Whether values that cannot be selected (excluded weekdays and dates) stay visible, dimmed,
  /// instead of being removed from the wheels (default false).
  ///
  /// When a drag settles on a dimmed value, the wheel moves to the nearest
  /// selectable one. Style them with [disabledTextStyle].
  final bool showDisabledValues;

  /// Text style of the dimmed values shown with [showDisabledValues]
  /// (default: the unselected style at reduced opacity). Overridden by the
  /// theme's `disabledTextStyle` of the wheel.
  final TextStyle? disabledTextStyle;

  /// Specific dates that cannot be selected, e.g. public holidays or days
  /// that are fully booked. Combines with [excludedWeekdays] and
  /// [selectableDayPredicate].
  final List<AwesomeDate>? excludedDates;

  /// Decides whether a date can be selected: return false to exclude it, for
  /// example for holidays loaded from an API. Combines with
  /// [excludedWeekdays] and [excludedDates].
  ///
  /// It is called for many dates while the wheels are built, so keep it
  /// fast. Pass a stable function (a method or a top-level function rather
  /// than a new closure on every build): a different function replaces the
  /// rules and rebuilds the wheels.
  final bool Function(AwesomeDate date)? selectableDayPredicate;

  /// Optional controller to read and change the selected date from code.
  ///
  /// When given, the picker starts at `controller.value` instead of `initialDate`
  /// (passing both is an error), and keeps `controller.value` in sync with
  /// the wheels. See [AwesomeDatePickerController].
  final AwesomeDatePickerController? controller;

  @override
  State<AwesomeDatePicker> createState() => _AwesomeDatePickerState();
}

class _AwesomeDatePickerState extends State<AwesomeDatePicker> {
  late DatePickerLogic _logic;

  /// True while applying a change that came from the public controller: the
  /// user did not edit anything, so `onChanged` stays silent.
  bool _applyingController = false;

  /// The `intl` locale used for [AwesomeDatePicker.localeName], if any, and
  /// the glyphs of its digits when they are not 0-9.
  String? _intlLocale;
  List<String>? _digitGlyphs;

  void _resolveLocale() {
    final name = widget.localeName;
    _intlLocale = name == null ? null : AwesomeIntl.resolve(name);
    _digitGlyphs =
        _intlLocale == null ? null : AwesomeIntl.digitGlyphs(_intlLocale!);
  }

  @override
  void initState() {
    super.initState();
    _resolveLocale();
    _logic = _createLogic(
        initialDate: widget.controller?.value ?? widget.initialDate);
    _logic.addListener(_onLogicChanged);
    widget.controller?.addListener(_onControllerChanged);
    _publishAfterFrame();
  }

  @override
  void didUpdateWidget(AwesomeDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
      if (widget.controller != null) {
        // Adopt the value of the new controller once this frame is built.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _onControllerChanged();
        });
      }
    }

    final configChanged = oldWidget.minDate != widget.minDate ||
        oldWidget.maxDate != widget.maxDate ||
        oldWidget.locale != widget.locale ||
        oldWidget.localeName != widget.localeName ||
        oldWidget.dateFormat.hasDay != widget.dateFormat.hasDay ||
        !listEquals(oldWidget.excludedWeekdays, widget.excludedWeekdays) ||
        !listEquals(oldWidget.excludedDates, widget.excludedDates) ||
        oldWidget.selectableDayPredicate != widget.selectableDayPredicate;
    if (!configChanged) return;

    // Rebuild the logic with the new rules, keeping the current selection
    // (it is clamped into the new range if needed).
    _resolveLocale();
    final previous = _logic.selectedDate;
    _logic.removeListener(_onLogicChanged);
    _logic.dispose();
    _logic = _createLogic(initialDate: previous);
    _logic.addListener(_onLogicChanged);

    if (_logic.selectedDate != previous) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onChanged?.call(_logic.selectedDate);
        _publish();
      });
    }
  }

  DatePickerLogic _createLogic({AwesomeDate? initialDate}) {
    return DatePickerLogic(
      minDate: widget.minDate ?? AwesomeDate(year: 1900, month: 1, day: 1),
      maxDate: widget.maxDate ?? AwesomeDate(year: 2100, month: 12, day: 31),
      locale: widget.locale,
      monthNames:
          _intlLocale == null ? null : AwesomeIntl.monthNames(_intlLocale!),
      initialDate: initialDate,
      hasDayWheel: widget.dateFormat.hasDay,
      excludedWeekdays: widget.excludedWeekdays,
      excludedDates: widget.excludedDates,
      selectableDayPredicate: widget.selectableDayPredicate,
    );
  }

  /// Writes the selection back to the controller: it can differ from the value
  /// that was requested (clamped into the range, moved off an excluded day).
  void _publish() {
    final controller = widget.controller;
    if (controller != null && controller.value != _logic.selectedDate) {
      controller.value = _logic.selectedDate;
    }
  }

  void _publishAfterFrame() {
    if (widget.controller == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _publish();
    });
  }

  void _onControllerChanged() {
    final value = widget.controller!.value;
    if (value == _logic.selectedDate) return;
    _applyingController = true;
    _logic.setSelectedDate(value);
    _applyingController = false;
    _publish();
  }

  void _onLogicChanged() {
    if (!_applyingController) widget.onChanged?.call(_logic.selectedDate);
    _publish();
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    _logic.removeListener(_onLogicChanged);
    _logic.dispose();
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
          items: _logic.years,
          initialValue: _logic.selectedDate.year.toString(),
          theme: widget.theme?.yearTheme,
          onChanged: _logic.onSelectedYearChanged,
        );
      case PickerType.month_number:
        return _buildItemPicker(
          items: _logic.monthsNumbers,
          initialValue: _logic.selectedDate.month.toString(),
          theme: widget.theme?.monthTheme,
          onChanged: _logic.onSelectedMonthNumberChanged,
          canLoop: true,
        );
      case PickerType.month_text:
        return _buildItemPicker(
          items: _logic.monthsNames,
          initialValue: _logic.monthNameOf(_logic.selectedDate.month),
          theme: widget.theme?.monthTheme,
          onChanged: _logic.onSelectedMonthNameChanged,
          wide: true,
          canLoop: true,
        );
      case PickerType.day:
        return _buildItemPicker(
          key: ValueKey(_logic.selectedDate.month == _logic.minDate.month
              ? "day_picker 1"
              : _logic.selectedDate.month == _logic.maxDate.month
                  ? "day_picker 2"
                  : "day_picker 3"),
          items: widget.showDisabledValues ? _logic.allDays : _logic.days,
          disabledIndices:
              widget.showDisabledValues ? _logic.disabledDayIndices : const {},
          labels: widget.showWeekday
              ? _weekdayLabels(
                  widget.showDisabledValues ? _logic.allDays : _logic.days)
              : null,
          initialValue: _logic.selectedDate.day.toString(),
          theme: widget.theme?.dayTheme,
          onChanged: _logic.onSelectedDayChanged,
          canLoop: true,
          wide: widget.showWeekday,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// "Mon 12"-style labels for the day values of the selected month.
  List<String> _weekdayLabels(List<String> days) {
    final names = _intlLocale == null
        ? AwesomeDateUtils.getWeekdayNames(widget.locale)
        : AwesomeIntl.weekdayNames(_intlLocale!);
    final year = _logic.selectedDate.year;
    final month = _logic.selectedDate.month;
    final glyphs = _digitGlyphs;
    return [
      for (final day in days)
        '${names[DateTime(year, month, int.parse(day)).weekday - 1]} '
            '${glyphs == null ? day : AwesomeIntl.localizeDigits(day, glyphs)}',
    ];
  }

  /// Labels showing the digits of [items] in the locale's own digits, or null
  /// when they are the usual 0-9.
  List<String>? _localizedDigits(List<String> items) {
    final glyphs = _digitGlyphs;
    if (glyphs == null) return null;
    return [for (final item in items) AwesomeIntl.localizeDigits(item, glyphs)];
  }

  Widget _buildItemPicker({
    Key? key,
    required List<String> items,
    List<String>? labels,
    Set<int> disabledIndices = const {},
    required String initialValue,
    required ItemTheme? theme,
    required ValueChanged<String> onChanged,
    bool wide = false,
    bool canLoop = false,
  }) {
    return buildPickerWheel(
      key: key,
      items: items,
      labels: labels ?? _localizedDigits(items),
      disabledIndices: disabledIndices,
      value: initialValue,
      theme: theme,
      style: CustomItemPickerStyle(
        backgroundColor: widget.backgroundColor,
        selectorColor: widget.selectorColor,
        fadeEffect: widget.fadeEffect,
        selectedTextStyle: widget.selectedTextStyle,
        unselectedTextStyle: widget.unselectedTextStyle,
        disabledTextStyle: widget.disabledTextStyle,
        itemHeight: widget.itemHeight,
        itemWidth: widget.itemWidth,
        wheelStyle: widget.wheelStyle,
      ),
      visibleItemCount: widget.visibleItemCount,
      onChanged: onChanged,
      wide: wide,
      looping: canLoop && widget.looping,
      hapticFeedback: widget.enableHapticFeedback,
    );
  }
}
