import 'package:awesome_datetime_picker/src/core/data/format.dart';
import 'package:awesome_datetime_picker/src/core/data/locale.dart';
import 'package:awesome_datetime_picker/src/core/utils/awesome_intl.dart';
import 'package:awesome_datetime_picker/src/duration/awesome_duration_picker_controller.dart';
import 'package:awesome_datetime_picker/src/duration/awesome_duration_picker_theme.dart';
import 'package:awesome_datetime_picker/src/duration/duration_picker_logic.dart';
import 'package:awesome_datetime_picker/src/shared/awesome_semantic_labels.dart';
import 'package:awesome_datetime_picker/src/shared/awesome_wheel_style.dart';
import 'package:awesome_datetime_picker/src/shared/custom_item_picker_style.dart';
import 'package:awesome_datetime_picker/src/shared/item_theme.dart';
import 'package:awesome_datetime_picker/src/shared/picker_wheel.dart';
import 'package:flutter/material.dart';

/// An iOS-style wheel picker for selecting a duration: a timer, a workout, a
/// cooking time.
///
/// ```dart
/// AwesomeDurationPicker(
///   format: AwesomeDurationFormat.hm,
///   minuteInterval: 5,
///   maxDuration: const Duration(hours: 12),
///   onChanged: (Duration duration) => debugPrint('$duration'),
/// )
/// ```
///
/// The value is a [Duration]. The [format] chooses the wheels: hours and
/// minutes ([AwesomeDurationFormat.hm]), minutes and seconds
/// ([AwesomeDurationFormat.ms]) or all three ([AwesomeDurationFormat.hms]).
/// The first wheel counts everything above the next unit, so it is not limited
/// to 59: with [AwesomeDurationFormat.ms] and a [maxDuration] of two hours the
/// minutes wheel goes up to 120.
///
/// Unlike the time pickers, it starts at [minDuration] (zero) rather than at
/// the current time.
///
/// ## Styling
///
/// Colors and text styles follow the brightness of the theme unless
/// overridden, with the same precedence as the other pickers: the per-wheel
/// theme, then the options of this widget, then the `AwesomePickerThemeData`
/// of the app, then the defaults.
///
/// ## Changing properties after the first build
///
/// Changing [minDuration], [maxDuration], [format] or an interval keeps the
/// current selection, moved to the closest selectable duration. If that
/// changes the value, [onChanged] is called with the new one. The
/// [initialDuration] is only read once: use a [controller] to move the
/// selection later.
///
/// Throws an [AssertionError] in debug mode if [minDuration] is negative or
/// longer than [maxDuration], or an interval does not divide 60.
class AwesomeDurationPicker extends StatefulWidget {
  /// Creates a duration picker. All parameters are optional.
  AwesomeDurationPicker({
    super.key,
    this.minDuration,
    this.maxDuration,
    this.initialDuration,
    this.controller,
    this.onChanged,
    this.format = AwesomeDurationFormat.hm,
    this.minuteInterval = 1,
    this.secondInterval = 1,
    this.localeName,
    this.theme,
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
    this.semanticLabels,
  })  : assert(minDuration == null || !minDuration.isNegative,
            'minDuration cannot be negative'),
        assert(
          minDuration == null ||
              maxDuration == null ||
              maxDuration >= minDuration,
          'maxDuration must not be shorter than minDuration',
        ),
        assert(
          minuteInterval >= 1 && 60 % minuteInterval == 0,
          'minuteInterval must be a divisor of 60 (e.g. 1, 5, 10, 15, 30)',
        ),
        assert(
          secondInterval >= 1 && 60 % secondInterval == 0,
          'secondInterval must be a divisor of 60 (e.g. 1, 5, 10, 15, 30)',
        ),
        assert(
          controller == null || initialDuration == null,
          'Pass either controller or initialDuration, not both: the picker '
          'starts at controller.value',
        );

