import 'package:flutter/material.dart';

class ItemTheme {
  double? width;
  double? height;
  Color? backgroundColor;
  TextStyle? selectedTextStyle;
  TextStyle? unselectedTextStyle;
  Widget? title;
  EdgeInsets? padding;
  EdgeInsets? margin;

  ItemTheme({
    this.width,
    this.height,
    this.backgroundColor,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.title,
    this.padding,
    this.margin,
  });
}
