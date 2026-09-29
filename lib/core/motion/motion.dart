import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Cooked motion tokens - the single source of truth for every animation in
/// the app, so all screens move the same way.
///
/// Rules (from the Animation spec):
/// - micro-interactions 150-250 ms, screen/content 250-400 ms,
///   celebration 400-900 ms
/// - ease-out for entering, ease-in for leaving, no bouncy springs except
///   tiny button/heart feedback
/// - respect Reduce Motion, never block interaction, never delay content
///   that is already loaded.
abstract final class Motion {
  // Durations
  static const Duration press = Duration(milliseconds: 130);
  static const Duration micro = Duration(milliseconds: 180);
  static const Duration short = Duration(milliseconds: 220);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration long = Duration(milliseconds: 350);
  static const Duration number = Duration(milliseconds: 520);
  static const Duration celebration = Duration(milliseconds: 900);
  /// Network image fade-in over its skeleton.
  static const Duration imageFade = Duration(milliseconds: 250);

  /// Delay between consecutive items of a staggered list.
  static const Duration stagger = Duration(milliseconds: 50);

  // Curves
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve standard = Curves.easeInOutCubic;
  /// Only for tiny feedback (heart, toggles).
  static const Curve pop = Curves.easeOutBack;

  // Distances (logical px)
  static const double entranceOffset = 8;
  static const double pressScale = 0.97;

  /// True when the user asked the OS to reduce motion.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [d] or zero when Reduce Motion is on - state still changes instantly.
  static Duration of(BuildContext context, Duration d) =>
      reduced(context) ? Duration.zero : d;

  static void lightHaptic() => HapticFeedback.lightImpact();
  static void mediumHaptic() => HapticFeedback.mediumImpact();
  static void selectionHaptic() => HapticFeedback.selectionClick();
}
