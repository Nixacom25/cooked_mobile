import 'package:flutter/material.dart';

import 'motion.dart';

/// Fades a card in while it rises [offset] px (opacity 0 → 1, translateY
/// +8 → 0). Plays once, when first built - scrolling it off and back on
/// screen does not replay it. Use [index] for a light stagger.
class AnimatedCardEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final double offset;
  /// Cap so long lists don't make the last items wait.
  final int maxStaggeredItems;
  /// When set, the entrance plays only the first time an item with this id
  /// is shown this session - lazy lists (e.g. horizontal rows) that rebuild
  /// items on scroll show them instantly afterwards.
  final Object? onceId;

  const AnimatedCardEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = Motion.medium,
    this.offset = Motion.entranceOffset,
    this.maxStaggeredItems = 6,
    this.onceId,
  });

  static final Set<Object> _played = <Object>{};

  @override
  State<AnimatedCardEntrance> createState() => _AnimatedCardEntranceState();
}

class _AnimatedCardEntranceState extends State<AnimatedCardEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Motion.enter);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final once = widget.onceId;
    if (once != null && !AnimatedCardEntrance._played.add(once)) {
      _controller.value = 1;
      return;
    }
    if (Motion.reduced(context)) {
      _controller.value = 1;
      return;
    }
    final slot = widget.index.clamp(0, widget.maxStaggeredItems);
    final delay = Motion.stagger * slot;
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - _curve.value)),
          child: child,
        ),
      ),
    );
  }
}
