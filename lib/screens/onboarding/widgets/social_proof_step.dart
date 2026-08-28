import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../../widgets/red_button.dart';

class SocialProofStep extends StatefulWidget {
  final List<String> favoriteCuisines;
  final VoidCallback onContinue;

  const SocialProofStep({
    super.key,
    required this.favoriteCuisines,
    required this.onContinue,
  });

  @override
  State<SocialProofStep> createState() => _SocialProofStepState();
}

class _SocialProofStepState extends State<SocialProofStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _scoreOpacity;
  late Animation<Offset> _scoreSlide;

  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _subtitleSlide;

  late List<Animation<double>> _reviewOpacities;
  late List<Animation<Offset>> _reviewSlides;

  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200));

    Animation<double> createOpacity(double start, double end) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut)));
    }

    Animation<Offset> createSlide(double start, double end) {
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            start,
            end.clamp(0.0, 1.0),
            curve: Curves.easeOutCubic)));
    }

    _scoreOpacity = createOpacity(0.0, 0.3);
    _scoreSlide = createSlide(0.0, 0.3);

    _subtitleOpacity = createOpacity(0.1, 0.4);
    _subtitleSlide = createSlide(0.1, 0.4);

    _reviewOpacities = [];
    _reviewSlides = [];
    double currentDelay = 0.3;
    for (int i = 0; i < 3; i++) {
      _reviewOpacities.add(createOpacity(currentDelay, currentDelay + 0.3));
      _reviewSlides.add(createSlide(currentDelay, currentDelay + 0.3));
      currentDelay += 0.15;
    }

    _buttonOpacity = createOpacity(currentDelay, currentDelay + 0.3);
    _buttonSlide = createSlide(currentDelay, currentDelay + 0.3);

    _controller.forward();
    _triggerInAppReview();
  }

  Future<void> _triggerInAppReview() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    try {
      final InAppReview inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      }
    } catch (e) {
      debugPrint('Error triggering in-app review: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10.h),
                    // Big score
                    FadeTransition(
                      opacity: _scoreOpacity,
                      child: SlideTransition(
                        position: _scoreSlide,
                        child: Column(
                          children: [
                            Text(
                              '4.9',
                              style: GoogleFonts.rubik(
                                fontSize: 64.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF10B981),
                                height: 1.0)),
                            SizedBox(height: 10.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 3.w),
                                  child: Icon(
                                    Icons.star_rounded,
                                    color: const Color(0xFFF59E0B),
                                    size: 28.sp));
                              })),
                          ]))),
                    SizedBox(height: 16.h),

                    // Subtitle
                    FadeTransition(
                      opacity: _subtitleOpacity,
                      child: SlideTransition(
                        position: _subtitleSlide,
                        child: Text(
                          'stars from thousands\nof food lovers',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rubik(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF111827),
                            height: 1.15)))),
                    SizedBox(height: 32.h),

                    // Testimonials List
                    Column(
                      children: [
                        FadeTransition(
                          opacity: _reviewOpacities[0],
                          child: SlideTransition(
                            position: _reviewSlides[0],
                            child: _buildReviewCard(
                              name: 'Sarah M.',
                              quote:
                                  '"Cooked helped me stop\nordering dinner every night."'))),
                        FadeTransition(
                          opacity: _reviewOpacities[1],
                          child: SlideTransition(
                            position: _reviewSlides[1],
                            child: _buildReviewCard(
                              name: 'David K.',
                              quote:
                                  '"I finally use the groceries I\nalready have."'))),
                        FadeTransition(
                          opacity: _reviewOpacities[2],
                          child: SlideTransition(
                            position: _reviewSlides[2],
                            child: _buildReviewCard(
                              name: 'Elena R.',
                              quote:
                                  '"Meal ideas feel personalized\ninstead of random."'))),
                      ]),
                    SizedBox(height: 20.h),
                  ]))),

            // Bottom Button Area
            FadeTransition(
              opacity: _buttonOpacity,
              child: SlideTransition(
                position: _buttonSlide,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
                  child: SafeArea(
                    top: false,
                    bottom: true,
                    child: RedButton(
                      label: 'Continue',
                      color: const Color(0xFFC31E26),
                      onTap: widget.onContinue,
                      height: 52.h,
                      fontSize: 16.sp))))),
          ]);
      });
  }

  Widget _buildReviewCard({
    required String name,
    required String quote,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20.r)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE2E8F0)),
            child: ClipOval(
              child: Icon(
                Icons.person,
                color: const Color(0xFF111827),
                size: 28.sp))),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  quote,
                  style: GoogleFonts.poppins(fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF111827),
                    height: 1.3)),
                SizedBox(height: 4.h),
                Text(
                  '— $name',
                  style: GoogleFonts.rubik(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827))),
              ])),
        ]));
  }
}
