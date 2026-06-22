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
      'icon': 'flash.svg',
      'summary': 'For when you need food instantly.',
    },
    {
      'title': '15–30 minutes',
      'desc': 'Quick but not rushed',
      'icon': 'minute.svg',
      'summary': 'Perfect for quick weekday meals.',
    },
    {
      'title': '30–60 minutes',
      'desc': 'A normal cooking window',
      'icon': 'minute2.svg',
      'summary': 'Great for relaxed dinners.',
    },
    {
      'title': '1–2 hours',
      'desc': 'I enjoy the cooking process',
      'icon': 'hours.svg',
      'summary': 'For weekend cooking sessions.',
    },
    {
      'title': 'Any amount of time',
      'desc': 'Show me everything',
      'icon': 'pipeline.svg',
      'summary': 'All recipes are on the table.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 30.h),
                          Text(
                            'How much time do\nyou usually have to\ncook?',
                            style: TextStyle(
                              fontSize: 34.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF111827),
                              fontFamily: 'Larken',
                              height: 1.149,
                              letterSpacing: 0,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "We'll prioritize recipes that fit your\nschedule.",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: const Color(0xFF4B5563),
                              fontFamily: 'SF Pro',
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: _buildOptionCard(_options[0], false)),
                                  SizedBox(width: 12.w),
                                  Expanded(child: _buildOptionCard(_options[1], false)),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Expanded(child: _buildOptionCard(_options[2], false)),
                                  SizedBox(width: 12.w),
                                  Expanded(child: _buildOptionCard(_options[3], false)),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              _buildOptionCard(_options[4], true),
                            ],
                          ),
                          if (_selectedTime != null && _selectedTime != 'Any amount of time') ...[
                            SizedBox(height: 16.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCD34D),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                _options.firstWhere((o) => o['title'] == _selectedTime)['summary']!,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: 'SF Pro',
                                  color: const Color(0xFF111827),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: 10.h),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.onContinue != null)
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
            child: SafeArea(
              top: false,
              child: RedButton(
                label: 'Continue',
                onTap: widget.onContinue!,
                isDisabled: _selectedTime == null,
                height: 55.h,
                fontSize: 18.sp,
              ),
            ),
          ),
      ],
    );
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
        duration: const Duration(milliseconds: 200),
        width: isFullWidth ? double.infinity : null,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? const Color(0xFFC83A2D) : const Color(0xFFF3F4F6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icones/${option['icon']}',
              height: 25.sp,
              width: 25.sp,
              colorFilter: ColorFilter.mode(
                isSelected ? const Color(0xFFC83A2D) : const Color(0xFF9CA3AF),
                BlendMode.srcIn,
              ),
              placeholderBuilder: (context) => const SizedBox.shrink(),
            ),
            SizedBox(height: 4.h),
            Text(
              option['title']!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFFC83A2D) : const Color(0xFF111827),
                fontFamily: 'SF Pro',
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              option['desc']!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF9CA3AF),
                fontFamily: 'SF Pro',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
