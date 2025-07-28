import 'package:awesome_datetime_picker/awesome_datetime_picker.dart';
import 'package:awesome_datetime_picker/src/theme/item_theme.dart';
import 'package:awesome_datetime_picker/src/utils/awesome_time_utils.dart';
import 'package:awesome_datetime_picker/src/widgets/custom/custom_item_picker_widget.dart';
import 'package:flutter/material.dart';

/*class AwesomeAmPmPicker extends StatefulWidget {
  const AwesomeAmPmPicker({
    super.key,
    required this.selectedAmPm,
    required this.onSelectedAmPmChanged,
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

  final String selectedAmPm;
  final Function(int) onSelectedAmPmChanged;
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
  State<AwesomeAmPmPicker> createState() => _AwesomeAmPmPickerState();
}

class _AwesomeAmPmPickerState extends State<AwesomeAmPmPicker> {
  @override
  Widget build(BuildContext context) {
    return CustomItemPicker(
      items: AwesomeTimeUtils.amPm,
      initialIndex: AwesomeTimeUtils.amPm.indexOf(widget.selectedAmPm),
      maxIndex: 1,
      minIndex: 0,
      onSelectedItemChanged: widget.onSelectedAmPmChanged,
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
}*/
