import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'image_info_onboarding_step.dart';

class TakeoutSpendingStep extends StatelessWidget {
  final VoidCallback onContinue;

  const TakeoutSpendingStep({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return ImageInfoOnboardingStep(
      titleWidget: RichText(
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
            TextSpan(text: 'And it\'s '),
            TextSpan(
              text: 'costing\n',
              style: TextStyle(color: Color(0xFFC83A2D)),
            ),
            TextSpan(text: 'more than '),
            TextSpan(
              text: 'time.',
              style: TextStyle(color: Color(0xFFC83A2D)),
            ),
          ],
        ),
      ),
      subtitle: 'Small decisions become expensive habits.',
      imagePath: 'assets/images/step7.png',
      onContinue: onContinue,
    );
  }
}
