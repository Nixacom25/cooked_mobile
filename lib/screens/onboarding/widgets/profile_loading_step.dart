import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


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
      duration: const Duration(seconds: 4), // slightly longer to enjoy the image
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
    return Column(
      children: [
        SizedBox(height: 60.h),
        // The image from assets
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Center(
              child: Image.asset(
                'assets/images/step28.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        // The title text
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            'Building your personalized cooking profile${'.' * _dotCount}',
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
        SizedBox(height: 16.h),
        // The subtitle
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            'Cooked will use your cuisines, dislikes, and flavor preferences to recommend recipes that feel made for you.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
              height: 1.4,
            ),
          ),
        ),
        SizedBox(height: 60.h),
      ],
    );
  }
}
