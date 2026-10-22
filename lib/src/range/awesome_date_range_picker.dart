import 'package:awesome_datetime_picker/src/core/data/format.dart';
import 'package:awesome_datetime_picker/src/core/data/locale.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_date.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_date_range.dart';
import 'package:awesome_datetime_picker/src/core/utils/validation_utils.dart';
import 'package:awesome_datetime_picker/src/date/awesome_date_picker.dart';
import 'package:awesome_datetime_picker/src/date/awesome_date_picker_controller.dart';
import 'package:awesome_datetime_picker/src/date/awesome_date_picker_theme.dart';
import 'package:awesome_datetime_picker/src/range/awesome_date_range_picker_controller.dart';
import 'package:awesome_datetime_picker/src/shared/awesome_semantic_labels.dart';
import 'package:awesome_datetime_picker/src/shared/awesome_wheel_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// An iOS-style wheel picker for selecting a range of dates: a start date and
/// an end date.
///
/// ```dart
/// AwesomeDateRangePicker(
///   minDate: AwesomeDate(year: 2025, month: 1, day: 1),
///   maxDate: AwesomeDate(year: 2025, month: 12, day: 31),
///   minLength: 1, // at least one night
///   maxLength: 14, // at most two weeks
///   startLabel: Text('Check-in'),
///   endLabel: Text('Check-out'),
///   onChanged: (range) => debugPrint('${range.start} to ${range.end}'),
/// )
/// ```
///
/// It shows two date pickers, one for each end of the range, and keeps them
/// consistent: the end date is never before the start date, so moving the
/// start date past the end date moves the end date along. [minLength] and
/// [maxLength] limit the distance between both dates in the same way.
///
/// ## Styling
///
/// Both pickers share the options of [AwesomeDatePicker], with the same
/// precedence (per-wheel theme, then these options, then the light or dark
/// defaults).
///
/// ## Changing properties after the first build
///
/// Changing [minDate], [maxDate], [minLength], [maxLength], [locale],
/// [localeName] or the exclusions keeps the current range, adjusted to the new
/// rules. [initialRange] is only read once; to move the selection later, use a
/// [controller] or give the picker a new [Key].
///
/// ## onChanged
///
/// [onChanged] is called with the whole range each time the user changes it,
/// and also when the picker adjusts the other date as a consequence (for
/// example the end date following a start date that moved past it), so the
/// last value it reported is always the range the wheels show.
///
/// Throws an [AssertionError] in debug mode if [minDate] is after [maxDate],
/// if [maxLength] is smaller than [minLength], or if [dateFormat] has no day
/// wheel.
class AwesomeDateRangePicker extends StatefulWidget {
  /// Creates a date-range picker. All parameters are optional.
  AwesomeDateRangePicker({
    super.key,
    this.minDate,
    this.maxDate,
    this.initialRange,
    this.controller,
    this.onChanged,
    this.minLength = 0,
    this.maxLength,
    this.locale = LocaleType.en,
    this.localeName,
    this.dateFormat = AwesomeDateFormat.dMy,
    this.excludedWeekdays,
    this.excludedDates,
    this.selectableDayPredicate,
    this.showWeekday = false,
    this.showDisabledValues = false,
    this.semanticLabels,
    this.disabledTextStyle,
    this.theme,
    this.startLabel,
    this.endLabel,
    this.direction = Axis.vertical,
    this.spacing = 8,
    this.backgroundColor,
    this.selectorColor,
    this.fadeEffect,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.visibleItemCount,
    this.itemHeight,
    this.itemWidth,
    this.looping = false,
    this.enableHapticFeedback = false,
    this.wheelStyle,
  })  : assert(minLength >= 0, 'minLength cannot be negative'),
        assert(maxLength == null || maxLength >= minLength,
            'maxLength must not be smaller than minLength'),
        assert(dateFormat.hasDay && dateFormat.hasYear,
            'AwesomeDateRangePicker needs a date format with a day and a year wheel'),
        assert(
          ValidationUtils.isValidDateRange(minDate: minDate, maxDate: maxDate),
          'minDate must be before maxDate',
        ),
        assert(
          controller == null || initialRange == null,
          'Pass either controller or initialRange, not both: the picker '
          'starts at controller.value',
        );

