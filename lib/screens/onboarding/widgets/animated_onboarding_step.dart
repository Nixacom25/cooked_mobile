import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/red_button.dart';

class AnimatedOnboardingStep extends StatefulWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback onContinue;

  const AnimatedOnboardingStep({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.onContinue,
  });

  @override
  State<AnimatedOnboardingStep> createState() => _AnimatedOnboardingStepState();
}

class _AnimatedOnboardingStepState extends State<AnimatedOnboardingStep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  late Animation<double> _imageOpacity;
  late Animation<double> _imageScale;
  
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _subtitleSlide;
  
  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Swift and fluid 1s
    );

    // Image: 0ms to 400ms
    _imageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _imageScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)),
    );

    // Title: 200ms to 600ms
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic)),
    );

    // Subtitle: 300ms to 700ms (100ms after title)
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7, curve: Curves.easeOut)),
    );
    _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic)),
    );

    // Button: 400ms to 800ms (100ms after subtitle)
    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8, curve: Curves.easeOut)),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic)),
    );

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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _imageOpacity.value,
                child: Transform.scale(
                  scale: _imageScale.value,
                  child: Image.asset(
                    widget.imagePath,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 15.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _titleOpacity,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0D1B36),
                      fontFamily: 'SF Pro',
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              FadeTransition(
                opacity: _subtitleOpacity,
                child: SlideTransition(
                  position: _subtitleSlide,
                  child: Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF7B8190),
                      fontFamily: 'SF Pro',
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              FadeTransition(
                opacity: _buttonOpacity,
                child: SlideTransition(
                  position: _buttonSlide,
                  child: RedButton(
                    label: 'Continue',
                    onTap: widget.onContinue,
                    height: 55.h,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
