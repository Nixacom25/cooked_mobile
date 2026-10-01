import 'package:flutter/material.dart';

import 'motion.dart';

/// Text with a soft highlight sweeping across it, left to right, on a loop
/// (the "thinking" shine used by chat assistants). The text stays readable:
/// it rests slightly muted and the band brings it back to full color as it
/// passes.
///
/// Reduce Motion shows the plain text in full color.
class ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle style;

  /// Full-strength color, reached under the band. Defaults to [style]'s color.
  final Color? highlightColor;

  /// Resting opacity of the text outside the band (0-1).
  final double restOpacity;

  /// Time for the band to cross the text.
  final Duration sweep;

  /// Pause between two sweeps.
  final Duration pause;

  final TextAlign? textAlign;
  final int? maxLines;

  const ShimmerText(
    this.text, {
    super.key,
    required this.style,
    this.highlightColor,
    this.restOpacity = 0.45,
    this.sweep = const Duration(milliseconds: 1800),
    this.pause = const Duration(milliseconds: 900),
    this.textAlign,
    this.maxLines,
  });

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.sweep + widget.pause)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.highlightColor ?? widget.style.color ?? DefaultTextStyle.of(context).style.color!;
    final text = Text(
      widget.text,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      // Painted white, then colored by the shader below.
      style: widget.style.copyWith(color: Colors.white),
    );

    if (Motion.reduced(context)) {
      return Text(
        widget.text,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        style: widget.style.copyWith(color: color),
      );
    }

    final rest = color.withValues(alpha: color.a * widget.restOpacity);
    final total = (widget.sweep + widget.pause).inMilliseconds;
    final sweepShare = widget.sweep.inMilliseconds / total;

    return AnimatedBuilder(
      animation: _controller,
      child: text,
      builder: (context, child) {
        // Band center travels from just before the text to just after it,
        // then stays parked off-text during the pause.
        final p = (_controller.value / sweepShare).clamp(0.0, 1.0);
        final center = -0.25 + 1.5 * Curves.easeInOut.transform(p);
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: [rest, color, rest],
            // Band ~44% of the text wide, centred, then slid into place.
            stops: const [0.28, 0.5, 0.72],
            transform: _SlideGradient((center - 0.5) * bounds.width),
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}

class _SlideGradient extends GradientTransform {
  final double dx;
  const _SlideGradient(this.dx);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(dx, 0, 0);
}
