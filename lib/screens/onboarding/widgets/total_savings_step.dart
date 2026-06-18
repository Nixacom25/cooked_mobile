import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/red_button.dart';

class TotalSavingsStep extends StatefulWidget {
  final int eatingOutSavings;
  final int grocerySavings;
  final VoidCallback onContinue;

  const TotalSavingsStep({
    super.key, 
    required this.eatingOutSavings,
    required this.grocerySavings,
    required this.onContinue,
  });

  @override
  State<TotalSavingsStep> createState() => _TotalSavingsStepState();
}

class _TotalSavingsStepState extends State<TotalSavingsStep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  
  late Animation<double> _amountOpacity;
  late Animation<double> _amountScale;
  
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _subtitleSlide;
  
  late Animation<double> _imageOpacity;
  late Animation<Offset> _imageSlide;
  
  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic)),
    );

    _amountOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)),
    );
    _amountScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.elasticOut)),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8, curve: Curves.easeOut)),
    );
    _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic)),
    );

    _imageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );
    _imageSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic)),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic)),
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
    // Format total savings with commas
    final totalSavings = widget.eatingOutSavings + widget.grocerySavings;
    final formattedSavings = totalSavings.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
                    child: FadeTransition(
                      opacity: _titleOpacity,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Text(
                          'You could save\napproximately',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF111827),
                            fontFamily: 'Larken',
                            height: 1.149,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  FadeTransition(
                    opacity: _amountOpacity,
                    child: ScaleTransition(
                      scale: _amountScale,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '\$$formattedSavings',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 56.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF00C40A),
                              fontFamily: 'SF Pro',
                              height: 1,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Every Year',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF6B7280),
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  FadeTransition(
                    opacity: _subtitleOpacity,
                    child: SlideTransition(
                      position: _subtitleSlide,
                      child: Text(
                        'Just by cooking smarter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFF4B5563),
                          fontFamily: 'SF Pro',
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            
            // Image placed at the bottom, rotated, partially behind the button
            Positioned(
              left: -10.w,
              right: 10.w,
              bottom: 70.h, // overlapping the button slightly
              child: FadeTransition(
                opacity: _imageOpacity,
                child: SlideTransition(
                  position: _imageSlide,
                  child: Transform.rotate(
                    angle: -5 * (3.14159 / 180), // Convert degrees to radians
                    child: Image.asset(
                      'assets/onboarding/step8.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 300.h,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('assets/onboarding/step8.png missing'),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Button always on top
            Positioned(
              left: 24.w,
              right: 24.w,
              bottom: 20.h,
              child: FadeTransition(
                opacity: _buttonOpacity,
                child: SlideTransition(
                  position: _buttonSlide,
                  child: SafeArea(
                    top: false,
                    child: RedButton(
                      label: 'Continue',
                      onTap: widget.onContinue,
                      height: 55.h,
                      fontSize: 18.sp,
                    ),
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
