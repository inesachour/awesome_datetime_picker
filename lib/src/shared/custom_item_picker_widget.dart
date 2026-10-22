// ignore_for_file: public_member_api_docs
// Internal implementation file: it is not exported by the package, so its
// members are documented at class level only.

import 'package:awesome_datetime_picker/src/shared/custom_item_picker_style.dart';
import 'package:flutter/material.dart';

/// A single iOS-style wheel listing [items] and reporting the selected one.
///
/// Colors and text styles fall back to light or dark defaults depending on
/// the ambient theme brightness.
class CustomItemPicker extends StatefulWidget {
  final List<String> items;
  final int initialIndex;
  final ValueChanged<String> onSelectedItemChanged;
  final int? visibleItemCount;
  final CustomItemPickerStyle style;

  const CustomItemPicker({
    super.key,
    required this.items,
    required this.initialIndex,
    required this.onSelectedItemChanged,
    required this.visibleItemCount,
    required this.style,
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
    // indexOf returns -1 when the value is not in the list
    _selectedIndex = widget.initialIndex < 0 ? 0 : widget.initialIndex;
    _scrollController = FixedExtentScrollController(
      initialItem: _selectedIndex,
    );
  }

  @override
  void didUpdateWidget(CustomItemPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only sync if the parent's requested index is different from our current internal index.
    // This handles external updates and validation rejections while avoiding
    // interrupting the user's manual scroll (where widget.initialIndex == _selectedIndex).
    if (widget.initialIndex != _selectedIndex) {
      _selectedIndex = widget.initialIndex;
      // Ensure the index is within bounds
      if (_selectedIndex >= widget.items.length) {
        _selectedIndex = widget.items.length - 1;
      }
      if (_selectedIndex < 0) {
        _selectedIndex = 0;
      }

      // Jump to the new index if scroll controller is attached
      if (_scrollController.hasClients) {
        _scrollController.jumpToItem(_selectedIndex);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double itemHeight = widget.style.theme?.height ??
        widget.style.itemHeight ??
        defaultItemHeight;
    final double pickerHeight =
        itemHeight * (widget.visibleItemCount ?? defaultVisibleItemCount);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final defaults = _PickerDefaults(isDark: isDark);

    final selectedStyle = widget.style.theme?.selectedTextStyle ??
        widget.style.selectedTextStyle ??
        defaults.selectedTextStyle;

    final unselectedStyle = widget.style.theme?.unselectedTextStyle ??
        widget.style.unselectedTextStyle ??
        defaults.unselectedTextStyle;

    final backgroundColor = widget.style.theme?.backgroundColor ??
        widget.style.backgroundColor ??
        defaults.backgroundColor;

    return Column(
      children: [
        widget.style.theme?.title ?? const SizedBox.shrink(),
        Container(
          height: pickerHeight,
          width: widget.style.theme?.width ??
              widget.style.itemWidth ??
              MediaQuery.of(context).size.width * 0.15,
          margin: widget.style.theme?.margin,
          padding: widget.style.theme?.padding,
          decoration: BoxDecoration(
            color: backgroundColor,
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
                      color: widget.style.selectorColor ?? defaults.selectorColor,
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
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    );
                  },
                ),
              ),

              // Fade effects
              if (widget.style.fadeEffect ?? true) ...[
                _FadeGradient(
                  height: itemHeight,
                  isTop: true,
                  color: backgroundColor,
                ),
                _FadeGradient(
                  height: itemHeight,
                  isTop: false,
                  color: backgroundColor,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Brightness-aware fallbacks used when the user supplies no color or style.
///
/// The light values match the original iOS-like look; the dark values keep
/// the same contrast relationships on a dark surface.
class _PickerDefaults {
  final bool isDark;

  const _PickerDefaults({required this.isDark});

  Color get backgroundColor => isDark ? const Color(0xFF1C1C1E) : Colors.white;

  Color get selectorColor =>
      isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100;

  TextStyle get selectedTextStyle => TextStyle(
        color: isDark ? Colors.white : Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      );

  TextStyle get unselectedTextStyle => TextStyle(
        color: isDark ? Colors.white54 : Colors.black54,
        fontSize: 18,
      );
}

/// Optimized fade gradient widget - stateless and const-friendly
class _FadeGradient extends StatelessWidget {
  final double height;
  final bool isTop;
  final Color color;

  const _FadeGradient({
    required this.height,
    required this.isTop,
    required this.color,
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
              colors: [
                color,
                color.withAlpha(0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
