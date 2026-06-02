import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'selection_onboarding_step.dart';

class GroceriesBadStep extends StatefulWidget {
  final VoidCallback onContinue;

  const GroceriesBadStep({super.key, required this.onContinue});

  @override
  State<GroceriesBadStep> createState() => _GroceriesBadStepState();
}

class _GroceriesBadStepState extends State<GroceriesBadStep> {
  String _selectedValue = '';

  Widget _buildBottomCard() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFBE8D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: const Color(0xFF1B1C1C), fontSize: 16.sp, fontFamily: 'SF Pro'),
                children: [
                  const TextSpan(text: 'The average household wastes over '),
                  TextSpan(text: '\$1,500', style: TextStyle(color: const Color(0xFF00C40A), fontSize: 32.sp, fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' /year in food'),
                ],
              ),
            ),
          ),
          Image.asset('assets/images/logo2.png', width: 40.w, height: 40.w),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SelectionOnboardingStep(
      title: 'How often do groceries go bad before you use them?',
      maxSelections: 1,
      useGrid: true,
      onContinue: widget.onContinue,
      onSelectionChanged: (selections) {
        if (selections.isNotEmpty) {
          setState(() => _selectedValue = selections.first);
        } else {
          setState(() => _selectedValue = '');
        }
      },
      bottomCardWidget: _selectedValue.isEmpty ? null : _buildBottomCard(),
      options: [
        SelectionOption(id: 'never', label: 'Almost never'),
        SelectionOption(id: 'sometimes', label: 'Sometimes'),
        SelectionOption(id: 'weekly', label: 'Weekly'),
        SelectionOption(id: 'constantly', label: 'Constantly'),
      ],
    );
  }
}
