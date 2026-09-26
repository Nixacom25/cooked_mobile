import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_theme.dart';

/// Same look as Profile's own menu rows, reused across Profile and the
/// Settings sub-pages. Takes either a Material icon or an svg asset, and
/// optional color overrides for destructive rows (Delete Account, Logout).
class SettingsMenuItem extends StatelessWidget {
  final String? svgPath;
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;
  final Color? chevronColor;
  final Widget? trailing;

  const SettingsMenuItem({
    super.key,
    this.svgPath,
    this.icon,
    required this.label,
    required this.onTap,
    this.textColor,
    this.iconColor,
    this.chevronColor,
    this.trailing,
  }) : assert(svgPath != null || icon != null, 'Provide either svgPath or icon');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveTextColor = textColor ?? colors.textPrimary;
    final effectiveIconColor = iconColor ?? colors.textPrimary;
    final effectiveChevronColor = chevronColor ?? colors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          children: [
            SizedBox(
              width: 24.r,
              height: 24.r,
              child: Center(
                child: icon != null
                    ? Icon(icon, size: 22.r, color: effectiveIconColor)
                    : SvgPicture.asset(
                        svgPath!,
                        width: 22.r,
                        height: 22.r,
                        colorFilter: ColorFilter.mode(effectiveIconColor, BlendMode.srcIn),
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.circle_outlined, size: 20.r, color: effectiveIconColor),
                      ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                  color: effectiveTextColor,
                ),
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded, color: effectiveChevronColor, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
