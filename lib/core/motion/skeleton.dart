import 'package:flutter/material.dart';

import 'motion.dart';

/// Skeleton colors: warm gray / off-white in light mode, dark grays in dark
/// mode (never white flashes).
class SkeletonColors {
  final Color base;
  final Color highlight;
  const SkeletonColors(this.base, this.highlight);

  static SkeletonColors of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark
        ? const SkeletonColors(Color(0xFF26262A), Color(0xFF323237))
        : const SkeletonColors(Color(0xFFEFEBE6), Color(0xFFF8F5F1));
  }
}

/// One shared shimmer for a whole subtree: a low-contrast gradient sweeping
/// left → right every ~1.4 s. Every [SkeletonBox] below it moves in sync.
class Shimmer extends StatefulWidget {
  final Widget child;
  const Shimmer({super.key, required this.child});

  static _ShimmerState? _of(BuildContext context) =>
      context.findAncestorStateOfType<_ShimmerState>();

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      controller.stop();
    } else if (!controller.isAnimating) {
      controller.repeat();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// A skeleton block. Inside a [Shimmer] it shares its animation; alone it
/// runs its own. Give it the exact size of the final content so the layout
/// never jumps when the real content crossfades in.
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final BoxShape shape;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.shape = BoxShape.rectangle,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  AnimationController? _own;

  Animation<double> _animation(BuildContext context) {
    final shared = Shimmer._of(context);
    if (shared != null) return shared.controller;
    _own ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (!Motion.reduced(context) && !_own!.isAnimating) _own!.repeat();
    return _own!;
  }

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = SkeletonColors.of(context);
    return AnimatedBuilder(
      animation: _animation(context),
      builder: (context, _) {
        final t = (_own ?? Shimmer._of(context)!.controller).value;
        // Sweep from off-screen left (-2) to off-screen right (+2).
        final x = -2 + 4 * t;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.circle ? null : widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(x - 1, 0),
              end: Alignment(x + 1, 0),
              colors: [colors.base, colors.highlight, colors.base],
            ),
          ),
        );
      },
    );
  }
}

/// Crossfades a skeleton into real content when [loading] turns false.
/// Keep both the same size.
class SkeletonSwitcher extends StatelessWidget {
  final bool loading;
  final Widget skeleton;
  final Widget child;

  const SkeletonSwitcher({
    super.key,
    required this.loading,
    required this.skeleton,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Motion.of(context, Motion.short),
      switchInCurve: Motion.enter,
      switchOutCurve: Motion.exit,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, if (current != null) current],
      ),
      child: loading
          ? KeyedSubtree(key: const ValueKey('skeleton'), child: skeleton)
          : KeyedSubtree(key: const ValueKey('content'), child: child),
    );
  }
}
