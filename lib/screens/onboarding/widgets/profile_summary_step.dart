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

class _ProfileSummaryStepState extends State<ProfileSummaryStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _topOpacity;

  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;

  late Animation<double> _chipsOpacity;
  late Animation<Offset> _chipsSlide;

  late Animation<double> _listOpacity;
  late Animation<Offset> _listSlide;

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
          curve: Interval(start, end, curve: Curves.easeOut),
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
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    }

    _topOpacity = createOpacity(0.0, 0.3);

    _titleOpacity = createOpacity(0.1, 0.4);
    _titleSlide = createSlide(0.1, 0.4);

    _chipsOpacity = createOpacity(0.2, 0.5);
    _chipsSlide = createSlide(0.2, 0.5);

    _listOpacity = createOpacity(0.3, 0.6);
    _listSlide = createSlide(0.3, 0.6);

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    // Title
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Text(
                          'Your personalized\nplan is ready.',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 34.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0D1B3E),
                            fontFamily: 'SF Pro',
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Subtitle
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Text(
                          'Built around your goals, taste, schedule, and savings.',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0xFF4B5563),
                            fontFamily: 'SF Pro',
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Big Number
                    FadeTransition(
                      opacity: _topOpacity,
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              '1,847',
                              style: TextStyle(
                                fontSize: 60.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF059669), // Green
                                fontFamily: 'SF Pro',
                                height: 1.0,
                                letterSpacing: -2.0,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'recipes curated for your taste',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF1B1C1C),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'SF Pro',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Images Row
                    FadeTransition(
                      opacity: _chipsOpacity,
                      child: SlideTransition(
                        position: _chipsSlide,
                        child: SizedBox(
                          height: 140.h,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            clipBehavior: Clip.none,
                            children: [
                              _buildImageCard(
                                'assets/images/step23_1.png',
                                0.8,
                              ),
                              SizedBox(width: 12.w),
                              _buildImageCard(
                                'assets/images/step23_2.png',
                                1.0,
                              ), // Center fully visible
                              SizedBox(width: 12.w),
                              _buildImageCard(
                                'assets/images/step23_3.png',
                                0.8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // 4 Grid Cards
                    FadeTransition(
                      opacity: _listOpacity,
                      child: SlideTransition(
                        position: _listSlide,
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                          childAspectRatio: 2.2, // Tweak this for height
                          children: [
                            _buildInfoCard(
                              Icons.savings_outlined,
                              'Save \$2,496 /\nyear',
                            ),
                            _buildInfoCard(
                              Icons.access_time,
                              'Save 180+\nhour / year',
                            ),
                            _buildInfoCard(
                              Icons.restaurant_menu,
                              '1,847 recipes\nmatched',
                            ),
                            _buildInfoCard(
                              Icons.eco_outlined,
                              'Healthier meals,\nmade easy',
                            ),
                          ],
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
                        child: Text(
                          'Unlock',
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
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageCard(String path, double opacity) {
    return Container(
      width: 140.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: const Color(0xFFF3F4F6),
        image: DecorationImage(
          image: AssetImage(path),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(1 - opacity),
            BlendMode.lighten,
          ),
          onError: (e, s) => null, // Fallback silently
        ),
        boxShadow: [
          if (opacity == 1.0)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: const Color(0xFFC83A2D).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFC83A2D), size: 16.sp),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B1C1C),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
