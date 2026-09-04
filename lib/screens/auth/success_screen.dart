import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../routes/app_routes.dart';
import '../../widgets/red_button.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarH = MediaQuery.of(context).padding.top;
    final bottomH = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, statusBarH + 16.h, 24.w, bottomH + 20.h),
          child: Column(
            children: [
              // Top Title: Congratulations!
              Text(
                'Congratulations!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Rubik',
                  color: const Color(0xFF0F172A),
                ),
              ),

              const Spacer(),

              // Center Illustration: success1.png
              Image.asset(
                'assets/images/success1.png',
                width: 280.w,
                fit: BoxFit.contain,
              ),

              const Spacer(),

              // Bottom Info: Account Created!
              Text(
                'Creation Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Rubik',
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 12.h),

              Text(
                'Your account is complete, please enjoy\nthe best menu from us.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF64748B),
                  fontFamily: 'SF Pro',
                  height: 1.35,
                ),
              ),
              SizedBox(height: 32.h),

              RedButton(
                label: 'Get Started',
                color: const Color(0xFFC31E26),
                height: 52.h,
                fontSize: 16.sp,
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                    arguments: {'initialTab': 0},
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
