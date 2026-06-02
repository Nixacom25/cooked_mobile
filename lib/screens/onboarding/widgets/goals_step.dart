import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      title: 'What brings you here?',
      subtitle: 'Select up to 2 primary goals',
      maxSelections: 2,
      onContinue: widget.onContinue,
      initialSelected: widget.initialSelected,
      onSelectionChanged: widget.onChanged,
      options: [
        SelectionOption(id: 'save_money', label: 'Save money', icon: FontAwesomeIcons.moneyBill1Wave),
        SelectionOption(id: 'eat_healthier', label: 'Eat healthier', icon: FontAwesomeIcons.solidHeart),
        SelectionOption(id: 'gain_muscle', label: 'Gain muscle', icon: Icons.fitness_center),
        SelectionOption(id: 'lose_weight', label: 'Lose Weight', icon: FontAwesomeIcons.leaf),
        SelectionOption(id: 'waste_less', label: 'Waste less food', icon: Icons.delete_outline),
        SelectionOption(id: 'learn_cook', label: 'Learn to cook', icon: Icons.soup_kitchen),
        SelectionOption(id: 'discover_recipes', label: 'Discover recipes', icon: Icons.search),
        SelectionOption(id: 'meal_prep', label: 'Meal prep easier', icon: Icons.assignment_outlined),
      ],
    );
  }
}
