import 'package:flutter/material.dart';

import 'motion.dart';

/// Text with a soft band sweeping across it, left to right, on a loop (the
/// "thinking" shine used by chat assistants). The text keeps its own color;
/// only the moving band is tinted ([bandColor], grey by default).
///
/// Reduce Motion shows the plain text.
class ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle style;

  /// Color of the moving band. The rest of the text uses [style]'s color.
  final Color bandColor;

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
    this.bandColor = const Color(0xFF9E9E9E),
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
    final color = widget.style.color ?? DefaultTextStyle.of(context).style.color!;
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
            colors: [color, widget.bandColor, color],
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
