import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/string_extensions.dart';

class AllergyOption {
  final String title;
  final String icon;

  AllergyOption({required this.title, required this.icon});
}

class AllergiesStep extends StatefulWidget {
  final Set<String> initialSelected;
  final Function(Set<String> selected) onChanged;

  const AllergiesStep({
    super.key,
    required this.initialSelected,
    required this.onChanged,
  });

  @override
  State<AllergiesStep> createState() => _AllergiesStepState();
}

class _AllergiesStepState extends State<AllergiesStep> {
  late Set<String> _selectedAllergies;
  final List<String> _customAllergies = [];
  bool _showOtherInput = false;
  final TextEditingController _otherController = TextEditingController();

  final List<AllergyOption> _options = [
    AllergyOption(title: 'Tree Nuts', icon: 'nut.svg'),
    AllergyOption(title: 'Peanuts', icon: 'peanut.svg'),
    AllergyOption(title: 'Shellfish', icon: 'shellfish.svg'),
    AllergyOption(title: 'Fish', icon: 'fish.svg'),
    AllergyOption(title: 'Eggs', icon: 'eggs.svg'),
    AllergyOption(title: 'Soy', icon: 'soy.svg'),
    AllergyOption(title: 'Dairy / Milk', icon: 'dairy.svg'),
    AllergyOption(title: 'Wheat / Gluten', icon: 'gluten.svg'),
    AllergyOption(title: 'Sesame', icon: 'sesame.svg'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedAllergies = Set.from(widget.initialSelected);
    final standardTitles = _options.map((e) => e.title).toSet();
    for (var a in _selectedAllergies) {
      if (!standardTitles.contains(a) && a != 'No allergies') {
        _customAllergies.add(a);
      }
    }
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _toggleOption(String title) {
    setState(() {
      if (title == 'No allergies') {
        _selectedAllergies.clear();
        _customAllergies.clear();
        _selectedAllergies.add(title);
        _showOtherInput = false;
      } else {
        _selectedAllergies.remove('No allergies');
        if (_selectedAllergies.contains(title)) {
          _selectedAllergies.remove(title);
        } else {
          _selectedAllergies.add(title);
        }
      }
    });
    widget.onChanged(_selectedAllergies);
  }

  void _addCustomAllergy() {
    final val = _otherController.text.trim().toTitleCase();
    if (val.isNotEmpty) {
      setState(() {
        _selectedAllergies.remove('No allergies');
        if (!_customAllergies.contains(val)) {
          _customAllergies.add(val);
          _selectedAllergies.add(val);
        }
        _otherController.clear();
        _showOtherInput = false;
      });
      widget.onChanged(_selectedAllergies);
    }
  }

  void _removeCustomAllergy(String val) {
    setState(() {
      _customAllergies.remove(val);
      _selectedAllergies.remove(val);
    });
    widget.onChanged(_selectedAllergies);
  }

  @override
  Widget build(BuildContext context) {
    final isNoAllergies = _selectedAllergies.contains('No allergies');

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Any allergies or intolerances?',
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
            'Your safety is our top priority',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF9CA3AF),
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
            childAspectRatio: 1.6,
            children: [
              ..._options.map((option) {
                final isSelected = _selectedAllergies.contains(option.title);
                return _AllergyCard(
                  title: option.title,
                  icon: option.icon,
                  isSelected: isSelected,
                  onTap: () => _toggleOption(option.title),
                );
              }),
              _AllergyCard(
                title: 'Others',
                icon: '',
                isSelected: _showOtherInput || _customAllergies.isNotEmpty,
                onTap: () {
                  setState(() => _showOtherInput = !_showOtherInput);
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (_showOtherInput) ...[
            TextField(
              controller: _otherController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Type your allergy..',
                hintStyle: const TextStyle(color: Color(0xFFBDC3C7)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFC83A2D)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFC83A2D)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                    color: Color(0xFFC83A2D),
                    width: 1.5,
                  ),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _addCustomAllergy(),
            ),
            SizedBox(height: 16.h),
          ],
          if (_customAllergies.isNotEmpty) ...[
            GestureDetector(
              onTap: () => setState(() => _showOtherInput = true),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(50.r),
                  border: Border.all(color: const Color(0xFF0D1B3E), width: 1),
                ),
                child: Center(
                  child: Text(
                    '+ Other allergy not listed',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0D1B3E),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            ..._customAllergies.map(
              (a) => Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFC83A2D)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        a,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0D1B3E),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeCustomAllergy(a),
                      child: Icon(
                        Icons.close,
                        color: const Color(0xFFC83A2D),
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => _toggleOption('No allergies'),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: isNoAllergies ? const Color(0xFFF1FDF5) : Colors.white,
                borderRadius: BorderRadius.circular(50.r),
                border: Border.all(
                  color: const Color(0xFF22C55E),
                  width: isNoAllergies ? 2 : 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isNoAllergies) ...[
                    Icon(
                      Icons.check,
                      color: const Color(0xFF22C55E),
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    'No allergies',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF22C55E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF9F6),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 24.sp,
                  color: const Color(0xFFFBBF24),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Recipes containing these ingredients will NEVER appear in your feed',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'SF Pro',
                      color: const Color(0xFF4B5563),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}

class _AllergyCard extends StatelessWidget {
  final String title;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AllergyCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFC83A2D)
                : const Color(0xFFE5E7EB).withOpacity(0.5),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon.isNotEmpty) ...[
              SvgPicture.asset(
                'assets/icones/$icon',
                height: 28.h,
                width: 28.w,
                placeholderBuilder: (context) => const SizedBox.shrink(),
              ),
              SizedBox(height: 6.h),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro',
                color: isSelected
                    ? const Color(0xFF0D1B3E)
                    : const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
