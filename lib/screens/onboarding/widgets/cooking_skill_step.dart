import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'selection_onboarding_step.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/l10n.dart';

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
      case 'beginner': return context.l10n.onbAvoidOverlyComplex;
      case 'home_cook': return context.l10n.onbAvoidUntested;
      case 'confident': return context.l10n.onbAvoidBoring;
      case 'advanced': return context.l10n.onbAvoidBasic;
      default: return context.l10n.onbAvoidComplex;
    }
  }

  Widget _buildBottomCard(String selectedValue) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFD97706).withValues(alpha: 0.16)
            : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFFD97706).withValues(alpha: 0.4)
                : const Color(0xFFFBE8D0))),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.poppins(
            color: context.colors.textPrimary,
            fontSize: 16.sp),
          children: [
            TextSpan(text: context.l10n.onbAvoidA),
            TextSpan(
              text: _getHighlightText(selectedValue),
              style: const TextStyle(
                color: Color(0xFFD92D20),
                fontWeight: FontWeight.bold)),
            TextSpan(text: context.l10n.onbAvoidB),
          ])));
  }

  @override
  Widget build(BuildContext context) {
    return SelectionOnboardingStep(
      title: context.l10n.onbSkillTitle,
      subtitle: context.l10n.onbSkillSubtitle,
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
          svgAsset: 'assets/icones/beginner.svg'),
        SelectionOption(
          id: 'home_cook',
          label: 'Home Cook',
          subLabel: 'I follow recipes step by step',
          icon: Icons.restaurant),
        SelectionOption(
          id: 'confident',
          label: 'Confident Cook',
          subLabel: 'I improvise and experiment',
          svgAsset: 'assets/icones/chef.svg'),
        SelectionOption(
          id: 'advanced',
          label: 'Advanced / Semi-Pro',
          subLabel: 'I want challenging recipes.',
          svgAsset: 'assets/icones/firew.svg'),
      ]);
  }
}
