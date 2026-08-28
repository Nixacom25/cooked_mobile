import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../widgets/red_button.dart';

class FeaturesExcitedStep extends StatefulWidget {
  final List<String> initialSelected;
  final Function(List<String> selected) onChanged;
  final VoidCallback onContinue;

  const FeaturesExcitedStep({
    super.key,
    required this.initialSelected,
    required this.onChanged,
    required this.onContinue,
  });

  @override
  State<FeaturesExcitedStep> createState() => _FeaturesExcitedStepState();
}

class _FeaturesExcitedStepState extends State<FeaturesExcitedStep> {
  late Set<String> _selected;

  final List<Map<String, String>> _options = [
    {
      'id': 'scan_ingredients',
      'title': 'Scan Ingredients',
      'desc': 'Take a photo and get recipes from what you already have.',
      'icon': 'scans.svg',
    },
    {
      'id': 'meal_planning',
      'title': 'Meal Planning',
      'desc': 'Plan your meals for the week without starting from scratch.',
      'icon': 'calendar2.svg',
    },
    {
      'id': 'import_recipes',
      'title': 'Import Recipes',
      'desc': 'Save recipes from TikTok, Instagram, YouTube, or websites.',
      'icon': 'imports.svg',
    },
    {
      'id': 'grocery_lists',
      'title': 'Grocery Lists',
      'desc': 'Turn recipes into shopping lists automatically.',
      'icon': 'grocerys.svg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialSelected);
  }

  void _toggleOption(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
    widget.onChanged(_selected.toList());
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
                  'What are you most\nexcited about?',
                  style: GoogleFonts.rubik(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827),
                    height: 1.15)),
                SizedBox(height: 10.h),
                Text(
                  "Pick the features you’ll use most",
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    color: const Color(0xFF111827),
                    height: 1.3)),
                SizedBox(height: 24.h),
                ..._options.map((opt) {
                  final isSelected = _selected.contains(opt['id']);
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: GestureDetector(
                      onTap: () => _toggleOption(opt['id']!),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: SvgPicture.asset(
                                'assets/icones/${opt['icon']}',
                                height: 24.sp,
                                width: 24.sp,
                                colorFilter: ColorFilter.mode(
                                  isSelected
                                      ? const Color(0xFFC31E26)
                                      : const Color(0xFF0F172A),
                                  BlendMode.srcIn),
                                placeholderBuilder: (context) => Icon(
                                  Icons.star,
                                  color: isSelected
                                      ? const Color(0xFFC31E26)
                                      : const Color(0xFF0F172A),
                                  size: 24.sp))),
                            SizedBox(width: 14.w),
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
                                  SizedBox(height: 3.h),
                                  Text(
                                    opt['desc']!,
                                    style: GoogleFonts.poppins(fontSize: 13.sp,
                                      color: const Color(0xFF111827),
                                      height: 1.3)),
                                ])),
                            SizedBox(width: 10.w),
                            Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: isSelected
                                  ? Container(
                                      width: 20.r,
                                      height: 20.r,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFC31E26)),
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 12.sp))
                                  : Container(
                                      width: 20.r,
                                      height: 20.r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFCBD5E1),
                                          width: 1.5)))),
                          ]))));
                }),
                SizedBox(height: 20.h),
              ]))),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
          child: SafeArea(
            top: false,
            bottom: true,
            child: RedButton(
              label: 'Continue',
              color: const Color(0xFFC31E26),
              onTap: widget.onContinue,
              height: 52.h,
              fontSize: 16.sp,
              isDisabled: _selected.isEmpty))),
      ]);
  }
}
