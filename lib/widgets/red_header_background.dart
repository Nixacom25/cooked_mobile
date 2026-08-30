import 'package:flutter/material.dart';

class RedHeaderBackground extends StatelessWidget {
  final double? height;
  final double? width;
  final Widget? child;
  final BorderRadius? borderRadius;

  const RedHeaderBackground({
    super.key,
    this.height,
    this.width,
    this.child,
    this.borderRadius,
  });

  static const LinearGradient gradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0xFFB00812), // Deep red bottom left
      Color(0xFFC40614), // Rich red middle
      Color(0xFFD43A3E), // Warm ruby red upper middle
      Color(0xFFD66F6C), // Soft warm rosy glow top right
    ],
    stops: [0.0, 0.4, 0.75, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: const BoxDecoration(
          gradient: gradient,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // High-resolution Figma mockup background asset fond_page2.png
            Image.asset(
              'assets/images/fond_page2.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),

            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

