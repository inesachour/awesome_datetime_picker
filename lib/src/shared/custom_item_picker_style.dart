// ignore_for_file: public_member_api_docs
// Internal implementation file: it is not exported by the package, so its
// members are documented at class level only.

import 'package:awesome_datetime_picker/src/shared/awesome_wheel_style.dart';
import 'package:awesome_datetime_picker/src/shared/item_theme.dart';
import 'package:flutter/material.dart';

/// Visual options shared by all wheels, collected from the public pickers.
class CustomItemPickerStyle {
  final Color? backgroundColor;
  final Color? selectorColor;
  final bool? fadeEffect;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final TextStyle? disabledTextStyle;
  final double? itemHeight;
  final double? itemWidth;
  final ItemTheme? theme;
  final AwesomeWheelStyle? wheelStyle;

  const CustomItemPickerStyle({
    this.backgroundColor,
    this.selectorColor,
    this.fadeEffect,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.disabledTextStyle,
    this.itemHeight,
    this.itemWidth,
    this.theme,
    this.wheelStyle,
  });
}
