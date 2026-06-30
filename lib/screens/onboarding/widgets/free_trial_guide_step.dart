import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
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
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0D1B3E),
                      fontFamily: 'Larken',
                      height: 1.1,
                      letterSpacing: -0.5,
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
                      fontSize: 16.sp,
                      color: const Color(0xFF7B8190),
                      fontFamily: 'SF Pro',
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 32.h),

              // Guide Container (Timeline)
              FadeTransition(
                opacity: _containerOpacity,
                child: SlideTransition(
                  position: _containerSlide,
                  child: Stack(
                    children: [
                      // Timeline line
                      Positioned(
                        left: 36.w, // Center of the cards (width 72.w)
                        top: 44.h,
                        bottom: 44.h,
                        child: Container(
                          width: 2.w,
                          color: const Color(0xFFFDE8E8), // Soft peach line
                        ),
                      ),
                      
                      Column(
                        children: [
                          FadeTransition(
                            opacity: _itemOpacities[0],
                            child: SlideTransition(
                              position: _itemSlides[0],
                              child: _buildTimelineCard(
                                label: 'Today',
                                iconPath: 'assets/icones/clock1.svg',
                                color: const Color(0xFFC83A2D), // Red
                                bgColor: const Color(0xFFFFF1F2), // Light red
                                description: 'Unlock personalized recipes, meal suggestions, and ingredient scanning.',
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          FadeTransition(
                            opacity: _itemOpacities[1],
                            child: SlideTransition(
                              position: _itemSlides[1],
                              child: _buildTimelineCard(
                                label: 'Day 2',
                                iconPath: 'assets/icones/notif.svg',
                                color: const Color(0xFF0284C7), // Blue
                                bgColor: const Color(0xFFF0F9FF), // Light blue
                                description: 'We\'ll send you a reminder before your trial ends.',
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          FadeTransition(
                            opacity: _itemOpacities[2],
                            child: SlideTransition(
                              position: _itemSlides[2],
                              child: _buildTimelineCard(
                                label: 'Day 3',
                                iconPath: 'assets/icones/star1.svg',
                                color: const Color(0xFFD97706), // Yellow
                                bgColor: const Color(0xFFFEF3C7), // Light yellow
                                description: 'Full access starts. Cancel in advance to avoid payment.',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 36.h),
              
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
                            fontFamily: 'SF Pro',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1B1C1C),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Center(
                        child: Text(
                          'View other plans',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF7B8190),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),

              // Bottom Button Area
              FadeTransition(
                opacity: _buttonOpacity,
                child: SlideTransition(
                  position: _buttonSlide,
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
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineCard({
    required String label,
    required String iconPath,
    required Color color,
    required Color bgColor,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Card Icon
        Container(
          width: 72.w,
          height: 88.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: color.withOpacity(0.5),
              width: 1.5.w,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 26.h,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
                  border: Border(
                    bottom: BorderSide(
                      color: color.withOpacity(0.3),
                      width: 1.w,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B1C1C),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SvgPicture.asset(
                    iconPath,
                    width: 24.sp,
                    height: 24.sp,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 24.w),
        
        // Content
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1B1C1C),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
