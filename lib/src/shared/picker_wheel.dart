import 'package:awesome_datetime_picker/src/shared/custom_item_picker_style.dart';
import 'package:awesome_datetime_picker/src/shared/custom_item_picker_widget.dart';
import 'package:awesome_datetime_picker/src/shared/item_theme.dart';
import 'package:flutter/material.dart';

/// Builds one wheel column of a picker, selecting [value] in [items].
///
/// Shared by the date and time pickers, which pass their own public options
/// through [style] and [visibleItemCount].
Widget buildPickerWheel({
  Key? key,
  required List<String> items,
  required String value,
  required ItemTheme? theme,
  required CustomItemPickerStyle style,
  required int? visibleItemCount,
  required ValueChanged<String> onChanged,
}) {
  return CustomItemPicker(
    key: key,
    items: items,
    initialIndex: items.indexOf(value),
    style: CustomItemPickerStyle(
      theme: theme,
      backgroundColor: style.backgroundColor,
      selectorColor: style.selectorColor,
      fadeEffect: style.fadeEffect,
      selectedTextStyle: style.selectedTextStyle,
      unselectedTextStyle: style.unselectedTextStyle,
      itemHeight: style.itemHeight,
      itemWidth: style.itemWidth,
    ),
    visibleItemCount: visibleItemCount,
    onSelectedItemChanged: onChanged,
  );
}
