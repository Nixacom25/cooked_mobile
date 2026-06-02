import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'selection_onboarding_step.dart';

class SpendEatingOutStep extends StatefulWidget {
  final VoidCallback onContinue;

  const SpendEatingOutStep({super.key, required this.onContinue});

  @override
  State<SpendEatingOutStep> createState() => _SpendEatingOutStepState();
}

class _SpendEatingOutStepState extends State<SpendEatingOutStep> {
  String _selectedValue = '';

  int _calculateSavings(String value) {
    switch (value) {
      case 'under_50': return 120;
      case '50_100': return 214;
      case '100_250': return 520;
      case '250_500': return 1040;
      case 'over_500': return 2600;
      default: return 0;
    }
  }

  Widget _buildBottomCard(int savings) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFBE8D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Potential Yearly Savings', style: TextStyle(color: const Color(0xFF7D562D), fontSize: 14.sp)),
                SizedBox(height: 8.h),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: const Color(0xFF1B1C1C), fontSize: 16.sp, fontFamily: 'SF Pro'),
                    children: [
                      const TextSpan(text: 'That could be over\n'),
                      TextSpan(text: '\$$savings', style: TextStyle(color: const Color(0xFF00C40A), fontSize: 32.sp, fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' /year'),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Text('Imagine what you could cook with that.', style: TextStyle(color: const Color(0xFF7D562D), fontSize: 14.sp)),
              ],
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
      title: 'How much do you spend eating out weekly?',
      subtitle: 'Help us estimate the value you\'ll unlock.',
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
      bottomCardWidget: _selectedValue.isEmpty ? null : _buildBottomCard(_calculateSavings(_selectedValue)),
      options: [
        SelectionOption(id: 'under_50', label: 'Under \$50'),
        SelectionOption(id: '50_100', label: '\$50–100'),
        SelectionOption(id: '100_250', label: '\$100–250'),
        SelectionOption(id: '250_500', label: '\$250–500'),
        SelectionOption(id: 'over_500', label: '\$500+'),
      ],
    );
  }
}
