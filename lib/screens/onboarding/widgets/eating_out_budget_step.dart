import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'selection_onboarding_step.dart';

class EatingOutBudgetStep extends StatefulWidget {
  final ValueChanged<int> onContinue;
  final String? initialSelected;
  final ValueChanged<String>? onChanged;

  const EatingOutBudgetStep({
    super.key, 
    required this.onContinue,
    this.initialSelected,
    this.onChanged,
  });

  @override
  State<EatingOutBudgetStep> createState() => _EatingOutBudgetStepState();
}

class _EatingOutBudgetStepState extends State<EatingOutBudgetStep> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialSelected ?? '';
  }

  int _calculateSpend(String value) {
    switch (value) {
      case 'under_50': return 40;
      case '50_100': return 75;
      case '100_250': return 175;
      case '250_500': return 375;
      case 'over_500': return 650;
      default: return 0;
    }
  }

  Widget _buildBottomCard(int spend) {
    final savings = (spend * 52 * 0.30).round();
    final formattedSavings = savings.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFFBE8D0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Potential Yearly Savings', 
                  style: TextStyle(color: const Color(0xFF7D562D), fontSize: 13.sp, fontFamily: 'SF Pro'),
                ),
                SizedBox(height: 8.h),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: const Color(0xFF111827), fontSize: 16.sp, fontFamily: 'SF Pro'),
                    children: [
                      const TextSpan(text: 'That could be over\n'),
                      TextSpan(
                        text: '\$$formattedSavings', 
                        style: TextStyle(color: const Color(0xFF00C40A), fontSize: 32.sp, fontWeight: FontWeight.w800, height: 1.2),
                      ),
                      TextSpan(
                        text: ' /year',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Image.asset('assets/images/logo2.png', width: 48.w, height: 48.w),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SelectionOnboardingStep(
      title: 'How much do you spend eating out every week?',
      subtitle: 'Take your best guess.\nWe\'ll do the math.',
      maxSelections: 1,
      useGrid: true,
      initialSelected: _selectedValue.isNotEmpty ? [_selectedValue] : [],
      onContinue: () {
        final spend = _calculateSpend(_selectedValue);
        widget.onContinue((spend * 52 * 0.30).round());
      },
      onSelectionChanged: (selections) {
        final newVal = selections.isNotEmpty ? selections.first : '';
        setState(() => _selectedValue = newVal);
        if (widget.onChanged != null) {
          widget.onChanged!(newVal);
        }
      },
      bottomCardWidget: _selectedValue.isEmpty ? null : _buildBottomCard(_calculateSpend(_selectedValue)),
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
