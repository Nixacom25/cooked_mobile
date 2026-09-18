import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../widgets/red_button.dart';
import '../../../core/theme/app_theme.dart';

class CostingMoreStep extends StatefulWidget {
  final VoidCallback onContinue;

  const CostingMoreStep({super.key, required this.onContinue});

  @override
  State<CostingMoreStep> createState() => _CostingMoreStepState();
}

class _CostingMoreStepState extends State<CostingMoreStep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _subtitleSlide;
  
  late Animation<double> _chartOpacity;
  late Animation<double> _chartScale;
  
  late Animation<double> _cardOpacity;
  late Animation<Offset> _cardSlide;
  
  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900));

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic)));

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)));
    _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic)));

    _chartOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.7, curve: Curves.easeOut)));
    _chartScale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic)));

    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8, curve: Curves.easeOut)));
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic)));

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8, curve: Curves.easeOut)));
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic)));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDottedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.maxWidth;
        const dashWidth = 4.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: context.colors.border)));
          }));
      });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Subtitle Header
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _titleOpacity,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          style: GoogleFonts.rubik(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textPrimary,
                            height: 1.2,
                            letterSpacing: -0.3),
                          children: [
                            TextSpan(text: 'And it’s '),
                            TextSpan(
                              text: 'costing\n',
                              style: TextStyle(color: context.colors.accent)),
                            TextSpan(text: 'more than '),
                            TextSpan(
                              text: 'time',
                              style: TextStyle(color: context.colors.accent)),
                          ])))),
                  SizedBox(height: 8.h),
                  FadeTransition(
                    opacity: _subtitleOpacity,
                    child: SlideTransition(
                      position: _subtitleSlide,
                      child: Text(
                        'Small decisions become\nexpensive habits',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w400,
                          height: 1.35)))),
                ])),

            SizedBox(height: 16.h),

            // Comparison Chart Container
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: FadeTransition(
                  opacity: _chartOpacity,
                  child: Transform.scale(
                    scale: _chartScale.value,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: context.colors.pageBackground,
                          width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 4)),
                        ]),
                      child: Stack(
                        children: [
                          // Y-Axis Labels + Horizontal Dotted Grid Lines
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (final label in [
                                '\$2,500',
                                '\$2,000',
                                '\$1,500',
                                '\$1,000',
                                '\$500',
                                '\$0'
                              ])
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 42.w,
                                      child: Text(
                                        label,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.sp,
                                          color: context.colors.textMuted,
                                          fontWeight: FontWeight.w500))),
                                    Expanded(child: _buildDottedLine()),
                                  ]),
                            ]),

                          // Bars Overlay
                          Padding(
                            padding: EdgeInsets.only(left: 48.w, right: 12.w, bottom: 4.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Takeout Bar (Red)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Top Stat Label
                                    Column(
                                      children: [
                                        Text(
                                          '\$2,080',
                                          style: GoogleFonts.rubik(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w500,
                                            color: context.colors.accent,
                                            height: 1.1)),
                                        Text(
                                          '/year',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.sp,
                                            color: context.colors.textPrimary)),
                                      ]),
                                    SizedBox(height: 6.h),
                                    // Red Bar Body
                                    Container(
                                      width: 100.w,
                                      height: 165.h,
                                      padding: EdgeInsets.all(10.w),
                                      decoration: BoxDecoration(
                                        color: context.colors.accent,
                                        borderRadius: BorderRadius.circular(16.r)),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 28.r,
                                            height: 28.r,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white),
                                            child: Padding(
                                              padding: EdgeInsets.all(6.r),
                                              child: SvgPicture.asset(
                                                'assets/icones/recipe.svg',
                                                colorFilter: ColorFilter.mode(context.colors.accent, BlendMode.srcIn),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          Text(
                                            'Takeout',
                                            style: GoogleFonts.rubik(fontSize: 13.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white)),
                                          SizedBox(height: 2.h),
                                          Text(
                                            '3 Meals / Week',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white.withValues(alpha: 0.9))),
                                        ])),
                                  ]),

                                // Home Cooked Bar (Light Grey)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Top Stat Label
                                    Column(
                                      children: [
                                        Text(
                                          '\$540',
                                          style: GoogleFonts.rubik(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w500,
                                            color: context.colors.textPrimary,
                                            height: 1.1)),
                                        Text(
                                          '/year',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.sp,
                                            color: context.colors.textPrimary)),
                                      ]),
                                    SizedBox(height: 6.h),
                                    // Grey Bar Body
                                    Container(
                                      width: 100.w,
                                      height: 85.h,
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: context.colors.pageBackground,
                                        borderRadius: BorderRadius.circular(16.r)),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 26.r,
                                            height: 26.r,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: context.colors.textSecondary),
                                            child: Padding(
                                              padding: EdgeInsets.all(5.r),
                                              child: SvgPicture.asset(
                                                'assets/icones/home.svg',
                                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            'Home Cooked',
                                            style: GoogleFonts.rubik(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: context.colors.textPrimary)),
                                          Text(
                                            'Made at home',
                                            style: GoogleFonts.poppins(
                                              fontSize: 9.sp,
                                              fontWeight: FontWeight.w400,
                                              color: context.colors.textPrimary)),
                                        ])),
                                  ]),
                              ])),
                        ])))))),

            SizedBox(height: 14.h),

            // Banner Highlight Below Chart
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: FadeTransition(
                opacity: _cardOpacity,
                child: SlideTransition(
                  position: _cardSlide,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: context.colors.pageBackground,
                      borderRadius: BorderRadius.circular(16.r)),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icones/nearly.svg',
                          width: 32.r,
                          height: 32.r,
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.rubik(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    color: context.colors.textPrimary),
                                  children: [
                                    TextSpan(text: 'That is nearly '),
                                    TextSpan(
                                      text: '4x',
                                      style: TextStyle(
                                        color: context.colors.accent,
                                        fontWeight: FontWeight.w500)),
                                    TextSpan(text: ' more'),
                                  ])),
                              SizedBox(height: 2.h),
                              Text(
                                'Than cooking at home',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: context.colors.textPrimary,
                                  fontWeight: FontWeight.w400)),
                            ])),
                      ]))))),

            // Footer Continue Button
            FadeTransition(
              opacity: _buttonOpacity,
              child: SlideTransition(
                position: _buttonSlide,
                child: SafeArea(
                  top: false,
                  bottom: true,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 20.h),
                    child: RedButton(
                      label: 'Continue',
                      color: context.colors.accent,
                      onTap: widget.onContinue,
                      height: 52.h,
                      fontSize: 16.sp))))),
          ]);
      });
  }
}
