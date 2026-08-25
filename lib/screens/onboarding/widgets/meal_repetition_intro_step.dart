import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/red_button.dart';

class MealRepetitionIntroStep extends StatelessWidget {
  final VoidCallback onContinue;

  const MealRepetitionIntroStep({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tired of eating the\nsame thing every\nweek?",
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    fontFamily: 'Rubik',
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Built around your taste.",
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF475569),
                    fontFamily: 'SF Pro',
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 24.h),
                Center(
                  child: Image.asset(
                    'assets/onboarding/step18.png',
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300.h,
                      color: const Color(0xFFF1F5F9),
                      alignment: Alignment.center,
                      child: const Text('assets/onboarding/step18.png missing'),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
          child: SafeArea(
            top: false,
            bottom: true,
            child: RedButton(
              label: 'Continue',
              color: const Color(0xFFC31E26),
              onTap: onContinue,
              height: 52.h,
              fontSize: 16.sp,
            ),
          ),
        ),
      ],
    );
  }
}
