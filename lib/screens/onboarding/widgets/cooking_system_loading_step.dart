import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/red_button.dart';

class CookingSystemLoadingStep extends StatefulWidget {
  final VoidCallback onContinue;

  const CookingSystemLoadingStep({super.key, required this.onContinue});

  @override
  State<CookingSystemLoadingStep> createState() => _CookingSystemLoadingStepState();
}

class _CookingSystemLoadingStepState extends State<CookingSystemLoadingStep> with TickerProviderStateMixin {
  int _currentLoadingStep = 0; // 0 to 3 for the 4 steps, 4 means all done
  Timer? _timer;
  
  late AnimationController _rotationController;

  final List<String> _loadingTasks = [
    'Understanding your cooking challenges',
    'Calculating your potential savings',
    'Understanding your dietary preferences',
    'Learning your cuisine preferences',
  ];

  @override
  void initState() {
    super.initState();
    
    // Slight static rotation or slow animation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // 10s max for 4 steps => 2.5s per step
    _timer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      if (_currentLoadingStep < 4) {
        setState(() {
          _currentLoadingStep++;
        });
      }
      if (_currentLoadingStep >= 4) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rotationController.dispose();
    super.dispose();
  }

  Widget _buildTaskItem(int index, String text) {
    int state = 0;
    if (_currentLoadingStep > index) {
      state = 2; // done
    } else if (_currentLoadingStep == index) {
      state = 1; // loading
    }

    Widget leading;
    if (state == 2) {
      leading = Container(
        width: 24.w,
        height: 24.w,
        decoration: const BoxDecoration(
          color: Color(0xFFC83A2D),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check, color: Colors.white, size: 16.sp),
      );
    } else if (state == 1) {
      leading = SizedBox(
        width: 24.w,
        height: 24.w,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC83A2D)),
          backgroundColor: const Color(0xFFE5E7EB),
        ),
      );
    } else {
      leading = Container(
        width: 24.w,
        height: 24.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF9CA3AF), width: 1.5),
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24.w,
            child: Column(
              children: [
                leading,
                if (index < _loadingTasks.length - 1)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Container(
                        width: 2.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(1.r),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 2.h,
                bottom: index < _loadingTasks.length - 1 ? 24.h : 0,
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: state == 0 ? const Color(0xFF6B7280) : const Color(0xFF111827),
                  fontFamily: 'SF Pro',
                  fontWeight: state > 0 ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF111827),
                        fontFamily: 'Larken',
                        height: 1.149,
                      ),
                      children: const [
                        TextSpan(text: 'Let\'s build your\ncooking '),
                        TextSpan(
                          text: 'profile.',
                          style: TextStyle(color: Color(0xFFC83A2D)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'The more we learn, the better your\nrecommendations.',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF4B5563),
                      fontFamily: 'SF Pro',
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: List.generate(
                  _loadingTasks.length,
                  (index) => _buildTaskItem(index, _loadingTasks[index]),
                ),
              ),
            ),
          ],
        ),

        Positioned(
          right: 20.w,
          bottom: 60.h,
          child: Transform.rotate(
            angle: -1 * (3.14159 / 180),
            child: Image.asset(
              'assets/onboarding/step9.png',
              width: 400.w,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 300.w,
                height: 300.h,
                color: Colors.transparent,
                child: Center(child: Text('step9.png missing')),
              ),
            ),
          ),
        ),

        if (_currentLoadingStep >= 4)
          Positioned(
            left: 24.w,
            right: 24.w,
            bottom: 20.h,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: SafeArea(
                top: false,
                child: RedButton(
                  label: 'Start \u2192',
                  onTap: widget.onContinue,
                  height: 55.h,
                  fontSize: 18.sp,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
