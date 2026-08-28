import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../services/revenuecat_service.dart';
import '../../../widgets/red_button.dart';

class TrialStep extends StatefulWidget {
  final Function(String plan) onPlanSelected;
  final VoidCallback onSkip;
  final bool showTrialBadge;

  const TrialStep({
    super.key,
    required this.onPlanSelected,
    required this.onSkip,
    this.showTrialBadge = true,
  });

  @override
  State<TrialStep> createState() => _TrialStepState();
}

class _TrialStepState extends State<TrialStep> with SingleTickerProviderStateMixin {
  String _selectedPlan = 'yearly';
  String _monthlyPrice = '\$9.99 /mo';
  String _yearlyPrice = '\$2.49 /mo';

  late AnimationController _controller;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _card1Opacity;
  late Animation<double> _card1Scale;
  late Animation<double> _card2Opacity;
  late Animation<double> _card2Scale;

  @override
  void initState() {
    super.initState();
    _loadPrices();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200));

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic)));

    _card1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.5, curve: Curves.easeOut)));
    _card1Scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8, curve: Curves.easeOut)));

    _card2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.6, curve: Curves.easeOut)));
    _card2Scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.9, curve: Curves.easeOut)));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadPrices() async {
    final offerings = await RevenueCatService.instance.getOfferings();
    if (mounted && offerings?.current != null) {
      final current = offerings!.current!;
      setState(() {
        if (current.monthly != null) {
          _monthlyPrice = '${current.monthly!.storeProduct.priceString} /mo';
        }
        if (current.annual != null) {
          final annualPrice = current.annual!.storeProduct.price;
          final monthlyPrice = annualPrice / 12;
          final currencySymbol = current.annual!.storeProduct.priceString.replaceAll(RegExp(r'[\d.,\s]'), '');
          _yearlyPrice = '$currencySymbol${monthlyPrice.toStringAsFixed(2)} /mo';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          children: [
            // 1. Top Flexible Image Area with Top & Bottom White Fades
            Expanded(
              child: FadeTransition(
                opacity: _titleOpacity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/onboarding/step27.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFF1F5F9),
                          alignment: Alignment.center,
                          child: const Icon(Icons.fastfood, color: Color(0xFFCBD5E1))))),
                    // Top White Fade
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 40.h,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white,
                              Color(0x00FFFFFF),
                            ])))),
                    // Bottom White Fade
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 50.h,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.white,
                              Color(0x00FFFFFF),
                            ])))),
                  ]))),

            // 2. Lower Content Area (Title, Subtitle, Plan Cards, No Payment Text, Button)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  // Title & Subtitle
                  FadeTransition(
                    opacity: _titleOpacity,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: Column(
                        children: [
                          Text(
                            'Unlock your full\npersonalized cooking system.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rubik(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF111827),
                              height: 1.15)),
                          SizedBox(height: 6.h),
                          Text(
                            'Built around your goals, schedule, and taste.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: const Color(0xFF111827),
                              height: 1.3)),
                        ]))),
                  SizedBox(height: 16.h),

                  // Subscription Options
                  Row(
                    children: [
                      Expanded(
                        child: FadeTransition(
                          opacity: _card1Opacity,
                          child: Transform.scale(
                            scale: _card1Scale.value,
                            child: _buildPlanCard(
                              id: 'monthly',
                              title: 'Monthly',
                              price: _monthlyPrice,
                              isSelected: _selectedPlan == 'monthly')))),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: FadeTransition(
                          opacity: _card2Opacity,
                          child: Transform.scale(
                            scale: _card2Scale.value,
                            child: _buildPlanCard(
                              id: 'yearly',
                              title: 'Yearly',
                              price: _yearlyPrice,
                              isSelected: _selectedPlan == 'yearly',
                              badge: widget.showTrialBadge ? '3 days free' : null)))),
                    ]),
                  SizedBox(height: 14.h),

                  // No payment due today (clickable only in dev/debug mode)
                  GestureDetector(
                    onTap: kDebugMode
                        ? () {
                            HapticFeedback.selectionClick();
                            widget.onSkip();
                          }
                        : null,
                    child: Text(
                      'No payment due today',
                      style: GoogleFonts.rubik(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFC31E26)))),
                  SizedBox(height: 10.h),

                  // Red Button & Subscription Terms
                  SafeArea(
                    top: false,
                    bottom: true,
                    child: Column(
                      children: [
                        RedButton(
                          label: _selectedPlan == 'yearly' ? 'Try for Free' : 'Subscribe Now',
                          color: const Color(0xFFC31E26),
                          onTap: () => widget.onPlanSelected(_selectedPlan),
                          height: 52.h,
                          fontSize: 16.sp),
                        SizedBox(height: 8.h),
                        Text(
                          _selectedPlan == 'yearly'
                              ? '3 days free, then \$29.99/year. Cancel anytime.'
                              : 'Billed immediately at $_monthlyPrice. Cancel anytime.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: const Color(0xFF111827))),
                        SizedBox(height: 14.h),
                      ])),
                ])),
          ]);
      });
  }

  Widget _buildPlanCard({
    required String id,
    required String title,
    required String price,
    required bool isSelected,
    String? badge,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPlan = id);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFC31E26)
                    : Colors.transparent,
                width: 1.5)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: const Color(0xFF111827))),
                      SizedBox(height: 4.h),
                      FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          price,
                          style: GoogleFonts.rubik(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF111827)))),
                    ])),
                SizedBox(width: 6.w),
                isSelected
                    ? Container(
                        width: 20.r,
                        height: 20.r,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFC31E26)),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12.sp))
                    : Container(
                        width: 20.r,
                        height: 20.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 1.5))),
              ])),
          if (badge != null)
            Positioned(
              top: -10.h,
              right: 12.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFC31E26),
                  borderRadius: BorderRadius.circular(50.r)),
                child: Text(
                  badge,
                  style: GoogleFonts.rubik(fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)))),
        ]));
  }
}
