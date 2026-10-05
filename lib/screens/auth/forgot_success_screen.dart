import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../routes/app_routes.dart';
import '../../widgets/red_button.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/l10n.dart';

class ForgotSuccessScreen extends StatelessWidget {
  const ForgotSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarH = MediaQuery.of(context).padding.top;
    final bottomH = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: context.colors.pageBackground,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, statusBarH + 16.h, 24.w, bottomH + 20.h),
          child: Column(
            children: [
              // Top Title: Congratulations!
              Text(
                context.l10n.commonCongratulations,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Rubik',
                  color: context.colors.textPrimary,
                ),
              ),

              const Spacer(),

              // Center Illustration: success1.png
              Image.asset(
                'assets/images/success1.webp',
                width: 280.w,
                fit: BoxFit.contain,
              ),

              const Spacer(),

              // Bottom Info: Password Changed!
              Text(
                context.l10n.authPasswordChanged,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Rubik',
                  color: context.colors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),

              Text(
                context.l10n.authPasswordChangedMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: context.colors.textSecondary,
                  fontFamily: 'SF Pro',
                  height: 1.35,
                ),
              ),
              SizedBox(height: 32.h),

              RedButton(
                label: context.l10n.commonGetStarted,
                color: context.colors.accent,
                height: 52.h,
                fontSize: 16.sp,
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
