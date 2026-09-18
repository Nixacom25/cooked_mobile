import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class LanguageRegionStep extends StatefulWidget {
  final String initialLanguage;
  final String initialCountry;
  final String initialMeasurementSystem;
  final Function({
    required String language,
    required String country,
    required String measurementSystem,
  })
  onChanged;

  const LanguageRegionStep({
    super.key,
    required this.initialLanguage,
    required this.initialCountry,
    required this.initialMeasurementSystem,
    required this.onChanged,
  });

  @override
  State<LanguageRegionStep> createState() => _LanguageRegionStepState();
}

class _LanguageRegionStepState extends State<LanguageRegionStep> {
  late String _selectedLanguage;
  late String _selectedCountry;
  late String _selectedMeasurementSystem;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.initialLanguage;
    _selectedCountry = widget.initialCountry;
    _selectedMeasurementSystem = widget.initialMeasurementSystem;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _notifyChange() {
    widget.onChanged(
      language: _selectedLanguage,
      country: _selectedCountry,
      measurementSystem: _selectedMeasurementSystem);
  }

  final List<String> _languages = [
    'US English',
    'GB English',
    'FR Français',
    'ES Español',
    'DE Deutsch',
    'SA العربية',
  ];

  final List<String> _countries = [
    'US United States',
    'GB United Kingdom',
    'FR France',
    'DE Germany',
    'SN Senegal',
    'NG Nigeria',
    'MA Morocco',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Language & Region',
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: context.colors.textPrimary,
              height: 1.2)),
          SizedBox(height: 8.h),
          Text(
            "We'll use this to suggest local recipes and ingredients available near you",
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: context.colors.textMuted,
              height: 1.5)),
          SizedBox(height: 40.h),

          _buildLabel('Language'),
          SizedBox(height: 8.h),
          _buildDropdown(
            value: _selectedLanguage,
            items: _languages,
            onChanged: (val) {
              HapticFeedback.mediumImpact();
              setState(() => _selectedLanguage = val!);
              _notifyChange();
            }),

          SizedBox(height: 24.h),

          _buildLabel('Country/Region'),
          SizedBox(height: 8.h),
          _buildDropdown(
            value: _selectedCountry,
            items: _countries,
            onChanged: (val) {
              HapticFeedback.mediumImpact();
              setState(() => _selectedCountry = val!);
              _notifyChange();
            }),

          SizedBox(height: 32.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: context.colors.pageBackground,
              borderRadius: BorderRadius.circular(12.r)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Measurement system : ${_selectedMeasurementSystem == 'Imperial'
              ? 'Imperial (cups, oz, °F)'
              : 'Metric (grams, ml, °C)'} ',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: context.colors.textPrimary))),
              ])),
          SizedBox(height: 8.h),
          _buildMeasurementSelector(),
          SizedBox(height: 32.h),
        ]));
  }

  Widget _buildMeasurementSelector() {
    return Container(
      width: double.infinity,
      height: 56.h,
      padding: EdgeInsets.all(7.r),
      decoration: BoxDecoration(
        color: context.colors.pageBackground,
        borderRadius: BorderRadius.circular(50.r),
        border: Border.all(color: context.colors.surface)),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleOption(
              'Imperial',
              _selectedMeasurementSystem == 'Imperial')),
          Expanded(
            child: _buildToggleOption(
              'Metric',
              _selectedMeasurementSystem == 'Metric')),
        ]));
  }

  Widget _buildToggleOption(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() => _selectedMeasurementSystem = label);
        _notifyChange();
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? context.colors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(50.r)),
        child: Text(
          label == 'Imperial'
              ? 'Imperial (cups, oz, °F)'
              : 'Metric (grams, ml, °C)',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : context.colors.textSecondary))));
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: context.colors.textPrimary));
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return PopupMenuButton<String>(
          offset: Offset(0, 56.h),
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            maxWidth: constraints.maxWidth,
            maxHeight: 280.h, // Allow scrolling if items exceed this height
          ),
          onSelected: onChanged,
          color: context.colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 4,
          padding: EdgeInsets.zero,
          itemBuilder: (context) {
            return items.map((String item) {
              final bool isSelected = item == value;
              return PopupMenuItem<String>(
                value: item,
                padding: EdgeInsets.zero,
                height: 56.h,
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF4C459) : context.colors.surface),
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(fontSize: 14.sp,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: context.colors.textPrimary))));
            }).toList();
          },
          child: Container(
            height: 56.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: context.colors.divider)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary))),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: context.colors.textPrimary,
                  size: 24.sp),
              ])));
      });
  }
}