  /// The earliest selectable date (default 1/1/1900).
  final AwesomeDate? minDate;

  /// The latest selectable date (default 31/12/2100).
  final AwesomeDate? maxDate;

  /// The range selected when the picker is first shown (default: from today,
  /// lasting [minLength] days). It is adjusted if it breaks the rules of the
  /// picker.
  final AwesomeDateRange? initialRange;

  /// Optional controller to read and change the selected range from code.
  ///
  /// When given, the picker starts at `controller.value` instead of
  /// [initialRange] (passing both is an error), and keeps `controller.value` in
  /// sync with the wheels. See [AwesomeDateRangePickerController].
  final AwesomeDateRangePickerController? controller;

  /// Called with the new range when the user changes it, or when the picker
  /// adjusts the other date as a consequence (see the class documentation).
  final ValueChanged<AwesomeDateRange>? onChanged;

  /// Minimum distance in days between the start and the end date (default 0:
  /// the range may be a single day). With 1, the end is at least the day after
  /// the start.
  final int minLength;

  /// Maximum distance in days between the start and the end date (default:
  /// unlimited). When the start date moves further than this from the end date,
  /// the end date follows it.
  final int? maxLength;

  /// The language of the month names (default [LocaleType.en]).
  final LocaleType locale;

  /// Name of any locale known by `package:intl` (e.g. `'pt_BR'`, `'ja'`). It
  /// replaces [locale] and localizes month names, weekday names and digits. See
  /// [AwesomeDatePicker.localeName].
  final String? localeName;

  /// The format of both dates (default [AwesomeDateFormat.dMy]). It must have a
  /// day wheel.
  final AwesomeDateFormat dateFormat;

  /// Weekdays that cannot be selected, for the start and the end date
  /// (1 = Monday, 7 = Sunday).
  final List<int>? excludedWeekdays;

  /// Specific dates that cannot be selected, for the start and the end date.
  final List<AwesomeDate>? excludedDates;

  /// Decides whether a date can be selected, for the start and the end date.
  /// Pass a stable function: a different function re-applies the rules. See
  /// [AwesomeDatePicker.selectableDayPredicate].
  final bool Function(AwesomeDate date)? selectableDayPredicate;

  /// Whether the day wheels also show the weekday, e.g. "Mon 12".
  final bool showWeekday;

  /// Whether values that cannot be selected stay visible, dimmed. See
  /// [AwesomeDatePicker.showDisabledValues].
  final bool showDisabledValues;

  /// Text style of the dimmed values shown with [showDisabledValues].
  final TextStyle? disabledTextStyle;

  /// The words a screen reader announces for each wheel before its value,
  /// such as "Day, 15". By default they are in the language of [locale] (or
  /// [localeName]) when it is one of the built-in languages, and in English
  /// otherwise. The properties you give replace the built-in words. See
  /// [AwesomeSemanticLabels].
  ///
  /// Each wheel is announced with a prefix saying which date it belongs to:
  /// "Start date, Day" and "End date, Day" (see
  /// [AwesomeSemanticLabels.startDate] and [AwesomeSemanticLabels.endDate]).
  final AwesomeSemanticLabels? semanticLabels;

  /// The theme of the wheels (year, month and day), applied to both dates.
  final AwesomeDatePickerTheme? theme;

  /// Widget shown above the start date, e.g. `Text('From')`.
  final Widget? startLabel;

  /// Widget shown above the end date, e.g. `Text('To')`.
  final Widget? endLabel;

  /// How the start and the end pickers are laid out: one above the other
  /// ([Axis.vertical], the default) or side by side ([Axis.horizontal]).
  final Axis direction;

  /// Space between the start and the end picker (default 8).
  final double spacing;

  /// The background color of the wheels.
  final Color? backgroundColor;

