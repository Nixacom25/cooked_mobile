import 'package:flutter/material.dart';

import 'motion.dart';

/// Smoothly interpolates a number from its previous value to [value]
/// ($8.42 → $9.31 → … → $14.27). The value itself is already final - the
/// animation is purely visual. Optionally pulses (1.0 → 1.04 → 1.0) when it
/// settles and fires one light haptic for significant changes.
class AnimatedNumber extends StatefulWidget {
  final double value;
  final String Function(double value) format;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Duration duration;
  final bool pulse;
  /// Minimum absolute change that triggers a haptic (null = never).
  final double? hapticThreshold;
  /// When set, the number first shows this value and counts up to [value]
  /// once [startDelay] has passed (e.g. $0 → $68 when a card appears).
  final double? countUpFrom;
  final Duration startDelay;

  const AnimatedNumber({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.textAlign,
    this.duration = Motion.number,
    this.pulse = false,
    this.hapticThreshold,
    this.countUpFrom,
    this.startDelay = Duration.zero,
  });

  /// "$12.34" style currency.
  static String currency(double v, {int decimals = 2}) =>
      '\$${v.toStringAsFixed(decimals)}';

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: Motion.short,
  );
  late bool _counting = widget.countUpFrom == null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_counting) return;
    if (Motion.reduced(context)) {
      _counting = true;
      return;
    }
    Future<void>.delayed(widget.startDelay, () {
      if (mounted && !_counting) setState(() => _counting = true);
    });
  }

  @override
  void didUpdateWidget(AnimatedNumber old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      final threshold = widget.hapticThreshold;
      if (threshold != null && (widget.value - old.value).abs() >= threshold) {
        Motion.lightHaptic();
      }
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      // With no explicit begin, the builder starts at [value] on first build
      // and afterwards animates from whatever is on screen to the new value.
      // With countUpFrom, it holds that value until the delay has passed,
      // then counts up to [value].
      tween: Tween<double>(
        begin: widget.countUpFrom,
        end: _counting ? widget.value : widget.countUpFrom,
      ),
      duration: Motion.of(context, widget.duration),
      curve: Motion.standard,
      onEnd: () {
        if (widget.pulse && !Motion.reduced(context)) {
          _pulse.forward(from: 0);
        }
      },
      builder: (context, v, _) {
        return AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            // 1.0 → 1.04 → 1.0
            final t = _pulse.value;
            final scale = 1 + 0.04 * (t < 0.5 ? t * 2 : (1 - t) * 2);
            return Transform.scale(scale: scale, child: child);
          },
          child: Text(
            widget.format(v),
            style: widget.style,
            textAlign: widget.textAlign,
          ),
        );
      },
    );
  }
}
