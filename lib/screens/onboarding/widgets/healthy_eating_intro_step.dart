import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/red_button.dart';

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
                            color: const Color(0xFF111827),
                            height: 1.15),
                          children: [
                            const TextSpan(text: "Healthy eating\nshouldn’t "),
                            const TextSpan(
                              text: "feel like",
                              style: TextStyle(color: Color(0xFFC31E26))),
                            const TextSpan(text: " a\n"),
                            const TextSpan(
                              text: "second job",
                              style: TextStyle(color: Color(0xFFC31E26))),
                          ])),
                      SizedBox(height: 10.h),
                      Text(
                        "Recipes you’ll actually look forward\nto eating.",
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          color: const Color(0xFF111827),
                          height: 1.3)),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Image.asset(
                  'assets/onboarding/step17.png',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 300.h,
                    color: const Color(0xFFF1F5F9),
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
              color: const Color(0xFFC31E26),
              onTap: onContinue,
              height: 52.h,
              fontSize: 16.sp))),
      ]);
  }
}
