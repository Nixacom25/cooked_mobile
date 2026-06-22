import 'dart:math';
import 'package:flutter/material.dart';
import '../models/recipe.dart';

class ConfettiAnimation extends StatefulWidget {
  final Widget child;
  final List<RecipeIngredient>? ingredients;
  const ConfettiAnimation({Key? key, required this.child, this.ingredients}) : super(key: key);

  @override
  _ConfettiAnimationState createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _controller.addListener(() {
      _updateParticles();
      setState(() {});
    });
  }

  void _updateParticles() {
    final size = MediaQuery.of(context).size;
    if (_particles.isEmpty && size.width > 0) {
      _particles = List.generate(30, (index) => _createParticle(size));
    }

    for (var particle in _particles) {
      particle.y += particle.speed;
      particle.rotation += particle.rotationSpeed;
      // Fade out and reset when reaching the pot line (around 65% of screen height)
      if (particle.y > size.height * 0.65) {
        // Reset particle to top
        final newParticle = _createParticle(size);
        particle.x = newParticle.x;
        particle.y = -40; // start slightly higher
        particle.speed = newParticle.speed;
        particle.size = newParticle.size;
        particle.emoji = newParticle.emoji;
        particle.color = newParticle.color;
      }
    }
  }

  _ConfettiParticle _createParticle(Size size) {
    // 50% chance emoji, 50% chance square confetti
    bool isEmoji = _random.nextDouble() > 0.4;
    String? emoji;
    Color? color;

    if (isEmoji) {
      // Basil leaves, Mint leaves, Chili peppers
      List<String> emojis = ["🌿", "🍃", "🌶️"];
      emoji = emojis[_random.nextInt(emojis.length)];
    } else {
      // Small diced pieces (red/orange/yellow)
      List<Color> colors = [
        Colors.red.shade400,
        Colors.orange.shade400,
        Colors.yellow.shade500,
      ];
      color = colors[_random.nextInt(colors.length)];
    }

    return _ConfettiParticle(
      x: _random.nextDouble() * size.width,
      y: -40.0 - _random.nextDouble() * size.height, // Stagger start
      speed: 3.0 + _random.nextDouble() * 4.0, // Increased speed
      rotationSpeed: (_random.nextDouble() - 0.5) * 0.1, // rotation
      size: 15.0 + _random.nextDouble() * 20.0, // size 15-35
      emoji: emoji,
      color: color,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Draw particles FIRST so they appear BEHIND the mainContent (the cards/pot)
        ..._particles.map((particle) {
          // Add opacity to make them fade out as they approach the pot
          double opacity = 1.0;
          double limit = size.height * 0.65;
          if (particle.y > limit - 100) {
            opacity = ((limit - particle.y) / 100).clamp(0.0, 1.0);
          }
          return Positioned(
            left: particle.x,
            top: particle.y,
            child: Opacity(
              opacity: opacity,
              child: Transform.rotate(
                angle: particle.rotation,
                child: _buildParticleWidget(particle),
              ),
            ),
          );
        }).toList(),
        widget.child,
      ],
    );
  }

  Widget _buildParticleWidget(_ConfettiParticle particle) {
    if (particle.emoji != null) {
      return Text(
        particle.emoji!,
        style: TextStyle(fontSize: particle.size),
      );
    } else {
      // Small colored square
      return Container(
        width: particle.size * 0.6,
        height: particle.size * 0.6,
        decoration: BoxDecoration(
          color: particle.color,
          borderRadius: BorderRadius.circular(2.0), // slightly rounded squares
        ),
      );
    }
  }
}

class _ConfettiParticle {
  double x;
  double y;
  double speed;
  double rotation = 0;
  double rotationSpeed;
  double size;
  String? emoji;
  Color? color;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.rotationSpeed,
    required this.size,
    this.emoji,
    this.color,
  });
}

