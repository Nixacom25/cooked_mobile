import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CuisinesStep extends StatefulWidget {
  final List<String> initialSelected;
  final Function(List<String> selected) onChanged;

  const CuisinesStep({
    super.key,
    required this.initialSelected,
    required this.onChanged,
  });

  @override
  State<CuisinesStep> createState() => _CuisinesStepState();
}

class _CuisinesStepState extends State<CuisinesStep> {
  final List<Map<String, String>> _cuisines = [
    {'id': 'italian', 'title': 'Italian'},
    {'id': 'japanese', 'title': 'Japanese'},
    {'id': 'mexican', 'title': 'Mexican'},
    {'id': 'chinese', 'title': 'Chinese'},
    {'id': 'thai', 'title': 'Thai'},
    {'id': 'middle', 'title': 'Middle Eastern'},
    {'id': 'west', 'title': 'West African'},
    {'id': 'east', 'title': 'East African'},
    {'id': 'caribbean', 'title': 'Caribbean'},
    {'id': 'others', 'title': 'Others'},
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
            'Which cuisines do you love?',
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
            'Select up to 6 favorites',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 25.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 1.15,
            ),
            itemCount: _cuisines.length,
            itemBuilder: (context, index) {
              final cuisine = _cuisines[index];
              return _buildCuisineCard(cuisine);
            },
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildCuisineCard(Map<String, String> cuisine) {
    final bool isSelected = _selected.contains(cuisine['title']);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selected.remove(cuisine['title']);
          } else if (_selected.length < 6) {
            _selected.add(cuisine['title']!);
          }
        });
        widget.onChanged(_selected.toList());
      },
      child: Container(
        padding: EdgeInsets.all(2.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFC83A2D)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2.w : 1.w,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                child: Image.asset(
                  'assets/images/${cuisine['id']}.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFF3F4F6),
                      child: Icon(
                        Icons.restaurant,
                        color: const Color(0xFF9CA3AF),
                        size: 32.sp,
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                cuisine['title']!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0D1B3E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
