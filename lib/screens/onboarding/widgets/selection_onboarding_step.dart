import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../widgets/red_button.dart';

class SelectionOption {
  final String id;
  final String label;
  final String? subLabel;
  final IconData? icon;
  final String? imageAsset;
  final String? svgAsset;

  SelectionOption({required this.id, required this.label, this.subLabel, this.icon, this.imageAsset, this.svgAsset});
}

class SelectionOnboardingStep extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<SelectionOption> options;
  final int maxSelections;
  final bool useGrid;
  final Widget? topCardWidget;
  final Widget? bottomCardWidget;
  final VoidCallback? onContinue;
  final ValueChanged<List<String>>? onSelectionChanged;
  final List<String> initialSelected;
  final String? exclusiveOptionId;
  final Axis gridItemDirection;
  final bool preserveSvgColor;

  const SelectionOnboardingStep({
    super.key,
    required this.title,
    this.subtitle,
    required this.options,
    this.onContinue,
    this.maxSelections = -1,
    this.useGrid = false,
    this.topCardWidget,
    this.bottomCardWidget,
    this.onSelectionChanged,
    this.initialSelected = const [],
    this.exclusiveOptionId,
    this.gridItemDirection = Axis.vertical,
    this.preserveSvgColor = false,
  });

  @override
  State<SelectionOnboardingStep> createState() => _SelectionOnboardingStepState();
}

class _SelectionOnboardingStepState extends State<SelectionOnboardingStep> with SingleTickerProviderStateMixin {
  late final List<String> _selectedIds;
  
  late AnimationController _controller;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _topCardOpacity;
  late Animation<Offset> _topCardSlide;
  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;

  // Staggered list items
  late List<Animation<double>> _itemOpacities;
  late List<Animation<Offset>> _itemSlides;

