import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FloatingHeart extends StatefulWidget {
  final VoidCallback onAnimationComplete;
  final double xOffset;
  final double durationMultiplier;
  final double scaleMultiplier;

  const FloatingHeart({
    super.key,
    required this.onAnimationComplete,
    this.xOffset = 0,
    this.durationMultiplier = 1.0,
    this.scaleMultiplier = 1.0,
  });

  @override
  State<FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<FloatingHeart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  late Animation<double> _verticalTranslation;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    final duration = Duration(milliseconds: (1800 * widget.durationMultiplier).toInt());
    _controller = AnimationController(vsync: this, duration: duration);

    // 1. Initial Pop & Bounce (0ms - 220ms)
    // 2. Scale down (220ms - end)
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.6, end: 1.15).chain(CurveTween(curve: Curves.easeOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 8,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.75).chain(CurveTween(curve: Curves.linear)),
        weight: 82,
      ),
    ]).animate(_controller);

    // 3. Opacity: 0 -> 1 quickly, then 1 -> 0 in last 25%
    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: Curves.easeIn)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
    ]).animate(_controller);

    // 4. Vertical translation: 0 -> -140px
    _verticalTranslation = Tween<double>(begin: 0, end: -160.h).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 1.0, curve: Curves.linear)),
    );

    // 5. Rotation: -8deg -> +8deg (randomized start)
    final startRotation = (math.Random().nextDouble() * 0.2) - 0.1; // -0.1 to 0.1 rad (~ -6 to +6 deg)
    _rotation = Tween<double>(begin: startRotation, end: -startRotation).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward().then((_) => widget.onAnimationComplete());
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
      builder: (context, child) {
        // 6. Sinusoidal horizontal movement
        // x = sin(progress * PI * 2) * 12
        final progress = _controller.value;
        final wobble = math.sin(progress * math.pi * 2.5) * 12.w;
        
        return Transform.translate(
          offset: Offset(widget.xOffset + wobble, _verticalTranslation.value),
          child: Transform.rotate(
            angle: _rotation.value,
            child: Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value * widget.scaleMultiplier,
                child: Icon(
                  Icons.favorite_rounded,
                  color: const Color(0xFFC83A2D),
                  size: 24.sp,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FloatingHeartManager extends StatefulWidget {
  final Widget child;
  const FloatingHeartManager({super.key, required this.child});

  static FloatingHeartManagerState? of(BuildContext context) {
    return context.findAncestorStateOfType<FloatingHeartManagerState>();
  }

  @override
  State<FloatingHeartManager> createState() => FloatingHeartManagerState();
}

class FloatingHeartManagerState extends State<FloatingHeartManager> {
  final List<Widget> _hearts = [];
  final math.Random _random = math.Random();

  void spawnHeart(Offset position) {
    final key = UniqueKey();
    final xOffset = (_random.nextDouble() * 20) - 10; // -10 to +10
    final durationMult = 0.9 + (_random.nextDouble() * 0.3); // 0.9 to 1.2
    final scaleMult = 0.9 + (_random.nextDouble() * 0.2); // 0.9 to 1.1

    setState(() {
      _hearts.add(
        Positioned(
          key: key,
          left: position.dx - 12, // center the heart (size is ~24)
          top: position.dy - 12,
          child: FloatingHeart(
            xOffset: xOffset,
            durationMultiplier: durationMult,
            scaleMultiplier: scaleMult,
            onAnimationComplete: () {
              if (mounted) {
                setState(() {
                  _hearts.removeWhere((h) => h.key == key);
                });
              }
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ..._hearts,
      ],
    );
  }
}
