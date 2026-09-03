import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'loading_text.dart';

// ── Shared red button with loading state ──────────────────────────────────────
class RedButton extends StatelessWidget {
  final String label;
  final String? loadingLabel;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final double? fontSize;
  final Color? color;
  final Color? textColor;

  const RedButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
    this.loadingLabel,
    this.width,
    this.height,
    this.fontSize,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool effectiveDisabled = isDisabled || isLoading || onTap == null;
    final Color buttonColor = effectiveDisabled 
        ? (color?.withOpacity(0.5) ?? const Color(0xFFE5E7EB)) 
        : (color ?? const Color(0xFFC83A2D));
    final Color effectiveTextColor = effectiveDisabled 
        ? (textColor?.withOpacity(0.7) ?? const Color(0xFF9CA3AF)) 
        : (textColor ?? Colors.white);

    return GestureDetector(
      onTap: effectiveDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width ?? double.infinity,
        height: height ?? 54.h,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: effectiveDisabled ? [] : [
            BoxShadow(
              color: buttonColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? LoadingText(
                  text: loadingLabel ?? 'Processing',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w700,
                    fontSize: fontSize ?? 16.sp,
                    color: effectiveTextColor,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w700,
                    fontSize: fontSize ?? 16.sp,
                    color: effectiveTextColor,
                  ),
                ),
        ),
      ),
    );
  }
}
