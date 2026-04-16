import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecipeGenerationLoadingStep extends StatefulWidget {
  final VoidCallback? onComplete;
  const RecipeGenerationLoadingStep({super.key, this.onComplete});

  @override
  State<RecipeGenerationLoadingStep> createState() =>
      _RecipeGenerationLoadingStepState();
}

class _RecipeGenerationLoadingStepState
    extends State<RecipeGenerationLoadingStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  final List<Map<String, String>> _steps = [
    {'icon': '🥕', 'text': 'Analyzing your ingredients'},
    {'icon': '📊', 'text': 'Matching recipe database'},
    {'icon': '👨‍🍳', 'text': 'Generating recipe suggestions'},
    {'icon': '🔥', 'text': 'Optimizing cooking steps'},
    {'icon': '⭐️', 'text': 'Finding the best recipes for you'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _progressAnimation =
        Tween<double>(begin: 0, end: 100).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        )..addListener(() {
          setState(() {});
        });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && widget.onComplete != null) {
            widget.onComplete!();
          }
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 48.h),
          Text(
            '${_progressAnimation.value.toInt()}%',
            style: TextStyle(
              fontSize: 44.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Creating recipes from\nyour ingredients 🍳',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              height: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Analyzing ingredients and generating\npersonalized recipes...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 40.h),

          // Custom Gradient Progress Bar
          Container(
            height: 6.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(3.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progressAnimation.value / 100,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC83A2D), Color(0xFFF4C459)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 48.h),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Today's food recommendations",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
                fontFamily: 'SF Pro',
              ),
            ),
          ),
          SizedBox(height: 24.h),

          ..._steps.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, String> step = entry.value;
            // Reveal checkmarks sequentially: 18%, 36%, 54%, 72%, 90%
            bool isActive = _progressAnimation.value >= ((index + 1) * 18);

            return Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Row(
                children: [
                  Text(step['icon']!, style: TextStyle(fontSize: 15.sp)),
                  SizedBox(width: 10.w),
                  Text(
                    step['text']!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A1A),
                      fontFamily: 'SF Pro',
                    ),
                  ),
                  const Spacer(),
                  if (isActive)
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFFC83A2D),
                      size: 20.sp,
                    )
                  else
                    Container(
                      width: 20.sp,
                      height: 20.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 2.w,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