  /// The color of the selector (highlight).
  final Color? selectorColor;

  /// Whether to fade the items at the top and bottom edges (default true).
  final bool? fadeEffect;

  /// The text style for the selected items.
  final TextStyle? selectedTextStyle;

  /// The text style for the unselected items.
  final TextStyle? unselectedTextStyle;

  /// The number of visible items in each wheel at once.
  final int? visibleItemCount;

  /// The height of each item.
  final double? itemHeight;

  /// The width of each wheel.
  final double? itemWidth;

  /// Whether the day and month wheels wrap around (default false).
  final bool looping;

  /// Whether to play a light haptic tick while dragging a wheel (default
  /// false).
  final bool enableHapticFeedback;

  /// Advanced appearance of the wheels. See [AwesomeWheelStyle].
  final AwesomeWheelStyle? wheelStyle;

  @override
  State<AwesomeDateRangePicker> createState() => _AwesomeDateRangePickerState();
}

class _AwesomeDateRangePickerState extends State<AwesomeDateRangePicker> {
  late AwesomeDate _minDate;
  late AwesomeDate _maxDate;

  /// The latest start date that still leaves a selectable end date.
  late AwesomeDate _lastStart;

  late final AwesomeDatePickerController _startController;
  late AwesomeDatePickerController _endController;

  /// Identifies the dates the end picker offers. It changes with the start
  /// date; the end picker is rebuilt, with a fresh controller, when it does.
  late String _endRangeKey;

  late AwesomeDate _start;
  late AwesomeDate _end;

  /// True while applying a change that came from the public controller: the
  /// user did not edit anything, so `onChanged` stays silent.
  bool _programmatic = false;

  /// True while the public controller moves the start date: the end date is
  /// updated by that code, not in reaction to the start date.
  bool _pushingStart = false;

  static const AwesomeDate _defaultMin =
      AwesomeDate(year: 1900, month: 1, day: 1);
  static const AwesomeDate _defaultMax =
      AwesomeDate(year: 2100, month: 12, day: 31);

  // ===== Date helpers =====

  static AwesomeDate _addDays(AwesomeDate date, int days) {
    final result = DateTime(date.year, date.month, date.day + days);
    return AwesomeDate(year: result.year, month: result.month, day: result.day);
  }

  static bool _before(AwesomeDate a, AwesomeDate b) =>
      a.toDateTime().isBefore(b.toDateTime());

  static AwesomeDate _clamp(
      AwesomeDate date, AwesomeDate min, AwesomeDate max) {
    if (_before(date, min)) return min;
    if (_before(max, date)) return max;
    return date;
  }

  /// Dates the end picker offers for a start date [start].
  (AwesomeDate, AwesomeDate) _endBounds(AwesomeDate start) {
    final min = _addDays(start, widget.minLength);
    final byLength = widget.maxLength == null
        ? _maxDate
        : _addDays(start, widget.maxLength!);
    return (min, _before(byLength, _maxDate) ? byLength : _maxDate);
  }

  bool _hasEnd(AwesomeDate start) {
    final (min, max) = _endBounds(start);
    return !_before(max, min) &&
        ValidationUtils.hasSelectableDate(
          minDate: min,
          maxDate: max,
          excludedWeekdays: widget.excludedWeekdays,
          excludedDates: widget.excludedDates,
          selectableDayPredicate: widget.selectableDayPredicate,
        );
  }

  String _keyFor(AwesomeDate min, AwesomeDate max) => '$min|$max';

  /// Computes the limits of the start date: the first and last dates of the
  /// range, and the latest start with a selectable end.
  void _resolveBounds() {
    _minDate = widget.minDate ?? _defaultMin;
    _maxDate = widget.maxDate ?? _defaultMax;

    var candidate = _addDays(_maxDate, -widget.minLength);
    // Bounded: the scan only goes on while exclusions hide every end date.
    for (int i = 0; i < 20000 && !_before(candidate, _minDate); i++) {
      if (_hasEnd(candidate)) {
        _lastStart = candidate;
        return;
      }
      candidate = _addDays(candidate, -1);
    }
    assert(
        false,
        'no start date has a selectable end date: the limits, '
        'minLength/maxLength and the exclusions leave no valid range');
    _lastStart = _minDate;
  }

