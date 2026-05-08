import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/string_extensions.dart';
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
  final TextEditingController _othersController = TextEditingController();
  final FocusNode _othersFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected.toSet();
    _othersFocusNode.addListener(() {
      if (_othersFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          final context = _othersFocusNode.context;
          if (context != null) {
            Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 300), alignment: 0.5);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _othersController.dispose();
    _othersFocusNode.dispose();
    super.dispose();
  }

  void _addCustomEquipment() {
    final text = _othersController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      final items = text.split(',').map((s) => s.trim().toTitleCase()).where((s) => s.isNotEmpty);
      for (var item in items) {
        if (!_selected.contains(item)) {
          _selected.add(item);
        }
      }
      _othersController.clear();
    });
    widget.onChanged(_selected.toList());
  }

  void _removeEquipment(String title) {
    setState(() {
      _selected.remove(title);
    });
    widget.onChanged(_selected.toList());
  }

  @override
  Widget build(BuildContext context) {
    final predefinedTitles = _appliances.map((a) => a['title']).toSet();
    final customEquipment = _selected.where((s) => !predefinedTitles.contains(s)).toList();
    final bool isOtherSelected = _selected.contains('Other');

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s in your kitchen?',
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
            'Select your equipment',
            style: TextStyle(
              fontSize: 13.sp,
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
          
          if (isOtherSelected) ...[
            SizedBox(height: 24.h),
            Text(
              'Specify other equipment',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF7B8190),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: _othersController,
                focusNode: _othersFocusNode,
                onSubmitted: (_) => _addCustomEquipment(),
                textCapitalization: TextCapitalization.words,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 14.sp,
                  color: const Color(0xFF1A1A1A),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter equipment and press Enter',
                  hintStyle: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 14.sp,
                    color: Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_rounded, color: Color(0xFFC83A2D)),
                    onPressed: _addCustomEquipment,
                  ),
                ),
              ),
            ),
            if (customEquipment.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: customEquipment.map((e) => Chip(
                  label: Text(e, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: const Color(0xFFC83A2D),
                  deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
                  onDeleted: () => _removeEquipment(e),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                )).toList(),
              ),
            ],
          ],

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 120.h),
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
            if (app['title'] == 'Other') {
              // Expand field but don't focus automatically
            }
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
            if (app['icon']!.isNotEmpty)
              SvgPicture.asset(
                'assets/icones/${app['icon']}',
                height: 28.sp,
                width: 28.sp,
                placeholderBuilder: (context) => SizedBox(
                  height: 28.sp,
                  width: 28.sp,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Icon(Icons.add_circle_outline, size: 28.sp, color: isSelected ? const Color(0xFFC83A2D) : const Color(0xFF9CA3AF)),
            SizedBox(height: 8.h),
            Text(
              app['title']!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 13.sp,
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
