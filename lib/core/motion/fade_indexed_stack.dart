import 'package:flutter/material.dart';

import 'motion.dart';

/// IndexedStack that crossfades the newly selected child in (bottom-tab
/// switching: quick fade, no horizontal slide). Every child stays mounted,
/// so tabs keep their state and scroll position.
class FadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = Motion.micro,
  });

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration, value: 1);
  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: Motion.enter);

  @override
  void didUpdateWidget(FadeIndexedStack old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index && !Motion.reduced(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: [
        // Same widget type for every child, whether active or not, so
        // switching tabs never remounts a subtree.
        // IndexedStack keeps hidden children's animations running
        // (maintainAnimation). TickerMode pauses them, so looping animations
        // of off-screen tabs no longer render frames non-stop.
        for (int i = 0; i < widget.children.length; i++)
          TickerMode(
            enabled: i == widget.index,
            child: FadeTransition(
              opacity: i == widget.index ? _fade : kAlwaysCompleteAnimation,
              child: widget.children[i],
            ),
          ),
      ],
    );
  }
}
