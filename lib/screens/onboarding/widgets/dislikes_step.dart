import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../widgets/red_button.dart';

class DislikesStep extends StatefulWidget {
  final Set<String> initialSelected;
  final Function(Set<String> selected) onChanged;
  final VoidCallback? onContinue;
  final bool isFromProfile;

  const DislikesStep({
    super.key,
    required this.initialSelected,
    required this.onChanged,
    this.onContinue,
    this.isFromProfile = false,
  });

  @override
  State<DislikesStep> createState() => _DislikesStepState();
}

class _DislikesStepState extends State<DislikesStep> {
  late Set<String> _selectedDislikes;
  late List<String> _suggestions;
  final TextEditingController _customController = TextEditingController();

  final List<String> _defaultSuggestions = [
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
    _suggestions = List.from(_defaultSuggestions);
    for (var d in _selectedDislikes) {
      if (!_suggestions.contains(d)) {
        _suggestions.insert(0, d);
      }
    }
  }

  @override
  void didUpdateWidget(DislikesStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelected != widget.initialSelected) {
      setState(() {
        _selectedDislikes = Set.from(widget.initialSelected);
        for (var d in _selectedDislikes) {
          if (!_suggestions.contains(d)) {
            _suggestions.insert(0, d);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
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

  void _addCustomDislike() {
    final text = _customController.text.trim();
    if (text.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        if (!_suggestions.contains(text)) {
          _suggestions.insert(0, text);
        }
        _selectedDislikes.add(text);
      });
      _customController.clear();
      widget.onChanged(_selectedDislikes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showInput = widget.isFromProfile || widget.onContinue == null;

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
                  style: GoogleFonts.rubik(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827),
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "We’ll keep them out of your\nrecommendations",
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    color: const Color(0xFF111827),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 20.h),

                // Custom Dislike Input Field (Displayed ONLY when in Profile / Settings)
                if (showInput) ...[
                  Container(
                    height: 52.h,
                    margin: EdgeInsets.only(bottom: 20.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Icon(
                          Icons.block_rounded,
                          color: const Color(0xFFC31E26),
                          size: 20.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextField(
                            controller: _customController,
                            textCapitalization: TextCapitalization.sentences,
                            style: GoogleFonts.rubik(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Type a food you dislike (e.g. Pork, Mayo)...',
                              hintStyle: GoogleFonts.rubik(
                                fontSize: 14.sp,
                                color: const Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onSubmitted: (_) => _addCustomDislike(),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: _addCustomDislike,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 32.r,
                            height: 32.r,
                            decoration: const BoxDecoration(
                              color: Color(0xFFC31E26),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

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
                            color: isSelected
                                ? const Color(0xFFC31E26)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          s,
                          style: GoogleFonts.rubik(
                            color: isSelected
                                ? const Color(0xFFC31E26)
                                : const Color(0xFF0F172A),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Cream Banner Token (#FAF4E5) - Displayed ONLY in Onboarding
                if (!widget.isFromProfile && widget.onContinue != null) ...[
                  SizedBox(height: 28.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF4E5),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(
                      "More preferences can be updated later in Settings.",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: const Color(0xFF111827),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
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
