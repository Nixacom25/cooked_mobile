import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import '../referral_code_screen.dart';
import '../../../services/store_price_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../widgets/red_button.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/l10n.dart';

class TrialStep extends StatefulWidget {
  final Function(String plan) onPlanSelected;
  final VoidCallback onSkip;
  final bool showTrialBadge;
  /// Called when the user redeemed a referral/gift code (Premium unlocked,
  /// no payment needed).
  final VoidCallback? onRedeemed;
  final List<String> favoriteCuisines;

  const TrialStep({
    super.key,
    required this.onPlanSelected,
    required this.onSkip,
    this.showTrialBadge = true,
    this.onRedeemed,
    this.favoriteCuisines = const [],
  });

  @override
  State<TrialStep> createState() => _TrialStepState();
}

class _TrialStepState extends State<TrialStep> with SingleTickerProviderStateMixin {
  String _selectedPlan = 'yearly';
  // Filled from the store (never hardcoded); empty until loaded.
  String _monthlyPrice = '';
  String _yearlyPrice = '';
  StorePrices _prices = const StorePrices();
  bool _isLoading = false;

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
    await StorePriceService.instance.load();
    if (!mounted) return;
    final p = StorePriceService.instance.prices.value;
    setState(() {
      _prices = p;
      _monthlyPrice = p.monthly != null ? context.l10n.pricePerMonthShort(p.monthly!) : '';
      _yearlyPrice = p.yearlyPerMonth != null
          ? context.l10n.pricePerMonthShort(p.yearlyPerMonth!)
          : (p.yearly != null ? context.l10n.pricePerYearShort(p.yearly!) : '');
    });
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          children: [
            // 1. Top Flexible Image Area with Top & Bottom Fades (white in
            // light mode, black in dark mode so they blend into the dark
            // jpeg instead of leaving a bright white band across it)
            Expanded(
              child: FadeTransition(
                opacity: _titleOpacity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              context.colors.pageBackground.withValues(alpha: 0.3),
                              context.colors.pageBackground.withValues(alpha: 0.6),
                              context.colors.pageBackground,
                              context.colors.pageBackground.withValues(alpha: 0.6),
                              context.colors.pageBackground.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.10, 0.15, 0.25, 0.75, 0.85, 1.0]).createShader(rect);
                        },
                        blendMode: BlendMode.dstIn,
                        child: Image.asset(
                          // The jpeg is a dedicated dark-mode version of this
                          // illustration (dark backdrop, light text) - the png
                          // alone would show its own light background in dark mode.
                          isDark
                              ? 'assets/onboarding/step27.webp'
                              : 'assets/onboarding/step27_alt.webp',
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: context.colors.pageBackground,
                            alignment: Alignment.center,
                            child: Icon(Icons.fastfood, color: context.colors.border))))),
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
                            context.l10n.trialTitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rubik(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w500,
                              color: context.colors.textPrimary,
                              height: 1.15)),
                          SizedBox(height: 6.h),
                          Text(
                            context.l10n.trialSubtitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: context.colors.textPrimary,
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
                              title: context.l10n.planMonthly,
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
                              title: context.l10n.planYearly,
                              price: _yearlyPrice,
                              isSelected: _selectedPlan == 'yearly',
                              badge: widget.showTrialBadge ? context.l10n.trialThreeDaysFree : null)))),
                    ]),
                  SizedBox(height: 14.h),

                  // No payment due today (only shown in dev/debug mode)
                  if (kDebugMode)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        widget.onSkip();
                      },
                      child: Text(
                        context.l10n.trialNoPaymentToday,
                        style: GoogleFonts.rubik(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: context.colors.accent))),
                  if (kDebugMode) SizedBox(height: 10.h),

                  // Red Button & Subscription Terms
                  SafeArea(
                    top: false,
                    bottom: true,
                    child: Column(
                      children: [
                        RedButton(
                          label: _isLoading ? context.l10n.commonProcessingDots : (_selectedPlan == 'yearly' ? context.l10n.trialTryFree : context.l10n.trialSubscribeNow),
                          color: context.colors.accent,
                          onTap: _isLoading ? null : () => widget.onPlanSelected(_selectedPlan),
                          height: 52.h,
                          fontSize: 16.sp),
                        SizedBox(height: 8.h),
                        Text(
                          _selectedPlan == 'yearly'
                              ? context.l10n.commonCancelAnytime(_prices.trialThenYearly(context.l10n))
                              : (_prices.monthly != null
                                  ? context.l10n.trialMonthlyNoTrial(_prices.monthly!)
                                  : context.l10n.trialMonthlyNoTrialNoPrice),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: context.colors.textPrimary)),
                        SizedBox(height: 6.h),
                        // Friend gave you a code? Redeem it instead of paying.
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _isLoading ? null : _openReferralCode,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
                            child: Text(
                              context.l10n.trialHaveReferralCode,
                              style: GoogleFonts.rubik(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: context.colors.accent,
                                decoration: TextDecoration.underline,
                                decorationColor: context.colors.accent)),
                          ),
                        ),
                        SizedBox(height: 8.h),
                      ])),
                ])),
          ]);
      });
  }

  Future<void> _openReferralCode() async {
    HapticFeedback.selectionClick();
    final redeemed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReferralCodeScreen(favoriteCuisines: widget.favoriteCuisines),
      ),
    );
    if (redeemed == true && mounted) widget.onRedeemed?.call();
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
              color: context.colors.pageBackground,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected
                    ? context.colors.accent
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
                          color: context.colors.textPrimary)),
                      SizedBox(height: 4.h),
                      FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          price,
                          style: GoogleFonts.rubik(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textPrimary))),
                    ])),
                SizedBox(width: 6.w),
                isSelected
                    ? Container(
                        width: 20.r,
                        height: 20.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colors.accent),
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
                            color: context.colors.border,
                            width: 1.5))),
              ])),
          if (badge != null)
            Positioned(
              top: -10.h,
              right: 12.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: context.colors.accent,
                  borderRadius: BorderRadius.circular(50.r)),
                child: Text(
                  badge,
                  style: GoogleFonts.rubik(fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)))),
        ]));
  }
}
