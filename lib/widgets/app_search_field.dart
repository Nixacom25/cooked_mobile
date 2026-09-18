import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_theme.dart';

class AppSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Color? backgroundColor;
  final Color? borderColor;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final double? borderRadius;
  final FocusNode? focusNode;

  const AppSearchField({
    super.key,
    this.controller,
    this.hintText = 'Search your recipes',
    this.onChanged,
    this.onSubmitted,
    this.backgroundColor,
    this.borderColor,
    this.suffixIcon,
    this.onSuffixTap,
    this.borderRadius,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? 50.r),
        border: Border.all(color: borderColor ?? colors.border),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 30.sp, color: colors.textMuted),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 14.sp,
                color: colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 14.sp,
                  color: colors.textMuted,
                ),
                filled: true,
                fillColor:
                    Colors.transparent, // background is handled by Container
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          if (suffixIcon != null)
            GestureDetector(
              onTap: onSuffixTap,
              child: Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Icon(
                  suffixIcon,
                  size: 22.sp,
                  color: colors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
