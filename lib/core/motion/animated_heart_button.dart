import 'package:flutter/material.dart';

import 'motion.dart';

/// Wraps any heart / save icon and animates it when [active] flips.
///
/// Save (Instagram-style like): the outline squeezes away, a big filled
/// heart pops up above the icon (~2x) and drops back into place while
/// shrinking to icon size, then the real (filled) icon takes over. The
/// heart stays the app red the whole time. Medium haptic. ~1.1 s.
///
/// The flying heart is drawn in the app overlay, so it is never cut off or
/// hidden by neighbours (e.g. a pinned image header above the icon).
///
/// Unsave: quick crossfade to the outline with a 1 → 0.9 → 1 dip, light
/// haptic.
///
/// The caller owns the state (update it optimistically on tap and roll
/// back if the request fails) - the animation follows the state.
class HeartBump extends StatefulWidget {
  final bool active;
  final Widget child;
  /// Final color of the flying heart (should match the filled icon).
  final Color ringColor;
  /// Reference size (≈ the tap target); the flying heart uses [iconSize].
  final double ringSize;
  /// Size of the heart icon itself. Defaults to ~55% of [ringSize].
  final double? iconSize;

  const HeartBump({
    super.key,
    required this.active,
    required this.child,
    this.ringColor = const Color(0xFFC31E26),
    this.ringSize = 36,
    this.iconSize,
  });

  @override
  State<HeartBump> createState() => _HeartBumpState();
}

class _HeartBumpState extends State<HeartBump> with TickerProviderStateMixin {
  late final AnimationController _like = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..addStatusListener(_onLikeStatus);
  late final AnimationController _unlike = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  final LayerLink _link = LayerLink();
  final OverlayPortalController _portal = OverlayPortalController();

  void _onLikeStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
      _setPortal(false);
    }
  }

  /// The overlay can't be toggled while the tree is building, so the change
  /// is applied right after the current frame.
  void _setPortal(bool show) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _portal.isShowing == show) return;
      if (show && (!_like.isAnimating || Overlay.maybeOf(context) == null)) return;
      show ? _portal.show() : _portal.hide();
    });
  }

  @override
  void didUpdateWidget(HeartBump old) {
    super.didUpdateWidget(old);
    if (old.active == widget.active) return;
    widget.active ? Motion.mediumHaptic() : Motion.lightHaptic();
    if (Motion.reduced(context)) return;
    if (widget.active) {
      _unlike.stop();
      _like.forward(from: 0);
      _setPortal(true);
    } else {
      _like.stop();
      _like.value = 0;
      _setPortal(false);
      _unlike.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _like.dispose();
    _unlike.dispose();
    super.dispose();
  }

  double _seg(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);

  /// The big heart that pops above the icon and drops back into it.
  Widget _flyingHeart(double iconSize) {
    return AnimatedBuilder(
      animation: _like,
      builder: (context, _) {
        final t = _like.value;
        // 0.00-0.30  pops up above the icon (scale 0 → 2)
        // 0.30-0.55  drops back into place, 2 → 1
        // 0.85-1.00  hands off to the real icon
        final pop = Curves.easeOutBack.transform(_seg(t, 0, 0.30));
        final drop = Curves.easeInOutCubic.transform(_seg(t, 0.30, 0.55));
        final lift = -iconSize * 1.6 * (1 - drop) * pop.clamp(0.0, 1.0);
        final scale = (2.0 * pop) * (1 - drop) + 1.0 * drop;
        final handOff = _seg(t, 0.85, 1.0);
        return Opacity(
          opacity: 1 - handOff,
          child: Transform.translate(
            offset: Offset(0, lift),
            child: Transform.scale(
              scale: scale,
              child: Icon(Icons.favorite_rounded, size: iconSize, color: widget.ringColor),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = widget.iconSize ?? widget.ringSize * 0.55;
    final icon = AnimatedSwitcher(
      duration: Motion.of(context, Motion.press),
      child: KeyedSubtree(key: ValueKey(widget.active), child: widget.child),
    );

    final animatedIcon = AnimatedBuilder(
      animation: Listenable.merge([_like, _unlike]),
      child: icon,
      builder: (context, child) {
        // Unsave: 1 → 0.9 → 1
        if (_unlike.isAnimating) {
          final u = _unlike.value;
          final dip = 1 - 0.1 * (u < 0.5 ? u * 2 : (1 - u) * 2);
          return Transform.scale(scale: dip, child: child);
        }
        if (!_like.isAnimating) return child!;
        // Save: the outline squeezes away, then the real icon fades back
        // in as the flying heart lands on it.
        final t = _like.value;
        final squeeze = 1 - 0.3 * _seg(t, 0, 0.12);
        return Opacity(
          opacity: _seg(t, 0.85, 1.0),
          child: Transform.scale(scale: t < 0.12 ? squeeze : 1, child: child),
        );
      },
    );

    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (context) => Positioned(
        left: 0,
        top: 0,
        child: IgnorePointer(
          child: CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.center,
            followerAnchor: Alignment.center,
            child: SizedBox.square(
              dimension: iconSize,
              child: OverflowBox(
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                child: _flyingHeart(iconSize),
              ),
            ),
          ),
        ),
      ),
      child: CompositedTransformTarget(link: _link, child: animatedIcon),
    );
  }
}
