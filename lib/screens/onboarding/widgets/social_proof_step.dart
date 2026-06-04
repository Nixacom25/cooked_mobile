import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

class _SocialProofStepState extends State<SocialProofStep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  late Animation<double> _scoreOpacity;
  late Animation<Offset> _scoreSlide;

  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _subtitleSlide;

  late Animation<double> _chipsOpacity;
  late Animation<Offset> _chipsSlide;

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
        CurvedAnimation(parent: _controller, curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut)),
      );
    }

    Animation<Offset> createSlide(double start, double end) {
      return Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutCubic)),
      );
    }

    _scoreOpacity = createOpacity(0.0, 0.3);
    _scoreSlide = createSlide(0.0, 0.3);

    _subtitleOpacity = createOpacity(0.1, 0.4);
    _subtitleSlide = createSlide(0.1, 0.4);

    _chipsOpacity = createOpacity(0.2, 0.5);
    _chipsSlide = createSlide(0.2, 0.5);

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
                padding: EdgeInsets.only(top: 30.h, bottom: 10.h, left: 20.w, right: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 4.9 Score
                    FadeTransition(
                      opacity: _scoreOpacity,
                      child: SlideTransition(
                        position: _scoreSlide,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFFC83A2D),
                                    const Color(0xFFC83A2D).withValues(alpha: 0.39),
                                  ],
                                ).createShader(bounds);
                              },
                              child: Text(
                                '4.9',
                                style: TextStyle(
                                  fontSize: 85.sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  fontFamily: 'Outfit',
                                  height: 1.0,
                                  letterSpacing: -2.0,
                                ),
                              ),
                            ),
                            
                            // Stars
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 0.w),
                                  child: Icon(Icons.star, color: const Color(0xFFFFB800), size: 28.sp),
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
                            fontSize: 25.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF171717),
                            fontFamily: 'Outfit',
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Cuisine Chips
                    FadeTransition(
                      opacity: _chipsOpacity,
                      child: SlideTransition(
                        position: _chipsSlide,
                        child: Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          alignment: WrapAlignment.center,
                          children: widget.favoriteCuisines.take(3).map((item) => _buildChip(item)).toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Review Cards
                    FadeTransition(
                      opacity: _reviewOpacities[0],
                      child: SlideTransition(
                        position: _reviewSlides[0],
                        child: _buildReviewCard(
                          img: 'assets/images/sarah.png',
                          name: 'Sarah M.',
                          initials: 'SM',
                          quote: '"Cooked helped me stop\nordering dinner every night."',
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
                          quote: '"I finally use the groceries I\nalready have."',
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
                          quote: '"Meal ideas feel personalized\ninstead of random."',
                        ),
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
                            Icon(Icons.arrow_forward, color: Colors.white, size: 20.sp),
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
      }
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6D6), // Light amber/yellow
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          color: const Color(0xFF262626), // Dark amber/brown
          fontWeight: FontWeight.w600,
          fontFamily: 'SF Pro',
        ),
      ),
    );
  }

  Widget _buildReviewCard({required String img, required String name, required String initials, required String quote}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: const Color(0xFFFBE8D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundImage: AssetImage(img),
            backgroundColor: Colors.transparent,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quote,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1B1C1C),
                    fontFamily: 'SF Pro',
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8.h),
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
