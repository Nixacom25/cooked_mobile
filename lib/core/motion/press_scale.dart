import 'package:flutter/material.dart';

import 'motion.dart';

/// Tap feedback: scales to [scale] on touch-down and back on release, and
/// can darken its child slightly. Never delays the tap callback.
class PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final GestureLongPressStartCallback? onLongPressStart;
  final double scale;
  /// 0-1 black overlay while pressed (e.g. 0.05 for photo cards).
  final double darken;
  final BorderRadius? borderRadius;
  final HitTestBehavior behavior;

  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onLongPressStart,
    this.scale = Motion.pressScale,
    this.darken = 0,
    this.borderRadius,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final duration = Motion.of(context, Motion.press);
    Widget child = widget.child;
    if (widget.darken > 0) {
      child = Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: duration,
                opacity: _pressed ? 1 : 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: widget.darken),
                    borderRadius: widget.borderRadius,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onLongPressStart: widget.onLongPressStart,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: duration,
        curve: _pressed ? Motion.enter : Motion.standard,
        child: child,
      ),
    );
  }
}
