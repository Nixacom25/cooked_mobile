import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'selection_onboarding_step.dart';

class GroceriesBadStep extends StatefulWidget {
  final ValueChanged<int> onContinue;
  final String? initialSelected;
  final ValueChanged<String>? onChanged;

  const GroceriesBadStep({
    super.key, 
    required this.onContinue,
    this.initialSelected,
    this.onChanged,
  });

  @override
  State<GroceriesBadStep> createState() => _GroceriesBadStepState();
}

class _GroceriesBadStepState extends State<GroceriesBadStep> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialSelected ?? '';
  }

  int _calculateWaste(String value) {
    switch (value) {
      case 'never': return 300;
      case 'sometimes': return 900;
      case 'weekly': return 1500;
      case 'constantly': return 2500;
      default: return 0;
    }
  }

  Widget _buildBottomCard(int waste) {
    final formattedWaste = waste.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFFBE8D0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: const Color(0xFF111827), fontSize: 16.sp, fontFamily: 'SF Pro'),
                children: [
                  const TextSpan(text: 'Your household wasting average of\n'),
                  TextSpan(
                    text: '\$$formattedWaste', 
                    style: TextStyle(color: const Color(0xFF00C40A), fontSize: 32.sp, fontWeight: FontWeight.w800, height: 1.2),
                  ),
                  TextSpan(
                    text: ' /year in food', 
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ),
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
      title: 'How often do groceries go unused?',
      subtitle: 'Food waste adds up faster than most people realize.',
      maxSelections: 1,
      useGrid: true,
      initialSelected: _selectedValue.isNotEmpty ? [_selectedValue] : [],
      onContinue: () {
        final waste = _calculateWaste(_selectedValue);
        widget.onContinue((waste * 0.40).round());
      },
      onSelectionChanged: (selections) {
        final newVal = selections.isNotEmpty ? selections.first : '';
        setState(() => _selectedValue = newVal);
        if (widget.onChanged != null) {
          widget.onChanged!(newVal);
        }
      },
      bottomCardWidget: _selectedValue.isEmpty ? null : _buildBottomCard(_calculateWaste(_selectedValue)),
      options: [
        SelectionOption(id: 'never', label: 'Almost never'),
        SelectionOption(id: 'sometimes', label: 'Sometimes'),
        SelectionOption(id: 'weekly', label: 'Weekly'),
        SelectionOption(id: 'constantly', label: 'Constantly'),
      ],
    );
  }
}
