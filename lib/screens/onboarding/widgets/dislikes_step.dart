import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../widgets/red_button.dart';

class DislikesStep extends StatefulWidget {
  final Set<String> initialSelected;
  final Function(Set<String> selected) onChanged;
  final VoidCallback? onContinue;

  const DislikesStep({
    super.key,
    required this.initialSelected,
    required this.onChanged,
    this.onContinue,
  });

  @override
  State<DislikesStep> createState() => _DislikesStepState();
}

class _DislikesStepState extends State<DislikesStep> {
  late Set<String> _selectedDislikes;

  final List<String> _suggestions = [
    'Liver', 'Anchovies', 'Black licorice',
    'Brussels sprouts', 'Blue cheese',
    'Oysters', 'Sardines', 'Olives', 'Beets',
    'Cottage cheese', 'Okra', 'Spam',
    'Tofu', 'Turnips', 'Kimchi', 'Eggplant',
    'Cauliflower', 'Cilantro', 'Lima beans',
    'Pickled herring', 'Sauerkraut',
    'Goat cheese', 'Bitter melon',
    'Mushrooms', 'Grape fruit',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDislikes = Set.from(widget.initialSelected);
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
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "What foods don't\nyou like?",
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF111827),
                    fontFamily: 'Larken',
                    height: 1.149,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "We'll keep them out of your\nrecommendations.",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF4B5563),
                    fontFamily: 'SF Pro',
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 30.h),

                // Predefined Suggestions Grid (Wrap)
                Wrap(
                  spacing: 8.w,
                  runSpacing: 12.h,
                  children: _suggestions.map((s) {
                    final isSelected = _selectedDislikes.contains(s);
                    return GestureDetector(
                      onTap: () => _toggleSuggestion(s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
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
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            fontFamily: 'SF Pro',
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 32.h),

                // Yellow Banner
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2C94C),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "More preferences can be updated later in\nSettings.",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'SF Pro',
                      color: const Color(0xFF111827), // Dark brown/black text
                      height: 1.4,
                    ),
                  ),
                ),
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
}
