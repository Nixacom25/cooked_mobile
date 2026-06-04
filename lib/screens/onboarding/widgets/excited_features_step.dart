import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class ExcitedFeature {
  final String title;
  final String description;
  final String svgAsset;

  ExcitedFeature(this.title, this.description, this.svgAsset);
}

class ExcitedFeaturesStep extends StatefulWidget {
  final List<String> initialFeatures;
  final Function(List<String> features) onChanged;

  const ExcitedFeaturesStep({
    super.key,
    required this.initialFeatures,
    required this.onChanged,
  });

  @override
  State<ExcitedFeaturesStep> createState() => _ExcitedFeaturesStepState();
}

class _ExcitedFeaturesStepState extends State<ExcitedFeaturesStep> {
  late Set<String> _selectedFeatures;

  final List<ExcitedFeature> _features = [
    ExcitedFeature(
      'Scan Ingredients',
      'Find recipes from what you already have',
       'scan1.svg', // or any scanner icon
    ),
    ExcitedFeature(
      'Import Recipes',
      'Save recipes from TikTok, Instagram, YouTube, or websites',
      'import1.svg',
    ),
    ExcitedFeature(
      'Grocery List',
      'Turn recipes into shopping lists',
      'grocery.svg',
    ),
    ExcitedFeature(
      'Meal Planing',
      'Plan meal of the week',
      'planning.svg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedFeatures = widget.initialFeatures.toSet();
  }

  void _handleFeatureTap(String feature) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedFeatures.contains(feature)) {
        _selectedFeatures.remove(feature);
      } else {
        _selectedFeatures.add(feature);
      }
    });
    widget.onChanged(_selectedFeatures.toList());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are you most excited to use?',
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
            "We'll personalize Cooked around what matters most to you",
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 32.h),
          ..._features.map((feature) {
            final isSelected = _selectedFeatures.contains(feature.title);

            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: GestureDetector(
                onTap: () => _handleFeatureTap(feature.title),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFC83A2D) : const Color(0xFFE5E7EB),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: const Color(0xFFC83A2D).withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icones/${feature.svgAsset}',
                        height: 24.h,
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature.title,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A1A),
                                fontFamily: 'SF Pro',
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              feature.description,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: const Color(0xFF7B8190),
                                fontFamily: 'SF Pro',
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected) ...[
                        SizedBox(width: 12.w),
                        Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: const BoxDecoration(
                            color: Color(0xFFC83A2D),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                        ),
                      ],
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
