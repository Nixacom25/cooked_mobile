import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class KitchenStep extends StatefulWidget {
  final List<String> initialSelected;
  final Function(List<String> selected) onChanged;

  const KitchenStep({
    super.key,
    required this.initialSelected,
    required this.onChanged,
  });

  @override
  State<KitchenStep> createState() => _KitchenStepState();
}

class _KitchenStepState extends State<KitchenStep> {
  final List<Map<String, String>> _appliances = [
    {'title': 'Oven', 'icon': 'oven-baker.svg'},
    {'title': 'Stovetop / Gas burner', 'icon': 'fire.svg'},
    {'title': 'Microwave', 'icon': 'microwave.svg'},
    {'title': 'Air fryer', 'icon': 'pan.svg'},
    {'title': 'Blender / Liquidizer', 'icon': 'blender.svg'},
    {'title': 'Food processor', 'icon': 'food-steamer.svg'},
    {'title': 'Instant Pot / Pressure cooker', 'icon': 'kitchen.svg'},
    {'title': 'Grill / BBQ', 'icon': 'grill.svg'},
    {'title': 'Rice cooker', 'icon': 'rice-cooker.svg'},
    {'title': 'Stand mixer / Hand mixer', 'icon': 'hand.svg'},
    {'title': 'Steamer', 'icon': 'steamer.svg'},
    {'title': 'Other', 'icon': ''},
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
            'What\'s in your kitchen?',
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
            'Select your equipment',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 32.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 1.5,
            ),
            itemCount: _appliances.length,
            itemBuilder: (context, index) {
              final app = _appliances[index];
              return _buildApplianceCard(app);
            },
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildApplianceCard(Map<String, String> app) {
    final bool isSelected = _selected.contains(app['title']);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selected.remove(app['title']);
          } else {
            _selected.add(app['title']!);
          }
        });
        widget.onChanged(_selected.toList());
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icones/${app['icon']}',
              height: 28.sp,
              width: 28.sp,
              placeholderBuilder: (context) => SizedBox(
                height: 28.sp,
                width: 28.sp,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              app['title']!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
