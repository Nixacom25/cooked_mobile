import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/red_button.dart';
import '../../../core/theme/app_theme.dart';

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
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tired of eating the\nsame thing every\nweek?",
                        style: GoogleFonts.rubik(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w500,
                          color: context.colors.textPrimary,
                          height: 1.15)),
                      SizedBox(height: 10.h),
                      Text(
                        "Built around your taste.",
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          color: context.colors.textPrimary,
                          height: 1.3)),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Image.asset(
                  'assets/onboarding/step18.png',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 300.h,
                    color: context.colors.pageBackground,
                    alignment: Alignment.center,
                    child: const Text('assets/onboarding/step18.png missing'))),
                SizedBox(height: 20.h),
              ]))),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
          child: SafeArea(
            top: false,
            bottom: true,
            child: RedButton(
              label: 'Continue',
              color: context.colors.accent,
              onTap: onContinue,
              height: 52.h,
              fontSize: 16.sp))),
      ]);
  }
}
