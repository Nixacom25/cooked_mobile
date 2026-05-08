import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GoalsStep extends StatefulWidget {
  final List<String> initialSelected;
  final Function(List<String> selected) onChanged;

  const GoalsStep({
    super.key,
    required this.initialSelected,
    required this.onChanged,
  });

  @override
  State<GoalsStep> createState() => _GoalsStepState();
}

class _GoalsStepState extends State<GoalsStep> {
  final List<Map<String, String>> _goals = [
    {'title': 'Cook more at home and save money', 'icon': 'dollar-bag.svg'},
    {'title': 'Reduce food waste — use what I have', 'icon': 'recycle.svg'},
    {'title': 'Eat healthier and track nutrition', 'icon': 'salad.svg'},
    {'title': 'Discover new cuisines and recipes', 'icon': 'world.svg'},
    {'title': 'Meal prep and plan my week', 'icon': 'calendar.svg'},
    {'title': 'Learn to cook from scratch', 'icon': 'books.svg'},
  ];

  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What brings you here?',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Select up to 2 primary goals',
            style: TextStyle(
              fontSize: 11.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 24.h),
          ..._goals.map((goal) => _buildGoalItem(goal)),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F5EF),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            alignment: Alignment.center,
            child: Text(
              '${_selected.length}/2 goals selected',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF7B8190),
              ),
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildGoalItem(Map<String, String> goal) {
    final bool isSelected = _selected.contains(goal['title']);
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selected.remove(goal['title']);
            } else if (_selected.length < 2) {
              _selected.add(goal['title']!);
            }
          });
          widget.onChanged(_selected.toList());
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFC83A2D)
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 1.5.w : 1.w,
            ),
          ),
          child: Row(
            children: [
              Container(
                child: SvgPicture.asset(
                  'assets/icones/${goal['icon']}',
                  height: 28.sp,
                  width: 28.sp,
                  placeholderBuilder: (context) => SizedBox(
                    height: 28.sp,
                    width: 28.sp,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  goal['title']!,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
