import 'package:flutter/material.dart';
import 'selection_onboarding_step.dart';

class FrustrationsStep extends StatelessWidget {
  final VoidCallback onContinue;
  final List<String> initialSelected;
  final ValueChanged<List<String>>? onChanged;

  const FrustrationsStep({
    super.key, 
    required this.onContinue,
    this.initialSelected = const [],
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SelectionOnboardingStep(
      title: "What's holding you back from cooking more?",
      subtitle: 'Choose the ones that feels most true.',
      maxSelections: 3,
      onContinue: onContinue,
      initialSelected: initialSelected,
      onSelectionChanged: onChanged,
      options: [
        SelectionOption(
            id: 'dont_know',
            label: "I don't know what to cook",
            svgAsset: 'assets/icones/knowing.svg'),
        SelectionOption(
            id: 'time',
            label: 'Cooking takes too much time',
            svgAsset: 'assets/icones/minute.svg'),
        SelectionOption(
            id: 'takeout',
            label: 'I spend too much on takeout',
            svgAsset: 'assets/icones/eating.svg'),
        SelectionOption(
            id: 'unhealthy',
            label: 'Healthy eating feels difficult',
            svgAsset: 'assets/icones/coeur.svg'),
        SelectionOption(
            id: 'grocery',
            label: 'Grocery shopping is stressful',
            svgAsset: 'assets/icones/triste.svg'),
      ],
    );
  }
}
