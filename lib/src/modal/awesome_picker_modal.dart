import 'package:awesome_datetime_picker/src/core/data/format.dart';
import 'package:awesome_datetime_picker/src/core/data/locale.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_date.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_date_range.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_datetime.dart';
import 'package:awesome_datetime_picker/src/core/models/awesome_time.dart';
import 'package:awesome_datetime_picker/src/date/awesome_date_picker.dart';
import 'package:awesome_datetime_picker/src/date/awesome_date_picker_controller.dart';
import 'package:awesome_datetime_picker/src/date/awesome_date_picker_theme.dart';
import 'package:awesome_datetime_picker/src/datetime/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/datetime/awesome_datetime_picker_controller.dart';
import 'package:awesome_datetime_picker/src/datetime/awesome_datetime_picker_theme.dart';
import 'package:awesome_datetime_picker/src/duration/awesome_duration_picker.dart';
import 'package:awesome_datetime_picker/src/duration/awesome_duration_picker_controller.dart';
import 'package:awesome_datetime_picker/src/duration/awesome_duration_picker_theme.dart';
import 'package:awesome_datetime_picker/src/range/awesome_date_range_picker.dart';
import 'package:awesome_datetime_picker/src/range/awesome_date_range_picker_controller.dart';
import 'package:awesome_datetime_picker/src/shared/awesome_semantic_labels.dart';
import 'package:awesome_datetime_picker/src/shared/awesome_wheel_style.dart';
import 'package:awesome_datetime_picker/src/time/awesome_time_picker.dart';
import 'package:awesome_datetime_picker/src/time/awesome_time_picker_controller.dart';
import 'package:awesome_datetime_picker/src/time/awesome_time_picker_theme.dart';
import 'package:flutter/material.dart';

/// How a picker is presented by [showAwesomePicker] and the `showAwesome...`
/// functions.
enum AwesomePickerPresentation {
  /// A sheet that slides up from the bottom of the screen.
  bottomSheet,

  /// A dialog in the middle of the screen.
  dialog,
}

/// Shows any picker in a bottom sheet or a dialog with a Cancel and a Done
/// button, and returns the value the user confirmed.
///
/// It completes with `controller.value` when the user taps Done, and with
/// null when the user cancels or dismisses the modal; in that case the
/// controller is also set back to the value it had when the modal opened.
///
/// You create the controller (and dispose it) and build the picker with it:
///
/// ```dart
/// final controller = AwesomeDatePickerController();
/// final date = await showAwesomePicker<AwesomeDate>(
///   context,
///   controller: controller,
///   builder: (context) => AwesomeDatePicker(
///     controller: controller,
///     dateFormat: AwesomeDateFormat.dMMy,
///     wheelStyle: AwesomeWheelStyle(magnification: 1.1),
///   ),
/// );
/// ```
///
/// For the common cases, [showAwesomeDatePicker], [showAwesomeTimePicker],
/// [showAwesomeDateTimePicker], [showAwesomeDateRangePicker] and
/// [showAwesomeDurationPicker] do this for you.
///
/// The button texts default to the localized ones of
/// [MaterialLocalizations]; [title] is shown between the buttons.
Future<T?> showAwesomePicker<T>(
  BuildContext context, {
  required ValueNotifier<T> controller,
  required WidgetBuilder builder,
  Widget? title,
  String? confirmText,
  String? cancelText,
  AwesomePickerPresentation presentation =
      AwesomePickerPresentation.bottomSheet,
  bool useRootNavigator = false,
  bool barrierDismissible = true,
  Color? barrierColor,
  RouteSettings? routeSettings,
  Color? backgroundColor,
  ShapeBorder? shape,
}) async {
  final initial = controller.value;
  final result = await _show<T>(
    context,
    presentation: presentation,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    routeSettings: routeSettings,
    backgroundColor: backgroundColor,
    shape: shape,
    builder: (modalContext) => _PickerModalContent<T>(
      title: title,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: () =>
          Navigator.of(modalContext, rootNavigator: useRootNavigator)
              .pop(controller.value),
      onCancel: () =>
          Navigator.of(modalContext, rootNavigator: useRootNavigator).pop(),
      child: builder(modalContext),
    ),
  );
  if (result == null && controller.value != initial) {
    controller.value = initial;
  }
  return result;
}

