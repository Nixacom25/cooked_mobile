import 'package:flutter/material.dart';
import 'animated_onboarding_step.dart';

class MealsStep extends StatelessWidget {
  final VoidCallback onContinue;

  const MealsStep({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return AnimatedOnboardingStep(
      imagePath: 'assets/images/step2.png',
      title: 'Never wonder what to cook again.',
      subtitle: 'Cooked builds personalized meal ideas around your taste, schedule, and ingredients.',
      onContinue: onContinue,
    );
  }
}
