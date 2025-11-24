import 'package:awesome_datetime_picker/src/theme/item_theme.dart';
import 'package:flutter/material.dart';

class CustomItemPicker extends StatefulWidget {
  final List<String> items;
  final int initialIndex;
  final ValueChanged<String> onSelectedItemChanged;
  final int? visibleItemCount;
  final ItemTheme? theme;
  final Color? backgroundColor;
  final Color? selectorColor;
  final bool? fadeEffect;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final double? itemHeight;
  final double? itemWidth;

  const CustomItemPicker({
    super.key,
    required this.items,
    required this.initialIndex,
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
  State<CustomItemPicker> createState() => _CustomItemPickerState();
}

class _CustomItemPickerState extends State<CustomItemPicker> {
  late FixedExtentScrollController _scrollController;
  late int _selectedIndex;
  static const int defaultVisibleItemCount = 5;
  static const double defaultItemHeight = 40.0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _scrollController = FixedExtentScrollController(
      initialItem: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double itemHeight =
        widget.theme?.height ?? widget.itemHeight ?? defaultItemHeight;
    final double pickerHeight =
        itemHeight * (widget.visibleItemCount ?? defaultVisibleItemCount);

    const TextStyle defaultSelectedStyle = TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    );

    const TextStyle defaultUnselectedStyle = TextStyle(
      color: Colors.black54,
      fontSize: 18,
    );

    final selectedStyle = widget.theme?.selectedTextStyle ??
        widget.selectedTextStyle ??
        defaultSelectedStyle;

    final unselectedStyle = widget.theme?.unselectedTextStyle ??
        widget.unselectedTextStyle ??
        defaultUnselectedStyle;

    return Column(
      children: [
        widget.theme?.title ?? const SizedBox.shrink(),
        Container(
          height: pickerHeight,
          width: widget.theme?.width ??
              widget.itemWidth ??
              MediaQuery.of(context).size.width * 0.15,
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
              // Selector highlight
              Positioned.fill(
                child: Center(
                  child: Container(
                    height: itemHeight,
                    decoration: BoxDecoration(
                      color: widget.selectorColor ?? Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                ),
              ),

              // Scrollable list
              ListWheelScrollView.useDelegate(
                controller: _scrollController,
                itemExtent: itemHeight,
                perspective: 0.01,
                physics: const FixedExtentScrollPhysics(),
                diameterRatio: 1.5,
                onSelectedItemChanged: (index) {
                  // Only update if index actually changed
                  if (_selectedIndex != index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                    widget.onSelectedItemChanged(widget.items[index]);
                  }
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: widget.items.length,
                  builder: (context, index) {
                    final value = widget.items[index];
                    final isSelected = index == _selectedIndex;

                    return Center(
                      child: Text(
                        value,
                        style: isSelected ? selectedStyle : unselectedStyle,
                      ),
                    );
                  },
                ),
              ),

              // Fade effects
              if (widget.fadeEffect ?? true) ...[
                _FadeGradient(
                  height: itemHeight,
                  isTop: true,
                ),
                _FadeGradient(
                  height: itemHeight,
                  isTop: false,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Optimized fade gradient widget - stateless and const-friendly
class _FadeGradient extends StatelessWidget {
  final double height;
  final bool isTop;

  const _FadeGradient({
    required this.height,
    required this.isTop,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: 0,
      right: 0,
      height: height,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
              end: isTop ? Alignment.bottomCenter : Alignment.topCenter,
              colors: const [
                Colors.white,
                Color(0x00FFFFFF),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
