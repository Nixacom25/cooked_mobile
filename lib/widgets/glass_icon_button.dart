import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GlassIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? size;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final Color? glassColor;
  final Color? borderColor;
  final double blurSigma;

  const GlassIconButton({
    super.key,
    required this.child,
    this.onTap,
    this.size,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.shape = BoxShape.circle,
    this.borderRadius,
    this.glassColor,
    this.borderColor,
    this.blurSigma = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = width ?? size ?? 44.r;
    final double buttonHeight = height ?? size ?? 44.r;
    final BorderRadius effectiveBorderRadius = borderRadius ?? BorderRadius.circular(14.r);

    final Color fillColor = glassColor ?? Colors.white.withValues(alpha: 0.45);
    final Color borderC = borderColor ?? Colors.white.withValues(alpha: 0.70);

    Widget content = Container(
      width: buttonWidth,
      height: buttonHeight,
      padding: padding,
      decoration: BoxDecoration(
        color: fillColor,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? effectiveBorderRadius : null,
        border: Border.all(
          color: borderC,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: child),
    );

    Widget frosted = ClipPath(
      clipper: shape == BoxShape.circle
          ? const _CircleClipper()
          : _RRectClipper(effectiveBorderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: content,
      ),
    );

    if (margin != null) {
      frosted = Padding(padding: margin!, child: frosted);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: frosted,
      );
    }

    return frosted;
  }
}

class _CircleClipper extends CustomClipper<Path> {
  const _CircleClipper();

  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _RRectClipper extends CustomClipper<Path> {
  final BorderRadius borderRadius;
  const _RRectClipper(this.borderRadius);

  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.addRRect(borderRadius.toRRect(Rect.fromLTWH(0, 0, size.width, size.height)));
    return path;
  }

  @override
  bool shouldReclip(covariant _RRectClipper oldClipper) => oldClipper.borderRadius != borderRadius;
}
