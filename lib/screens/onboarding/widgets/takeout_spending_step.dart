import 'package:flutter/material.dart';
import 'image_info_onboarding_step.dart';

class TakeoutSpendingStep extends StatelessWidget {
  final VoidCallback onContinue;

  const TakeoutSpendingStep({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return ImageInfoOnboardingStep(
      title: 'Convenience adds up fast.',
      subtitle: 'Small habits become expensive routines',
      imagePath: 'assets/images/step7.png',
      onContinue: onContinue,
    );
  }
}
