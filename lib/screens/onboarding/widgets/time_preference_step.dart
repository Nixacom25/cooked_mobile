import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import '../../../widgets/red_button.dart';

class TimePreferenceStep extends StatefulWidget {
  final String? initialSelected;
  final Function(String selected) onChanged;
  final VoidCallback? onContinue;

  const TimePreferenceStep({
    super.key,
    required this.initialSelected,
    required this.onChanged,
    this.onContinue,
  });

  @override
  State<TimePreferenceStep> createState() => _TimePreferenceStepState();
}

class _TimePreferenceStepState extends State<TimePreferenceStep> {
  String? _selectedTime;

  final List<Map<String, dynamic>> _options = [
    {
      'title': 'Under 15 minutes',
      'desc': 'Ultra-fast meals',
      'icon': 'under.svg',
      'summary': 'For when you need food instantly.',
    },
    {
      'title': '15–30 minutes',
      'desc': 'Quick but not rushed',
      'icon': 'demi.svg',
      'summary': 'Perfect for quick weekday meals.',
    },
    {
      'title': '30–60 minutes',
      'desc': 'A normal cooking window',
      'icon': 'heure.svg',
      'summary': 'Great for relaxed dinners.',
    },
    {
      'title': '1–2 hours',
      'desc': 'I enjoy the cooking process',
      'icon': 'minutes.svg',
      'summary': 'For weekend cooking sessions.',
    },
    {
      'title': 'Any amount of time',
      'desc': 'Show me everything',
      'icon': 'time.svg',
      'summary': 'All recipes are on the table.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialSelected ?? '15–30 minutes';
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = _options.firstWhere(
      (o) => o['title'] == _selectedTime,
      orElse: () => _options[1]);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How much time do you\nusually have to cook?',
                  style: GoogleFonts.rubik(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827),
                    height: 1.15)),
                SizedBox(height: 10.h),
                Text(
                  'We’ll prioritize recipes that fit your schedule',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    color: const Color(0xFF111827),
                    height: 1.3)),
                SizedBox(height: 24.h),
                Text(
                  'Cooking time',
                  style: GoogleFonts.rubik(fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827))),
                SizedBox(height: 12.h),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildOptionCard(_options[0], false)),
                        SizedBox(width: 12.w),
                        Expanded(child: _buildOptionCard(_options[1], false)),
                      ]),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(child: _buildOptionCard(_options[2], false)),
                        SizedBox(width: 12.w),
                        Expanded(child: _buildOptionCard(_options[3], false)),
                      ]),
                    SizedBox(height: 10.h),
                    _buildOptionCard(_options[4], true),
                  ]),
                SizedBox(height: 20.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF4E5),
                    borderRadius: BorderRadius.circular(14.r)),
                  child: Text(
                    selectedOption['summary']!,
                    style: GoogleFonts.poppins(fontSize: 14.sp,
                      color: const Color(0xFF111827),
                      height: 1.35))),
                SizedBox(height: 20.h),
              ]))),
        if (widget.onContinue != null)
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
            child: SafeArea(
              top: false,
              bottom: true,
              child: RedButton(
                label: 'Continue',
                color: const Color(0xFFC31E26),
                onTap: widget.onContinue!,
                isDisabled: _selectedTime == null,
                height: 52.h,
                fontSize: 16.sp))),
      ]);
  }

  Widget _buildOptionCard(Map<String, dynamic> option, bool isFullWidth) {
    final isSelected = _selectedTime == option['title'];
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedTime = option['title']);
        widget.onChanged(option['title']!);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: isFullWidth ? double.infinity : null,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xFFC31E26) : Colors.transparent,
            width: 1.5)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icones/${option['icon']}',
              height: 24.sp,
              width: 24.sp,
              colorFilter: ColorFilter.mode(
                isSelected ? const Color(0xFFC31E26) : const Color(0xFF0F172A),
                BlendMode.srcIn),
              placeholderBuilder: (context) => const SizedBox.shrink()),
            SizedBox(height: 8.h),
            Text(
              option['title']!,
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFFC31E26) : const Color(0xFF0F172A))),
            SizedBox(height: 2.h),
            Text(
              option['desc']!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF111827))),
          ])));
  }
}
