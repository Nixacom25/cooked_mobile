import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PerfectMealStep extends StatefulWidget {
  final VoidCallback onStartCooking;
  final VoidCallback onViewMore;

  const PerfectMealStep({
    super.key,
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

  late Animation<double> _tag1Scale;
  late Animation<double> _tag2Scale;
  late Animation<double> _tag3Scale;

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

    _tag1Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.6, curve: Curves.elasticOut)),
    );
    _tag2Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.7, curve: Curves.elasticOut)),
    );
    _tag3Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.8, curve: Curves.elasticOut)),
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
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Subtitle
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Perfect meal to get\nstarted.',
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0D1B3E),
                                fontFamily: 'SF Pro',
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 12.h),
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
                    SizedBox(height: 30.h),

                    // Center Image with floating tags
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Main Image
                          FadeTransition(
                            opacity: _imageOpacity,
                            child: Transform.scale(
                              scale: _imageScale.value,
                              child: Image.asset(
                                'assets/images/step35.png',
                                width: 250.w,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          
                          // Floating Tag 1: 20 min
                          Positioned(
                            top: 40.h,
                            left: -10.w,
                            child: Transform.scale(
                              scale: _tag1Scale.value,
                              child: _buildFloatingTag(
                                icon: Icons.access_time,
                                text: '20 min',
                                color: const Color(0xFF86B971), // Green
                              ),
                            ),
                          ),

                          // Floating Tag 2: High Protein
                          Positioned(
                            top: 100.h,
                            right: -30.w,
                            child: Transform.scale(
                              scale: _tag2Scale.value,
                              child: _buildFloatingTag(
                                text: 'High Protein',
                                color: const Color(0xFF5A8DD4), // Blue
                              ),
                            ),
                          ),

                          // Floating Tag 3: Uses your ingredients
                          Positioned(
                            bottom: 30.h,
                            left: -20.w,
                            child: Transform.scale(
                              scale: _tag3Scale.value,
                              child: _buildFloatingTag(
                                icon: Icons.shopping_bag_outlined,
                                text: 'Uses your\ningredients',
                                color: const Color(0xFF86B971), // Green
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // Bottom info and chips
                    FadeTransition(
                      opacity: _bottomOpacity,
                      child: SlideTransition(
                        position: _bottomSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Insight Box
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF9EB), // Light yellow
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: const Color(0xFFFDE6B0), width: 1.w),
                              ),
                              child: Row(
                                children: [
                                  Text('💡', style: TextStyle(fontSize: 24.sp)),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: const Color(0xFF4B5563),
                                          fontFamily: 'SF Pro',
                                          height: 1.3,
                                        ),
                                        children: [
                                          const TextSpan(text: 'Great for your '),
                                          TextSpan(
                                            text: 'high-protein',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFFC83A2D),
                                            ),
                                          ),
                                          const TextSpan(text: ' quick\ndinner goals.'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 32.h),

                            // Why We Picked This Section
                            Text(
                              'WHY WE PICKED THIS',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: const Color(0xFF7B8190),
                                fontFamily: 'SF Pro',
                              ),
                            ),
                            SizedBox(height: 16.h),

                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildReasonChip('👍', 'Matches your taste'),
                                  SizedBox(width: 12.w),
                                  _buildReasonChip('⚡', 'Quick dinner'),
                                  SizedBox(width: 12.w),
                                  _buildReasonChip('📦', 'Uses your ingredients'),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions Area
            FadeTransition(
              opacity: _bottomOpacity,
              child: SlideTransition(
                position: _bottomSlide,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 20.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
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
                        SizedBox(height: 16.h),
                        GestureDetector(
                          onTap: widget.onViewMore,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'View More Recipes',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF7B8190),
                                  fontFamily: 'SF Pro',
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(Icons.arrow_forward, color: const Color(0xFF7B8190), size: 16.sp),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildFloatingTag({IconData? icon, required String text, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 14.sp),
            SizedBox(width: 6.w),
          ],
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'SF Pro',
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonChip(String emoji, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EB), // Light yellow
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: const Color(0xFFFDE6B0), width: 1.w),
      ),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 16.sp)),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4B5563),
              fontFamily: 'SF Pro',
            ),
          ),
        ],
      ),
    );
  }
}
