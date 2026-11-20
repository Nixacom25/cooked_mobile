import 'package:flutter/material.dart';

import '../core/motion/skeleton.dart';

/// Photo of a scan result. AI photos (fal) arrive a few seconds after the
/// recipes: a shimmering skeleton holds the exact space until the photo is
/// decoded, then the photo fades in. Errors fall back to the default dish.
class ScanRecipePhoto extends StatelessWidget {
  final String? url;
  const ScanRecipePhoto({super.key, required this.url});

  static const _fallback = 'assets/images/plat1.png';

  /// Starts downloading the scan photos as soon as the results arrive (they
  /// are being generated server side already), so every card is ready sooner.
  static void precache(BuildContext context, Iterable<String?> urls) {
    for (final u in urls) {
      if (u == null || !u.startsWith('http')) continue;
      precacheImage(NetworkImage(u), context, onError: (_, __) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = url;
    if (u == null || u.isEmpty) {
      return Image.asset(_fallback, fit: BoxFit.cover);
    }
    if (!u.startsWith('http')) {
      return Image.asset(
        u,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(_fallback, fit: BoxFit.cover),
      );
    }
    return Image(
      image: NetworkImage(u),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return Stack(
          fit: StackFit.expand,
          children: [
            // Only while loading: no animation left running behind the photo.
            if (frame == null)
              const Shimmer(
                child: SkeletonBox(borderRadius: BorderRadius.zero),
              ),
            AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              child: child,
            ),
          ],
        );
      },
      errorBuilder: (_, __, ___) => Image.asset(_fallback, fit: BoxFit.cover),
    );
  }
}
