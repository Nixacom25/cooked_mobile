import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import '../../../widgets/red_button.dart';

class CookingTargetStep extends StatefulWidget {
  final String initialTarget;
  final Function(String target) onChanged;
  final VoidCallback? onContinue;

  const CookingTargetStep({
    super.key,
    required this.initialTarget,
    required this.onChanged,
    this.onContinue,
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
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Who are you usually\ncooking for?',
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
                            "This helps us recommend the right portions.",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: const Color(0xFF4B5563),
                              fontFamily: 'SF Pro',
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Column(
                            children: _options.map((opt) => _buildOption(opt)).toList(),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).viewInsets.bottom,
                          ),
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
                height: 55.h,
                fontSize: 18.sp,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOption(Map<String, String> opt) {
    final bool isSelected = _selected == opt['title'];
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selected = opt['title']!);
          widget.onChanged(_selected);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFC83A2D)
                  : const Color(0xFFF3F4F6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icones/${opt['icon']}',
                height: 24.sp,
                width: 24.sp,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? const Color(0xFFC83A2D)
                      : const Color(0xFF9CA3AF),
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (context) => const SizedBox.shrink(),
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
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFFC83A2D)
                            : const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      opt['subtitle']!,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 12.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: const Color(0xFFC83A2D),
                  size: 24.sp,
                )
              else
                Container(
                  width: 24.sp,
                  height: 24.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1.5,
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
