import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/red_button.dart';
import '../../../core/theme/app_theme.dart';

class HealthyEatingIntroStep extends StatelessWidget {
  final VoidCallback onContinue;

  const HealthyEatingIntroStep({
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
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.rubik(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textPrimary,
                            height: 1.15),
                          children: [
                            const TextSpan(text: "Healthy eating\nshouldn’t "),
                            TextSpan(
                              text: "feel like",
                              style: TextStyle(color: context.colors.accent)),
                            const TextSpan(text: " a\n"),
                            TextSpan(
                              text: "second job",
                              style: TextStyle(color: context.colors.accent)),
                          ])),
                      SizedBox(height: 10.h),
                      Text(
                        "Recipes you’ll actually look forward\nto eating.",
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          color: context.colors.textPrimary,
                          height: 1.3)),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Image.asset(
                  // The jpeg is a dedicated dark-mode version of this
                  // illustration (dark backdrop, light text) - the png
                  // alone would show its own light background in dark mode.
                  Theme.of(context).brightness == Brightness.dark
                      ? 'assets/onboarding/step17.jpeg'
                      : 'assets/onboarding/step17.png',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 300.h,
                    color: context.colors.pageBackground,
                    alignment: Alignment.center,
                    child: const Text('assets/onboarding/step17.png missing'))),
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
