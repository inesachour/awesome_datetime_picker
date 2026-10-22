// ignore_for_file: public_member_api_docs
// Internal implementation file: it is not exported by the package, so its
// members are documented at class level only.

import 'package:awesome_datetime_picker/src/shared/awesome_wheel_style.dart';
import 'package:awesome_datetime_picker/src/shared/custom_item_picker_style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A single iOS-style wheel listing [items] and reporting the selected one.
///
/// Colors and text styles fall back to light or dark defaults depending on
/// the ambient theme brightness.
class CustomItemPicker extends StatefulWidget {
  final List<String> items;

  /// Text shown for each item, when it differs from the item's value (e.g.
  /// "Mon 12" for the value "12"). Same length as [items].
  final List<String>? labels;

  /// Positions of the items that are shown but cannot be selected. When a drag
  /// settles on one, the wheel moves to the nearest selectable item.
  final Set<int> disabledIndices;
  final int initialIndex;
  final ValueChanged<String> onSelectedItemChanged;
  final int? visibleItemCount;
  final CustomItemPickerStyle style;

  /// Whether the wheel shows long labels (such as month names) and therefore
  /// gets a wider default width. Ignored when a width is set explicitly.
  final bool wide;

  /// Whether the wheel wraps around from the last item to the first.
  final bool looping;

  /// Whether to play a light haptic tick each time the user's drag moves the
  /// wheel to another item.
  final bool hapticFeedback;