/// Shows an [AwesomeDatePicker] in a bottom sheet or a dialog and returns the
/// date the user confirmed, or null if they cancelled.
///
/// The picker options are the ones of [AwesomeDatePicker]; the remaining
/// parameters are the ones of [showAwesomePicker]. For options not listed
/// here, use [showAwesomePicker] with your own [AwesomeDatePicker].
///
/// ```dart
/// final date = await showAwesomeDatePicker(
///   context,
///   title: Text('Birthday'),
///   maxDate: AwesomeDate(year: 2025, month: 12, day: 31),
/// );
/// ```
Future<AwesomeDate?> showAwesomeDatePicker(
  BuildContext context, {
  AwesomeDate? initialDate,
  AwesomeDate? minDate,
  AwesomeDate? maxDate,
  LocaleType locale = LocaleType.en,
  String? localeName,
  AwesomeDateFormat dateFormat = AwesomeDateFormat.dMy,
  List<int>? excludedWeekdays,
  List<AwesomeDate>? excludedDates,
  bool Function(AwesomeDate date)? selectableDayPredicate,
  bool showWeekday = false,
  bool showDisabledValues = false,
  AwesomeDatePickerTheme? theme,
  bool looping = false,
  bool enableHapticFeedback = false,
  AwesomeWheelStyle? wheelStyle,
  AwesomeSemanticLabels? semanticLabels,
  Widget? title,
  String? confirmText,
  String? cancelText,
  AwesomePickerPresentation presentation =
      AwesomePickerPresentation.bottomSheet,
  bool useRootNavigator = false,
  bool barrierDismissible = true,
  Color? barrierColor,
  RouteSettings? routeSettings,
  Color? backgroundColor,
  ShapeBorder? shape,
}) {
  return _showOwned<AwesomeDate, AwesomeDatePickerController>(
    context,
    createController: () =>
        AwesomeDatePickerController(initialValue: initialDate),
    pickerBuilder: (context, controller) => AwesomeDatePicker(
      controller: controller,
      minDate: minDate,
      maxDate: maxDate,
      locale: locale,
      localeName: localeName,
      dateFormat: dateFormat,
      excludedWeekdays: excludedWeekdays,
      excludedDates: excludedDates,
      selectableDayPredicate: selectableDayPredicate,
      showWeekday: showWeekday,
      showDisabledValues: showDisabledValues,
      theme: theme,
      looping: looping,
      enableHapticFeedback: enableHapticFeedback,
      wheelStyle: wheelStyle,
      semanticLabels: semanticLabels,
    ),
    title: title,
    confirmText: confirmText,
    cancelText: cancelText,
    presentation: presentation,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    routeSettings: routeSettings,
    backgroundColor: backgroundColor,
    shape: shape,
  );
}

/// Shows an [AwesomeTimePicker] in a bottom sheet or a dialog and returns the
/// time the user confirmed, or null if they cancelled.
///
/// The picker options are the ones of [AwesomeTimePicker]; the remaining
/// parameters are the ones of [showAwesomePicker]. For options not listed
/// here, use [showAwesomePicker] with your own [AwesomeTimePicker].
///
/// ```dart
/// final time = await showAwesomeTimePicker(
///   context,
///   timeFormat: AwesomeTimeFormat.hm,
///   minuteInterval: 15,
/// );
/// ```
Future<AwesomeTime?> showAwesomeTimePicker(
  BuildContext context, {
  AwesomeTime? initialTime,
  AwesomeTime? minTime,
  AwesomeTime? maxTime,
  AwesomeTimeFormat timeFormat = AwesomeTimeFormat.Hm,
  String? localeName,
  List<int>? excludedHours,
  int minuteInterval = 1,
  int secondInterval = 1,
  bool showDisabledValues = false,
  AwesomeTimePickerTheme? theme,
  bool looping = false,
  bool enableHapticFeedback = false,
  AwesomeWheelStyle? wheelStyle,
  AwesomeSemanticLabels? semanticLabels,
  Widget? title,
  String? confirmText,
  String? cancelText,
  AwesomePickerPresentation presentation =
      AwesomePickerPresentation.bottomSheet,
  bool useRootNavigator = false,
  bool barrierDismissible = true,
  Color? barrierColor,
  RouteSettings? routeSettings,
  Color? backgroundColor,
  ShapeBorder? shape,
}) {
  return _showOwned<AwesomeTime, AwesomeTimePickerController>(
    context,
    createController: () =>
        AwesomeTimePickerController(initialValue: initialTime),
    pickerBuilder: (context, controller) => AwesomeTimePicker(
      controller: controller,
      minTime: minTime,
      maxTime: maxTime,
      timeFormat: timeFormat,
      localeName: localeName,
      excludedHours: excludedHours,
      minuteInterval: minuteInterval,
      secondInterval: secondInterval,
      showDisabledValues: showDisabledValues,
      theme: theme,
      looping: looping,
      enableHapticFeedback: enableHapticFeedback,
      wheelStyle: wheelStyle,
      semanticLabels: semanticLabels,
    ),
    title: title,
    confirmText: confirmText,
    cancelText: cancelText,
    presentation: presentation,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    routeSettings: routeSettings,
    backgroundColor: backgroundColor,
    shape: shape,
  );
}

