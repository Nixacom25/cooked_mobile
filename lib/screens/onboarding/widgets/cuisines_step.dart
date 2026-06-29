import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../widgets/red_button.dart';
import 'package:flutter/services.dart';

class CuisinesStep extends StatefulWidget {
  final List<String> initialSelected;
  final Function(List<String> selected) onChanged;

  final VoidCallback? onContinue;

  const CuisinesStep({
    super.key,
    required this.initialSelected,
    required this.onChanged,
    this.onContinue,
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
    {'id': 'indian', 'title': 'Indian'},
    {'id': 'thai', 'title': 'Thai'},
    {'id': 'mediterranean', 'title': 'Mediterranean'},
    {'id': 'west-african', 'title': 'West African'},
    {'id': 'caribbean', 'title': 'Caribbean'},
    {'id': 'others', 'title': 'Others'},
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

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What cuisines do you love?',
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF111827),
                    fontFamily: 'Larken',
                    height: 1.149,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Pick your favorites. The more you choose,\nthe better your recommendations.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF4B5563),
                    fontFamily: 'SF Pro',
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 25.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _cuisines.length,
                  itemBuilder: (context, index) {
                    final cuisine = _cuisines[index];
                    return _buildCuisineCard(cuisine);
                  },
                ),
                
                if (_selected.contains('Others')) ...[
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
                        hintText: 'Type a cuisine...',
                        hintStyle: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 14.sp,
                          color: Colors.grey[400],
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                        suffixIcon: Padding(
                          padding: EdgeInsets.all(8.r),
                          child: GestureDetector(
                            onTap: _addCustomCuisine,
                            child: Container(
                              width: 36.w,
                              height: 36.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFFC83A2D),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(Icons.add_rounded, color: Colors.white, size: 24.sp),
                            ),
                          ),
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
                ],
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20.h),
              ],
            ),
          ),
        ),
        if (widget.onContinue != null)
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
            child: SafeArea(
              top: false,
              child: RedButton(
                label: 'Continue',
                onTap: widget.onContinue!,
                height: 55.h,
                fontSize: 18.sp,
              ),
            ),
          ),
      ],
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
        padding: EdgeInsets.all(1.5.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFC83A2D)
                : const Color(0xFFF3F4F6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
                child: Image.asset(
                  'assets/cuisine/${cuisine['id']}.png',
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
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                cuisine['title']!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? const Color(0xFFC83A2D) : const Color(0xFF111827),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}