  @override
  void initState() {
    super.initState();
    _selectedIds = List<String>.from(widget.initialSelected);
    
    // Base duration for header + button
    int baseDurationMs = 600;
    // Add 50ms per item
    int totalDurationMs = baseDurationMs + (widget.options.length * 50);
    // Cap at 1500ms so it doesn't take forever for huge lists
    if (totalDurationMs > 1500) totalDurationMs = 1500;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalDurationMs),
    );

    // Header animations (Title: 0 to 400ms, Subtitle: 100 to 500ms, TopCard: 200 to 600ms)
    double timeToPct(int ms) => ms / totalDurationMs;

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(timeToPct(0), timeToPct(400), curve: Curves.easeOut)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Interval(timeToPct(0), timeToPct(400), curve: Curves.easeOutCubic)),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(timeToPct(100), timeToPct(500), curve: Curves.easeOut)),
    );
    _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Interval(timeToPct(100), timeToPct(500), curve: Curves.easeOutCubic)),
    );

    _topCardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(timeToPct(200), timeToPct(600), curve: Curves.easeOut)),
    );
    _topCardSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Interval(timeToPct(200), timeToPct(600), curve: Curves.easeOutCubic)),
    );

    // Waterfall items
    _itemOpacities = [];
    _itemSlides = [];
    int itemStartDelayMs = 200; // Start first item at 200ms
    
    for (int i = 0; i < widget.options.length; i++) {
      int startMs = itemStartDelayMs + (i * 50);
      int endMs = startMs + 400; // 400ms animation per item
      
      _itemOpacities.add(Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Interval(timeToPct(startMs), timeToPct(endMs).clamp(0.0, 1.0), curve: Curves.easeOut)),
      ));
      
      _itemSlides.add(Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Interval(timeToPct(startMs), timeToPct(endMs).clamp(0.0, 1.0), curve: Curves.easeOutCubic)),
      ));
    }

    // Button animation (End of list)
    int btnStartMs = totalDurationMs - 400;
    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(timeToPct(btnStartMs), 1.0, curve: Curves.easeOut)),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Interval(timeToPct(btnStartMs), 1.0, curve: Curves.easeOutCubic)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleOption(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        // Prevent deselecting if it's the exclusive option and it's the only one selected
        if (widget.exclusiveOptionId != null && id == widget.exclusiveOptionId && _selectedIds.length == 1) {
          return;
        }
        _selectedIds.remove(id);
        
        // If nothing is selected anymore and there is an exclusive option, auto-select it
        if (_selectedIds.isEmpty && widget.exclusiveOptionId != null) {
          _selectedIds.add(widget.exclusiveOptionId!);
        }
      } else {
        if (widget.exclusiveOptionId != null && id == widget.exclusiveOptionId) {
          // If the exclusive option is selected, clear everything else
          _selectedIds.clear();
          _selectedIds.add(id);
        } else {
          // If a normal option is selected, remove the exclusive option if it exists
          if (widget.exclusiveOptionId != null && _selectedIds.contains(widget.exclusiveOptionId)) {
            _selectedIds.remove(widget.exclusiveOptionId);
          }

          if (widget.maxSelections == 1) {
            _selectedIds.clear();
            _selectedIds.add(id);
          } else if (widget.maxSelections <= 0 || _selectedIds.length < widget.maxSelections) {
            _selectedIds.add(id);
          }
        }
      }
    });
    if (widget.onSelectionChanged != null) {
      widget.onSelectionChanged!(_selectedIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 34.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF111827),
                            fontFamily: 'Larken',
                            height: 1.149,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      SizedBox(height: 16.h),
                      FadeTransition(
                        opacity: _subtitleOpacity,
                        child: SlideTransition(
                          position: _subtitleSlide,
                          child: Text(
                            widget.subtitle!,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: const Color(0xFF4B5563),
                              fontFamily: 'SF Pro',
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (widget.topCardWidget != null) ...[
                      SizedBox(height: 24.h),
                      FadeTransition(
                        opacity: _topCardOpacity,
                        child: SlideTransition(
                          position: _topCardSlide,
                          child: widget.topCardWidget!,
                        ),
                      ),
                    ],
                    SizedBox(height: 20.h),
                    if (widget.useGrid)
                      Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: List.generate(widget.options.length, (index) {
                          final option = widget.options[index];
                          final isSelected = _selectedIds.contains(option.id);
                          final itemWidth = (MediaQuery.of(context).size.width - 48.w - 12.w) / 2;
                          return FadeTransition(
                            opacity: _itemOpacities[index],
                            child: SlideTransition(
                              position: _itemSlides[index],
                              child: GestureDetector(
                                onTap: () => _toggleOption(option.id),
                                child: Container(
                                  width: itemWidth,
                                  padding: widget.gridItemDirection == Axis.horizontal
                                      ? EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h)
                                      : EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFFD92D20) : const Color(0xFFE5E7EB),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: widget.gridItemDirection == Axis.horizontal
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if (option.imageAsset != null) ...[
                                              Image.asset(option.imageAsset!, height: 28.h, fit: BoxFit.contain),
                                              SizedBox(width: 8.w),
                                            ] else if (option.svgAsset != null) ...[
                                              SvgPicture.asset(
                                                option.svgAsset!, 
                                                height: 20.h, 
                                                width: 20.w,
                                                colorFilter: widget.preserveSvgColor ? null : ColorFilter.mode(
                                                  isSelected ? const Color(0xFFD92D20) : const Color(0xFF9CA3AF),
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                            ] else if (option.icon != null) ...[
                                              Icon(option.icon, color: isSelected ? const Color(0xFFD92D20) : const Color(0xFF9CA3AF), size: 24.sp),
                                              SizedBox(width: 8.w),
                                            ],
                                            Flexible(
                                              child: Text(
                                                option.label,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF0D1B36),
                                                  fontFamily: 'SF Pro',
                                                  height: 1.2,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if (option.imageAsset != null) ...[
                                              Padding(
                                                padding: EdgeInsets.only(bottom: 8.h),
                                                child: Image.asset(
                                                  option.imageAsset!,
                                                  height: 80.h,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ] else if (option.svgAsset != null) ...[
                                              Padding(
                                                padding: EdgeInsets.only(bottom: 8.h),
                                                child: SvgPicture.asset(
                                                  option.svgAsset!,
                                                  height: 24.h,
                                                  width: 24.w,
                                                  colorFilter: widget.preserveSvgColor ? null : ColorFilter.mode(
                                                    isSelected ? const Color(0xFFD92D20) : const Color(0xFF9CA3AF),
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                              ),
                                            ] else if (option.icon != null) ...[
                                              Icon(
                                                option.icon,
                                                color: isSelected ? const Color(0xFFD92D20) : const Color(0xFF9CA3AF),
                                                size: 20.sp,
                                              ),
                                              SizedBox(height: 8.h),
                                            ],
                                            Text(
                                              option.label,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF0D1B36),
                                                fontFamily: 'SF Pro',
                                                height: 1.2,
                                              ),
                                            ),
                                            if (option.subLabel != null) ...[
                                              SizedBox(height: 6.h),
                                              Text(
                                                option.subLabel!,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: const Color(0xFF7B8190),
                                                  fontFamily: 'SF Pro',
                                                  height: 1.2,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          );
                        }),
                      )
                    else
                      ...List.generate(widget.options.length, (index) {
                        final option = widget.options[index];
                        final isSelected = _selectedIds.contains(option.id);
                        return FadeTransition(
                          opacity: _itemOpacities[index],
                          child: SlideTransition(
                            position: _itemSlides[index],
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: GestureDetector(
                                onTap: () => _toggleOption(option.id),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFFD92D20) : const Color(0xFFE5E7EB),
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFFD92D20).withOpacity(0.1),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    children: [
                                      if (option.imageAsset != null) ...[
                                        Image.asset(option.imageAsset!, height: 24.h, fit: BoxFit.contain),
                                        SizedBox(width: 10.w),
                                      ] else if (option.svgAsset != null) ...[
                                        SvgPicture.asset(
                                          option.svgAsset!, 
                                          height: 20.h, 
                                          width: 20.w,
                                          colorFilter: widget.preserveSvgColor ? null : ColorFilter.mode(
                                            isSelected ? const Color(0xFFD92D20) : const Color(0xFF9CA3AF),
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                      ] else if (option.icon != null) ...[
                                        Icon(
                                          option.icon,
                                          color: isSelected ? const Color(0xFFD92D20) : const Color(0xFF9CA3AF),
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 10.w),
                                      ],
                                      Expanded(
                                        child: Text(
                                          option.label,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF0D1B36),
                                            fontFamily: 'SF Pro',
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: const Color(0xFFD92D20),
                                          size: 20.sp,
                                        )
                                      else
                                        Container(
                                          width: 20.sp,
                                          height: 20.sp,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFFE5E7EB),
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                );
              }
            ),
          ),
        ),
        if (widget.bottomCardWidget != null)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _buttonOpacity, // Link bottomCardWidget to button animation timing for simplicity
                child: SlideTransition(
                  position: _buttonSlide,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 10.h),
                    child: widget.bottomCardWidget!,
                  ),
                ),
              );
            }
          ),
        // Footer Button
        if (widget.onContinue != null)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _buttonOpacity,
                child: SlideTransition(
                  position: _buttonSlide,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 15.h),
                    child: RedButton(
                      label: 'Continue',
                      onTap: widget.onContinue!,
                      isDisabled: _selectedIds.isEmpty,
                      height: 55.h,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              );
            }
          ),
      ],
    );
  }
}
