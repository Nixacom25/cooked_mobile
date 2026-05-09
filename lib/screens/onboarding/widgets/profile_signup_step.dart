import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileSignupStep extends StatelessWidget {
  final VoidCallback onSignupEmail;
  final VoidCallback onSignupGoogle;
  final VoidCallback onSignupApple;
  final VoidCallback onGuest;

  const ProfileSignupStep({
    super.key,
    required this.onSignupEmail,
    required this.onSignupGoogle,
    required this.onSignupApple,
    required this.onGuest,
    this.isAppleEnabled = true,
  });

  final bool isAppleEnabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Save your profile,',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Your 22-step profile is ready to save',
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Pick up exactly where you left off on any device',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF6B7280),
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 28.h),
          _buildAuthButton(
            onPressed: onSignupGoogle,
            icon: 'google.svg',
            label: 'Sign up with Google',
          ),
          SizedBox(height: 12.h),
          _buildAuthButton(
            onPressed: onSignupApple,
            icon: 'apple.svg',
            label: 'Sign up with Apple',
            isEnabled: isAppleEnabled,
          ),
          SizedBox(height: 12.h),
          _buildAuthButton(
            onPressed: onSignupEmail,
            icon: 'email1.svg',
            label: 'Sign up with Email',
          ),
        ],
      ),
    );
  }

  Widget _buildAuthButton({
    required VoidCallback onPressed,
    required String icon,
    required String label,
    bool isEnabled = true,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
              side: BorderSide(
                color: isEnabled ? const Color(0xFFC83A2D) : Colors.grey,
              ),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icones/$icon',
                height: 18.sp,
                width: 18.sp,
                placeholderBuilder: (context) => SizedBox(
                  height: 18.sp,
                  width: 18.sp,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                isEnabled ? label : '$label (Soon)',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'SF Pro',
                  color: isEnabled ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
