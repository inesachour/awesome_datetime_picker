import 'package:awesome_datetime_picker/src/models/awesome_date.dart';
import 'package:awesome_datetime_picker/src/theme/item_theme.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/custom_item_picker_widget.dart';
import 'package:flutter/material.dart';

class AwesomeYearPicker extends StatefulWidget {
  const AwesomeYearPicker({
    super.key,
    required this.selectedDate,
    required this.maxDate,
    required this.minDate,
    required this.onSelectedYearChanged,
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
  final Function(int) onSelectedYearChanged;
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
  State<AwesomeYearPicker> createState() => _AwesomeYearPickerState();
}

class _AwesomeYearPickerState extends State<AwesomeYearPicker> {
  late List<String> years;

  @override
  void initState() {
    super.initState();
    years = List.generate(widget.maxDate.year - widget.minDate.year + 1,
        (index) => (widget.minDate.year + index).toString());
  }

  @override
  Widget build(BuildContext context) {
    return CustomItemPicker(
      items: years,
      initialIndex: years.indexOf(widget.selectedDate.year.toString()),
      maxIndex: widget.maxDate.year - widget.minDate.year,
      minIndex: 0,
      onSelectedItemChanged: widget.onSelectedYearChanged,
      theme: widget.theme,
      backgroundColor: widget.backgroundColor,
      fadeEffect: widget.fadeEffect,
      selectedTextStyle: widget.selectedTextStyle,
      unselectedTextStyle: widget.unselectedTextStyle,
      selectorColor: widget.selectorColor,
      visibleItemCount: widget.visibleItemCount,
      itemHeight: widget.itemHeight,
      itemWidth: widget.itemWidth,
    );
  }
}
