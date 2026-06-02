import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileSummaryStep extends StatefulWidget {
  final List<String> favoriteCuisines;
  final List<String> flavorDna;
  final int recipeCount;
  final VoidCallback onContinue;

  const ProfileSummaryStep({
    super.key,
    required this.favoriteCuisines,
    required this.flavorDna,
    required this.recipeCount,
    required this.onContinue,
  });

  @override
  State<ProfileSummaryStep> createState() => _ProfileSummaryStepState();
}

class _ProfileSummaryStepState extends State<ProfileSummaryStep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _topOpacity;
  late Animation<double> _topScale;

  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;

  late Animation<double> _chipsOpacity;
  late Animation<Offset> _chipsSlide;

  late Animation<double> _listOpacity;
  late Animation<Offset> _listSlide;

  late Animation<double> _infoOpacity;
  late Animation<Offset> _infoSlide;

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
        CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOut)),
      );
    }

    Animation<Offset> createSlide(double start, double end) {
      return Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOutCubic)),
      );
    }

    _topOpacity = createOpacity(0.0, 0.3);
    _topScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.elasticOut)),
    );

    _titleOpacity = createOpacity(0.1, 0.4);
    _titleSlide = createSlide(0.1, 0.4);

    _chipsOpacity = createOpacity(0.2, 0.5);
    _chipsSlide = createSlide(0.2, 0.5);

    _listOpacity = createOpacity(0.3, 0.6);
    _listSlide = createSlide(0.3, 0.6);

    _infoOpacity = createOpacity(0.4, 0.7);
    _infoSlide = createSlide(0.4, 0.7);

    _buttonOpacity = createOpacity(0.5, 0.8);
    _buttonSlide = createSlide(0.5, 0.8);

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
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Ready Chip & Checkmark
                    FadeTransition(
                      opacity: _topOpacity,
                      child: Transform.scale(
                        scale: _topScale.value,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50.r),
                                border: Border.all(color: const Color(0xFFEEEEEE)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome, size: 16.sp, color: const Color(0xFFC83A2D)),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'PROFILE READY',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF111827),
                                      fontFamily: 'SF Pro',
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Container(
                              width: 80.r,
                              height: 80.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFC83A2D).withOpacity(0.05),
                              ),
                              child: Center(
                                child: Container(
                                  width: 50.r,
                                  height: 50.r,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFC83A2D),
                                  ),
                                  child: Icon(Icons.check, color: Colors.white, size: 30.sp),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Title
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Text(
                          'Your personalized cooking\nsystem is ready.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0D1B3E),
                            fontFamily: 'SF Pro',
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

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

                    // Big List Card
                    FadeTransition(
                      opacity: _listOpacity,
                      child: SlideTransition(
                        position: _listSlide,
                        child: Container(
                          padding: EdgeInsets.all(20.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: const Color(0xFFEEEEEE)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildListItem(
                                icon: Icons.restaurant,
                                text: '1,847 recipes curated for your taste',
                              ),
                              _buildDivider(),
                              _buildListItem(
                                icon: Icons.public,
                                text: '800+ recipes matching your cuisines',
                              ),
                              _buildDivider(),
                              _buildListItem(
                                icon: Icons.access_time_filled,
                                text: 'Quick meals matched to your schedule',
                              ),
                              _buildDivider(),
                              _buildListItem(
                                icon: Icons.savings,
                                text: 'Estimated savings up to \$180/month',
                              ),
                              _buildDivider(),
                              _buildListItem(
                                icon: Icons.delete_outline,
                                text: 'Grocery waste reduction suggestions ready',
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Info Box
                    FadeTransition(
                      opacity: _infoOpacity,
                      child: SlideTransition(
                        position: _infoSlide,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB), // Light yellow
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('💡', style: TextStyle(fontSize: 16.sp)),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontFamily: 'SF Pro',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF374151),
                                      height: 1.4,
                                    ),
                                    children: [
                                      const TextSpan(text: 'Based on your habits, '),
                                      TextSpan(
                                        text: 'Cooked ',
                                        style: TextStyle(fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
                                      ),
                                      const TextSpan(text: 'could help reduce takeout spending by up to '),
                                      TextSpan(
                                        text: '\$180/month.',
                                        style: TextStyle(fontWeight: FontWeight.w700, color: const Color(0xFF059669)), // Green
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
                    SizedBox(height: 30.h),
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
                    padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 20.h),
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
                              'Reveal Full Profile',
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

  Widget _buildListItem({required IconData icon, required String text, bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: const Color(0xFFC83A2D), size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111827),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Divider(
        color: const Color(0xFFF3F4F6),
        height: 1.h,
        thickness: 1.h,
      ),
    );
  }
}
