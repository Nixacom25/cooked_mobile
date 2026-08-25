import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/red_button.dart';

class FreeTrialGuideStep extends StatefulWidget {
  final VoidCallback onContinue;

  const FreeTrialGuideStep({
    super.key,
    required this.onContinue,
  });

  @override
  State<FreeTrialGuideStep> createState() => _FreeTrialGuideStepState();
}

class _FreeTrialGuideStepState extends State<FreeTrialGuideStep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _containerOpacity;
  late Animation<Offset> _containerSlide;
  late List<Animation<double>> _itemOpacities;
  late List<Animation<Offset>> _itemSlides;
  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    Animation<double> createOpacity(double start, double end) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut)),
      );
    }

    Animation<Offset> createSlide(double start, double end) {
      return Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutCubic)),
      );
    }

    _titleOpacity = createOpacity(0.0, 0.3);
    _titleSlide = createSlide(0.0, 0.3);

    _containerOpacity = createOpacity(0.1, 0.4);
    _containerSlide = createSlide(0.1, 0.4);

    _itemOpacities = [];
    _itemSlides = [];
    double currentDelay = 0.2;
    for (int i = 0; i < 3; i++) {
      _itemOpacities.add(createOpacity(currentDelay, currentDelay + 0.3));
      _itemSlides.add(createSlide(currentDelay, currentDelay + 0.3));
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
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Text(
                          'Free trial guide',
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            fontFamily: 'Rubik',
                            height: 1.15,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Text(
                          'Get the most out of your Cooked trial.',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: const Color(0xFF475569),
                            fontFamily: 'SF Pro',
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Guide Container (Cards)
                    FadeTransition(
                      opacity: _containerOpacity,
                      child: SlideTransition(
                        position: _containerSlide,
                        child: Column(
                          children: [
                            FadeTransition(
                              opacity: _itemOpacities[0],
                              child: SlideTransition(
                                position: _itemSlides[0],
                                child: _buildTimelineCard(
                                  label: 'Today',
                                  icon: Icons.lock_outline_rounded,
                                  borderColor: const Color(0xFFFCA5A5),
                                  headerBgColor: const Color(0xFFFEE2E2),
                                  iconColor: const Color(0xFFDC2626),
                                  description: 'Unlock personalized recipes, meal suggestions, and ingredient scanning.',
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            FadeTransition(
                              opacity: _itemOpacities[1],
                              child: SlideTransition(
                                position: _itemSlides[1],
                                child: _buildTimelineCard(
                                  label: 'Day 2',
                                  icon: Icons.notifications_none_rounded,
                                  borderColor: const Color(0xFF7DD3FC),
                                  headerBgColor: const Color(0xFFE0F2FE),
                                  iconColor: const Color(0xFF0284C7),
                                  description: "We'll send you a reminder before your trial ends.",
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            FadeTransition(
                              opacity: _itemOpacities[2],
                              child: SlideTransition(
                                position: _itemSlides[2],
                                child: _buildTimelineCard(
                                  label: 'Day 3',
                                  icon: Icons.star_outline_rounded,
                                  borderColor: const Color(0xFFFCD34D),
                                  headerBgColor: const Color(0xFFFEF3C7),
                                  iconColor: const Color(0xFFD97706),
                                  description: "We'll send you a reminder before your trial ends.",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 36.h),

                    // Price Summary
                    FadeTransition(
                      opacity: _buttonOpacity,
                      child: SlideTransition(
                        position: _buttonSlide,
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                '3 days free, then \$29.99/year',
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Center(
                              child: Text(
                                'View other plans',
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

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
                      fontSize: 16.sp,
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

  Widget _buildTimelineCard({
    required String label,
    required IconData icon,
    required Color borderColor,
    required Color headerBgColor,
    required Color iconColor,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Badge Card
        Container(
          width: 80.w,
          height: 84.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 4.h),
                decoration: BoxDecoration(
                  color: headerBgColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                  border: Border(
                    bottom: BorderSide(
                      color: borderColor,
                      width: 1.0,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Icon(
                    icon,
                    size: 26.sp,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16.w),

        // Description Text
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0F172A),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
