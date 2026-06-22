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
      'icon': 'scan1.svg', // Assuming you have an icon like this, or use a generic one
    },
    {
      'id': 'meal_planning',
      'title': 'Meal Planning',
      'desc': 'Plan your meals for the week without starting from scratch.',
      'icon': 'calendar2.svg', // Or similar
    },
    {
      'id': 'import_recipes',
      'title': 'Import Recipes',
      'desc': 'Save recipes from TikTok, Instagram, YouTube, or websites.',
      'icon': 'import1.svg', // Or similar
    },
    {
      'id': 'grocery_lists',
      'title': 'Grocery Lists',
      'desc': 'Turn recipes into shopping lists automatically.',
      'icon': 'grocery.svg', // Or similar
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
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What are you most\nexcited about?',
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
                  "Pick the features you'll use most.",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF4B5563),
                    fontFamily: 'SF Pro',
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 32.h),
                ..._options.map((opt) {
                  final isSelected = _selected.contains(opt['id']);
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: GestureDetector(
                      onTap: () => _toggleOption(opt['id']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
                            ),
                          ]
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icones/${opt['icon']}',
                              height: 28.sp,
                              width: 28.sp,
                              colorFilter: ColorFilter.mode(
                                isSelected ? const Color(0xFFC83A2D) : const Color(0xFF9CA3AF),
                                BlendMode.srcIn,
                              ),
                              placeholderBuilder: (context) => Icon(Icons.star, color: Colors.grey, size: 28.sp),
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
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? const Color(0xFFC83A2D) : const Color(0xFF111827),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    opt['desc']!,
                                    style: TextStyle(
                                      fontFamily: 'SF Pro',
                                      fontSize: 13.sp,
                                      color: const Color(0xFF9CA3AF),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Padding(
                                padding: EdgeInsets.only(left: 12.w),
                                child: Icon(
                                  Icons.check_circle,
                                  color: const Color(0xFFC83A2D),
                                  size: 24.sp,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
          child: SafeArea(
            top: false,
            child: RedButton(
              label: 'Continue',
              onTap: widget.onContinue,
              height: 55.h,
              fontSize: 18.sp,
              isDisabled: _selected.isEmpty,
            ),
          ),
        ),
      ],
    );
  }
}
