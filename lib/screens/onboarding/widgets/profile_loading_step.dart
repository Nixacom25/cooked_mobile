import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileLoadingStep extends StatefulWidget {
  final VoidCallback onComplete;

  const ProfileLoadingStep({super.key, required this.onComplete});

  @override
  State<ProfileLoadingStep> createState() => _ProfileLoadingStepState();
}

class _ProfileLoadingStepState extends State<ProfileLoadingStep> with TickerProviderStateMixin {
  late AnimationController _dotsController;
  int _dotCount = 0;

  int _currentTaskIndex = 0; // 0 to 4
  Timer? _tasksTimer;

  late PageController _pageController;
  Timer? _carouselTimer;

  final List<String> _loadingTasks = [
    'Learning your tastes',
    'Finding recipes you\'ll love',
    'Calculating savings',
    'Building your meal feed',
    'Personalizing recommendations',
  ];

  final List<String> _recipeImages = [
    'assets/cuisine/chinese.png',
    'assets/cuisine/mexican.png',
    'assets/cuisine/japanese.png',
    'assets/cuisine/west-african.png',
    'assets/cuisine/caribbean.png',
    'assets/cuisine/italian.png',
    'assets/cuisine/indian.png',
    'assets/cuisine/thai.png',
  ];

  @override
  void initState() {
    super.initState();

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addListener(() {
        final newCount = (_dotsController.value * 4).floor() % 4;
        if (newCount != _dotCount) {
          setState(() => _dotCount = newCount);
        }
      })..repeat();

    _pageController = PageController(viewportFraction: 0.45, initialPage: 1);

    // Carousel timer
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

    // 2.5s total, 5 tasks => 0.5s per task
    _tasksTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_currentTaskIndex < _loadingTasks.length) {
        setState(() {
          _currentTaskIndex++;
        });
      }
      if (_currentTaskIndex >= _loadingTasks.length) {
        timer.cancel();
        _startComplete();
      }
    });
  }

  Future<void> _startComplete() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) widget.onComplete();
  }

  @override
  void dispose() {
    _dotsController.dispose();
    _tasksTimer?.cancel();
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildTaskItem(int index, String text) {
    int state = 0;
    if (_currentTaskIndex > index) {
      state = 2; // done
    } else if (_currentTaskIndex == index) {
      state = 1; // loading
    }

    Widget leading;
    if (state == 2) {
      leading = Container(
        width: 22.r,
        height: 22.r,
        decoration: const BoxDecoration(
          color: Color(0xFFC31E26),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check, color: Colors.white, size: 13.sp),
      );
    } else if (state == 1) {
      leading = SizedBox(
        width: 22.r,
        height: 22.r,
        child: const CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC31E26)),
          backgroundColor: Color(0xFFE2E8F0),
        ),
      );
    } else {
      leading = Container(
        width: 22.r,
        height: 22.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading,
          SizedBox(width: 12.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 15.sp,
              color: state == 0 ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
              fontFamily: 'Rubik',
              fontWeight: state > 0 ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            "Building your\npersonalized cooking\nsystem${'.' * _dotCount}",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              fontFamily: 'Rubik',
              height: 1.15,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        SizedBox(
          height: 220.h,
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
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

                  value = value.clamp(-2.0, 2.0);

                  final double rotationZ = -value * 0.15; 
                  final double translateY = value.abs() * 30.h; 
                  final double scale = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0); 
                  final double blurSigma = (value.abs() * 6.0).clamp(0.0, 10.0);

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translate(0.0, translateY, 0.0)
                      ..rotateZ(rotationZ)
                      ..scale(scale),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: Stack(
                          fit: StackFit.loose,
                          children: [
                            Image.asset(
                              _recipeImages[imageIndex],
                              width: 150.w,
                              height: 200.h,
                              fit: BoxFit.cover,
                            ),
                            if (blurSigma > 0)
                              Positioned.fill(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                                  child: Container(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                _loadingTasks.length,
                (index) => _buildTaskItem(index, _loadingTasks[index]),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}
