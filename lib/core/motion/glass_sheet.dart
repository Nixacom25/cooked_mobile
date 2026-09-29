import 'dart:ui';

import 'package:flutter/material.dart';

import 'motion.dart';

/// Modal bottom sheet over a dimmed + blurred background. The sheet rises
/// 30 px while fading in (~250 ms); closing reverses it faster.
Future<T?> showGlassSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool isScrollControlled = false,
}) {
  return Navigator.of(context).push<T>(_GlassSheetRoute<T>(
    builder: builder,
    dismissible: isDismissible,
    isScrollControlled: isScrollControlled,
  ));
}

class _GlassSheetRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;
  final bool dismissible;
  final bool isScrollControlled;

  _GlassSheetRoute({
    required this.builder,
    required this.dismissible,
    required this.isScrollControlled,
  });

  @override
  Color? get barrierColor => null; // drawn ourselves (dim + blur)

  @override
  bool get barrierDismissible => dismissible;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => Motion.medium;

  @override
  Duration get reverseTransitionDuration => Motion.micro;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final sheet = Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * (isScrollControlled ? 0.95 : 0.75),
        ),
        child: Material(color: Colors.transparent, child: builder(context)),
      ),
    );
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: dismissible ? () => Navigator.of(context).maybePop() : null,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                final t = animation.value;
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6 * t, sigmaY: 6 * t),
                  child: ColoredBox(color: Colors.black.withValues(alpha: 0.18 * t)),
                );
              },
            ),
          ),
        ),
        sheet,
      ],
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (Motion.reduced(context)) return child;
    final curved = CurvedAnimation(parent: animation, curve: Motion.enter, reverseCurve: Motion.exit);
    // Only the sheet moves; the backdrop just fades via its own builder.
    return AnimatedBuilder(
      animation: curved,
      child: child,
      builder: (context, child) => Opacity(
        opacity: curved.value,
        child: Transform.translate(offset: Offset(0, 30 * (1 - curved.value)), child: child),
      ),
    );
  }
}

/// Scale + fade for glass popovers / menus: opacity 0 → 1, scale 0.96 → 1,
/// translateY -4 → 0 (~200 ms). Wrap a menu's content with it.
class GlassPopIn extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Alignment alignment;

  const GlassPopIn({
    super.key,
    required this.animation,
    required this.child,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: Motion.enter, reverseCurve: Motion.exit);
    return AnimatedBuilder(
      animation: curved,
      child: child,
      builder: (context, child) {
        final t = curved.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, -4 * (1 - t)),
            child: Transform.scale(scale: 0.96 + 0.04 * t, alignment: alignment, child: child),
          ),
        );
      },
    );
  }
}
