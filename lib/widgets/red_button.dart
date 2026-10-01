import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'loading_text.dart';
import '../core/theme/app_theme.dart';
import '../core/l10n/l10n.dart';

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
        ? (color?.withValues(alpha: 0.5) ?? context.colors.divider)
        : (color ?? context.colors.accent);
    final Color effectiveTextColor = effectiveDisabled 
        ? (textColor?.withValues(alpha: 0.7) ?? context.colors.textMuted)
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
              color: buttonColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? LoadingText(
                  text: loadingLabel ?? context.l10n.commonProcessing,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w700,
                    fontSize: fontSize ?? 16.sp,
                    color: effectiveTextColor,
                  ),
                )
              // One line; long labels (translations) shrink to fit.
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w700,
                        fontSize: fontSize ?? 16.sp,
                        color: effectiveTextColor,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