  /// [start], or the nearest start date that has a selectable end date.
  AwesomeDate _startWithEnd(AwesomeDate start) {
    if (_hasEnd(start)) return start;
    for (int i = 1; i < 20000; i++) {
      final forward = _addDays(start, i);
      final backward = _addDays(start, -i);
      final canForward = !_before(_lastStart, forward);
      final canBackward = !_before(backward, _minDate);
      if (!canForward && !canBackward) break;
      if (canForward && _hasEnd(forward)) return forward;
      if (canBackward && _hasEnd(backward)) return backward;
    }
    return start;
  }

  AwesomeDateRange get _range => AwesomeDateRange(start: _start, end: _end);

  // ===== Lifecycle =====

  @override
  void initState() {
    super.initState();
    _resolveBounds();

    final initial = widget.controller?.value ??
        widget.initialRange ??
        _today(widget.minLength);
    _start = _startWithEnd(_clamp(initial.start, _minDate, _lastStart));
    final (endMin, endMax) = _endBounds(_start);
    _end = _clamp(initial.end, endMin, endMax);

    _startController = AwesomeDatePickerController(initialValue: _start);
    _endController = AwesomeDatePickerController(initialValue: _end);
    _endRangeKey = _keyFor(endMin, endMax);

    _startController.addListener(_onStartChanged);
    _endController.addListener(_onEndChanged);
    widget.controller?.addListener(_onPublicControllerChanged);
    _publishAfterFrame();
  }

  AwesomeDateRange _today(int length) {
    final today = AwesomeDate.today();
    return AwesomeDateRange(start: today, end: _addDays(today, length));
  }

