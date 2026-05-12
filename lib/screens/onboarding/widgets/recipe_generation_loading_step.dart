import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../services/user_service.dart';
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
  bool _isNavigating = false;

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
      duration: const Duration(seconds: 15), // Longer slow progress
    );

    _progressAnimation = Tween<double>(begin: 0, end: 90).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() {});
      });

    _controller.forward();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_isNavigating) return;
      try {
        final user = await UserService.instance.getCurrentUser();
        if (user['suggestionsReady'] == true) {
          timer.cancel();
          _onSuggestionsReady();
        }
      } catch (e) {
        debugPrint('Polling error: $e');
      }
    });
  }

  Future<void> _onSuggestionsReady() async {
    if (_isNavigating) return;

    // Speed up progress to 100%
    _progressAnimation = Tween<double>(
      begin: _progressAnimation.value,
      end: 100,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.duration = const Duration(milliseconds: 800);
    _controller.forward(from: 0);

    // Prefetch data
    try {
      await Future.wait([
        RecipeService.instance.getHomeSuggestions(forceRefresh: true),
        RecipeService.instance.getMyRecipes(forceRefresh: true),
        CookbookService.instance.getMyCookbooks(forceRefresh: true),
      ]);

      final suggestions = RecipeService.instance.homeSuggestionsNotifier.value;
      if (suggestions != null && mounted) {
        final images = suggestions.take(6).map((r) => r.image).toList();
        for (var url in images) {
          if (url != null && url.isNotEmpty) {
            precacheImage(CachedNetworkImageProvider(url), context);
          }
        }
      }
    } catch (e) {
      debugPrint('Prefetch error: $e');
    }

    if (mounted) {
      setState(() => _isNavigating = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && widget.onComplete != null) {
          widget.onComplete!();
        }
      });
    }
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
              fontSize: 44.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Getting everything ready for you',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              height: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _progressAnimation.value >= 99 
                ? 'Redirecting to Home...'
                : 'We’re preparing your personalized recipes\nand setting up your experience',
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
              _progressAnimation.value >= 99 ? "Sync completed" : "Progress Steps",
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
            
            // Sequential checkmarks based on progress or data ready
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
                      child: isLast ? const SizedBox.shrink() : null,
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
