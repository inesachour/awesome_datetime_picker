import 'package:awesome_datetime_picker/src/theme/item_theme.dart';
import 'package:flutter/material.dart';

class CustomNumberPicker extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int initialValue;
  final ValueChanged<int> onSelectedItemChanged;
  final double itemExtent;
  final int visibleItemCount;
  final ItemTheme? theme;

  const CustomNumberPicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
    required this.onSelectedItemChanged,
    this.itemExtent = 40.0,
    this.visibleItemCount = 5,
    this.theme,
  }) : assert(visibleItemCount >= 3 && visibleItemCount % 2 == 1);

  @override
  State<CustomNumberPicker> createState() => _CustomNumberPickerState();
}

class _CustomNumberPickerState extends State<CustomNumberPicker> {
  late FixedExtentScrollController _scrollController;
  late int _selectedItem;

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
    final double pickerHeight = widget.itemExtent * widget.visibleItemCount;

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

    return Container(
      height: pickerHeight,
      width: widget.theme?.width ?? MediaQuery.sizeOf(context).width * 0.16,
      decoration: BoxDecoration(
        color: widget.theme?.backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // The selection highlight
          Positioned.fill(
            child: Center(
              child: Container(
                height: widget.itemExtent,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
            ),
          ),

          // The picker wheel
          ListWheelScrollView.useDelegate(
            controller: _scrollController,
            itemExtent: widget.itemExtent,
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
                            defaultSelectedStyle)
                        : (widget.theme?.unselectedTextStyle ??
                            defaultUnselectedStyle),
                  ),
                );
              },
            ),
          ),

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
      ),
    );
  }
}