/// Shows an [AwesomeDateTimePicker] in a bottom sheet or a dialog and returns
/// the date and time the user confirmed, or null if they cancelled.
///
/// The picker options are the ones of [AwesomeDateTimePicker]; the remaining
/// parameters are the ones of [showAwesomePicker]. For options not listed
/// here, use [showAwesomePicker] with your own [AwesomeDateTimePicker].
///
/// ```dart
/// final dateTime = await showAwesomeDateTimePicker(
///   context,
///   minDateTime: AwesomeDateTime(
///     date: AwesomeDate(year: 2025, month: 1, day: 1),
///     time: AwesomeTime(hour: 8, minute: 0),
///   ),
///   timeFormat: AwesomeTimeFormat.hm,
/// );
/// ```
Future<AwesomeDateTime?> showAwesomeDateTimePicker(
  BuildContext context, {
  AwesomeDateTime? initialDateTime,
  AwesomeDateTime? minDateTime,
  AwesomeDateTime? maxDateTime,
  LocaleType locale = LocaleType.en,
  String? localeName,
  AwesomeDateFormat dateFormat = AwesomeDateFormat.dMy,
  AwesomeTimeFormat timeFormat = AwesomeTimeFormat.Hm,
  List<int>? excludedWeekdays,
  List<AwesomeDate>? excludedDates,
  bool Function(AwesomeDate date)? selectableDayPredicate,
  List<int>? excludedHours,
  int minuteInterval = 1,
  int secondInterval = 1,
  bool showWeekday = false,
  bool showDisabledValues = false,
  AwesomeDateTimePickerTheme? theme,
  bool looping = false,
  bool enableHapticFeedback = false,
  AwesomeWheelStyle? wheelStyle,
  AwesomeSemanticLabels? semanticLabels,
  Widget? title,
  String? confirmText,
  String? cancelText,
  AwesomePickerPresentation presentation =
      AwesomePickerPresentation.bottomSheet,
  bool useRootNavigator = false,
  bool barrierDismissible = true,
  Color? barrierColor,
  RouteSettings? routeSettings,
  Color? backgroundColor,
  ShapeBorder? shape,
}) {
  return _showOwned<AwesomeDateTime, AwesomeDateTimePickerController>(
    context,
    createController: () =>
        AwesomeDateTimePickerController(initialValue: initialDateTime),
    pickerBuilder: (context, controller) => AwesomeDateTimePicker(
      controller: controller,
      minDateTime: minDateTime,
      maxDateTime: maxDateTime,
      locale: locale,
      localeName: localeName,
      dateFormat: dateFormat,
      timeFormat: timeFormat,
      excludedWeekdays: excludedWeekdays,
      excludedDates: excludedDates,
      selectableDayPredicate: selectableDayPredicate,
      excludedHours: excludedHours,
      minuteInterval: minuteInterval,
      secondInterval: secondInterval,
      showWeekday: showWeekday,
      showDisabledValues: showDisabledValues,
      theme: theme,
      looping: looping,
      enableHapticFeedback: enableHapticFeedback,
      wheelStyle: wheelStyle,
      semanticLabels: semanticLabels,
    ),
    title: title,
    confirmText: confirmText,
    cancelText: cancelText,
    presentation: presentation,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    routeSettings: routeSettings,
    backgroundColor: backgroundColor,
    shape: shape,
  );
}

