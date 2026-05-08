import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/recipe_service.dart';
import '../../../services/cookbook_service.dart';

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
  Timer? _pollingTimer;
  bool _isDataReady = false;
  int _retryCount = 0;
  static const int _maxRetries = 20; // ~50 seconds total polling

  final List<Map<String, String>> _steps = [
    {'icon': '🥕', 'text': 'Building your recommendations'},
    {'icon': '📊', 'text': 'Curating recipes for you'},
    {'icon': '👨‍🍳', 'text': 'Preparing your cooking tools'},
    {'icon': '🔥', 'text': 'Finalizing setup'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40), // Long duration for visual smoothness
    );

    _progressAnimation = Tween<double>(begin: 0, end: 95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInCubic),
    )..addListener(() {
        setState(() {});
      });

    _controller.forward();
    _startPolling();
  }

  void _startPolling() {
    // Immediate first check
    _checkStatus();
    
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    if (_isDataReady) return;

    try {
      final recipes = await RecipeService.instance.getMyRecipes();
      final cookbooks = await CookbookService.instance.getMyCookbooks();

      // Logic: Finalization is complete when we have 2 cookbooks and at least 8 recipes
      // (This matches the Backend's UserInitializationServiceImpl logic)
      if (cookbooks.length >= 2 && recipes.length >= 8) {
        _isDataReady = true;
        _finishLoading();
      } else {
        _retryCount++;
        // If we exceeded max retries, or if we have at least SOME data after a while, proceed
        if (_retryCount >= _maxRetries && (recipes.isNotEmpty || cookbooks.isNotEmpty)) {
          _isDataReady = true;
          _finishLoading();
        }
      }
    } catch (e) {
      _retryCount++;
      if (_retryCount >= _maxRetries) {
        _isDataReady = true;
        _finishLoading();
      }
    }
  }

  void _finishLoading() {
    _pollingTimer?.cancel();
    _controller.stop();
    
    // Animate the rest of the bar quickly
    final currentProgress = _progressAnimation.value;
    _controller.duration = const Duration(milliseconds: 1000);
    _progressAnimation = Tween<double>(begin: currentProgress, end: 100).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    )..addListener(() {
        setState(() {});
      });
    
    _controller.forward(from: 0).then((_) {
      if (mounted && widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
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
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              letterSpacing: -1.0,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Getting everything ready for you',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              height: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _isDataReady 
                ? 'Redirecting to Home...'
                : 'We’re preparing your personalized recipes\nand setting up your experience',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
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
          SizedBox(height: 48.h),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _isDataReady ? "Sync completed" : "Progress Steps",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A1A),
                fontFamily: 'SF Pro',
              ),
            ),
          ),
          SizedBox(height: 24.h),

          ..._steps.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, String> step = entry.value;
            
            // Sequential checkmarks based on progress or data ready
            bool isLast = index == _steps.length - 1;
            bool isActive;
            if (isLast) {
              isActive = _isDataReady;
            } else {
              isActive = _progressAnimation.value >= ((index + 1) * 20) || _isDataReady;
            }

            return Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Row(
                children: [
                  Text(step['icon']!, style: TextStyle(fontSize: 15.sp)),
                  SizedBox(width: 10.w),
                  Text(
                    step['text']!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
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
                      child: isLast ? Padding(
                        padding: EdgeInsets.all(4.r),
                        child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE5E7EB)),
                      ) : null,
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
