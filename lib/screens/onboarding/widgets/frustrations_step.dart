import 'package:flutter/material.dart';
import 'selection_onboarding_step.dart';

class FrustrationsStep extends StatelessWidget {
  final VoidCallback onContinue;

  const FrustrationsStep({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return SelectionOnboardingStep(
      title: 'What frustrates you most?',
      subtitle: 'Select up to 3.',
      maxSelections: 3,
      onContinue: onContinue,
      options: [
        SelectionOption(
            id: 'spending',
            label: 'Spending too much eating out',
            svgAsset: 'assets/icones/eating.svg'),
        SelectionOption(
            id: 'groceries',
            label: 'Groceries going bad',
            svgAsset: 'assets/icones/triste.svg'),
        SelectionOption(
            id: 'unhealthy',
            label: 'Eating unhealthy',
            svgAsset: 'assets/icones/coeur.svg'),
        SelectionOption(
            id: 'dont_know',
            label: 'Never knowing what to cook',
            svgAsset: 'assets/icones/knowing.svg'),
        SelectionOption(
            id: 'takeout',
            label: 'Ordering takeout too often',
            svgAsset: 'assets/icones/ordering.svg'),
        SelectionOption(
            id: 'recipes',
            label: 'Saving recipes but never using them',
            svgAsset: 'assets/icones/saving.svg'),
      ],
    );
  }
}

