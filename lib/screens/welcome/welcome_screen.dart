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
                        'Cooking should\nfeel easier.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          fontFamily: 'SF Pro',
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        'Cooked turns ingredients, saved videos,\nand recipe ideas into meals you’ll actually\nwant to make.',
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
                            'Have an account? ',
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
