import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PerfectMealStep extends StatefulWidget {
  final List<String> favoriteCuisines;
  final List<String> goals;
  final String cookingTime;
  final VoidCallback onStartCooking;
  final VoidCallback onViewMore;

  const PerfectMealStep({
    super.key,
    required this.favoriteCuisines,
    required this.goals,
    required this.cookingTime,
    required this.onStartCooking,
    required this.onViewMore,
  });

  @override
  State<PerfectMealStep> createState() => _PerfectMealStepState();
}

class _PerfectMealStepState extends State<PerfectMealStep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  
  late Animation<double> _imageScale;
  late Animation<double> _imageOpacity;

  late Animation<double> _bottomOpacity;
  late Animation<Offset> _bottomSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic)),
    );

    _imageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
    );
    _imageScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic)),
    );

    _bottomOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.9, curve: Curves.easeOut)),
    );
    _bottomSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.9, curve: Curves.easeOutCubic)),
    );

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
        final reasons = [
          {'text': 'Matches your taste', 'icon': Icons.thumb_up_alt_outlined},
          {'text': 'Quick dinner', 'icon': Icons.bolt_rounded},
          {'text': 'Uses your ingredients', 'icon': Icons.kitchen_outlined},
        ];

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title & Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: FadeTransition(
                  opacity: _titleOpacity,
                  child: SlideTransition(
                    position: _titleSlide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Perfect meal for you',
                          style: TextStyle(
                            fontSize: 34.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF0D1B3E),
                            fontFamily: 'Larken',
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Based on your goals, taste, and cooking',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0xFF4B5563),
                            fontFamily: 'SF Pro',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Image in the center takes the available space (Edge-to-Edge)
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _imageOpacity,
                    child: Transform.scale(
                      scale: _imageScale.value,
                      child: Image.asset(
                        'assets/onboarding/step28.png',
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: const Text('assets/onboarding/step28.png missing'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 16.h),

              // Bottom info and chips (Why We Picked This)
              FadeTransition(
                opacity: _bottomOpacity,
                child: SlideTransition(
                  position: _bottomSlide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Why We Picked This Section Header
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Text(
                          'WHY WE PICKED THIS',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: const Color(0xFF7B8190),
                            fontFamily: 'SF Pro',
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Horizontal Scrollable Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        clipBehavior: Clip.none,
                        child: Row(
                          children: reasons.map((r) {
                            return Padding(
                              padding: EdgeInsets.only(right: 12.w),
                              child: _buildReasonChip(r['icon'] as IconData, r['text'] as String),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24.h),

              // Bottom Actions Area
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: FadeTransition(
                  opacity: _bottomOpacity,
                  child: SlideTransition(
                    position: _bottomSlide,
                    child: SizedBox(
                      width: double.infinity,
                      height: 55.h,
                      child: ElevatedButton(
                        onPressed: widget.onStartCooking,
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
                            Icon(Icons.restaurant, color: Colors.white, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'Start Cooking',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
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

  Widget _buildReasonChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EB), // Light yellow bg from mockup
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: const Color(0xFFFDE6B0), width: 1.w),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC83A2D), size: 18.sp),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B1C1C),
              fontFamily: 'SF Pro',
            ),
          ),
        ],
      ),
    );
  }
}
