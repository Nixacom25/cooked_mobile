import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';

/// The single Welcome screen — kept as the user requested.
/// Flow: Splash → Welcome → GetStarted → Login / Register
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Food pattern full screen
          Image.asset('assets/images/fond.png', fit: BoxFit.cover),

          // Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Logo + title in the upper-center area
                          const Spacer(flex: 3),
                          Image.asset(
                            'assets/images/logo.png',
                            width: 130.w,
                            fit: BoxFit.contain,
                          ),
                          const Spacer(flex: 3),

                          // Bottom section (no card — transparent)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                            child: Column(
                              children: [
                                Text(
                                  'Welcome to Cooked',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                    fontFamily: 'SF Pro',
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Scan ingredients. Save recipes.Plan effortlessly.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: AppColors.textMuted,
                                    fontFamily: 'SF Pro',
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(height: 20.h),

                                // Get Started → navigates to GetStarted (replaces Welcome so no back)
                                SizedBox(
                                  width: double.infinity,
                                  height: 54.h,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes.preferences,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFC83A2D),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.r),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Get Started',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'SF Pro',
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),

                                // Already have account?
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Have an account? ',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontFamily: 'SF Pro',
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          Navigator.pushNamed(context, AppRoutes.login),
                                      child: Text(
                                        'Sign In',
                                        style: TextStyle(
                                          color: const Color(0xFFC83A2D),
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'SF Pro',
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
