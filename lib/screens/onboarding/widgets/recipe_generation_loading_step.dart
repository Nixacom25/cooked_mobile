// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecipeGenerationLoadingStep extends StatefulWidget {
  final VoidCallback onContinue;
  const RecipeGenerationLoadingStep({super.key, required this.onContinue});

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
    {'icon': '⭐', 'text': 'Finding the best recipes for you'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Exactly 10 seconds for visual effect
    );

    _progressAnimation = Tween<double>(begin: 1, end: 100).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    )..addListener(() {
        setState(() {});
      });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onContinue();
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

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10.h),
                Text(
                  'Your personalized\ncooking system is\nready',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0D1B3E),
                    fontFamily: 'Outfit',
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 48.h),
                Text(
                  '${_progressAnimation.value.toInt()}%',
                  style: TextStyle(
                    fontSize: 44.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFC83A2D),
                    fontFamily: 'Outfit',
                  ),
                ),
                SizedBox(height: 20.h),

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
                    widthFactor: (_progressAnimation.value / 100).clamp(0.0, 1.0),
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
                SizedBox(height: 40.h),

                ..._steps.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, String> step = entry.value;
                  
                  // Sequential checkmarks based on progress
                  bool isLast = index == _steps.length - 1;
                  bool isActive;
                  if (isLast) {
                    isActive = _progressAnimation.value >= 99;
                  } else {
                    isActive = _progressAnimation.value >= ((index + 1) * 20) || _progressAnimation.value >= 99;
                  }

                  return Padding(
                    padding: EdgeInsets.only(bottom: 20.h),
                    child: Row(
                      children: [
                        Text(step['icon']!, style: TextStyle(fontSize: 16.sp)),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            step['text']!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A1A),
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ),
                        if (isActive)
                          Icon(
                            Icons.check_circle,
                            color: const Color(0xFFC83A2D),
                            size: 24.sp,
                          )
                        else
                          Container(
                            width: 24.sp,
                            height: 24.sp,
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
          ),
        ),

      ],
    );
  }
}
