import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TimePreferenceStep extends StatefulWidget {
  final String? initialSelected;
  final Function(String selected) onChanged;

  const TimePreferenceStep({
    super.key,
    required this.initialSelected,
    required this.onChanged,
  });

  @override
  State<TimePreferenceStep> createState() => _TimePreferenceStepState();
}

class _TimePreferenceStepState extends State<TimePreferenceStep> {
  String? _selectedTime;

  final List<Map<String, dynamic>> _options = [
    {
      'title': 'Any Amount of Time',
      'desc': 'Anything goes',
      'icon': 'star.svg',
    },
    {
      'title': 'Under 15 minutes',
      'desc': 'I need ultra-fast meals',
      'icon': 'electric.svg',
    },
    {
      'title': '15–30 minutes',
      'desc': 'Quick but not rushed',
      'icon': 'timer.svg',
    },
    {
      'title': '30–60 minutes',
      'desc': 'I have time to cook a full meal',
      'icon': 'clock.svg',
    },
    {
      'title': '1–2 hours',
      'desc': 'I enjoy the cooking process',
      'icon': 'pizza.svg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How much time do you have to cook?',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'This sets your default time filter',
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 32.h),
          ..._options.map((option) {
            final isSelected = _selectedTime == option['title'];

            return Padding(
              padding: EdgeInsets.only(bottom: 15.h),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedTime = option['title']);
                  widget.onChanged(option['title']!);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFC83A2D)
                          : const Color(0xFFE5E7EB).withOpacity(0.5),
                      width: isSelected ? 2.w : 1.5.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icones/${option['icon']}',
                        height: 32.sp,
                        width: 32.sp,
                        placeholderBuilder: (context) => SizedBox(
                          height: 32.sp,
                          width: 32.sp,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option['title']!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0D1B3E),
                                fontFamily: 'SF Pro',
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              option['desc']!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF9CA3AF),
                                fontFamily: 'SF Pro',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}