  /// The shortest selectable duration (default zero).
  final Duration? minDuration;

  /// The longest selectable duration. The default depends on [format]: 23:59
  /// for hours and minutes (and with seconds 23:59:59), and 59:59 for minutes
  /// and seconds.
  final Duration? maxDuration;

  /// The duration selected when the picker is first shown (default
  /// [minDuration]). It is moved onto the minute and second intervals and into
  /// the limits if needed.
  final Duration? initialDuration;

  /// Optional controller to read and change the selected duration from code.
  ///
  /// When given, the picker starts at `controller.value` instead of
  /// [initialDuration] (passing both is an error), and keeps `controller.value`
  /// in sync with the wheels. See [AwesomeDurationPickerController].
  final AwesomeDurationPickerController? controller;

  /// Called with the new duration when the user changes it.
  final ValueChanged<Duration>? onChanged;

  /// The wheels to show (default [AwesomeDurationFormat.hm]).
  final AwesomeDurationFormat format;

  /// Distance in minutes between two selectable minutes (default 1). Must be a
  /// divisor of 60. With [AwesomeDurationFormat.ms] it applies to the whole
  /// number of minutes, e.g. 5 offers 0, 5, 10, ... 120.
  final int minuteInterval;

  /// Distance in seconds between two selectable seconds (default 1). Must be a
  /// divisor of 60. Only used by the formats that show a seconds wheel.
  final int secondInterval;

  /// Name of any locale known by `package:intl` (e.g. `'fa'`, `'ar_EG'`). It
  /// localizes the digits of the wheels, and the language in which a screen
  /// reader announces them when it is a built-in one. See
  /// [AwesomeTimePicker.localeName].
  final String? localeName;

  /// The theme of the hours, minutes and seconds wheels.
  final AwesomeDurationPickerTheme? theme;

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

  /// Whether the minutes and seconds wheels wrap around (default false). The
  /// first wheel, which counts the whole duration, never loops.
  final bool looping;

  /// Whether to play a light haptic tick while dragging a wheel (default
  /// false).
  final bool enableHapticFeedback;

  /// Advanced appearance of the wheels. See [AwesomeWheelStyle].
  final AwesomeWheelStyle? wheelStyle;

  /// The words a screen reader announces for each wheel before its value, such
  /// as "Hour, 1". By default they are in the language of [localeName] when it
  /// is one of the built-in languages, and in English otherwise. See
  /// [AwesomeSemanticLabels].
  final AwesomeSemanticLabels? semanticLabels;

  @override
  State<AwesomeDurationPicker> createState() => _AwesomeDurationPickerState();
}

class _AwesomeDurationPickerState extends State<AwesomeDurationPicker> {
  late DurationPickerLogic _logic;

  /// True while applying a change that came from the public controller: the
  /// user did not edit anything, so `onChanged` stays silent.
  bool _applyingController = false;

  /// The `intl` locale used for [AwesomeDurationPicker.localeName], if any,
  /// and the glyphs of its digits when they are not 0-9.
  List<String>? _digitGlyphs;

  void _resolveLocale() {
    final name = widget.localeName;
    _digitGlyphs = name == null
        ? null
        : AwesomeIntl.digitGlyphs(AwesomeIntl.resolve(name));
  }

  Duration get _minDuration => widget.minDuration ?? Duration.zero;

  Duration get _maxDuration =>
      widget.maxDuration ??
      (widget.format.hasHours
          ? Duration(
              hours: 23,
              minutes: 59,
              seconds: widget.format.hasSeconds ? 59 : 0)
          : const Duration(minutes: 59, seconds: 59));

  @override
  void initState() {
    super.initState();
    _resolveLocale();
    _logic = _createLogic(
        initialDuration: widget.controller?.value ?? widget.initialDuration);
    _logic.addListener(_onLogicChanged);
    widget.controller?.addListener(_onControllerChanged);
    _publishAfterFrame();
  }

