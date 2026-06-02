import 'package:flutter/material.dart';
import 'image_info_onboarding_step.dart';

class FrustrationsIntroStep extends StatelessWidget {
  final VoidCallback onContinue;

  const FrustrationsIntroStep({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return ImageInfoOnboardingStep(
      imagePath: 'assets/images/step13.png',
      title: 'Healthy eating feels harder than it should.',
      subtitle: 'Cooked simplifies healthy eating around YOUR preferences.',
      onContinue: onContinue,
    );
  }
}
