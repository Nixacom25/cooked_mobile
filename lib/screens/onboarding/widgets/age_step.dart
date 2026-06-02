import 'package:flutter/material.dart';
import 'selection_onboarding_step.dart';

class AgeStep extends StatefulWidget {
  final VoidCallback onContinue;

  const AgeStep({super.key, required this.onContinue});

  @override
  State<AgeStep> createState() => _AgeStepState();
}

class _AgeStepState extends State<AgeStep> {
  @override
  Widget build(BuildContext context) {
    return SelectionOnboardingStep(
      title: 'How old are you?',
      maxSelections: 1,
      onContinue: widget.onContinue,
      options: [
        SelectionOption(id: 'under_18', label: 'Under 18'),
        SelectionOption(id: '18_24', label: '18 - 24'),
        SelectionOption(id: '25_34', label: '25 - 34'),
        SelectionOption(id: '35_44', label: '35 - 44'),
        SelectionOption(id: '45_54', label: '45 - 54'),
        SelectionOption(id: '55_plus', label: '55+'),
      ],
    );
  }
}
