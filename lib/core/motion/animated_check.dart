import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'motion.dart';

/// Circle + check mark whose strokes draw in, with a subtle scale.
/// Used by success toasts, "Added to Cookbook", grocery check-offs, imports.
class AnimatedCheck extends StatefulWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final bool showCircle;
  final Duration duration;

  const AnimatedCheck({
    super.key,
    required this.size,
    required this.color,
    this.strokeWidth = 2,
    this.showCircle = true,
    this.duration = Motion.long,
  });

  @override
  State<AnimatedCheck> createState() => _AnimatedCheckState();
}

class _AnimatedCheckState extends State<AnimatedCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _controller.value = 1;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Motion.enter.transform(_controller.value);
        return Transform.scale(
          scale: 0.85 + 0.15 * t,
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _CheckPainter(
              progress: _controller.value,
              color: widget.color,
              strokeWidth: widget.strokeWidth,
              showCircle: widget.showCircle,
            ),
          ),
        );
      },
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool showCircle;

  _CheckPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.showCircle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Circle draws over the first 55%, the check over the rest (or all of
    // it without a circle).
    final checkStart = showCircle ? 0.45 : 0.0;
    if (showCircle) {
      final c = (progress / 0.55).clamp(0.0, 1.0);
      final rect = Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      );
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * c, false, paint);
    }

    final k = ((progress - checkStart) / (1 - checkStart)).clamp(0.0, 1.0);
    if (k <= 0) return;
    final w = size.width, h = size.height;
    final p1 = Offset(w * 0.28, h * 0.52);
    final p2 = Offset(w * 0.44, h * 0.67);
    final p3 = Offset(w * 0.73, h * 0.36);
    final l1 = (p2 - p1).distance, l2 = (p3 - p2).distance;
    final drawn = (l1 + l2) * k;
    final path = Path()..moveTo(p1.dx, p1.dy);
    if (drawn <= l1) {
      final p = Offset.lerp(p1, p2, drawn / l1)!;
      path.lineTo(p.dx, p.dy);
    } else {
      path.lineTo(p2.dx, p2.dy);
      final p = Offset.lerp(p2, p3, (drawn - l1) / l2)!;
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) =>
      old.progress != progress || old.color != color;
}
