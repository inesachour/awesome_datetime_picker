import 'package:awesome_datetime_picker/src/theme/item_theme.dart';
import 'package:flutter/material.dart';

class CustomNumberPicker extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int initialValue;
  final ValueChanged<int> onSelectedItemChanged;
  final int? visibleItemCount;
  final ItemTheme? theme;
  final Color? backgroundColor;
  final Color? selectorColor;
  final bool? fadeEffect;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final double? itemHeight;
  final double? itemWidth;

  const CustomNumberPicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
    required this.onSelectedItemChanged,
    required this.visibleItemCount,
    this.theme,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.backgroundColor,
    this.selectorColor,
    this.fadeEffect = true,
    this.itemHeight,
    this.itemWidth,
  }) : assert(visibleItemCount == null ||
            visibleItemCount >= 3 && visibleItemCount % 2 == 1);

  @override
  State<CustomNumberPicker> createState() => _CustomNumberPickerState();
}

class _CustomNumberPickerState extends State<CustomNumberPicker> {
  late FixedExtentScrollController _scrollController;
  late int _selectedItem;
  int defaultVisibleItemCount = 5;
  double defaultItemHeight = 40.0;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialValue;
    _scrollController = FixedExtentScrollController(
      initialItem: widget.initialValue - widget.minValue,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int itemCount = widget.maxValue - widget.minValue + 1;
    final double pickerHeight =
        (widget.theme?.height ?? widget.itemHeight ?? defaultItemHeight) *
            (widget.visibleItemCount ?? defaultVisibleItemCount);

    // Default text styles
    const TextStyle defaultSelectedStyle = TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    );

    const TextStyle defaultUnselectedStyle = TextStyle(
      color: Colors.black54,
      fontSize: 18,
    );

    return Column(
      children: [
        widget.theme?.title ?? Container(),
        Container(
          height: pickerHeight,
          width: widget.theme?.width ??
              widget.itemWidth ??
              MediaQuery.sizeOf(context).width * 0.16,
          margin: widget.theme?.margin,
          padding: widget.theme?.padding,
          decoration: BoxDecoration(
            color: widget.theme?.backgroundColor ??
                widget.backgroundColor ??
                Colors.white,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Stack(
            children: [
              // The selection highlight
              Positioned.fill(
                child: Center(
                  child: Container(
                    height: widget.theme?.height ??
                        widget.itemHeight ??
                        defaultItemHeight,
                    decoration: BoxDecoration(
                      color:
                          widget.selectorColor ?? Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                ),
              ),

              // The picker wheel
              ListWheelScrollView.useDelegate(
                controller: _scrollController,
                itemExtent: widget.theme?.height ??
                    widget.itemHeight ??
                    defaultItemHeight,
                perspective: 0.01, // iOS-like perspective
                physics: const FixedExtentScrollPhysics(),
                diameterRatio: 1.5, // iOS-like diameter
                onSelectedItemChanged: (index) {
                  final selectedValue = widget.minValue + index;
                  setState(() {
                    _selectedItem = selectedValue > widget.maxValue
                        ? widget.maxValue
                        : selectedValue;
                  });
                  widget.onSelectedItemChanged(selectedValue);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: itemCount,
                  builder: (context, index) {
                    final value = widget.minValue + index;
                    final isSelected = value == _selectedItem;

                    return Center(
                      child: Text(
                        value.toString(),
                        style: isSelected
                            ? (widget.theme?.selectedTextStyle ??
                                widget.selectedTextStyle ??
                                defaultSelectedStyle)
                            : (widget.theme?.unselectedTextStyle ??
                                widget.unselectedTextStyle ??
                                defaultUnselectedStyle),
                      ),
                    );
                  },
                ),
              ),
              if (widget.fadeEffect == null || widget.fadeEffect!) ...[
                // Top fade out gradient
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: widget.theme?.height ??
                      widget.itemHeight ??
                      defaultItemHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom fade out gradient
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: widget.theme?.height ??
                      widget.itemHeight ??
                      defaultItemHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
