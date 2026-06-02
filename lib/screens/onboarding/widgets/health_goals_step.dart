import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'selection_onboarding_step.dart';

class HealthGoalsStep extends StatefulWidget {
  final VoidCallback onContinue;
  final List<String> initialSelected;
  final Function(List<String>)? onChanged;

  const HealthGoalsStep({
    super.key, 
    required this.onContinue,
    this.initialSelected = const [],
    this.onChanged,
  });

  @override
  State<HealthGoalsStep> createState() => _HealthGoalsStepState();
}

class _HealthGoalsStepState extends State<HealthGoalsStep> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialSelected.isNotEmpty ? widget.initialSelected.first : '';
  }

  String _getHighlightText(String value) {
    switch (value) {
      case 'weight_loss': return 'weight loss';
      case 'muscle_gain': return 'muscle gain';
      case 'high_protein': return 'high protein';
      case 'healthy_heart': return 'heart healthy';
      case 'quick_meals': return 'quick & easy';
      case 'budget_friendly': return 'friendly';
      case 'eat_healthier': return 'healthy';
      case 'no_goal': return 'balanced';
      default: return 'delicious';
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
            const TextSpan(text: 'Perfect. We\'ll prioritize '),
            TextSpan(
              text: _getHighlightText(selectedValue),
              style: const TextStyle(
                color: Color(0xFFD92D20),
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(text: ' meals'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SelectionOnboardingStep(
      title: 'What are your health goals',
      subtitle: 'Cooked will use this to recommend better\nrecipes for you.',
      maxSelections: 1,
      useGrid: true,
      initialSelected: widget.initialSelected,
      onContinue: widget.onContinue,
      onSelectionChanged: (selections) {
        if (selections.isNotEmpty) {
          setState(() => _selectedValue = selections.first);
        } else {
          setState(() => _selectedValue = '');
        }
        if (widget.onChanged != null) {
          widget.onChanged!(selections);
        }
      },
      bottomCardWidget: _selectedValue.isNotEmpty ? _buildBottomCard(_selectedValue) : null,
      options: [
        SelectionOption(id: 'weight_loss', label: 'Weight loss', icon: FontAwesomeIcons.leaf),
        SelectionOption(id: 'muscle_gain', label: 'Muscle gain', icon: Icons.fitness_center),
        SelectionOption(id: 'high_protein', label: 'High protein', icon: Icons.egg_alt_outlined),
        SelectionOption(id: 'healthy_heart', label: 'Healthy heart', icon: Icons.monitor_heart_outlined),
        SelectionOption(id: 'quick_meals', label: 'Quick meals', icon: Icons.timer_outlined),
        SelectionOption(id: 'budget_friendly', label: 'Budget friendly', icon: FontAwesomeIcons.moneyBill1Wave),
        SelectionOption(id: 'eat_healthier', label: 'Eat healthier', icon: FontAwesomeIcons.solidHeart),
        SelectionOption(id: 'no_goal', label: 'No specific goal', icon: Icons.block),
      ],
    );
  }
}
