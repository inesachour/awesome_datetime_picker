import 'package:awesome_datetime_picker/src/theme/item_theme.dart';
import 'package:flutter/material.dart';

class CustomTextPicker extends StatefulWidget {
  final List<String> items;
  final String initialValue;
  final int maxIndex;
  final int minIndex;
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

  const CustomTextPicker({
    super.key,
    required this.items,
    required this.initialValue,
    required this.maxIndex,
    required this.minIndex,
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
  State<CustomTextPicker> createState() => _CustomTextPickerState();
}

class _CustomTextPickerState extends State<CustomTextPicker> {
  late FixedExtentScrollController _scrollController;
  late String _selectedItem;
  int defaultVisibleItemCount = 5;
  double defaultItemHeight = 40.0;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialValue;
    _scrollController = FixedExtentScrollController(
      initialItem: widget.items.indexOf(widget.initialValue) - widget.minIndex,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double pickerHeight =
        (widget.theme?.height ?? widget.itemHeight ?? defaultItemHeight) *
            (widget.visibleItemCount ?? defaultVisibleItemCount);

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
              MediaQuery.of(context).size.width * 0.25,
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
              ListWheelScrollView.useDelegate(
                controller: _scrollController,
                itemExtent: widget.theme?.height ??
                    widget.itemHeight ??
                    defaultItemHeight,
                perspective: 0.01,
                physics: const FixedExtentScrollPhysics(),
                diameterRatio: 1.5,
                onSelectedItemChanged: (index) {
                  final selectedValue = widget.items[
                      index + widget.minIndex > widget.maxIndex
                          ? widget.maxIndex
                          : index + widget.minIndex];
                  setState(() {
                    _selectedItem = selectedValue;
                  });
                  widget.onSelectedItemChanged(index + widget.minIndex + 1);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: widget.maxIndex - widget.minIndex + 1,
                  builder: (context, index) {
                    final value = widget.items[index + widget.minIndex];
                    final isSelected = value == _selectedItem;
                    return Center(
                      child: Text(
                        value,
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
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Color(0x00FFFFFF),
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
