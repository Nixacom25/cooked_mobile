import 'package:flutter/material.dart';
import 'selection_onboarding_step.dart';

class GoalsStep extends StatefulWidget {
  final VoidCallback? onContinue;
  final List<String> initialSelected;
  final Function(List<String>)? onChanged;

  const GoalsStep({
    super.key, 
    this.onContinue,
    this.initialSelected = const [],
    this.onChanged,
  });

  @override
  State<GoalsStep> createState() => _GoalsStepState();
}

class _GoalsStepState extends State<GoalsStep> {
  @override
  Widget build(BuildContext context) {
    return SelectionOnboardingStep(
      title: 'What\'s your goal right now?',
      subtitle: 'We\'ll personalize everything around it.',
      maxSelections: 2,
      useGrid: true,
      onContinue: widget.onContinue,
      initialSelected: widget.initialSelected,
      onSelectionChanged: widget.onChanged,
      gridItemDirection: Axis.vertical,
      options: [
        SelectionOption(id: 'save_money', label: 'Save Money', svgAsset: 'assets/icones/eating.svg'),
        SelectionOption(id: 'eat_healthier', label: 'Eat healthier', svgAsset: 'assets/icones/coeur.svg'),
        SelectionOption(id: 'gain_muscle', label: 'Gain muscle', svgAsset: 'assets/icones/muscle.svg'),
        SelectionOption(id: 'lose_weight', label: 'Lose weight', svgAsset: 'assets/icones/feuille.svg'),
        SelectionOption(id: 'waste_less', label: 'Waste less food', svgAsset: 'assets/icones/waste.svg'),
        SelectionOption(id: 'learn_cook', label: 'Learn to cook', svgAsset: 'assets/icones/knowing.svg'),
        SelectionOption(id: 'discover_recipes', label: 'Discover recipes', svgAsset: 'assets/icones/ordering.svg'),
        SelectionOption(id: 'meal_prep', label: 'Meal prep easier', svgAsset: 'assets/icones/saving.svg'), // mapped 'eating' as prep icon temporarily
      ],
    );
  }
}
