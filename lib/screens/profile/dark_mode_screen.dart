import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../services/theme_service.dart';
import '../../widgets/red_header_background.dart';
import '../../core/theme/app_theme.dart';

class DarkModeScreen extends StatelessWidget {
  const DarkModeScreen({super.key});

  static const _options = [
    (ThemeMode.dark, 'On', 'Always use the dark theme'),
    (ThemeMode.system, 'System Settings', "Match your phone's setting"),
    (ThemeMode.light, 'Off', 'Always use the light theme'),
  ];

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
                            'Dark Mode',
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
                  Expanded(
                    child: ValueListenableBuilder<ThemeMode>(
                      valueListenable: ThemeService.instance.themeModeNotifier,
                      builder: (context, currentMode, _) {
                        return ListView(
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                          children: [
                            ..._options.map((opt) {
                              final (mode, label, subtitle) = opt;
                              final isSelected = currentMode == mode;
                              return GestureDetector(
                                onTap: () => ThemeService.instance.setThemeMode(mode),
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.radio_button_checked_rounded
                                            : Icons.radio_button_off_rounded,
                                        color: isSelected
                                            ? context.colors.accent
                                            : context.colors.border,
                                        size: 22.sp,
                                      ),
                                      SizedBox(width: 14.w),
                                      Expanded(
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            fontFamily: 'Rubik',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16.sp,
                                            color: context.colors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            SizedBox(height: 12.h),
                            Text(
                              "If System Settings is selected, the app's appearance will "
                              "automatically switch to match your device's setting.",
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 13.sp,
                                color: context.colors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        );
                      },
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
