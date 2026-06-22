import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileSummaryStep extends StatefulWidget {
  final List<String> favoriteCuisines;
  final List<String> flavorDna;
  final int recipeCount;
  final int totalSavings;
  final List<String> goals;
  final VoidCallback onContinue;

  const ProfileSummaryStep({
    super.key,
    required this.favoriteCuisines,
    required this.flavorDna,
    required this.recipeCount,
    required this.totalSavings,
    required this.goals,
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

  late PageController _pageController;
  Timer? _carouselTimer;

  final List<String> _recipeImages = [
    'assets/images/plat1.png',
    'assets/images/plat2.png',
    'assets/images/plat3.png',
    'assets/images/plat4.png',
    'assets/images/plat5.png',
    'assets/images/plat6.png',
    'assets/images/plat7.png',
    'assets/images/plat8.png',
    'assets/images/plat9.png',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pageController = PageController(viewportFraction: 0.45, initialPage: 1);
    _carouselTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page?.round() ?? 0) + 1;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });

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

  String get _cuisineText {
    if (widget.favoriteCuisines.isEmpty) {
      return '10,000+\nrecipes waiting';
    } else if (widget.favoriteCuisines.length == 1) {
      return '500+ ${widget.favoriteCuisines.first}\nrecipes waiting';
    } else if (widget.favoriteCuisines.length == 2) {
      return '${widget.favoriteCuisines[0]} • ${widget.favoriteCuisines[1]}\n+ more';
    } else {
      return '${widget.favoriteCuisines[0]} • ${widget.favoriteCuisines[1]}\n+ ${widget.favoriteCuisines.length - 2} more';
    }
  }

  String get _goalText {
    if (widget.goals.contains('eat_healthier')) return 'Healthy recipes\nmatched to your goals';
    if (widget.goals.contains('lose_weight')) return 'Calorie-conscious\nmeals';
    if (widget.goals.contains('gain_muscle')) return 'High-protein\nmeal plans';
    if (widget.goals.contains('save_money')) return 'Budget-friendly\nrecipes';
    if (widget.goals.contains('waste_less')) return 'Recipes built around\nyour ingredients';
    return 'Personalized meals\nmade easy';
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 30.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    FadeTransition(
                                      opacity: _titleOpacity,
                                      child: SlideTransition(
                                        position: _titleSlide,
                                        child: Text(
                                          'Your personal cooking\nsystem is ready.',
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
                                          'Built around your goals, taste, schedule, and budget.',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: const Color(0xFF4B5563),
                                            fontFamily: 'SF Pro',
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.h),

                                    // Big Number
                                    FadeTransition(
                                      opacity: _topOpacity,
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Text(
                                              '${widget.recipeCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                              style: TextStyle(
                                                fontSize: 60.sp,
                                                fontWeight: FontWeight.w900,
                                                color: const Color(
                                                  0xFF00C40A,
                                                ), // Green
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
                                  ],
                                ),
                              ),

                              // Images PageView
                              FadeTransition(
                                opacity: _chipsOpacity,
                                child: SlideTransition(
                                  position: _chipsSlide,
                                  child: SizedBox(
                                    height: 160.h,
                                    child: PageView.builder(
                                      controller: _pageController,
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final imageIndex =
                                            index % _recipeImages.length;
                                        return AnimatedBuilder(
                                          animation: _pageController,
                                          builder: (context, child) {
                                            double value = 0.0;
                                            if (_pageController
                                                .position
                                                .haveDimensions) {
                                              value =
                                                  _pageController.page! - index;
                                            } else {
                                              value = (1 - index).toDouble();
                                            }

                                            value = value.clamp(-1.0, 1.0);
                                            final double scale =
                                                (1 - (value.abs() * 0.15))
                                                    .clamp(0.0, 1.0);
                                            final double opacity =
                                                (1 - (value.abs() * 0.2)).clamp(
                                                  0.0,
                                                  1.0,
                                                );

                                            return Transform.scale(
                                              scale: scale,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8.w,
                                                ),
                                                child: _buildImageCard(
                                                  _recipeImages[imageIndex],
                                                  opacity,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              const Spacer(),
                              SizedBox(height: 30.h),

                              // 4 Grid Cards
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: FadeTransition(
                                  opacity: _listOpacity,
                                  child: SlideTransition(
                                    position: _listSlide,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildInfoCard(
                                                Icons.savings_outlined,
                                                'Save \$${widget.totalSavings.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} /\nyear',
                                              ),
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: _buildInfoCard(
                                                Icons.access_time,
                                                'Save 180+\nhours / year',
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12.h),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildInfoCard(
                                                Icons.eco_outlined,
                                                _goalText,
                                              ),
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: _buildInfoCard(
                                                Icons.restaurant_menu,
                                                _cuisineText,
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
                    ),
                  );
                },
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
    final double blurSigma = ((1 - opacity) * 30.0).clamp(0.0, 10.0);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          if (opacity == 1.0)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          fit: StackFit.loose,
          children: [
            Image.asset(
              path,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            if (blurSigma > 0)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
          ],
        ),
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
