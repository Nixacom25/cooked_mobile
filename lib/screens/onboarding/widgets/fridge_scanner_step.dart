import 'package:flutter/material.dart';
import 'image_info_onboarding_step.dart';

class FridgeScannerStep extends StatelessWidget {
  final VoidCallback onContinue;

  const FridgeScannerStep({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return ImageInfoOnboardingStep(
      title: 'Imagine opening your fridge and instantly knowing what to make.',
      imagePath: 'assets/images/step6.png',
      buttonLabel: 'Show Me How',
      onContinue: onContinue,
    );
  }
}
