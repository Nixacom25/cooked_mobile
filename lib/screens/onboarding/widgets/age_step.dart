import 'package:flutter/material.dart';
import 'selection_onboarding_step.dart';

class AgeStep extends StatelessWidget {
  final VoidCallback onContinue;
  final String? initialSelected;
  final ValueChanged<String>? onChanged;

  const AgeStep({
    super.key, 
    required this.onContinue,
    this.initialSelected,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SelectionOnboardingStep(
      title: 'How old are you?',
      subtitle: 'We\'ll use this to personalize your recommendations.',
      maxSelections: 1,
      onContinue: onContinue,
      initialSelected: initialSelected != null && initialSelected!.isNotEmpty ? [initialSelected!] : [],
      onSelectionChanged: (selections) {
        if (onChanged != null) {
          onChanged!(selections.isNotEmpty ? selections.first : '');
        }
      },
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
