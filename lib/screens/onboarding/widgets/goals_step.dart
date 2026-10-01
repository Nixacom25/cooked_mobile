import 'package:flutter/material.dart';
import 'selection_onboarding_step.dart';
import '../../../core/l10n/l10n.dart';

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
      title: context.l10n.onbGoalsTitle,
      subtitle: context.l10n.onbGoalsSubtitle,
      maxSelections: 8,
      useGrid: true,
      onContinue: widget.onContinue,
      initialSelected: widget.initialSelected,
      onSelectionChanged: widget.onChanged,
      gridItemDirection: Axis.vertical,
      options: [
        SelectionOption(id: 'save_money', label: 'Save money', svgAsset: 'assets/icones/money.svg'),
        SelectionOption(id: 'eat_healthier', label: 'Eat healthier', svgAsset: 'assets/icones/coeur1.svg'),
        SelectionOption(id: 'gain_muscle', label: 'Gain muscle', svgAsset: 'assets/icones/muscle1.svg'),
        SelectionOption(id: 'lose_weight', label: 'Lose weight', svgAsset: 'assets/icones/lose.svg'),
        SelectionOption(id: 'waste_less', label: 'Waste less food', svgAsset: 'assets/icones/food.svg'),
        SelectionOption(id: 'learn_cook', label: 'Learn to cook', svgAsset: 'assets/icones/cook.svg'),
        SelectionOption(id: 'discover_recipes', label: 'Discover recipes', svgAsset: 'assets/icones/search.svg'),
        SelectionOption(id: 'meal_prep', label: 'Meal prep easier', svgAsset: 'assets/icones/meal.svg'),
      ]);
  }
}
