import 'dart:math';
import 'package:flutter/material.dart';

class SteamAnimation extends StatefulWidget {
  final double width;
  final double height;
  final Color steamColor;

  const SteamAnimation({
    super.key,
    required this.width,
    required this.height,
    this.steamColor = Colors.white,
  });

  @override
  State<SteamAnimation> createState() => _SteamAnimationState();
}

class _SteamAnimationState extends State<SteamAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_SteamParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        _updateParticles();
      });
      
    // Initialize some particles
    for (int i = 0; i < 8; i++) {
      _particles.add(_createParticle());
    }
    
    _controller.repeat();
  }

  _SteamParticle _createParticle() {
    return _SteamParticle(
      x: _random.nextDouble() * widget.width,
      y: widget.height + (_random.nextDouble() * 20), // Start slightly below
      size: 40 + _random.nextDouble() * 50, // MUCH LARGER SIZE
      speed: 1.5 + _random.nextDouble() * 2, // Upward speed
      drift: (_random.nextDouble() - 0.5) * 2.0, // Horizontal drift
      opacity: 0.4 + _random.nextDouble() * 0.4, // MUCH HIGHER OPACITY
      life: 0.0,
      wobbleSpeed: 0.05 + _random.nextDouble() * 0.1,
    );
  }

  void _updateParticles() {
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < _particles.length; i++) {
        var p = _particles[i];
        p.y -= p.speed;
        p.x += p.drift + sin(p.life * p.wobbleSpeed) * 0.5;
        p.size += 0.2; // Expand as it goes up
        p.life += 1;

        // Reset particle if it goes too high or completely fades out
        if (p.y < -p.size) {
          _particles[i] = _createParticle();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: CustomPaint(
        painter: _SteamPainter(_particles, widget.steamColor),
      ),
    );
  }
}

class _SteamParticle {
  double x;
  double y;
  double size;
  double speed;
  double drift;
  double opacity;
  double life;
  double wobbleSpeed;

  _SteamParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
    required this.opacity,
    required this.life,
    required this.wobbleSpeed,
  });
}

class _SteamPainter extends CustomPainter {
  final List<_SteamParticle> particles;
  final Color color;

  _SteamPainter(this.particles, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      // Calculate fade based on height (fades out at the top)
      double progress = 1.0 - (p.y / size.height);
      progress = progress.clamp(0.0, 1.0);
      
      // Fade in at the very bottom, fade out at the top
      double currentOpacity = p.opacity;
      if (progress < 0.2) {
        currentOpacity = p.opacity * (progress / 0.2); // Fade in
      } else if (progress > 0.6) {
        currentOpacity = p.opacity * (1.0 - ((progress - 0.6) / 0.4)); // Fade out
      }
      
      currentOpacity = currentOpacity.clamp(0.0, 1.0);
      Color particleColor = color.withOpacity(currentOpacity);

      // Use a radial gradient for a fuzzy edge instead of maskFilter (which breaks on some devices)
      final rect = Rect.fromCircle(center: Offset(p.x, p.y), radius: p.size / 2);
      final gradient = RadialGradient(
        colors: [
          particleColor,
          particleColor.withOpacity(0.0), // Fade to transparent at the edges
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(p.x, p.y), p.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SteamPainter oldDelegate) => true;
}
