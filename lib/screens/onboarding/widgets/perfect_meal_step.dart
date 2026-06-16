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
                              'Perfect meal for you',
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
                    SizedBox(height: 40.h),

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
                                'assets/images/step28.png',
                                width: 300.w,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 300.h,
                                  width: 300.w,
                                  color: Colors.grey[200],
                                  alignment: Alignment.center,
                                  child: const Text('assets/images/step28.png missing'),
                                ),
                              ),
                            ),
                          ),
                          
                          // The mockup implies the tags are part of the image or positioned around it.
                          // We'll leave the image to handle the lines if any, and overlay tags if needed.
                          // But if the tags are part of the image in step28.png, maybe we don't need these?
                          // Let's assume we need to render the tags.
                          
                          // Left Top: Uses your ingredients
                          Positioned(
                            top: 40.h,
                            left: -20.w,
                            child: Transform.scale(
                              scale: _tag1Scale.value,
                              child: _buildFloatingTag(
                                icon: Icons.energy_savings_leaf_outlined,
                                text: 'Uses your\ningredients',
                                color: const Color(0xFFD1FAE5), // Light green
                                iconColor: const Color(0xFF059669),
                              ),
                            ),
                          ),

                          // Right Top: High protein
                          Positioned(
                            top: 60.h,
                            right: -20.w,
                            child: Transform.scale(
                              scale: _tag2Scale.value,
                              child: _buildFloatingTag(
                                icon: Icons.fitness_center,
                                text: 'High protein',
                                color: const Color(0xFFDBEAFE), // Light blue
                                iconColor: const Color(0xFF2563EB),
                              ),
                            ),
                          ),

                          // Left Bottom: 20 min
                          Positioned(
                            bottom: 60.h,
                            left: -10.w,
                            child: Transform.scale(
                              scale: _tag3Scale.value,
                              child: _buildFloatingTag(
                                icon: Icons.access_time,
                                text: '20 min',
                                color: const Color(0xFFFEF3C7), // Light yellow
                                iconColor: const Color(0xFFD97706),
                              ),
                            ),
                          ),

                          // Right Bottom: Budget-friendly
                          Positioned(
                            bottom: 40.h,
                            right: -20.w,
                            child: Transform.scale(
                              scale: _tag1Scale.value, // Reusing animation
                              child: _buildFloatingTag(
                                icon: Icons.local_offer_outlined,
                                text: 'Budget-friendly',
                                color: const Color(0xFFFCE7F3), // Light pink
                                iconColor: const Color(0xFFDB2777),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 60.h),

                    // Bottom info and chips
                    FadeTransition(
                      opacity: _bottomOpacity,
                      child: SlideTransition(
                        position: _bottomSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                              clipBehavior: Clip.none,
                              child: Row(
                                children: [
                                  _buildReasonChip(Icons.thumb_up_outlined, 'Matches your taste'),
                                  SizedBox(width: 12.w),
                                  _buildReasonChip(Icons.bolt, 'Quick dinner'),
                                  SizedBox(width: 12.w),
                                  _buildReasonChip(Icons.inventory_2_outlined, 'Uses your ingredients'),
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

  Widget _buildFloatingTag({required IconData icon, required String text, required Color color, required Color iconColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 14.sp),
          ),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B1C1C),
              fontFamily: 'SF Pro',
              height: 1.1,
            ),
          ),
        ],
      ),
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
