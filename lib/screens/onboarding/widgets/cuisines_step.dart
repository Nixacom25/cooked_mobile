import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/string_extensions.dart';
import 'package:flutter/services.dart';

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
    {'id': 'indian', 'title': 'Indian'},
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

  void _addCustomCuisine() {
    HapticFeedback.selectionClick();
    final text = _othersController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      // Split by comma in case they pasted multiple
      final items = text.split(',').map((s) => s.trim().toTitleCase()).where((s) => s.isNotEmpty);
      for (var item in items) {
        if (!_selected.contains(item) && _selected.length < 10) { // Limit to 10 total
          _selected.add(item);
        }
      }
      _othersController.clear();
    });
    widget.onChanged(_selected.toList());
  }

  void _removeCuisine(String title) {
    HapticFeedback.selectionClick();
    setState(() {
      _selected.remove(title);
    });
    widget.onChanged(_selected.toList());
  }

  @override
  Widget build(BuildContext context) {
    final predefinedTitles = _cuisines.map((c) => c['title']).toSet();
    final customCuisines = _selected.where((s) => !predefinedTitles.contains(s)).toList();

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
            'Select your favorites',
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
          
          SizedBox(height: 24.h),
          Text(
            'Specify other cuisines',
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
              onSubmitted: (_) => _addCustomCuisine(),
              textCapitalization: TextCapitalization.words,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 14.sp,
                color: const Color(0xFF1A1A1A),
              ),
              decoration: InputDecoration(
                hintText: 'Enter a cuisine and press Enter',
                hintStyle: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 14.sp,
                  color: Colors.grey[400],
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_rounded, color: Color(0xFFC83A2D)),
                  onPressed: _addCustomCuisine,
                ),
              ),
            ),
          ),
          if (customCuisines.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: customCuisines.map((c) => Chip(
                label: Text(c, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: const Color(0xFFC83A2D),
                deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
                onDeleted: () => _removeCuisine(c),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              )).toList(),
            ),
          ],
          
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 120.h),
        ],
      ),
    );
  }

  Widget _buildCuisineCard(Map<String, String> cuisine) {
    final bool isSelected = _selected.contains(cuisine['title']);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          if (isSelected) {
            _selected.remove(cuisine['title']);
          } else {
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
