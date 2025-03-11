import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/utils/awesome_date_utils.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/custom_item_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeMonthPicker extends StatefulWidget {
  const AwesomeMonthPicker({
    super.key,
    required this.selectedDate,
    required this.maxDate,
    required this.minDate,
    required this.onSelectedMonthChanged,
    required this.locale,
    this.isNumber = true,
    this.theme,
    this.backgroundColor,
    this.fadeEffect,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.selectorColor,
    this.visibleItemCount,
    this.itemHeight,
    this.itemWidth,
  });

  final AwesomeDate selectedDate;
  final AwesomeDate maxDate;
  final AwesomeDate minDate;
  final Function(int) onSelectedMonthChanged;
  final bool isNumber;
  final LocaleType locale;
  final ItemTheme? theme;
  final Color? backgroundColor;
  final Color? selectorColor;
  final bool? fadeEffect;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final int? visibleItemCount;
  final double? itemHeight;
  final double? itemWidth;

  @override
  State<AwesomeMonthPicker> createState() => _AwesomeMonthPickerState();
}

class _AwesomeMonthPickerState extends State<AwesomeMonthPicker> {
  late List<String> months;

  @override
  void initState() {
    months = widget.isNumber
        ? List.generate(12, (index) => (index + 1).toString())
        : AwesomeDateUtils.getMonthNames(widget.locale);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int maxValue = 12, minValue = 1;
    if (widget.selectedDate.year == widget.maxDate.year) {
      maxValue = widget.maxDate.month;
    }
    if (widget.selectedDate.year == widget.minDate.year) {
      minValue = widget.minDate.month;
    }

    return CustomItemPicker(
      items: months,
      initialValue: widget.isNumber
          ? widget.selectedDate.month.toString()
          : months[widget.selectedDate.month - 1],
      minIndex: minValue - 1,
      maxIndex: maxValue - 1,
      onSelectedItemChanged: widget.onSelectedMonthChanged,
      theme: widget.theme,
      backgroundColor: widget.backgroundColor,
      fadeEffect: widget.fadeEffect,
      selectedTextStyle: widget.selectedTextStyle,
      unselectedTextStyle: widget.unselectedTextStyle,
      selectorColor: widget.selectorColor,
      visibleItemCount: widget.visibleItemCount,
      itemHeight: widget.itemHeight,
      itemWidth: widget.isNumber
          ? widget.itemWidth
          : widget.itemWidth ?? MediaQuery.of(context).size.width * 0.25,
    );
  }
}
