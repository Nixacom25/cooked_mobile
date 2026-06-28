import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_review/in_app_review.dart';

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
      duration: const Duration(milliseconds: 1400),
    );

    Animation<double> createOpacity(double start, double end) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    }

    Animation<Offset> createSlide(double start, double end) {
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            start,
            end.clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
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
    // Wait for the entry animations to complete (1.4 seconds)
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
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.h),
                    // Big score
                    FadeTransition(
                      opacity: _scoreOpacity,
                      child: SlideTransition(
                        position: _scoreSlide,
                        child: Column(
                          children: [
                            Text(
                              '4.9',
                              style: TextStyle(
                                fontSize: 80.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF00C40A),
                                fontFamily: 'SF Pro',
                                height: 1.0,
                                letterSpacing: -2.0,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                  ),
                                  child: Icon(
                                    Icons.star,
                                    color: const Color(0xFFFFB800),
                                    size: 28.sp,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Subtitle
                    FadeTransition(
                      opacity: _subtitleOpacity,
                      child: SlideTransition(
                        position: _subtitleSlide,
                        child: Text(
                          'stars from thousands of\nfood lovers',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1B1C1C),
                            fontFamily: 'SF Pro',
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // Testimonials List
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Column(
                        children: [
                          FadeTransition(
                            opacity: _reviewOpacities[0],
                            child: SlideTransition(
                              position: _reviewSlides[0],
                              child: _buildReviewCard(
                                img: 'assets/images/sarah.png',
                                name: 'Sarah M.',
                                initials: 'SM',
                                quote:
                                    '"Cooked helped me stop\nordering dinner every night."',
                              ),
                            ),
                          ),
                          FadeTransition(
                            opacity: _reviewOpacities[1],
                            child: SlideTransition(
                              position: _reviewSlides[1],
                              child: _buildReviewCard(
                                img: 'assets/images/david.png',
                                name: 'David K.',
                                initials: 'DK',
                                quote:
                                    '"I finally use the groceries I\nalready have."',
                              ),
                            ),
                          ),
                          FadeTransition(
                            opacity: _reviewOpacities[2],
                            child: SlideTransition(
                              position: _reviewSlides[2],
                              child: _buildReviewCard(
                                img: 'assets/images/elena.png',
                                name: 'Elena R.',
                                initials: 'ER',
                                quote:
                                    '"Meal ideas feel personalized\ninstead of random."',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Button Area
            FadeTransition(
              opacity: _buttonOpacity,
              child: SlideTransition(
                position: _buttonSlide,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 0.h, 24.w, 20.h),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55.h,
                      child: ElevatedButton(
                        onPressed: widget.onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC83A2D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8.w),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReviewCard({
    required String img,
    required String name,
    required String initials,
    required String quote,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50.r,
            height: 50.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF3F4F6),
              image: DecorationImage(
                image: AssetImage(img),
                fit: BoxFit.cover,
                onError: (e, s) => null,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  quote,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1B1C1C),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '— $name',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                    fontFamily: 'SF Pro',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
