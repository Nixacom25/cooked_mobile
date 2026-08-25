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
    'Mushrooms', 'Grapefruit',
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
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "What foods don’t\nyou like?",
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
                  "We’ll keep them out of your\nrecommendations",
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF475569),
                    fontFamily: 'SF Pro',
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 24.h),

                // Predefined Suggestions Grid (Wrap)
                Wrap(
                  spacing: 8.w,
                  runSpacing: 10.h,
                  children: _suggestions.map((s) {
                    final isSelected = _selectedDislikes.contains(s);
                    return GestureDetector(
                      onTap: () => _toggleSuggestion(s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFC31E26) : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFFC31E26) : const Color(0xFF0F172A),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Rubik',
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 28.h),

                // Cream Banner Token (#FAF4E5)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF4E5),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Text(
                    "More preferences can be updated later in Settings.",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'SF Pro',
                      color: const Color(0xFF0F172A),
                      height: 1.35,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
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
}
