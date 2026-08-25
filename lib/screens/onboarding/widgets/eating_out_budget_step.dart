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
    _selectedValue = widget.initialSelected ?? 'under_50';
  }

  int _calculateSpend(String value) {
    switch (value) {
      case 'under_50': return 40;
      case '50_100': return 75;
      case '100_250': return 175;
      case '250_500': return 375;
      case 'over_500': return 650;
      default: return 40;
    }
  }

  Widget _buildBottomCard(int spend) {
    final savings = (spend * 52 * 0.30).round();
    final formattedSavings = savings.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]},'
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF4E5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Potential Yearly Savings', 
            style: TextStyle(
              color: const Color(0xFF334155), 
              fontSize: 14.sp, 
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '~\$$formattedSavings',
                style: TextStyle(
                  color: const Color(0xFF16A34A),
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Rubik',
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                '/year',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 14.sp,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'That could be over',
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: 13.sp,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SelectionOnboardingStep(
      title: 'How much do you spend eating out every week?',
      subtitle: 'Take your best guess. We’ll do the math',
      maxSelections: 1,
      useGrid: true,
      initialSelected: [_selectedValue],
      onContinue: () {
        final spend = _calculateSpend(_selectedValue);
        widget.onContinue((spend * 52 * 0.30).round());
      },
      onSelectionChanged: (selections) {
        final newVal = selections.isNotEmpty ? selections.first : 'under_50';
        setState(() => _selectedValue = newVal);
        if (widget.onChanged != null) {
          widget.onChanged!(newVal);
        }
      },
      bottomCardWidget: _buildBottomCard(_calculateSpend(_selectedValue)),
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
