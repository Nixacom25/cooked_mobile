import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MealPlanningStep extends StatefulWidget {
  final String initialSelected;
  final Function(String selected) onChanged;

  const MealPlanningStep({
    super.key,
    required this.initialSelected,
    required this.onChanged,
  });

  @override
  State<MealPlanningStep> createState() => _MealPlanningStepState();
}

class _MealPlanningStepState extends State<MealPlanningStep> {
  final List<Map<String, String>> _options = [
    {
      'title': 'Weekly meal plan',
      'subtitle': 'Get a full plan every week',
      'icon': 'notes.svg',
    },
    {
      'title': 'Daily suggestions',
      'subtitle': 'One recipe each morning',
      'icon': 'sun.svg',
    },
    {
      'title': 'I\'ll plan myself',
      'subtitle': 'Just show me recipes',
      'icon': 'magnifier.svg',
    },
    {
      'title': 'Plan by ingredients',
      'subtitle': 'Scan my fridge, give me a plan',
      'icon': 'camera.svg',
    },
  ];

  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How do you like to plan meals?',
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
            'We\'ll customize the experience for you',
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 24.h),
          ..._options.map((opt) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildOption(opt),
          )),
        ],
      ),
    );
  }

  Widget _buildOption(Map<String, String> opt) {
    final bool isSelected = _selected == opt['title'];
    return InkWell(
      onTap: () {
        setState(() => _selected = opt['title']!);
        widget.onChanged(_selected);
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xFFC83A2D) : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5.w : 1.w,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFC83A2D).withOpacity(0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icones/${opt['icon']}',
              height: 20.sp,
              width: 20.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    opt['title']!,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    opt['subtitle']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 8.sp,
                      color: const Color(0xFF7B8190),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
