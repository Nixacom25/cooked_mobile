import 'package:flutter/material.dart';

import 'motion.dart';

/// New chip/item: scale 0.9 → 1 + fade in (~200 ms), once on mount.
class PopIn extends StatelessWidget {
  final Widget child;
  const PopIn({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: Motion.reduced(context) ? 1 : 0, end: 1),
      duration: Motion.of(context, Motion.short),
      curve: Motion.enter,
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(scale: 0.9 + 0.1 * t, child: child),
      ),
    );
  }
}

/// Removed chip/item: fades out + scales to 0.9, then its space collapses
/// so the neighbours slide into place instead of jumping. Set [removing]
/// and drop the item from the list in [onRemoved].
class AnimatedRemoval extends StatefulWidget {
  final bool removing;
  final VoidCallback onRemoved;
  final Widget child;
  final Axis axis;

  const AnimatedRemoval({
    super.key,
    required this.removing,
    required this.onRemoved,
    required this.child,
    this.axis = Axis.vertical,
  });

  @override
  State<AnimatedRemoval> createState() => _AnimatedRemovalState();
}

class _AnimatedRemovalState extends State<AnimatedRemoval> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: Motion.short);

  @override
  void didUpdateWidget(AnimatedRemoval old) {
    super.didUpdateWidget(old);
    if (widget.removing && !old.removing) {
      if (Motion.reduced(context)) {
        widget.onRemoved();
      } else {
        _c.forward().then((_) {
          if (mounted) widget.onRemoved();
        });
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final fade = Curves.easeIn.transform((_c.value / 0.6).clamp(0.0, 1.0));
        final collapse = Motion.standard.transform(((_c.value - 0.4) / 0.6).clamp(0.0, 1.0));
        return ClipRect(
          child: Align(
            alignment: Alignment.topLeft,
            heightFactor: widget.axis == Axis.vertical ? 1 - collapse : null,
            widthFactor: widget.axis == Axis.horizontal ? 1 - collapse : null,
            child: Opacity(
              opacity: 1 - fade,
              child: Transform.scale(scale: 1 - 0.1 * fade, child: child),
            ),
          ),
        );
      },
    );
  }
}
