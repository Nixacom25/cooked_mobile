import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/string_extensions.dart';
import 'package:flutter/services.dart';
import '../../../services/ingredient_service.dart';

class DislikesStep extends StatefulWidget {
  final Set<String> initialSelected;
  final Function(Set<String> selected) onChanged;

  const DislikesStep({
    super.key,
    required this.initialSelected,
    required this.onChanged,
  });

  @override
  State<DislikesStep> createState() => _DislikesStepState();
}

class _DislikesStepState extends State<DislikesStep> {
  late Set<String> _selectedDislikes;
  final TextEditingController _dislikeController = TextEditingController();
  final List<String> _customDislikes = [];

  final List<String> _suggestions = [
    'Onions',
    'Garlic',
    'Broccoli',
    'Eggs',
    'Chicken',
    'Cheese',
    'Brussels sprouts',
    'Seafood',
    'Anchovies',
    'Bell Peppers',
    'Tomatos',
    'Spinach',
    'Tofu',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDislikes = Set.from(widget.initialSelected);
    
    // Extract custom dislikes that aren't in suggestions
    for (var d in _selectedDislikes) {
      if (!_suggestions.contains(d)) {
        _customDislikes.add(d);
      }
    }
  }

  @override
  void dispose() {
    _dislikeController.dispose();
    super.dispose();
  }

  void _addDislike(String val) {
    HapticFeedback.selectionClick();
    final cleanVal = val.trim().toTitleCase();
    if (cleanVal.isNotEmpty) {
      setState(() {
        if (!_customDislikes.contains(cleanVal) && !_suggestions.contains(cleanVal)) {
          _customDislikes.add(cleanVal);
        }
        _selectedDislikes.add(cleanVal);
        _dislikeController.clear();
      });
      widget.onChanged(_selectedDislikes);
    }
  }

  void _removeCustomDislike(String val) {
    HapticFeedback.selectionClick();
    setState(() {
      _customDislikes.remove(val);
      _selectedDislikes.remove(val);
    });
    widget.onChanged(_selectedDislikes);
  }

  void _toggleSuggestion(String val) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedDislikes.contains(val)) {
        _selectedDislikes.remove(val);
      } else {
        _selectedDislikes.add(val);
      }
    });
    widget.onChanged(_selectedDislikes);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Any foods you dislike?',
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
            "We'll avoid these in your recipes",
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 30.h),

          // Custom Input Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                )
              ]
            ),
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                final query = textEditingValue.text.trim().toLowerCase();
                if (query.isEmpty) {
                  return const Iterable<String>.empty();
                }

                // 1. Filter local predefined suggestions
                final localMatches = _suggestions
                    .where((s) => s.toLowerCase().contains(query))
                    .toList();

                // 2. Fetch from IngredientService
                try {
                  final apiResults = await IngredientService.instance.searchIngredients(query);
                  final apiMatches = apiResults.map((e) => e['name'] as String).toList();
                  localMatches.addAll(apiMatches);
                } catch (_) {}

                return localMatches.toSet().take(6); // Remove duplicates and limit to 6
              },
              onSelected: (String selection) {
                _addDislike(selection);
                Future.delayed(const Duration(milliseconds: 50), () {
                  _dislikeController.clear();
                });
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                // Sync the external controller with the internal one for clear() access
                if (_dislikeController.text != controller.text) {
                  _dislikeController.text = controller.text;
                }
                controller.addListener(() {
                  if (_dislikeController.text != controller.text) {
                    _dislikeController.text = controller.text;
                  }
                });
                _dislikeController.addListener(() {
                  if (controller.text != _dislikeController.text) {
                    controller.text = _dislikeController.text;
                  }
                });

                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onSubmitted: (val) {
                    _addDislike(val);
                    controller.clear();
                    onFieldSubmitted();
                  },
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 14.sp,
                    color: const Color(0xFF1A1A1A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type an ingredient...',
                    hintStyle: TextStyle(
                      color: const Color(0xFFBDC3C7),
                      fontFamily: 'SF Pro',
                      fontSize: 14.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    suffixIcon: Padding(
                      padding: EdgeInsets.all(8.r),
                      child: GestureDetector(
                        onTap: () {
                          _addDislike(controller.text);
                          controller.clear();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFC83A2D),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(Icons.add_rounded, color: Colors.white, size: 24.sp),
                        ),
                      ),
                    ),
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(12.r),
                    clipBehavior: Clip.antiAlias,
                    color: Colors.white,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 250.h,
                        maxWidth: MediaQuery.of(context).size.width - 40.w,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return InkWell(
                            onTap: () => onSelected(option),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                              child: Row(
                                children: [
                                  Icon(Icons.search, size: 18.sp, color: const Color(0xFF9CA3AF)),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        fontFamily: 'SF Pro',
                                        fontSize: 14.sp,
                                        color: const Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Custom Dislikes Chips
          if (_customDislikes.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _customDislikes.map((c) => Chip(
                label: Text(c, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp, fontFamily: 'SF Pro')),
                backgroundColor: const Color(0xFFFBBF24), // Yellow
                deleteIcon: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 12, color: Color(0xFFFBBF24)),
                ),
                onDeleted: () => _removeCustomDislike(c),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  side: const BorderSide(color: Colors.transparent),
                ),
              )).toList(),
            ),
          ],

          SizedBox(height: 30.h),

          // Predefined Suggestions Grid (Wrap)
          Wrap(
            spacing: 5.w,
            runSpacing: 10.h,
            children: _suggestions.map((s) {
              final isSelected = _selectedDislikes.contains(s);
              return GestureDetector(
                onTap: () => _toggleSuggestion(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFC83A2D) : Colors.white,
                    borderRadius: BorderRadius.circular(50.r),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFC83A2D) : const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    s,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF4B5563),
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 32.h),

          // Warning Card
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F5EF),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 20.sp,
                  color: const Color(0xFFFBBF24),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    "We'll try not to include these in your recommendations",
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
          
          SizedBox(height: 100.h), // Extra space for buttons in SafeArea
        ],
      ),
    );
  }
}
