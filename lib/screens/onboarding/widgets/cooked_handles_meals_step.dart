import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/red_button.dart';

class CookedHandlesMealsStep extends StatelessWidget {
  final VoidCallback onContinue;

  const CookedHandlesMealsStep({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF111827),
                      fontFamily: 'Larken',
                      height: 1.149,
                      letterSpacing: 0,
                    ),
                    children: [
                      const TextSpan(text: "Cooked handles\nyour "),
                      const TextSpan(
                        text: "meals.",
                        style: TextStyle(color: Color(0xFFC83A2D)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "We plan. You cook.",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF4B5563),
                    fontFamily: 'SF Pro',
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 10.h),
                Center(
                  child: Image.asset(
                    'assets/onboarding/step19.png',
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300.h,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Text('assets/onboarding/step19.png missing'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
          child: SafeArea(
            top: false,
            child: RedButton(
              label: 'Continue',
              onTap: onContinue,
              height: 55.h,
              fontSize: 18.sp,
            ),
          ),
        ),
      ],
    );
  }
}
