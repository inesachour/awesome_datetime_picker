import 'package:flutter/material.dart';

class CustomTextPicker extends StatefulWidget {
  final List<String> items;
  final String initialValue;
  final ValueChanged<String> onSelectedItemChanged;
  final double itemExtent;
  final int visibleItemCount;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;

  const CustomTextPicker({
    super.key,
    required this.items,
    required this.initialValue,
    required this.onSelectedItemChanged,
    this.itemExtent = 40.0,
    this.visibleItemCount = 5,
    this.selectedTextStyle,
    this.unselectedTextStyle,
  }) : assert(visibleItemCount >= 3 && visibleItemCount % 2 == 1);

  @override
  State<CustomTextPicker> createState() => _CustomTextPickerState();
}

class _CustomTextPickerState extends State<CustomTextPicker> {
  late FixedExtentScrollController _scrollController;
  late String _selectedItem;

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
    final double pickerHeight = widget.itemExtent * widget.visibleItemCount;

    final TextStyle defaultSelectedStyle = const TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    );

    final TextStyle defaultUnselectedStyle = const TextStyle(
      color: Colors.black54,
      fontSize: 18,
    );

    return Container(
      height: pickerHeight,
      width: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Container(
                height: widget.itemExtent,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
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
              final selectedValue = widget.items[index];
              setState(() {
                _selectedItem = selectedValue;
              });
              widget.onSelectedItemChanged(selectedValue);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.items.length,
              builder: (context, index) {
                final value = widget.items[index];
                final isSelected = value == _selectedItem;
                return Center(
                  child: Text(
                    value,
                    style: isSelected
                        ? (widget.selectedTextStyle ?? defaultSelectedStyle)
                        : (widget.unselectedTextStyle ??
                            defaultUnselectedStyle),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
