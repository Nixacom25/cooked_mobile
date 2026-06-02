import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      currentDelay += 0.2;
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
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
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
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0D1B3E),
                            fontFamily: 'SF Pro',
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // Guide Container
                    FadeTransition(
                      opacity: _containerOpacity,
                      child: SlideTransition(
                        position: _containerSlide,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: const Color(0xFFFBE8E7), width: 1.5.w),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Timeline line
                              Positioned(
                                left: 12.w, // Center of the icons
                                top: 20.h,
                                bottom: 40.h,
                                child: Container(
                                  width: 2.w,
                                  color: const Color(0xFFF3F4F6),
                                ),
                              ),
                              
                              Column(
                                children: [
                                  FadeTransition(
                                    opacity: _itemOpacities[0],
                                    child: SlideTransition(
                                      position: _itemSlides[0],
                                      child: _buildTimelineItem(
                                        icon: Icons.calendar_today_outlined,
                                        iconColor: const Color(0xFFC83A2D),
                                        dotColor: const Color(0xFFC83A2D),
                                        title: 'Today',
                                        description: 'Unlock personalized recipes, meal suggestions, and ingredient scanning.',
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 30.h),
                                  FadeTransition(
                                    opacity: _itemOpacities[1],
                                    child: SlideTransition(
                                      position: _itemSlides[1],
                                      child: _buildTimelineItem(
                                        icon: Icons.notifications_active_outlined,
                                        iconColor: const Color(0xFFC83A2D),
                                        dotColor: const Color(0xFFF4C459), // Yellow/Orange
                                        title: 'In 2 days',
                                        description: 'We\'ll send you a reminder before your trial ends.',
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 30.h),
                                  FadeTransition(
                                    opacity: _itemOpacities[2],
                                    child: SlideTransition(
                                      position: _itemSlides[2],
                                      child: _buildTimelineItem(
                                        icon: Icons.receipt_long_outlined,
                                        iconColor: const Color(0xFFC83A2D),
                                        dotColor: const Color(0xFFD1D5DB), // Grey
                                        title: 'In 3 days',
                                        description: 'Billing starts unless you cancel anytime before.',
                                        isLast: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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

  Widget _buildTimelineItem({
    required IconData icon,
    required Color iconColor,
    required Color dotColor,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Dot
        Container(
          width: 26.w,
          alignment: Alignment.topCenter,
          margin: EdgeInsets.only(top: 2.h),
          child: Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: dotColor, width: 4.w),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0D1B3E),
                    ),
                  ),
                  Icon(icon, color: iconColor, size: 22.sp),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                description,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF4B5563),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
