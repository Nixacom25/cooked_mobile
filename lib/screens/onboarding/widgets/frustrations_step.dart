import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
            icon: FontAwesomeIcons.moneyBill1),
        SelectionOption(
            id: 'groceries',
            label: 'Groceries going bad',
            icon: FontAwesomeIcons.faceFrown),
        SelectionOption(
            id: 'unhealthy',
            label: 'Eating unhealthy',
            icon: FontAwesomeIcons.solidHeart),
        SelectionOption(
            id: 'dont_know',
            label: 'Never knowing what to cook',
            icon: FontAwesomeIcons.bowlFood),
        SelectionOption(
            id: 'takeout',
            label: 'Ordering takeout too often',
            icon: FontAwesomeIcons.bagShopping),
        SelectionOption(
            id: 'recipes',
            label: 'Saving recipes but never using them',
            icon: FontAwesomeIcons.fileLines),
      ],
    );
  }
}

