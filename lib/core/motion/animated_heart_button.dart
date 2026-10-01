import 'package:flutter/material.dart';

import 'motion.dart';

/// Wraps any heart / save icon and animates it when [active] flips.
///
/// Save (Instagram-style like): the outline squeezes away, a big filled
/// heart pops up above the icon (~2x), drops back into place while
/// shrinking to icon size, then its color shifts purple → pink → the app
/// red, and the real (filled) icon takes over. Medium haptic. ~1.1 s.
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
  );
  late final AnimationController _unlike = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  static const _purple = Color(0xFF9B2CF0);
  static const _magenta = Color(0xFFD6249F);

  @override
  void didUpdateWidget(HeartBump old) {
    super.didUpdateWidget(old);
    if (old.active == widget.active) return;
    widget.active ? Motion.mediumHaptic() : Motion.lightHaptic();
    if (Motion.reduced(context)) return;
    if (widget.active) {
      _unlike.stop();
      _like.forward(from: 0);
    } else {
      _like.stop();
      _like.value = 0;
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

  @override
  Widget build(BuildContext context) {
    final iconSize = widget.iconSize ?? widget.ringSize * 0.55;
    final icon = AnimatedSwitcher(
      duration: Motion.of(context, Motion.press),
      child: KeyedSubtree(key: ValueKey(widget.active), child: widget.child),
    );

    return AnimatedBuilder(
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

        final t = _like.value;
        // 0.00-0.12  outline squeezes away
        // 0.00-0.30  big heart pops up above the icon (scale 0 → 2)
        // 0.30-0.55  drops back into place, 2 → 1 (small settle)
        // 0.55-1.00  color purple → pink → red, real icon fades back in
        final squeeze = 1 - 0.3 * _seg(t, 0, 0.12);
        final pop = Curves.easeOutBack.transform(_seg(t, 0, 0.30));
        final drop = Curves.easeInOutCubic.transform(_seg(t, 0.30, 0.55));
        final lift = -iconSize * 1.6 * (1 - drop) * (pop.clamp(0.0, 1.0));
        final scale = (2.0 * pop) * (1 - drop) + 1.0 * drop;
        final colorT = _seg(t, 0.55, 1.0);
        final flyColor = colorT < 0.5
            ? Color.lerp(_purple, _magenta, colorT * 2)!
            : Color.lerp(_magenta, widget.ringColor, (colorT - 0.5) * 2)!;
        final handOff = _seg(t, 0.85, 1.0); // real icon returns

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Opacity(
              opacity: handOff,
              child: Transform.scale(scale: t < 0.12 ? squeeze : 1, child: child),
            ),
            IgnorePointer(
              child: Opacity(
                opacity: 1 - handOff,
                child: Transform.translate(
                  offset: Offset(0, lift),
                  child: Transform.scale(
                    scale: scale,
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (rect) => LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [flyColor, Color.lerp(flyColor, _magenta, 1 - colorT)!],
                      ).createShader(rect),
                      child: Icon(Icons.favorite_rounded, size: iconSize, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
