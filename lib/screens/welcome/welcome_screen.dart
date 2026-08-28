import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/red_button.dart';

/// The Welcome screen using welcome2.png background.
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image welcome2.png
          Image.asset(
            'assets/images/welcome2.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Content layout
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Logo (Red C Icon + White Cooked Text)
                  Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logo4.png',
                          width: 170.w,
                          fit: BoxFit.contain,
                        ),
                        // SizedBox(height: 4.h),
                        // Text(
                        //   'Cooked',
                        //   style: TextStyle(
                        //     color: Colors.white,
                        //     fontSize: 34.sp,
                        //     fontWeight: FontWeight.w900,
                        //     fontFamily: 'SF Pro',
                        //     letterSpacing: -0.5,
                        //   ),
                        // ),
                      ],
                    ),
                  ),

                  // Bottom Section
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome to Cooked',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rubik(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Scan ingredients. Save recipes.\nPlan effortlessly.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: 28.h),

                      // Get Started Button (White background, refined dark red text)
                      RedButton(
                        label: 'Get Started',
                        color: Colors.white,
                        textColor: const Color(0xFF8B1D1D),
                        fontSize: 17.sp,
                        height: 54.h,
                        onTap: () => Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.preferences,
                        ),
                      ),
                      SizedBox(height: 18.h),

                      // Already have an account? Sign In
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.rubik(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

