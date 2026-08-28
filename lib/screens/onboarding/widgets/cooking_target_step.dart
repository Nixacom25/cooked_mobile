import 'package:google_fonts/google_fonts.dart';
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
    {'title': '5–6 people', 'subtitle': 'Larger family', 'icon': 'people4.svg'},
    {
      'title': '7+ people',
      'subtitle': 'Large family or group',
      'icon': 'people5.svg',
    },
    {
      'title': 'It varies',
      'subtitle': "I'll adjust per recipe",
      'icon': 'people6.svg',
    },
  ];

  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialTarget.isNotEmpty ? widget.initialTarget : 'Two people';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Who are you usually\ncooking for?',
                  style: GoogleFonts.rubik(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827),
                    height: 1.15)),
                SizedBox(height: 10.h),
                Text(
                  "This helps us recommend the right portions",
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    color: const Color(0xFF111827),
                    height: 1.3)),
                SizedBox(height: 24.h),
                Column(
                  children: _options.map((opt) => _buildOption(opt)).toList()),
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
                height: 52.h,
                fontSize: 16.sp))),
      ]);
  }

  Widget _buildOption(Map<String, String> opt) {
    final bool isSelected = _selected == opt['title'];
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selected = opt['title']!);
          widget.onChanged(_selected);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFC31E26)
                  : Colors.transparent,
              width: 1.5)),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icones/${opt['icon']}',
                height: 24.sp,
                width: 24.sp,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? const Color(0xFFC31E26)
                      : const Color(0xFF0F172A),
                  BlendMode.srcIn),
                placeholderBuilder: (context) => const SizedBox.shrink()),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opt['title']!,
                      style: GoogleFonts.rubik(fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFFC31E26)
                            : const Color(0xFF0F172A))),
                    SizedBox(height: 2.h),
                    Text(
                      opt['subtitle']!,
                      style: GoogleFonts.poppins(fontSize: 13.sp,
                        color: const Color(0xFF111827))),
                  ])),
              if (isSelected)
                Container(
                  width: 20.r,
                  height: 20.r,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFC31E26)),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12.sp))
              else
                Container(
                  width: 20.r,
                  height: 20.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                      width: 1.5))),
            ]))));
  }
}