  @override
  void didUpdateWidget(AwesomeDateRangePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onPublicControllerChanged);
      widget.controller?.addListener(_onPublicControllerChanged);
      if (widget.controller != null) {
        // Adopt the value of the new controller once this frame is built.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _onPublicControllerChanged();
        });
      }
    }

    final rulesChanged = oldWidget.minDate != widget.minDate ||
        oldWidget.maxDate != widget.maxDate ||
        oldWidget.minLength != widget.minLength ||
        oldWidget.maxLength != widget.maxLength ||
        !listEquals(oldWidget.excludedWeekdays, widget.excludedWeekdays) ||
        !listEquals(oldWidget.excludedDates, widget.excludedDates) ||
        oldWidget.selectableDayPredicate != widget.selectableDayPredicate;
    if (!rulesChanged) return;

    // Keep the current range, adjusted to the new rules. The start picker
    // adjusts its own date (and reports it); the end picker is replaced when
    // its dates changed.
    final previous = _range;
    _resolveBounds();
    _syncEnd(_end);

    if (_range != previous) {
      // Like the other pickers: tell the app when the rules changed what is
      // selected (not during the build, so after this frame).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onChanged?.call(_range);
        _publish();
      });
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onPublicControllerChanged);
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  // ===== Keeping the two pickers consistent =====

  /// Moves the end picker to [desired], adjusted to the dates allowed for the
  /// current start. When those dates changed the end picker is rebuilt with a
  /// fresh controller: pushing the date into the old picker would clamp it
  /// against the previous dates first.
  void _syncEnd(AwesomeDate desired) {
    final (min, max) = _endBounds(_start);
    final clamped = _clamp(desired, min, max);
    final key = _keyFor(min, max);

    // Set first, so that the end controller's listener finds nothing to do.
    _end = clamped;
    if (key != _endRangeKey) {
      final old = _endController;
      old.removeListener(_onEndChanged);
      _endController = AwesomeDatePickerController(initialValue: clamped)
        ..addListener(_onEndChanged);
      _endRangeKey = key;
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    } else if (_endController.value != clamped) {
      _endController.value = clamped;
    }
  }

  void _onStartChanged() {
    final start = _startController.value;
    if (start == _start) return;

    // Exclusions can leave a start date without any end date: move to the
    // nearest start that has one.
    final adjusted = _startWithEnd(start);
    if (adjusted != start) {
      _startController.value = adjusted;
      return;
    }

    _start = start;
    if (_pushingStart) return;
    _syncEnd(_end);
    _emit();
  }

  void _onEndChanged() {
    final end = _endController.value;
    if (end == _end) return;
    _end = end;
    _emit();
  }

  void _emit() {
    _publish();
    if (!_programmatic) widget.onChanged?.call(_range);
    if (mounted) setState(() {});
  }

  // ===== Public controller =====

  void _publish() {
    final controller = widget.controller;
    if (controller != null && controller.value != _range) {
      controller.value = _range;
    }
  }

  void _publishAfterFrame() {
    if (widget.controller == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _publish();
    });
  }

  void _onPublicControllerChanged() {
    final value = widget.controller!.value;
    if (value == _range) return;

    _programmatic = true;
    _pushingStart = true;
    final start = _startWithEnd(_clamp(value.start, _minDate, _lastStart));
    if (start != _startController.value) _startController.value = start;
    _pushingStart = false;

    _syncEnd(value.end);
    _programmatic = false;

    _publish();
    if (mounted) setState(() {});
  }

  // ===== Build =====

  @override
  Widget build(BuildContext context) {
    final (endMin, endMax) = _endBounds(_start);
    // Each wheel says which date it belongs to: "Start date, Day".
    final labels = AwesomeSemanticLabels.resolve(
      locale: widget.locale,
      localeName: widget.localeName,
      custom: widget.semanticLabels,
    );
    return Flex(
      direction: widget.direction,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _part(
          widget.startLabel,
          _picker(
            key: const ValueKey('start'),
            controller: _startController,
            minDate: _minDate,
            maxDate: _lastStart,
            semanticLabels: labels.prefixed(labels.startDate!),
          ),
        ),
        SizedBox(
          width: widget.direction == Axis.horizontal ? widget.spacing : 0,
          height: widget.direction == Axis.vertical ? widget.spacing : 0,
        ),
        _part(
          widget.endLabel,
          _picker(
            key: ValueKey(_endRangeKey),
            controller: _endController,
            minDate: endMin,
            maxDate: endMax,
            semanticLabels: labels.prefixed(labels.endDate!),
          ),
        ),
      ],
    );
  }

  Widget _part(Widget? label, Widget picker) {
    if (label == null) return picker;
    return Column(mainAxisSize: MainAxisSize.min, children: [label, picker]);
  }

  Widget _picker({
    required Key key,
    required AwesomeDatePickerController controller,
    required AwesomeDate minDate,
    required AwesomeDate maxDate,
    required AwesomeSemanticLabels semanticLabels,
  }) {
    return AwesomeDatePicker(
      semanticLabels: semanticLabels,
      key: key,
      controller: controller,
      minDate: minDate,
      maxDate: maxDate,
      locale: widget.locale,
      localeName: widget.localeName,
      dateFormat: widget.dateFormat,
      excludedWeekdays: widget.excludedWeekdays,
      excludedDates: widget.excludedDates,
      selectableDayPredicate: widget.selectableDayPredicate,
      showWeekday: widget.showWeekday,
      showDisabledValues: widget.showDisabledValues,
      disabledTextStyle: widget.disabledTextStyle,
      theme: widget.theme,
      backgroundColor: widget.backgroundColor,
      selectorColor: widget.selectorColor,
      fadeEffect: widget.fadeEffect,
      selectedTextStyle: widget.selectedTextStyle,
      unselectedTextStyle: widget.unselectedTextStyle,
      visibleItemCount: widget.visibleItemCount,
      itemHeight: widget.itemHeight,
      itemWidth: widget.itemWidth,
      looping: widget.looping,
      enableHapticFeedback: widget.enableHapticFeedback,
      wheelStyle: widget.wheelStyle,
    );
  }
}
