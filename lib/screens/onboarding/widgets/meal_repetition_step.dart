import 'package:flutter/material.dart';
import 'image_info_onboarding_step.dart';

class MealRepetitionStep extends StatelessWidget {
  final VoidCallback onContinue;

  const MealRepetitionStep({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return ImageInfoOnboardingStep(
      imagePath: 'assets/images/step16.png',
      title: 'Most people repeat the\nsame meals every week.',
      subtitle: 'And still spend too much time\ndeciding what to eat.',
      onContinue: onContinue,
    );
  }
}
