import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/red_button.dart';

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
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
        begin: const Offset(0, 0.15),
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
                          'Your personalized\nplan is ready.',
                          textAlign: TextAlign.left,
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
                    SizedBox(height: 10.h),

                    // Subtitle
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Text(
                          'Built around your goals, taste,\nschedule, and savings',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: const Color(0xFF475569),
                            fontFamily: 'SF Pro',
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Big Green Stat Number
                    FadeTransition(
                      opacity: _topOpacity,
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              '1,847',
                              style: TextStyle(
                                fontSize: 52.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF10B981),
                                fontFamily: 'Rubik',
                                height: 1.0,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'recipes curated for your taste',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'SF Pro',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Images Carousel
                    FadeTransition(
                      opacity: _chipsOpacity,
                      child: SlideTransition(
                        position: _chipsSlide,
                        child: SizedBox(
                          height: 150.h,
                          child: PageView.builder(
                            controller: _pageController,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final imageIndex = index % _recipeImages.length;
                              return AnimatedBuilder(
                                animation: _pageController,
                                builder: (context, child) {
                                  double value = 0.0;
                                  if (_pageController.position.haveDimensions) {
                                    value = _pageController.page! - index;
                                  } else {
                                    value = (1 - index).toDouble();
                                  }

                                  value = value.clamp(-1.0, 1.0);
                                  final double scale = (1 - (value.abs() * 0.15)).clamp(0.0, 1.0);
                                  final double opacity = (1 - (value.abs() * 0.2)).clamp(0.0, 1.0);

                                  return Transform.scale(
                                    scale: scale,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6.w),
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
                    SizedBox(height: 24.h),

                    // 2x2 Grid Badge Cards
                    FadeTransition(
                      opacity: _listOpacity,
                      child: SlideTransition(
                        position: _listSlide,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildBadgeCard(
                                    icon: Icons.account_balance_wallet_outlined,
                                    title: 'Save \$2,496/\nyear',
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: _buildBadgeCard(
                                    icon: Icons.access_time,
                                    title: 'Save 180+ hours/\nyear',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildBadgeCard(
                                    icon: Icons.soup_kitchen_outlined,
                                    title: '1,847 recipes\nmatched',
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: _buildBadgeCard(
                                    icon: Icons.auto_awesome_outlined,
                                    title: 'Healthier meals,\nmade easy',
                                  ),
                                ),
                              ],
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
                      label: 'Unlock',
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

  Widget _buildImageCard(String path, double opacity) {
    final double blurSigma = ((1 - opacity) * 30.0).clamp(0.0, 10.0);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              path,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFF1F5F9),
                child: const Icon(Icons.fastfood, color: Color(0xFFCBD5E1)),
              ),
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

  Widget _buildBadgeCard({
    required IconData icon,
    required String title,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFFC31E26),
            size: 22.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
