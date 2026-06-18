import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'animated_onboarding_step.dart';

class SpendEatingOutStep extends StatelessWidget {
  final VoidCallback onContinue;

  const SpendEatingOutStep({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return AnimatedOnboardingStep(
      imagePath: 'assets/images/step4.png',
      titleWidget: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0D1B36),
            fontFamily: 'SF Pro',
            height: 1.2,
            letterSpacing: -0.5,
          ),
          children: const [
            TextSpan(text: 'Imagine dinner\nalready '),
            TextSpan(
              text: 'figured out',
              style: TextStyle(color: Color(0xFFC83A2D)),
            ),
          ],
        ),
      ),
      subtitle: 'No stress. No guesswork',
      buttonLabel: 'Show Me',
      onContinue: onContinue,
    );
  }
}
