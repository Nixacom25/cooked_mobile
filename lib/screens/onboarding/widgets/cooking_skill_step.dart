import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CookingSkillStep extends StatefulWidget {
  final String? initialSelected;
  final Function(String selected) onChanged;

  const CookingSkillStep({
    super.key,
    required this.initialSelected,
    required this.onChanged,
  });

  @override
  State<CookingSkillStep> createState() => _CookingSkillStepState();
}

class _CookingSkillStepState extends State<CookingSkillStep> {
  String? _selectedLevel;

  final List<Map<String, String>> _levels = [
    {
      'title': 'Total Beginner',
      'desc': 'I can barely boil water',
      'icon': 'frying.svg',
    },
    {
      'title': 'Home Cook',
      'desc': 'I follow recipes step by step',
      'icon': 'cook-medium-skin.svg',
    },
    {
      'title': 'Confident Cook',
      'desc': 'I improvise and experiment',
      'icon': 'cook-light-skin.svg',
    },
    {
      'title': 'Advanced / Semi-Pro',
      'desc': 'I want challenging recipes.',
      'icon': 'star.svg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's your cooking skill level?",
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              height: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "We'll match recipes to your experience",
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 32.h),
          ..._levels.map((level) {
            final isSelected = _selectedLevel == level['title'];

            return Padding(
              padding: EdgeInsets.only(bottom: 15.h),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedLevel = level['title']);
                  widget.onChanged(level['title']!);
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
                      Container(
                        child: SvgPicture.asset(
                          'assets/icones/${level['icon']}',
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
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              level['title']!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0D1B3E),
                                fontFamily: 'SF Pro',
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              level['desc']!,
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
          }).toList(),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}
