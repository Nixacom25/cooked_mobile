import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'selection_onboarding_step.dart';

class CookingSkillStep extends StatefulWidget {
  final VoidCallback? onContinue;
  final String? initialSelected;
  final Function(String)? onChanged;

  const CookingSkillStep({
    super.key,
    this.onContinue,
    this.initialSelected,
    this.onChanged,
  });

  @override
  State<CookingSkillStep> createState() => _CookingSkillStepState();
}

class _CookingSkillStepState extends State<CookingSkillStep> {
  String _selectedValue = '';

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialSelected ?? '';
  }

  String _getHighlightText(String value) {
    switch (value) {
      case 'beginner': return 'overly complex';
      case 'home_cook': return 'untested';
      case 'confident': return 'boring';
      case 'advanced': return 'basic';
      default: return 'complex';
    }
  }

  Widget _buildBottomCard(String selectedValue) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFBE8D0)),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            color: const Color(0xFF1B1C1C),
            fontSize: 16.sp,
            fontFamily: 'SF Pro',
          ),
          children: [
            const TextSpan(text: 'Great, we\'ll avoid '),
            TextSpan(
              text: _getHighlightText(selectedValue),
              style: const TextStyle(
                color: Color(0xFFD92D20),
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(text: ' recipes.'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SelectionOnboardingStep(
      title: "What's your cooking\nskill level?",
      subtitle: "We'll match recipes to your experience.",
      maxSelections: 1,
      useGrid: true,
      onContinue: widget.onContinue,
      initialSelected: _selectedValue.isNotEmpty ? [_selectedValue] : [],
      onSelectionChanged: (selections) {
        final val = selections.isNotEmpty ? selections.first : '';
        setState(() => _selectedValue = val);
        if (widget.onChanged != null) widget.onChanged!(val);
      },
      bottomCardWidget: _selectedValue.isNotEmpty ? _buildBottomCard(_selectedValue) : null,
      options: [
        SelectionOption(
          id: 'beginner',
          label: 'Total Beginner',
          subLabel: 'I can barely boil water',
          svgAsset: 'assets/icones/beginner.svg',
        ),
        SelectionOption(
          id: 'home_cook',
          label: 'Home Cook',
          subLabel: 'I follow recipes step by step',
          icon: Icons.restaurant,
        ),
        SelectionOption(
          id: 'confident',
          label: 'Confident Cook',
          subLabel: 'I improvise and experiment',
          svgAsset: 'assets/icones/chef.svg',
        ),
        SelectionOption(
          id: 'advanced',
          label: 'Advanced / Semi-Pro',
          subLabel: 'I want challenging recipes.',
          svgAsset: 'assets/icones/firew.svg',
        ),
      ],
    );
  }
}