/// Shows an [AwesomeDateRangePicker] in a bottom sheet or a dialog and returns
/// the range the user confirmed, or null if they cancelled.
///
/// The picker options are the ones of [AwesomeDateRangePicker]; the remaining
/// parameters are the ones of [showAwesomePicker]. For options not listed
/// here, use [showAwesomePicker] with your own [AwesomeDateRangePicker].
///
/// ```dart
/// final range = await showAwesomeDateRangePicker(
///   context,
///   minLength: 1,
///   startLabel: Text('Check-in'),
///   endLabel: Text('Check-out'),
/// );
/// ```
Future<AwesomeDateRange?> showAwesomeDateRangePicker(
  BuildContext context, {
  AwesomeDateRange? initialRange,
  AwesomeDate? minDate,
  AwesomeDate? maxDate,
  int minLength = 0,
  int? maxLength,
  LocaleType locale = LocaleType.en,
  String? localeName,
  AwesomeDateFormat dateFormat = AwesomeDateFormat.dMy,
  List<int>? excludedWeekdays,
  List<AwesomeDate>? excludedDates,
  bool Function(AwesomeDate date)? selectableDayPredicate,
  bool showWeekday = false,
  bool showDisabledValues = false,
  AwesomeDatePickerTheme? theme,
  Widget? startLabel,
  Widget? endLabel,
  bool looping = false,
  bool enableHapticFeedback = false,
  AwesomeWheelStyle? wheelStyle,
  AwesomeSemanticLabels? semanticLabels,
  Widget? title,
  String? confirmText,
  String? cancelText,
  AwesomePickerPresentation presentation =
      AwesomePickerPresentation.bottomSheet,
  bool useRootNavigator = false,
  bool barrierDismissible = true,
  Color? barrierColor,
  RouteSettings? routeSettings,
  Color? backgroundColor,
  ShapeBorder? shape,
}) {
  return _showOwned<AwesomeDateRange, AwesomeDateRangePickerController>(
    context,
    createController: () =>
        AwesomeDateRangePickerController(initialValue: initialRange),
    pickerBuilder: (context, controller) => AwesomeDateRangePicker(
      controller: controller,
      minDate: minDate,
      maxDate: maxDate,
      minLength: minLength,
      maxLength: maxLength,
      locale: locale,
      localeName: localeName,
      dateFormat: dateFormat,
      excludedWeekdays: excludedWeekdays,
      excludedDates: excludedDates,
      selectableDayPredicate: selectableDayPredicate,
      showWeekday: showWeekday,
      showDisabledValues: showDisabledValues,
      theme: theme,
      startLabel: startLabel,
      endLabel: endLabel,
      looping: looping,
      enableHapticFeedback: enableHapticFeedback,
      wheelStyle: wheelStyle,
      semanticLabels: semanticLabels,
    ),
    title: title,
    confirmText: confirmText,
    cancelText: cancelText,
    presentation: presentation,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    routeSettings: routeSettings,
    backgroundColor: backgroundColor,
    shape: shape,
  );
}

/// Shows an [AwesomeDurationPicker] in a bottom sheet or a dialog and returns
/// the duration the user confirmed, or null if they cancelled.
///
/// The picker options are the ones of [AwesomeDurationPicker]; the remaining
/// parameters are the ones of [showAwesomePicker]. For options not listed
/// here, use [showAwesomePicker] with your own [AwesomeDurationPicker].
///
/// ```dart
/// final duration = await showAwesomeDurationPicker(
///   context,
///   title: Text('Timer'),
///   format: AwesomeDurationFormat.hms,
///   minDuration: const Duration(seconds: 5),
/// );
/// ```
Future<Duration?> showAwesomeDurationPicker(
  BuildContext context, {
  Duration? initialDuration,
  Duration? minDuration,
  Duration? maxDuration,
  AwesomeDurationFormat format = AwesomeDurationFormat.hm,
  int minuteInterval = 1,
  int secondInterval = 1,
  String? localeName,
  AwesomeDurationPickerTheme? theme,
  bool looping = false,
  bool enableHapticFeedback = false,
  AwesomeWheelStyle? wheelStyle,
  AwesomeSemanticLabels? semanticLabels,
  Widget? title,
  String? confirmText,
  String? cancelText,
  AwesomePickerPresentation presentation =
      AwesomePickerPresentation.bottomSheet,
  bool useRootNavigator = false,
  bool barrierDismissible = true,
  Color? barrierColor,
  RouteSettings? routeSettings,
  Color? backgroundColor,
  ShapeBorder? shape,
}) {
  return _showOwned<Duration, AwesomeDurationPickerController>(
    context,
    createController: () => AwesomeDurationPickerController(
        initialValue: initialDuration ?? minDuration ?? Duration.zero),
    pickerBuilder: (context, controller) => AwesomeDurationPicker(
      controller: controller,
      minDuration: minDuration,
      maxDuration: maxDuration,
      format: format,
      minuteInterval: minuteInterval,
      secondInterval: secondInterval,
      localeName: localeName,
      theme: theme,
      looping: looping,
      enableHapticFeedback: enableHapticFeedback,
      wheelStyle: wheelStyle,
      semanticLabels: semanticLabels,
    ),
    title: title,
    confirmText: confirmText,
    cancelText: cancelText,
    presentation: presentation,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    routeSettings: routeSettings,
    backgroundColor: backgroundColor,
    shape: shape,
  );
}

