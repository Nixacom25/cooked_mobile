import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_theme.dart';
import '../services/theme_service.dart';

/// System/Light/Dark picker, opened from both the Profile menu and the
/// header's three-dot account menu so the toggle is reachable from
/// anywhere in the app.
void showAppearanceSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const AppearanceSheet(),
  );
}

class AppearanceSheet extends StatelessWidget {
  const AppearanceSheet({super.key});

  static const _options = [
    (ThemeMode.system, 'System', 'Match your phone\'s setting'),
    (ThemeMode.light, 'Light', 'Always use the light theme'),
    (ThemeMode.dark, 'Dark', 'Always use the dark theme'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: context.colors.divider,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Appearance',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w800,
                    fontSize: 20.sp,
                    color: context.colors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, size: 24.sp, color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.colors.divider),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService.instance.themeModeNotifier,
            builder: (context, currentMode, _) {
              return Column(
                children: _options.map((opt) {
                  final (mode, label, subtitle) = opt;
                  final isSelected = currentMode == mode;
                  return GestureDetector(
                    onTap: () {
                      ThemeService.instance.setThemeMode(mode);
                      Navigator.pop(context);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.sp,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 13.sp,
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                            color: isSelected ? context.colors.accent : context.colors.border,
                            size: 22.sp,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          SizedBox(height: bottomPad + 16.h),
        ],
      ),
    );
  }
}
