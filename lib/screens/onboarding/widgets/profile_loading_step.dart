import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileLoadingStep extends StatefulWidget {
  final VoidCallback onComplete;

  const ProfileLoadingStep({super.key, required this.onComplete});

  @override
  State<ProfileLoadingStep> createState() => _ProfileLoadingStepState();
}

class _ProfileLoadingStepState extends State<ProfileLoadingStep>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _dotsController;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _dotsController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1500),
          )
          ..addListener(() {
            final newCount = (_dotsController.value * 4).floor() % 4;
            if (newCount != _dotCount) {
              setState(() => _dotCount = newCount);
            }
          })
          ..repeat();

    _startLoading();
  }

  Future<void> _startLoading() async {
    await _progressController.forward();
    // Keep it at 100% for a brief moment to let the user see it's complete
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) widget.onComplete();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return Container(
                width: 115.r,
                height: 115.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFC83A2D),
                    width: 1.5.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC83A2D).withOpacity(0.1),
                      blurRadius: 20.r,
                      spreadRadius: 5.r,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icones/Vector.svg',
                      height: 64.sp,
                      width: 68.sp,
                    ),
                    SizedBox(
                      width: 130.r,
                      height: 130.r,
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFC83A2D),
                        ),
                        strokeWidth: 4.w,
                        value: _progressController.value,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 48.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: Text(
                    'Building your recipe profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0D1B3E),
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ),
                SizedBox(
                  width: 20.w,
                  child: Text(
                    '.' * _dotCount,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0D1B3E),
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'This won\'t take long',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
        ],
      ),
    );
  }
}