// ===== Implementation =====

Future<T?> _show<T>(
  BuildContext context, {
  required AwesomePickerPresentation presentation,
  required bool useRootNavigator,
  required bool barrierDismissible,
  required Color? barrierColor,
  required RouteSettings? routeSettings,
  required Color? backgroundColor,
  required ShapeBorder? shape,
  required WidgetBuilder builder,
}) {
  switch (presentation) {
    case AwesomePickerPresentation.bottomSheet:
      return showModalBottomSheet<T>(
        context: context,
        useRootNavigator: useRootNavigator,
        isDismissible: barrierDismissible,
        barrierColor: barrierColor,
        routeSettings: routeSettings,
        backgroundColor: backgroundColor,
        shape: shape,
        isScrollControlled: true,
        builder: (context) => SafeArea(
          child: SingleChildScrollView(child: builder(context)),
        ),
      );
    case AwesomePickerPresentation.dialog:
      return showDialog<T>(
        context: context,
        useRootNavigator: useRootNavigator,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        routeSettings: routeSettings,
        builder: (context) => Dialog(
          backgroundColor: backgroundColor,
          shape: shape,
          child: SingleChildScrollView(child: builder(context)),
        ),
      );
  }
}

/// Shows a picker whose controller belongs to the modal, which disposes it.
Future<T?> _showOwned<T, C extends ValueNotifier<T>>(
  BuildContext context, {
  required C Function() createController,
  required Widget Function(BuildContext context, C controller) pickerBuilder,
  required Widget? title,
  required String? confirmText,
  required String? cancelText,
  required AwesomePickerPresentation presentation,
  required bool useRootNavigator,
  required bool barrierDismissible,
  required Color? barrierColor,
  required RouteSettings? routeSettings,
  required Color? backgroundColor,
  required ShapeBorder? shape,
}) {
  return _show<T>(
    context,
    presentation: presentation,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    routeSettings: routeSettings,
    backgroundColor: backgroundColor,
    shape: shape,
    builder: (_) => _OwnedControllerModal<T, C>(
      createController: createController,
      pickerBuilder: pickerBuilder,
      title: title,
      confirmText: confirmText,
      cancelText: cancelText,
      useRootNavigator: useRootNavigator,
    ),
  );
}

/// Creates the controller of a picker for the lifetime of the modal and
/// disposes it with it, so that no code runs while the modal is animating
/// out.
class _OwnedControllerModal<T, C extends ValueNotifier<T>>
    extends StatefulWidget {
  const _OwnedControllerModal({
    required this.createController,
    required this.pickerBuilder,
    required this.title,
    required this.confirmText,
    required this.cancelText,
    required this.useRootNavigator,
  });

  final C Function() createController;
  final Widget Function(BuildContext context, C controller) pickerBuilder;
  final Widget? title;
  final String? confirmText;
  final String? cancelText;
  final bool useRootNavigator;

  @override
  State<_OwnedControllerModal<T, C>> createState() =>
      _OwnedControllerModalState<T, C>();
}

class _OwnedControllerModalState<T, C extends ValueNotifier<T>>
    extends State<_OwnedControllerModal<T, C>> {
  late final C _controller = widget.createController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigator =
        Navigator.of(context, rootNavigator: widget.useRootNavigator);
    return _PickerModalContent<T>(
      title: widget.title,
      confirmText: widget.confirmText,
      cancelText: widget.cancelText,
      onConfirm: () => navigator.pop(_controller.value),
      onCancel: () => navigator.pop(),
      child: widget.pickerBuilder(context, _controller),
    );
  }
}

/// The content of a modal: a Cancel / title / Done row above the picker.
class _PickerModalContent<T> extends StatelessWidget {
  const _PickerModalContent({
    required this.title,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.onCancel,
    required this.child,
  });

  final Widget? title;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              TextButton(
                onPressed: onCancel,
                child: Text(cancelText ?? localizations.cancelButtonLabel),
              ),
              Expanded(
                child: Center(
                  child: title == null
                      ? const SizedBox.shrink()
                      : DefaultTextStyle(
                          style: Theme.of(context).textTheme.titleMedium ??
                              const TextStyle(),
                          textAlign: TextAlign.center,
                          child: title!,
                        ),
                ),
              ),
              TextButton(
                onPressed: onConfirm,
                child: Text(confirmText ?? localizations.okButtonLabel),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: child,
        ),
      ],
    );
  }
}
