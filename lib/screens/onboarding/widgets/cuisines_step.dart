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
    {'id': 'thai', 'title': 'Thai'},
    {'id': 'middle-eastern', 'title': 'Middle Eastern'},
    {'id': 'west-african', 'title': 'West African'},
    {'id': 'east-african', 'title': 'East African'},
    {'id': 'caribbean', 'title': 'Caribbean'},
    {'id': 'indian', 'title': 'Indian'},
    {'id': 'spanish', 'title': 'Spanish'},
    {'id': 'greek', 'title': 'Greek'},
    {'id': 'french', 'title': 'French'},
    {'id': 'korean', 'title': 'Korean'},
    {'id': 'mediterranean', 'title': 'Mediterranean'},
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
      final items = text.split(',').map((s) => s.trim().toTitleCase()).where((s) => s.isNotEmpty);
      for (var item in items) {
        if (!_selected.contains(item) && _selected.length < 12) {
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
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What cuisines do\nyou love?',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    fontFamily: 'Rubik',
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Pick your favorites. The more you choose, the\nbetter your recommendations',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF475569),
                    fontFamily: 'SF Pro',
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 24.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.82,
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
                      fontFamily: 'Rubik',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: TextField(
                      controller: _othersController,
                      focusNode: _othersFocusNode,
                      onSubmitted: (_) => _addCustomCuisine(),
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 14.sp,
                        color: const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a cuisine...',
                        hintStyle: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 14.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        suffixIcon: Padding(
                          padding: EdgeInsets.all(6.r),
                          child: GestureDetector(
                            onTap: _addCustomCuisine,
                            child: Container(
                              width: 36.w,
                              height: 36.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFFC31E26),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
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
                        label: Text(c, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp)),
                        backgroundColor: const Color(0xFFC31E26),
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
            padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
            child: SafeArea(
              top: false,
              bottom: true,
              child: RedButton(
                label: 'Continue',
                color: const Color(0xFFC31E26),
                onTap: widget.onContinue!,
                height: 52.h,
                fontSize: 16.sp,
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
        decoration: BoxDecoration(
          color: const Color(0xFFFAF4E5),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xFFC31E26) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                child: Image.asset(
                  'assets/cuisine/${cuisine['id']}.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/cuisine/others.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFF1F5F9),
                          child: Icon(
                            Icons.restaurant_menu,
                            color: const Color(0xFFCBD5E1),
                            size: 32.sp,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF4E5),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(14.r)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      cuisine['title']!,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? const Color(0xFFC31E26) : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected) ...[
                    SizedBox(width: 4.w),
                    Container(
                      width: 18.r,
                      height: 18.r,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFC31E26),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 11.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}