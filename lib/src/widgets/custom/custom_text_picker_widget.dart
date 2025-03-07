import 'package:awesome_datetime_picker/src/theme/item_theme.dart';
import 'package:flutter/material.dart';

class CustomTextPicker extends StatefulWidget {
  final List<String> items;
  final String initialValue;
  final int maxIndex;
  final int minIndex;
  final ValueChanged<int> onSelectedItemChanged;
  final double itemExtent;
  final int? visibleItemCount;
  final ItemTheme? theme;
  Color? backgroundColor;
  Color? selectorColor;
  bool? fadeEffect;
  TextStyle? selectedTextStyle;
  TextStyle? unselectedTextStyle;

  CustomTextPicker({
    super.key,
    required this.items,
    required this.initialValue,
    required this.maxIndex,
    required this.minIndex,
    required this.onSelectedItemChanged,
    this.itemExtent = 40.0,
    required this.visibleItemCount,
    this.theme,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.backgroundColor,
    this.selectorColor,
    this.fadeEffect = true,
  }) : assert(visibleItemCount == null ||
            visibleItemCount >= 3 && visibleItemCount % 2 == 1);

  @override
  State<CustomTextPicker> createState() => _CustomTextPickerState();
}

class _CustomTextPickerState extends State<CustomTextPicker> {
  late FixedExtentScrollController _scrollController;
  late String _selectedItem;
  int defaultVisibleItemCount = 5;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialValue;
    _scrollController = FixedExtentScrollController(
      initialItem: widget.items.indexOf(widget.initialValue),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double pickerHeight = widget.itemExtent *
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

    return Container(
      height: pickerHeight,
      width: widget.theme?.width ?? MediaQuery.of(context).size.width * 0.16,
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
                height: widget.itemExtent,
                decoration: BoxDecoration(
                  color: widget.selectorColor ?? Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: _scrollController,
            itemExtent: widget.itemExtent,
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
              height: widget.itemExtent,
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
              height: widget.itemExtent,
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
    );
  }
}
