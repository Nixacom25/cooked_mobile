import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LanguageRegionStep extends StatefulWidget {
  final String initialLanguage;
  final String initialCountry;
  final String initialAlternativeRegion;
  final String initialMeasurementSystem;
  final Function({
    required String language,
    required String country,
    required String alternativeRegion,
    required String measurementSystem,
  })
  onChanged;

  const LanguageRegionStep({
    super.key,
    required this.initialLanguage,
    required this.initialCountry,
    required this.initialAlternativeRegion,
    required this.initialMeasurementSystem,
    required this.onChanged,
  });

  @override
  State<LanguageRegionStep> createState() => _LanguageRegionStepState();
}

class _LanguageRegionStepState extends State<LanguageRegionStep> {
  late String _selectedLanguage;
  late String _selectedCountry;
  late String _selectedAlternativeRegion;
  late String _selectedMeasurementSystem;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.initialLanguage;
    _selectedCountry = widget.initialCountry;
    _selectedAlternativeRegion = widget.initialAlternativeRegion;
    _selectedMeasurementSystem = widget.initialMeasurementSystem;
  }

  void _notifyChange() {
    widget.onChanged(
      language: _selectedLanguage,
      country: _selectedCountry,
      alternativeRegion: _selectedAlternativeRegion,
      measurementSystem: _selectedMeasurementSystem,
    );
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
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "We'll use this to suggest local recipes and ingredients available near you",
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
              height: 1.5,
            ),
          ),
          SizedBox(height: 32.h),

          _buildLabel('Language'),
          SizedBox(height: 8.h),
          _buildDropdown(
            value: _selectedLanguage,
            items: _languages,
            onChanged: (val) {
              setState(() => _selectedLanguage = val!);
              _notifyChange();
            },
          ),

          SizedBox(height: 24.h),

          _buildLabel('Country/Region'),
          SizedBox(height: 8.h),
          _buildDropdown(
            value: _selectedCountry,
            items: _countries,
            onChanged: (val) {
              setState(() => _selectedCountry = val!);
              _notifyChange();
            },
          ),

          SizedBox(height: 24.h),

          _buildLabel('Alternative Region'),
          SizedBox(height: 8.h),
          _buildDropdown(
            value: _selectedAlternativeRegion,
            items: _countries,
            onChanged: (val) {
              setState(() => _selectedAlternativeRegion = val!);
              _notifyChange();
            },
          ),

          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F5EF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Measurement system : ${_selectedMeasurementSystem == 'Imperial'
              ? 'Imperial (cups, oz, °F)'
              : 'Metric (grams, ml, °C)'} ',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: const Color(0xFF7B8190),
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          _buildMeasurementSelector(),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildMeasurementSelector() {
    return Container(
      width: double.infinity,
      height: 44.h,
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7F2),
        borderRadius: BorderRadius.circular(50.r),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleOption(
              'Imperial',
              _selectedMeasurementSystem == 'Imperial',
            ),
          ),
          Expanded(
            child: _buildToggleOption(
              'Metric',
              _selectedMeasurementSystem == 'Metric',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedMeasurementSystem = label);
        _notifyChange();
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC83A2D) : Colors.transparent,
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Text(
          label == 'Imperial'
              ? 'Imperial (cups, oz, °F)'
              : 'Metric (grams, ml, °C)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 9.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF7B8190),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF111827),
        fontFamily: 'SF Pro',
      ),
    );
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
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 4,
          padding: EdgeInsets.zero,
          itemBuilder: (context) {
            return items.map((String item) {
              final bool isSelected = item == value;
              return PopupMenuItem<String>(
                value: item,
                padding: EdgeInsets.zero,
                height: 48.h,
                child: Container(
                  width: double.infinity,
                  height: 48.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF4C459) : Colors.white,
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 10.sp,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              );
            }).toList();
          },
          child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF1A1A1A),
                  size: 20.sp,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
