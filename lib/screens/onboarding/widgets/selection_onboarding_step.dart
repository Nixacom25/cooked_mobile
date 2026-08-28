import 'package:google_fonts/google_fonts.dart';
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
    this.gridItemDirection = Axis.horizontal,
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
      duration: Duration(milliseconds: totalDurationMs));

    // Header animations (Title: 0 to 400ms, Subtitle: 100 to 500ms, TopCard: 200 to 600ms)
    double timeToPct(int ms) => ms / totalDurationMs;

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(timeToPct(0), timeToPct(400), curve: Curves.easeOut)));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Interval(timeToPct(0), timeToPct(400), curve: Curves.easeOutCubic)));

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(timeToPct(100), timeToPct(500), curve: Curves.easeOut)));
    _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Interval(timeToPct(100), timeToPct(500), curve: Curves.easeOutCubic)));

    _topCardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(timeToPct(200), timeToPct(600), curve: Curves.easeOut)));
    _topCardSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Interval(timeToPct(200), timeToPct(600), curve: Curves.easeOutCubic)));

    // Waterfall items
    _itemOpacities = [];
    _itemSlides = [];
    int itemStartDelayMs = 200; // Start first item at 200ms
    
    for (int i = 0; i < widget.options.length; i++) {
      int startMs = itemStartDelayMs + (i * 50);
      int endMs = startMs + 400; // 400ms animation per item
      
      _itemOpacities.add(Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Interval(timeToPct(startMs), timeToPct(endMs).clamp(0.0, 1.0), curve: Curves.easeOut))));
      
      _itemSlides.add(Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Interval(timeToPct(startMs), timeToPct(endMs).clamp(0.0, 1.0), curve: Curves.easeOutCubic))));
    }

    // Button animation (End of list)
    int btnStartMs = totalDurationMs - 400;
    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(timeToPct(btnStartMs), 1.0, curve: Curves.easeOut)));
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Interval(timeToPct(btnStartMs), 1.0, curve: Curves.easeOutCubic)));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SelectionOnboardingStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.initialSelected, _selectedIds)) {
      setState(() {
        _selectedIds.clear();
        _selectedIds.addAll(widget.initialSelected);
      });
    }
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
      widget.onSelectionChanged!(List<String>.from(_selectedIds));
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
                    SizedBox(height: 10.h),
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Text(
                          widget.title,
                          style: GoogleFonts.rubik(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF111827),
                            height: 1.2,
                            letterSpacing: -0.3)))),
                    if (widget.subtitle != null) ...[
                      SizedBox(height: 8.h),
                      FadeTransition(
                        opacity: _subtitleOpacity,
                        child: SlideTransition(
                          position: _subtitleSlide,
                          child: Text(
                            widget.subtitle!,
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              color: const Color(0xFF111827),
                              fontWeight: FontWeight.w400,
                              height: 1.35)))),
                    ],
                    if (widget.topCardWidget != null) ...[
                      SizedBox(height: 24.h),
                      FadeTransition(
                        opacity: _topCardOpacity,
                        child: SlideTransition(
                          position: _topCardSlide,
                          child: widget.topCardWidget!)),
                    ],
                    SizedBox(height: 20.h),
                    if (widget.useGrid)
                      Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: List.generate(widget.options.length, (index) {
                          final option = widget.options[index];
                          final isSelected = _selectedIds.contains(option.id);
                          final isLastOdd = index == widget.options.length - 1 && widget.options.length % 2 != 0;
                          final itemWidth = isLastOdd 
                              ? (MediaQuery.of(context).size.width - 48.w)
                              : (MediaQuery.of(context).size.width - 48.w - 12.w) / 2;
                              
                          return FadeTransition(
                            opacity: _itemOpacities[index],
                            child: SlideTransition(
                              position: _itemSlides[index],
                              child: GestureDetector(
                                onTap: () => _toggleOption(option.id),
                                child: Container(
                                  width: itemWidth,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w, 
                                    vertical: 14.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFFC31E26) : Colors.transparent,
                                      width: 1.5)),
                                  child: widget.gridItemDirection == Axis.vertical
                                      ? Stack(
                                          children: [
                                            // Top-right selection circle indicator
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: isSelected
                                                  ? Container(
                                                      width: 20.r,
                                                      height: 20.r,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFFC31E26)),
                                                      child: Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 13.sp))
                                                  : Container(
                                                      width: 20.r,
                                                      height: 20.r,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: const Color(0xFFCBD5E1),
                                                          width: 1.5)))),
                                            // Centered Icon & Label
                                            Padding(
                                              padding: EdgeInsets.symmetric(vertical: 4.h),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: [
                                                  if (option.svgAsset != null)
                                                    SvgPicture.asset(
                                                      option.svgAsset!, 
                                                      height: 26.h, 
                                                      width: 26.w,
                                                      colorFilter: widget.preserveSvgColor ? null : ColorFilter.mode(
                                                        isSelected ? const Color(0xFFC31E26) : const Color(0xFF0F172A),
                                                        BlendMode.srcIn))
                                                  else if (option.icon != null)
                                                    Icon(
                                                      option.icon,
                                                      color: isSelected ? const Color(0xFFC31E26) : const Color(0xFF0F172A),
                                                      size: 24.sp),
                                                  SizedBox(height: 8.h),
                                                  Text(
                                                    option.label,
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.rubik(
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w500,
                                                      color: isSelected ? const Color(0xFFC31E26) : const Color(0xFF0F172A))),
                                                ])),
                                          ])
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            if (option.svgAsset != null) ...[
                                              SvgPicture.asset(
                                                option.svgAsset!, 
                                                height: 22.h, 
                                                width: 22.w,
                                                colorFilter: widget.preserveSvgColor ? null : ColorFilter.mode(
                                                  isSelected ? const Color(0xFFC31E26) : const Color(0xFF0F172A),
                                                  BlendMode.srcIn)),
                                              SizedBox(width: 10.w),
                                            ] else if (option.icon != null) ...[
                                              Icon(
                                                option.icon,
                                                color: isSelected ? const Color(0xFFC31E26) : const Color(0xFF0F172A),
                                                size: 22.sp),
                                              SizedBox(width: 10.w),
                                            ],
                                            Expanded(
                                              child: Text(
                                                option.label,
                                                textAlign: TextAlign.start,
                                                style: GoogleFonts.rubik(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: isSelected ? const Color(0xFFC31E26) : const Color(0xFF0F172A)))),
                                            if (isSelected)
                                              Container(
                                                width: 20.r,
                                                height: 20.r,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xFFC31E26)),
                                                child: Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 12.sp)),
                                          ])))));
                        }))
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
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFFC31E26) : Colors.transparent,
                                      width: 1.5)),
                                  child: Row(
                                    children: [
                                      if (option.imageAsset != null) ...[
                                        Image.asset(option.imageAsset!, height: 24.h, fit: BoxFit.contain),
                                        SizedBox(width: 14.w),
                                      ] else if (option.svgAsset != null) ...[
                                        SvgPicture.asset(
                                          option.svgAsset!, 
                                          height: 22.h, 
                                          width: 22.w,
                                          colorFilter: widget.preserveSvgColor ? null : ColorFilter.mode(
                                            isSelected ? const Color(0xFFC31E26) : const Color(0xFF0F172A),
                                            BlendMode.srcIn)),
                                        SizedBox(width: 14.w),
                                      ] else if (option.icon != null) ...[
                                        Icon(
                                          option.icon,
                                          color: isSelected ? const Color(0xFFC31E26) : const Color(0xFF0F172A),
                                          size: 22.sp),
                                        SizedBox(width: 14.w),
                                      ],
                                      Expanded(
                                        child: Text(
                                          option.label,
                                          style: GoogleFonts.rubik(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w500,
                                            color: isSelected ? const Color(0xFFC31E26) : const Color(0xFF0F172A)))),
                                      if (isSelected)
                                        (option.id == 'No Allergies'
                                            ? SizedBox(width: 22.r, height: 22.r)
                                            : Container(
                                                width: 22.r,
                                                height: 22.r,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xFFC31E26)),
                                                child: Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 14.sp)))
                                      else
                                        Container(
                                          width: 22.r,
                                          height: 22.r,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFFCBD5E1),
                                              width: 1.5))),
                                    ]))))));
                      }),
                    if (widget.bottomCardWidget != null) ...[
                      SizedBox(height: 20.h),
                      widget.bottomCardWidget!,
                    ],
                  ]);
              }
            ))),
        // Footer Button
        if (widget.onContinue != null)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _buttonOpacity,
                child: SlideTransition(
                  position: _buttonSlide,
                  child: SafeArea(
                    top: false,
                    bottom: true,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
                      child: RedButton(
                        label: 'Continue',
                        color: const Color(0xFFC31E26),
                        onTap: widget.onContinue!,
                        isDisabled: _selectedIds.isEmpty,
                        height: 52.h,
                        fontSize: 16.sp)))));
            }
          ),
      ]);
  }
}
