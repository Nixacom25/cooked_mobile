import 'package:flutter/material.dart';
import 'animated_onboarding_step.dart';

class CookingSystemStep extends StatelessWidget {
  final VoidCallback onContinue;

  const CookingSystemStep({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return AnimatedOnboardingStep(
      imagePath: 'assets/images/step9.png',
      title: 'Now let\'s build your personalized cooking system',
      subtitle: 'The more cooked learns about you, the smarter your recommendations become',
      onContinue: onContinue,
    );
  }
}