  const CustomItemPicker({
    super.key,
    required this.items,
    this.labels,
    this.disabledIndices = const {},
    required this.initialIndex,
    required this.onSelectedItemChanged,
    required this.visibleItemCount,
    required this.style,
    this.wide = false,
    this.looping = false,
    this.hapticFeedback = false,
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

  /// True while the user's finger (or mouse) is moving the wheel, including
  /// the fling that follows. Haptics only play then, never for programmatic
  /// jumps or screen-reader steps.
  bool _userScrolling = false;

  /// Raw index last reported by the wheel and the direction of the last move
  /// (1 forward, -1 backward): used to choose between two equally close
  /// selectable items when a drag settles on a disabled one.
  late int _lastRawIndex;
  int _lastDirection = 1;

  bool get _loops => widget.looping && widget.items.length > 1;

  @override
  void initState() {
    super.initState();
    // indexOf returns -1 when the value is not in the list
    _selectedIndex = widget.initialIndex < 0 ? 0 : widget.initialIndex;
    _scrollController = FixedExtentScrollController(
      initialItem: _selectedIndex,
    );
    _lastRawIndex = _selectedIndex;
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

  /// Signed distance from the selected item to the nearest item that can be
  /// selected, searching in [preferred] direction first when two are equally
  /// close; null when every item is disabled.
  int? _distanceToEnabled(int preferred) {
    final n = widget.items.length;
    bool enabledAt(int index) {
      if (_loops) return !widget.disabledIndices.contains(index % n);
      return index >= 0 && index < n && !widget.disabledIndices.contains(index);
    }

    if (enabledAt(_selectedIndex)) return 0;
    for (int d = 1; d <= n; d++) {
      for (final direction in [preferred, -preferred]) {
        if (enabledAt(_selectedIndex + direction * d)) return direction * d;
      }
    }
    return null;
  }

  /// Moves the selection by one selectable item in [direction] (used by
  /// screen-reader actions). Disabled items are skipped.
  void _step(int direction) {
    if (!_scrollController.hasClients) return;
    final target = _nextEnabled(direction);
    if (target == _selectedIndex) return;
    // A looping wheel has no ends: its scroll position keeps counting.
    _scrollController.animateToItem(
      _scrollController.selectedItem + (target - _selectedIndex),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
    );
  }

  /// When a drag settles on a disabled item, eases to the nearest selectable
  /// one, in the direction the wheel was moving if two are equally close.
  void _snapToEnabled() {
    if (widget.disabledIndices.isEmpty ||
        !widget.disabledIndices.contains(_selectedIndex) ||
        !_scrollController.hasClients) {
      return;
    }
    final distance = _distanceToEnabled(_lastDirection);
    if (distance == null || distance == 0) return;
    _scrollController.animateToItem(
      _scrollController.selectedItem + distance,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  /// Index of the nearest selectable item beyond the selection in
  /// [direction] (the selection itself when there is none).
  int _nextEnabled(int direction) {
    final n = widget.items.length;
    for (int d = 1; d <= n; d++) {
      final index = _selectedIndex + direction * d;
      final inRange = _loops || (index >= 0 && index < n);
      if (inRange &&
          !widget.disabledIndices.contains(_loops ? index % n : index)) {
        return index;
      }
    }
    return _selectedIndex;
  }

  bool _hasEnabledBeyond(int direction) =>
      widget.items.isNotEmpty && _nextEnabled(direction) != _selectedIndex;

  String _labelOf(int index) => widget.labels?[index] ?? widget.items[index];

  String _itemAt(int index) {
    if (widget.items.isEmpty) return '';
    if (_loops) return _labelOf(index % widget.items.length);
    return index >= 0 && index < widget.items.length ? _labelOf(index) : '';
  }

  /// Default wheel width: a fraction of the screen width, kept within sensible
  /// bounds so wheels are neither truncated on phones nor huge on desktop/web.
  double _defaultWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return widget.wide
        ? (screenWidth * 0.3).clamp(110.0, 160.0)
        : (screenWidth * 0.15).clamp(56.0, 90.0);
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

    final disabledStyle =
        widget.style.theme?.disabledTextStyle ?? widget.style.disabledTextStyle;

    final backgroundColor = widget.style.theme?.backgroundColor ??
        widget.style.backgroundColor ??
        defaults.backgroundColor;

    final wheelStyle = widget.style.wheelStyle ?? const AwesomeWheelStyle();
    final magnification = wheelStyle.magnification ?? 1.0;

    Widget buildItem(int index) {
      final isSelected = index == _selectedIndex;
      final isDisabled = widget.disabledIndices.contains(index);
      final text = Text(
        _labelOf(index),
        style: isDisabled
            ? (disabledStyle ?? unselectedStyle)
            : isSelected
                ? selectedStyle
                : unselectedStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: false,
      );
      return Center(
        // Without an explicit style, disabled values are the unselected style
        // dimmed.
        child: isDisabled && disabledStyle == null
            ? Opacity(opacity: 0.35, child: text)
            : text,
      );
    }

    return Column(
      children: [
        widget.style.theme?.title ?? const SizedBox.shrink(),
        Semantics(
          container: true,
          value: _itemAt(_selectedIndex),
          increasedValue: _itemAt(_nextEnabled(1)),
          decreasedValue: _itemAt(_nextEnabled(-1)),
          onIncrease: _hasEnabledBeyond(1) ? () => _step(1) : null,
          onDecrease: _hasEnabledBeyond(-1) ? () => _step(-1) : null,
          child: Container(
            height: pickerHeight,
            width: widget.style.theme?.width ??
                widget.style.itemWidth ??
                _defaultWidth(context),
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
                      decoration: wheelStyle.selectorDecoration ??
                          BoxDecoration(
                            color: widget.style.selectorColor ??
                                defaults.selectorColor,
                            borderRadius: wheelStyle.selectorBorderRadius ??
                                BorderRadius.zero,
                          ),
                    ),
                  ),
                ),

                // Scrollable list. Mouse and trackpad dragging is enabled
                // explicitly (Flutter only allows touch by default), and the
                // individual items are hidden from screen readers because the
                // wheel exposes a single adjustable value instead.
                ExcludeSemantics(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: PointerDeviceKind.values.toSet(),
                      scrollbars: false,
                    ),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollStartNotification) {
                          _userScrolling = notification.dragDetails != null;
                        } else if (notification is ScrollEndNotification) {
                          _userScrolling = false;
                          // Not synchronously: the scroll position is still
                          // swapping its activity, and a new animation started
                          // now would be disposed with the old one.
                          Future.microtask(() {
                            if (mounted) _snapToEnabled();
                          });
                        }
                        return false;
                      },
                      child: ListWheelScrollView.useDelegate(
                        controller: _scrollController,
                        itemExtent: itemHeight,
                        perspective: wheelStyle.perspective ?? 0.01,
                        diameterRatio: wheelStyle.diameterRatio ?? 1.5,
                        useMagnifier: magnification != 1.0,
                        magnification: magnification,
                        squeeze: wheelStyle.squeeze ?? 1.0,
                        overAndUnderCenterOpacity:
                            wheelStyle.overAndUnderCenterOpacity ?? 1.0,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (rawIndex) {
                          // A looping wheel reports an ever-growing index.
                          final index = _loops
                              ? rawIndex % widget.items.length
                              : rawIndex;
                          _lastDirection = rawIndex >= _lastRawIndex ? 1 : -1;
                          _lastRawIndex = rawIndex;
                          // Only update if index actually changed
                          if (_selectedIndex != index) {
                            setState(() {
                              _selectedIndex = index;
                            });
                            if (widget.hapticFeedback && _userScrolling) {
                              HapticFeedback.selectionClick();
                            }
                            // Disabled values are only passed through: the
                            // wheel moves on when the drag settles.
                            if (!widget.disabledIndices.contains(index)) {
                              widget.onSelectedItemChanged(widget.items[index]);
                            }
                          }
                        },
                        childDelegate: _loops
                            ? ListWheelChildLoopingListDelegate(
                                children: List.generate(
                                    widget.items.length, buildItem),
                              )
                            : ListWheelChildBuilderDelegate(
                                childCount: widget.items.length,
                                builder: (context, index) => buildItem(index),
                              ),
                      ),
                    ),
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
