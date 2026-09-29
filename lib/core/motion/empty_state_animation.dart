import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'motion.dart';

enum EmptyStateKind {
  /// Magnifying glass searches left/right, a recipe icon appears, settles.
  search,
  /// An ingredient drops into the basket, basket nudges.
  basket,
  /// Empty recipe card, heart gently fills, back to idle.
  savedHeart,
  /// Book opens slightly, chef hat appears, closes.
  cookbook,
  /// Link travels toward a recipe card, card appears briefly.
  link,
}

/// Small, low-energy branded loops for empty states. One cycle is ~2.5 s of
/// motion followed by a long rest, so it never feels busy. Static under
/// Reduce Motion. All variants share the same size/colors so they read as
/// one family.
class EmptyStateAnimation extends StatefulWidget {
  final EmptyStateKind kind;
  final double size;
  final Color color;
  final Color accent;

  const EmptyStateAnimation({
    super.key,
    required this.kind,
    required this.color,
    this.accent = const Color(0xFFC31E26),
    this.size = 64,
  });

  @override
  State<EmptyStateAnimation> createState() => _EmptyStateAnimationState();
}

class _EmptyStateAnimationState extends State<EmptyStateAnimation>
    with SingleTickerProviderStateMixin {
  // 2.5 s of motion + 3 s rest.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5500),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _c.stop();
      _c.value = 0;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// 0→1 over the active part of the cycle, then holds 0.
  double _seg(double v, double start, double end) =>
      ((v - start) / (end - start)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox(
      width: s * 1.6,
      height: s * 1.3,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final v = _c.value / (2500 / 5500); // active phase 0..1, >1 = rest
          final t = v.clamp(0.0, 1.0);
          switch (widget.kind) {
            case EmptyStateKind.search:
              final sweep = t < 0.6 ? math.sin(_seg(t, 0, 0.6) * 2 * math.pi) : 0.0;
              final show = t < 0.6 ? 0.0 : math.sin(_seg(t, 0.6, 1) * math.pi);
              return Stack(alignment: Alignment.center, children: [
                Opacity(
                  opacity: show,
                  child: Transform.scale(
                    scale: 0.6 + 0.4 * show,
                    child: Icon(Icons.restaurant_menu_rounded, size: s * 0.38, color: widget.accent),
                  ),
                ),
                Transform.translate(
                  offset: Offset(sweep * s * 0.18, 0),
                  child: Icon(Icons.search_rounded, size: s, color: widget.color),
                ),
              ]);
            case EmptyStateKind.basket:
              final drop = Curves.easeIn.transform(_seg(t, 0, 0.45));
              final landed = t >= 0.45 && t < 1;
              final nudge = landed ? math.sin(_seg(t, 0.45, 0.75) * math.pi) : 0.0;
              return Stack(alignment: Alignment.center, children: [
                if (t > 0 && t < 0.5)
                  Transform.translate(
                    offset: Offset(0, -s * 0.55 * (1 - drop)),
                    child: Opacity(
                      opacity: 1 - _seg(t, 0.4, 0.5),
                      child: Icon(Icons.eco_rounded, size: s * 0.34, color: widget.accent),
                    ),
                  ),
                Transform.translate(
                  offset: Offset(0, s * 0.08 * nudge),
                  child: Icon(Icons.shopping_basket_outlined, size: s, color: widget.color),
                ),
              ]);
            case EmptyStateKind.savedHeart:
              final fill = math.sin(_seg(t, 0.15, 1) * math.pi);
              return Stack(alignment: Alignment.center, children: [
                Icon(Icons.crop_portrait_rounded, size: s * 1.1, color: widget.color.withValues(alpha: 0.5)),
                Transform.scale(
                  scale: 1 + 0.12 * fill,
                  child: Stack(alignment: Alignment.center, children: [
                    Icon(Icons.favorite_border_rounded, size: s * 0.45, color: widget.color),
                    Opacity(
                      opacity: fill,
                      child: Icon(Icons.favorite_rounded, size: s * 0.45, color: widget.accent),
                    ),
                  ]),
                ),
              ]);
            case EmptyStateKind.cookbook:
              final open = math.sin(_seg(t, 0, 1) * math.pi);
              return Stack(alignment: Alignment.center, children: [
                Transform.translate(
                  offset: Offset(0, -s * 0.42 * open),
                  child: Opacity(
                    opacity: open,
                    child: Icon(Icons.restaurant_rounded, size: s * 0.3, color: widget.accent),
                  ),
                ),
                Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateX(-0.35 * open),
                  child: Icon(
                    open > 0.3 ? Icons.menu_book_rounded : Icons.book_rounded,
                    size: s,
                    color: widget.color,
                  ),
                ),
              ]);
            case EmptyStateKind.link:
              final travel = Motion.standard.transform(_seg(t, 0, 0.55));
              final card = math.sin(_seg(t, 0.5, 1) * math.pi);
              return Stack(alignment: Alignment.center, children: [
                Transform.translate(
                  offset: Offset(s * 0.28, 0),
                  child: Opacity(
                    opacity: card,
                    child: Transform.scale(
                      scale: 0.8 + 0.2 * card,
                      child: Icon(Icons.receipt_long_rounded, size: s * 0.7, color: widget.accent),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(-s * 0.3 + s * 0.5 * travel, 0),
                  child: Opacity(
                    opacity: 1 - _seg(t, 0.5, 0.6) + (t >= 1 || t == 0 ? 1 : 0),
                    child: Icon(Icons.link_rounded, size: s * 0.6, color: widget.color),
                  ),
                ),
              ]);
          }
        },
      ),
    );
  }
}
