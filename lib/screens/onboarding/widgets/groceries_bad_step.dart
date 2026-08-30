import 'package:google_fonts/google_fonts.dart';
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
    _selectedValue = (widget.initialSelected != null && widget.initialSelected!.isNotEmpty)
        ? widget.initialSelected!
        : 'never';
  }

  int _calculateWaste(String value) {
    switch (value) {
      case 'never': return 300;
      case 'sometimes': return 900;
      case 'weekly': return 1500;
      case 'constantly': return 2500;
      default: return 300;
    }
  }

  Widget _buildBottomCard(int waste) {
    final formattedWaste = waste.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]},'
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF4E5),
        borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The average household wastes', 
            style: GoogleFonts.rubik(
              color: const Color(0xFF334155), 
              fontSize: 14.sp,
              fontWeight: FontWeight.w500)),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'over ',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF111827),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400)),
              Text(
                '\$$formattedWaste',
                style: GoogleFonts.rubik(
                  color: const Color(0xFF15803D),
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w500)),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  '/year in food',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF111827),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400),
                  overflow: TextOverflow.ellipsis)),
            ]),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return SelectionOnboardingStep(
      title: 'How often do groceries go unused?',
      subtitle: 'Take your best guess. We’ll do the math',
      maxSelections: 1,
      useGrid: true,
      initialSelected: [_selectedValue],
      onContinue: () {
        final waste = _calculateWaste(_selectedValue);
        widget.onContinue((waste * 0.40).round());
      },
      onSelectionChanged: (selections) {
        final newVal = selections.isNotEmpty ? selections.first : 'never';
        setState(() => _selectedValue = newVal);
        if (widget.onChanged != null) {
          widget.onChanged!(newVal);
        }
      },
      bottomCardWidget: _buildBottomCard(_calculateWaste(_selectedValue)),
      options: [
        SelectionOption(id: 'never', label: 'Almost never'),
        SelectionOption(id: 'sometimes', label: 'Sometimes'),
        SelectionOption(id: 'weekly', label: 'Weekly'),
        SelectionOption(id: 'constantly', label: 'Constantly'),
      ]);
  }
}
