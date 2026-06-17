import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/red_button.dart';

/// The single Welcome screen — kept as the user requested.
/// Flow: Splash → Welcome → GetStarted → Login / Register
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkExistingToken();
  }

  Future<void> _checkExistingToken() async {
    final token = await AuthService.instance.getToken();
    if (token != null && token.isNotEmpty) {
      await AuthService.instance.logout();
    }
  }

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Logo
                Padding(
                  padding: EdgeInsets.only(top: 25.h),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 80.w,
                    fit: BoxFit.contain,
                  ),
                ),

                // Middle Image (Fills available space)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.h),
                    child: Image.asset(
                      'assets/images/welcome.png',
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Bottom Section
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 10.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Cook More. Spend\nLess. Eat Better.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textDark,
                          fontFamily: 'LarkenVariable',
                          height: 1.149,
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        'Personalized recipes, meal plans, and\ngrocery lists built around you.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textMuted,
                          fontFamily: 'SF Pro',
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Get Started
                      RedButton(
                        label: 'Get Started',
                        onTap: () => Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.preferences,
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // Already have account?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontFamily: 'SF Pro',
                              fontSize: 14.sp,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.login),
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
        ],
      ),
    );
  }
}
