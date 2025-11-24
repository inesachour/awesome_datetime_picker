import 'package:awesome_datetime_picker/src/theme/item_theme.dart';
import 'package:flutter/material.dart';

class CustomItemPickerStyle {
  final Color? backgroundColor;
  final Color? selectorColor;
  final bool? fadeEffect;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final double? itemHeight;
  final double? itemWidth;
  final ItemTheme? theme;

  const CustomItemPickerStyle({
    this.backgroundColor,
    this.selectorColor,
    this.fadeEffect,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.itemHeight,
    this.itemWidth,
    this.theme,
  });
}