  @override
  void didUpdateWidget(AwesomeDurationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localeName != widget.localeName) _resolveLocale();

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

    final configChanged = oldWidget.minDuration != widget.minDuration ||
        oldWidget.maxDuration != widget.maxDuration ||
        oldWidget.format != widget.format ||
        oldWidget.minuteInterval != widget.minuteInterval ||
        oldWidget.secondInterval != widget.secondInterval;
    if (!configChanged) return;

    // Rebuild the logic with the new rules, keeping the current selection
    // (moved to the closest selectable duration if needed).
    final previous = _logic.selected;
    _logic.removeListener(_onLogicChanged);
    _logic.dispose();
    _logic = _createLogic(initialDuration: previous);
    _logic.addListener(_onLogicChanged);

    if (_logic.selected != previous) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onChanged?.call(_logic.selected);
        _publish();
      });
    }
  }

  DurationPickerLogic _createLogic({Duration? initialDuration}) {
    return DurationPickerLogic(
      format: widget.format,
      minDuration: _minDuration,
      maxDuration: _maxDuration,
      initialDuration: initialDuration,
      minuteInterval: widget.minuteInterval,
      secondInterval: widget.secondInterval,
    );
  }

  /// Writes the selection back to the controller: it can differ from the value
  /// that was requested (clamped into the limits, rounded to the intervals).
  void _publish() {
    final controller = widget.controller;
    if (controller != null && controller.value != _logic.selected) {
      controller.value = _logic.selected;
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
    if (value == _logic.selected) return;
    _applyingController = true;
    _logic.setSelectedDuration(value);
    _applyingController = false;
    _publish();
  }

  void _onLogicChanged() {
    if (!_applyingController) widget.onChanged?.call(_logic.selected);
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

  AwesomeSemanticLabels get _semanticLabels => AwesomeSemanticLabels.resolve(
        locale: LocaleType.en,
        localeName: widget.localeName,
        custom: widget.semanticLabels,
      );

  @override
  Widget build(BuildContext context) {
    // Wider than its parent? Shrink to fit instead of overflowing. A picker
    // that fits is not scaled.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var level = 0; level < _logic.units.length; level++)
            _buildWheel(level),
        ],
      ),
    );
  }

  Widget _buildWheel(int level) {
    final unit = _logic.units[level];
    final ItemTheme? theme;
    final String? semanticLabel;
    switch (unit) {
      case DurationUnit.hours:
        theme = widget.theme?.hourTheme;
        semanticLabel = _semanticLabels.hour;
      case DurationUnit.minutes:
        theme = widget.theme?.minuteTheme;
        semanticLabel = _semanticLabels.minute;
      case DurationUnit.seconds:
        theme = widget.theme?.secondTheme;
        semanticLabel = _semanticLabels.second;
    }

    final items = _logic.itemsOf(level);
    final glyphs = _digitGlyphs;
    return buildPickerWheel(
      items: items,
      labels: glyphs == null
          ? null
          : [
              for (final item in items) AwesomeIntl.localizeDigits(item, glyphs)
            ],
      value: _logic.selectedItemOf(level),
      theme: theme,
      style: CustomItemPickerStyle(
        backgroundColor: widget.backgroundColor,
        selectorColor: widget.selectorColor,
        fadeEffect: widget.fadeEffect,
        selectedTextStyle: widget.selectedTextStyle,
        unselectedTextStyle: widget.unselectedTextStyle,
        itemHeight: widget.itemHeight,
        itemWidth: widget.itemWidth,
        wheelStyle: widget.wheelStyle,
      ),
      visibleItemCount: widget.visibleItemCount,
      onChanged: (item) => _logic.onSelectedItemChanged(level, item),
      // The first wheel counts the whole duration: wrapping makes no sense.
      looping: widget.looping && level > 0,
      hapticFeedback: widget.enableHapticFeedback,
      semanticLabel: semanticLabel,
    );
  }
}
