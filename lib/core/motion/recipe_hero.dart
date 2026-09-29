import 'package:flutter/material.dart';

import 'motion.dart';

/// Shared-element transition card image → Recipe Detail header (and back).
///
/// The same recipe can appear in several lists on one screen, so a fixed
/// per-recipe Hero tag would collide. Instead, the card the user actually
/// touches ([RecipeHeroArea], on pointer-down) gets a fresh, unique tag; the
/// detail page claims that tag only if the touch just happened. Every other
/// card keeps a private tag, so nothing else ever flies.
class RecipeHero {
  static final ValueNotifier<_Activation?> _active = ValueNotifier(null);
  static int _seq = 0;

  static void _activate(Object owner) {
    _active.value = _Activation(owner, ++_seq, DateTime.now());
  }

  /// Tag for a detail page being opened now, or null when it wasn't opened
  /// from a card tap (deep link, notification...) - then nothing flies.
  static String? claimTag() {
    final a = _active.value;
    if (a == null) return null;
    if (DateTime.now().difference(a.at) > const Duration(milliseconds: 1500)) return null;
    return 'recipe-hero-${a.seq}';
  }
}

class _Activation {
  final Object owner;
  final int seq;
  final DateTime at;
  const _Activation(this.owner, this.seq, this.at);
}

/// Wrap a whole recipe card: touching anywhere on it makes it the hero
/// source for the next Recipe Detail push.
class RecipeHeroArea extends StatefulWidget {
  final Widget child;
  const RecipeHeroArea({super.key, required this.child});

  @override
  State<RecipeHeroArea> createState() => _RecipeHeroAreaState();
}

class _RecipeHeroAreaState extends State<RecipeHeroArea> {
  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => RecipeHero._activate(this),
      child: _RecipeHeroScope(owner: this, child: widget.child),
    );
  }
}

class _RecipeHeroScope extends InheritedWidget {
  final Object owner;
  const _RecipeHeroScope({required this.owner, required super.child});

  @override
  bool updateShouldNotify(_RecipeHeroScope old) => old.owner != owner;
}

/// The card's image. Always a Hero (so activating it never remounts the
/// image); its tag only matches the detail page for the touched card.
class RecipeHeroImage extends StatefulWidget {
  final Widget child;
  const RecipeHeroImage({super.key, required this.child});

  @override
  State<RecipeHeroImage> createState() => _RecipeHeroImageState();
}

class _RecipeHeroImageState extends State<RecipeHeroImage> {
  @override
  Widget build(BuildContext context) {
    final owner = context.dependOnInheritedWidgetOfExactType<_RecipeHeroScope>()?.owner;
    if (owner == null || Motion.reduced(context)) return widget.child;
    return ValueListenableBuilder<_Activation?>(
      valueListenable: RecipeHero._active,
      child: widget.child,
      builder: (context, a, child) {
        final tag = a != null && identical(a.owner, owner)
            ? 'recipe-hero-${a.seq}'
            : 'recipe-hero-own-${identityHashCode(this)}';
        return Hero(tag: tag, transitionOnUserGestures: true, child: child!);
      },
    );
  }
}
