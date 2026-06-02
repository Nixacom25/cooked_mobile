import 'package:flutter/material.dart';
import 'animated_onboarding_step.dart';

class SavingsStep extends StatelessWidget {
  final VoidCallback onContinue;

  const SavingsStep({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return AnimatedOnboardingStep(
      imagePath: 'assets/images/step1.png',
      title: 'Most people spend thousands eating out.',
      subtitle: 'But you can save money with Cooked.',
      onContinue: onContinue,
    );
  }
}

