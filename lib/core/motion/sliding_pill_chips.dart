import 'package:flutter/material.dart';

import 'motion.dart';

/// Horizontal chip row with ONE shared selected pill that slides (and
/// resizes) from the previous chip to the newly selected one, Airbnb-style,
/// instead of each chip flashing its own background. The pill fades out
/// when nothing is selected. Chips should be drawn with a transparent
/// background when selected (the pill sits behind them).
class SlidingPillChips extends StatefulWidget {
  final int itemCount;
  final int? selectedIndex;
  final Widget Function(BuildContext context, int index, bool selected) itemBuilder;
  final ValueChanged<int> onTap;
  final Color pillColor;
  final double height;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const SlidingPillChips({
    super.key,
    required this.itemCount,
    required this.selectedIndex,
    required this.itemBuilder,
    required this.onTap,
    required this.pillColor,
    required this.height,
    this.spacing = 8,
    this.padding = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  State<SlidingPillChips> createState() => _SlidingPillChipsState();
}

class _SlidingPillChipsState extends State<SlidingPillChips> {
  final GlobalKey _stackKey = GlobalKey();
  List<GlobalKey> _keys = [];
  Rect? _pill;
  Rect? _lastPill; // kept while fading out so it doesn't jump

  @override
  void initState() {
    super.initState();
    _syncKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(SlidingPillChips old) {
    super.didUpdateWidget(old);
    _syncKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _syncKeys() {
    if (_keys.length != widget.itemCount) {
      _keys = List.generate(widget.itemCount, (_) => GlobalKey());
    }
  }

  void _measure() {
    if (!mounted) return;
    final i = widget.selectedIndex;
    Rect? next;
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (i != null && i >= 0 && i < _keys.length && stackBox != null) {
      final box = _keys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final offset = box.localToGlobal(Offset.zero, ancestor: stackBox);
        next = offset & box.size;
      }
    }
    if (next != _pill) {
      setState(() {
        if (next != null) _lastPill = next;
        _pill = next;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = Motion.of(context, Motion.short);
    final rect = _pill ?? _lastPill;
    return SizedBox(
      height: widget.height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: widget.padding,
        child: Stack(
          key: _stackKey,
          children: [
            if (rect != null)
              AnimatedPositioned(
                duration: d,
                curve: Motion.standard,
                left: rect.left,
                top: rect.top,
                width: rect.width,
                height: rect.height,
                child: AnimatedOpacity(
                  duration: d,
                  opacity: _pill != null ? 1 : 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.pillColor,
                      borderRadius: widget.borderRadius,
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                for (int i = 0; i < widget.itemCount; i++)
                  Padding(
                    padding: EdgeInsets.only(right: i == widget.itemCount - 1 ? 0 : widget.spacing),
                    child: KeyedSubtree(
                      key: _keys[i],
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.onTap(i),
                        child: widget.itemBuilder(context, i, i == widget.selectedIndex),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
