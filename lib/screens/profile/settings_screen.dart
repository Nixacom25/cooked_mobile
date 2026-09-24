import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../routes/app_routes.dart';
import '../../widgets/red_header_background.dart';
import '../../core/theme/app_theme.dart';

/// Profile > Settings. Entry point for device/account-level preferences
/// (appearance, push notification categories) that don't belong on the main
/// Profile menu itself.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: RedHeaderBackground()),
          SafeArea(
            bottom: false,
            child: Container(
              margin: EdgeInsets.only(top: 25.h),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 42.r,
                            height: 42.r,
                            decoration: BoxDecoration(
                              color: context.colors.pageBackground,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 20.sp,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Settings',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 20.sp,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 42.r),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      children: [
                        SettingsMenuItem(
                          icon: Icons.dark_mode_outlined,
                          label: 'Dark Mode',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.darkMode),
                        ),
                        Divider(height: 1, thickness: 1, color: context.colors.pageBackground),
                        SettingsMenuItem(
                          svgPath: 'assets/icones/notif.svg',
                          label: 'Notifications',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.notificationSettings),
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Same look as Profile's own menu rows, but reusable across the Settings
/// sub-pages and able to take either a Material icon or an svg asset.
class SettingsMenuItem extends StatelessWidget {
  final String? svgPath;
  final IconData? icon;
  final String label;
  final VoidCallback onTap;

  const SettingsMenuItem({
    super.key,
    this.svgPath,
    this.icon,
    required this.label,
    required this.onTap,
  }) : assert(svgPath != null || icon != null, 'Provide either svgPath or icon');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
                    ? Icon(icon, size: 22.r, color: colors.textPrimary)
                    : SvgPicture.asset(
                        svgPath!,
                        width: 22.r,
                        height: 22.r,
                        colorFilter: ColorFilter.mode(colors.textPrimary, BlendMode.srcIn),
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.circle_outlined, size: 20.r, color: colors.textPrimary),
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
                  color: colors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.textSecondary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
