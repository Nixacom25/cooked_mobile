import 'package:flutter/material.dart';

import 'motion.dart';

/// Teaches that a horizontal row scrolls: the first time [hintId] is shown
/// this session, the row shifts left ~16 px and eases back (~700 ms).
/// Never repeats and never plays under Reduce Motion.
class ScrollHint {
  static final Set<String> _shown = <String>{};

  static void play(BuildContext context, ScrollController controller, String hintId) {
    if (Motion.reduced(context) || !_shown.add(hintId)) return;
    Future<void>.delayed(const Duration(milliseconds: 600), () async {
      if (!controller.hasClients || controller.offset != 0) return;
      await controller.animateTo(16, duration: const Duration(milliseconds: 350), curve: Motion.standard);
      if (!controller.hasClients) return;
      await controller.animateTo(0, duration: const Duration(milliseconds: 350), curve: Motion.standard);
    });
  }
}
