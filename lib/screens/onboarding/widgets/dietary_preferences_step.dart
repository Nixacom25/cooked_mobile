import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DietaryProfile {
  final String title;
  final String description;
  final String icon;

  DietaryProfile({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class DietaryPreferencesStep extends StatefulWidget {
  final Set<String> initialSelected;
  final Function(Set<String> selected) onChanged;

  const DietaryPreferencesStep({
    super.key,
    required this.initialSelected,
    required this.onChanged,
  });

  @override
  State<DietaryPreferencesStep> createState() => _DietaryPreferencesStepState();
}

class _DietaryPreferencesStepState extends State<DietaryPreferencesStep> {
  late Set<String> _selectedDiet;

  final List<DietaryProfile> _options = [
    DietaryProfile(
      title: 'No Restrictions',
      description: 'I Eat Everything',
      icon: 'all.svg',
    ),
    DietaryProfile(
      title: 'Vegetarian',
      description: 'No Meat/Fish/Dairy.',
      icon: 'vegetarian.svg',
    ),
    DietaryProfile(
      title: 'Vegan',
      description: 'No Animals Products',
      icon: 'vegan.svg',
    ),
    DietaryProfile(
      title: 'Pescatarian',
      description: 'Fish OK, No other Meat',
      icon: 'fish.svg',
    ),
    DietaryProfile(
      title: 'Gluten-Free',
      description: 'No Wheat or Gluten',
      icon: 'gluten.svg',
    ),
    DietaryProfile(
      title: 'Halal',
      description: 'Islamic Dietary Laws',
      icon: 'halal.svg',
    ),
    DietaryProfile(
      title: 'Kosher',
      description: 'Jewish Dietary Laws',
      icon: 'kosher.svg',
    ),
    DietaryProfile(
      title: 'Lactose Intolerant',
      description: 'No Dairy',
      icon: 'dairy.svg',
    ),
    DietaryProfile(
      title: 'Keto/Low-Carb',
      description: 'High Fat, Low Carb',
      icon: 'keto.svg',
    ),
    DietaryProfile(
      title: 'Diabetic-Friendly',
      description: 'Low GI Focus',
      icon: 'diabetic.svg',
    ),
    DietaryProfile(
      title: 'Paleo',
      description: 'Whole Foods Only',
      icon: 'paleo.svg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDiet = Set.from(widget.initialSelected);
    if (_selectedDiet.isEmpty) {
      _selectedDiet.add('No Restrictions');
    }
  }

  void _toggleOption(String title) {
    setState(() {
      if (title == 'No Restrictions') {
        _selectedDiet.clear();
        _selectedDiet.add('No Restrictions');
      } else {
        _selectedDiet.remove('No Restrictions');
        if (_selectedDiet.contains(title)) {
          _selectedDiet.remove(title);
          if (_selectedDiet.isEmpty) {
            _selectedDiet.add('No Restrictions');
          }
        } else {
          _selectedDiet.add(title);
        }
      }
    });
    widget.onChanged(_selectedDiet);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's your dietary profile?",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0D1B36),
              fontFamily: 'SF Pro',
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Select all that apply',
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 32.h),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 1.3,
            children: _options.map((option) {
              final isSelected = _selectedDiet.contains(option.title);

              return GestureDetector(
                onTap: () => _toggleOption(option.title),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFC83A2D)
                          : const Color(0xFFE5E7EB).withOpacity(0.5),
                      width: isSelected ? 2 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icones/${option.icon}',
                        height: 32.h,
                        width: 32.w,
                        placeholderBuilder: (context) => SizedBox(
                          height: 32.h,
                          width: 32.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        option.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'SF Pro',
                          color: isSelected
                              ? const Color(0xFF0D1B3E)
                              : const Color(0xFF4B5563),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        option.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'SF Pro',
                          color: const Color(0xFF9CA3AF),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
