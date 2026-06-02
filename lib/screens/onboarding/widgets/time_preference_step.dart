import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

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
      'title': 'Under 15 minutes',
      'desc': 'Ultra-fast meals',
      'icon': 'electric.svg',
      'summary': 'For when you need food instantly.',
    },
    {
      'title': '15–30 minutes',
      'desc': 'Quick but not rushed',
      'icon': 'timer.svg',
      'summary': 'Perfect for quick weekday meals.',
    },
    {
      'title': '30–60 minutes',
      'desc': 'A normal cooking window',
      'icon': 'clock.svg',
      'summary': 'Great for relaxed dinners.',
    },
    {
      'title': '1–2 hours',
      'desc': 'I enjoy the cooking process',
      'icon': 'pizza.svg', // Fallback if hourglass is missing
      'summary': 'For weekend cooking sessions.',
    },
    {
      'title': 'Any amount of time',
      'desc': 'Show me everything',
      'icon': 'star.svg', // Fallback for infinity
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
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How much time do you usually have to cook?',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'This sets your default recipe time filter.',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 32.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: _options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = _selectedTime == option['title'];
              final isFullWidth = index == 4; // 'Any amount of time'
              final itemWidth = isFullWidth 
                  ? double.infinity 
                  : (MediaQuery.of(context).size.width - 40.w - 12.w) / 2;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedTime = option['title']);
                  widget.onChanged(option['title']!);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: itemWidth,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFC83A2D) : const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                    boxShadow: [
                      if (isSelected) BoxShadow(
                        color: const Color(0xFFC83A2D).withOpacity(0.05),
                        blurRadius: 10.r,
                        offset: Offset(0, 4.h),
                      )
                    ]
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icones/${option['icon']}',
                        height: 32.sp,
                        width: 32.sp,
                        colorFilter: ColorFilter.mode(
                          isSelected ? const Color(0xFFC83A2D) : const Color(0xFF9CA3AF),
                          BlendMode.srcIn,
                        ),
                        placeholderBuilder: (context) => const SizedBox.shrink(),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        option['title']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0D1B3E),
                          fontFamily: 'SF Pro',
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        option['desc']!,
                        textAlign: TextAlign.center,
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
              );
            }).toList(),
          ),
          
          if (_selectedTime != null && _selectedTime != 'Any amount of time') ...[
            SizedBox(height: 32.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED), // Very light orange/beige
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFFFEDD5)),
              ),
              child: Text(
                _options.firstWhere((o) => o['title'] == _selectedTime)['summary']!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SF Pro',
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
