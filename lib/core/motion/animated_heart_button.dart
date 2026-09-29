import 'package:flutter/material.dart';

import 'motion.dart';

/// Wraps any heart / save icon and animates it when [active] flips:
/// - save: icon crossfades to filled, scale 1 → 1.2 → 1, small red ring
///   pulse, medium haptic
/// - unsave: crossfade to outline, scale 1 → 0.9 → 1, light haptic
/// ~300 ms. The caller owns the state (update it optimistically on tap and
/// roll back if the request fails) - the animation follows the state.
class HeartBump extends StatefulWidget {
  final bool active;
  final Widget child;
  final Color ringColor;
  /// Diameter the ring grows to.
  final double ringSize;

  const HeartBump({
    super.key,
    required this.active,
    required this.child,
    this.ringColor = const Color(0xFFC31E26),
    this.ringSize = 36,
  });

  @override
  State<HeartBump> createState() => _HeartBumpState();
}

class _HeartBumpState extends State<HeartBump> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  @override
  void didUpdateWidget(HeartBump old) {
    super.didUpdateWidget(old);
    if (old.active == widget.active) return;
    widget.active ? Motion.mediumHaptic() : Motion.lightHaptic();
    if (!Motion.reduced(context)) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = AnimatedSwitcher(
      duration: Motion.of(context, Motion.press),
      child: KeyedSubtree(key: ValueKey(widget.active), child: widget.child),
    );
    return AnimatedBuilder(
      animation: _controller,
      child: icon,
      builder: (context, child) {
        final t = _controller.value;
        final running = _controller.isAnimating;
        // Rise over the first 40%, settle over the rest.
        final bump = t < 0.4 ? Curves.easeOut.transform(t / 0.4) : 1 - Curves.easeInOut.transform((t - 0.4) / 0.6);
        final scale = running ? 1 + (widget.active ? 0.2 : -0.1) * bump : 1.0;
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (running && widget.active)
              IgnorePointer(
                child: Opacity(
                  opacity: (1 - t).clamp(0.0, 1.0),
                  child: Container(
                    width: widget.ringSize * (0.5 + 0.5 * t),
                    height: widget.ringSize * (0.5 + 0.5 * t),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.ringColor.withValues(alpha: 0.55),
                        width: 1.5 * (1 - t) + 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            Transform.scale(scale: scale, child: child),
          ],
        );
      },
    );
  }
}
