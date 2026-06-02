import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/red_button.dart';

class ImageInfoOnboardingStep extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String imagePath;
  final String buttonLabel;
  final VoidCallback onContinue;

  const ImageInfoOnboardingStep({
    super.key,
    required this.title,
    this.subtitle,
    required this.imagePath,
    this.buttonLabel = 'Continue',
    required this.onContinue,
  });

  @override
  State<ImageInfoOnboardingStep> createState() => _ImageInfoOnboardingStepState();
}

class _ImageInfoOnboardingStepState extends State<ImageInfoOnboardingStep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _subtitleSlide;
  
  late Animation<double> _imageOpacity;
  late Animation<double> _imageScale;
  
  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Swift and fluid 1s
    );

    // Title: 0ms to 400ms
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic)),
    );

    // Subtitle: 100ms to 500ms
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
    );
    _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic)),
    );

    // Image: 200ms to 600ms
    _imageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)),
    );
    _imageScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic)),
    );

    // Button: 300ms to 700ms
    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7, curve: Curves.easeOut)),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic)),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _titleOpacity,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: Text(
                        widget.title,
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
                  if (widget.subtitle != null) ...[
                    SizedBox(height: 12.h),
                    FadeTransition(
                      opacity: _subtitleOpacity,
                      child: SlideTransition(
                        position: _subtitleSlide,
                        child: Text(
                          widget.subtitle!,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0xFF7B8190),
                            fontFamily: 'SF Pro',
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: FadeTransition(
                opacity: _imageOpacity,
                child: Transform.scale(
                  scale: _imageScale.value,
                  child: Container(
                    padding: EdgeInsets.only(top: 0.h),
                    width: double.infinity,
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            FadeTransition(
              opacity: _buttonOpacity,
              child: SlideTransition(
                position: _buttonSlide,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 15.h),
                  child: RedButton(
                    label: widget.buttonLabel,
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
    );
  }
}