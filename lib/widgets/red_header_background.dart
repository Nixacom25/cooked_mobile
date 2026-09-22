import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import '../core/theme/app_theme.dart';

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

  static const LinearGradient _darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF4A0508),
      Color(0xFFC31E26),
      Color(0x00C31E26),
    ],
    stops: [0.0, 0.22, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        color: isDark ? context.colors.pageBackground : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isDark)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                // Fixed-height glow band regardless of how tall this widget
                // is asked to be, since it's used both behind a short
                // tab-screen header and behind a full-screen auth card.
                height: 220.h,
                child: const DecoratedBox(
                  decoration: BoxDecoration(gradient: _darkGradient),
                ),
              )
            else ...[
              const DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
              // High-resolution Figma mockup background asset fond_page2.png
              ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      context.colors.pageBackground.withValues(alpha: 0.3),
                      context.colors.pageBackground.withValues(alpha: 0.6),
                      context.colors.pageBackground,
                    ],
                    stops: const [0.0, 0.15, 0.25, 0.35]).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  'assets/images/fond_page2.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ],

            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

