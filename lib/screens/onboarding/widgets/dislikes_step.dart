import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../widgets/red_button.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ios_toast.dart';

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
  bool _showCustomInput = false;

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

  void _handleContinue() {
    // Remove "Other" from selection if it's still there (placeholder)
    _selectedDislikes.remove('Other');
    
    if (_selectedDislikes.isEmpty) {
      HapticFeedback.heavyImpact();
      IosToast.show(
        context,
        message: 'Please select at least one food dislike',
        type: ToastType.warning);
      return;
    }
    widget.onContinue!();
  }

  void _addCustomDislike() {
    final text = _customController.text.trim();
    if (text.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        // Remove "Other" and replace with the specific food
        _selectedDislikes.remove('Other');
        if (!_suggestions.contains(text)) {
          _suggestions.insert(0, text);
        }
        _selectedDislikes.add(text);
        _showCustomInput = false;
      });
      _customController.clear();
      widget.onChanged(_selectedDislikes);
    } else {
      // If text is empty, just close the input field and remove "Other" (placeholder)
      setState(() {
        _showCustomInput = false;
        _selectedDislikes.remove('Other');
      });
      widget.onChanged(_selectedDislikes);
    }
  }

  void _toggleCustomInput() {
    HapticFeedback.selectionClick();
    setState(() {
      _showCustomInput = !_showCustomInput;
      // When "Other" is selected, automatically add it to selected dislikes
      if (_showCustomInput) {
        _selectedDislikes.add('Other');
        // Add "Other" to suggestions if not already there
        if (!_suggestions.contains('Other')) {
          _suggestions.insert(0, 'Other');
        }
      } else {
        _selectedDislikes.remove('Other');
      }
    });
    widget.onChanged(_selectedDislikes);
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
                    color: context.colors.textPrimary,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "We’ll keep them out of your\nrecommendations",
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    color: context.colors.textPrimary,
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
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: context.colors.border,
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
                          color: context.colors.accent,
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
                              color: context.colors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Type a food you dislike (e.g. Pork, Mayo)...',
                              hintStyle: GoogleFonts.rubik(
                                fontSize: 14.sp,
                                color: context.colors.textMuted,
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
                            decoration: BoxDecoration(
                              color: context.colors.accent,
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
                          color: context.colors.pageBackground,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected
                                ? context.colors.accent
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          s,
                          style: GoogleFonts.rubik(
                            color: isSelected
                                ? context.colors.accent
                                : context.colors.textPrimary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Other button for onboarding (not profile)
                if (!widget.isFromProfile && widget.onContinue != null) ...[
                  SizedBox(height: 12.h),
                  GestureDetector(
                    onTap: _toggleCustomInput,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: _showCustomInput 
                            ? context.colors.accent 
                            : context.colors.pageBackground,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: _showCustomInput
                              ? context.colors.accent
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Other',
                            style: GoogleFonts.rubik(
                              color: _showCustomInput
                                  ? Colors.white
                                  : context.colors.textPrimary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(
                            _showCustomInput ? Icons.close : Icons.add,
                            size: 16.sp,
                            color: _showCustomInput
                                ? Colors.white
                                : context.colors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Custom input field (shown when Other is clicked in onboarding)
                if (_showCustomInput && !widget.isFromProfile && widget.onContinue != null) ...[
                  SizedBox(height: 12.h),
                  Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: context.colors.border,
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
                          color: context.colors.accent,
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
                              color: context.colors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Type a food you dislike (e.g. Pork, Mayo)...',
                              hintStyle: GoogleFonts.rubik(
                                fontSize: 14.sp,
                                color: context.colors.textMuted,
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
                            decoration: BoxDecoration(
                              color: context.colors.accent,
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
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(
                      "More preferences can be updated later in Settings.",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: context.colors.textPrimary,
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
                color: context.colors.accent,
                onTap: _handleContinue,
                height: 52.h,
                fontSize: 16.sp,
              ),
            ),
          ),
      ],
    );
  }
}
