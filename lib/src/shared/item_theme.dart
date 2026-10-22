import 'package:flutter/material.dart';

/// Appearance of a single wheel (year, month, day, hour, minute or AM/PM).
///
/// Every property is optional. A value set here takes precedence over the
/// matching option on the picker (such as `selectedTextStyle` or
/// `itemHeight`), which in turn takes precedence over the built-in
/// light/dark defaults.
class ItemTheme {
  /// Width of the wheel (default: 15% of the screen width).
  final double? width;

  /// Height of one item, which also sets the wheel height together with
  /// the picker's `visibleItemCount` (default 40).
  final double? height;

  /// Background color of the wheel.
  final Color? backgroundColor;

  /// Text style of the selected (centered) item.
  final TextStyle? selectedTextStyle;

  /// Text style of the items that are not selected.
  final TextStyle? unselectedTextStyle;

  /// Widget displayed above the wheel, for example a label such as "Year".
  final Widget? title;

  /// Padding inside the wheel container.
  final EdgeInsets? padding;

  /// Margin around the wheel container.
  final EdgeInsets? margin;

  /// Creates an item theme. All properties are optional.
  const ItemTheme({
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
