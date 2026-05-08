import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CookingTargetStep extends StatefulWidget {
  final String initialTarget;
  final Function(String target) onChanged;

  const CookingTargetStep({
    super.key,
    required this.initialTarget,
    required this.onChanged,
  });

  @override
  State<CookingTargetStep> createState() => _CookingTargetStepState();
}

class _CookingTargetStepState extends State<CookingTargetStep> {
  final List<Map<String, String>> _options = [
    {'title': 'Just me', 'subtitle': '1 person', 'icon': 'people1.svg'},
    {
      'title': 'Two people',
      'subtitle': 'Couple or pair',
      'icon': 'people2.svg',
    },
    {'title': '3–4 people', 'subtitle': 'Small family', 'icon': 'people3.svg'},
    {'title': '5–6 people', 'subtitle': 'Larger family', 'icon': 'people5.svg'},
    {
      'title': '7+ people',
      'subtitle': 'Large family or group',
      'icon': 'people4.svg',
    },
    {
      'title': 'It varies',
      'subtitle': "I'll adjust per recipe",
      'icon': 'varies.svg',
    },
  ];

  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialTarget;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Who are you cooking for?',
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
            "We'll auto-adjust serving sizes",
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 32.h),
          ..._options.map((opt) => _buildOption(opt)),
        ],
      ),
    );
  }

  Widget _buildOption(Map<String, String> opt) {
    final bool isSelected = _selected == opt['title'];
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: () {
          setState(() => _selected = opt['title']!);
          widget.onChanged(_selected);
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
              Container(
                child: SvgPicture.asset(
                  'assets/icones/${opt['icon']}',
                  height: 32.sp,
                  width: 32.sp,
                  placeholderBuilder: (context) => SizedBox(
                    height: 32.sp,
                    width: 32.sp,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opt['title']!,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      opt['subtitle']!,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 12.sp,
                        color: const Color(0xFF7B8190),
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
  }
}
