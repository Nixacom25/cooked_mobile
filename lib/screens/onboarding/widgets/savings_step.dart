import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/red_button.dart';

class SavingsStep extends StatefulWidget {
  final VoidCallback onContinue;

  const SavingsStep({super.key, required this.onContinue});

  @override
  State<SavingsStep> createState() => _SavingsStepState();
}

class _SavingsStepState extends State<SavingsStep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _subtitleSlide;
  
  late Animation<double> _imageOpacity;
  late Animation<double> _imageScale;
  
  late Animation<double> _infoOpacity;
  late Animation<Offset> _infoSlide;
  
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

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
    );
    _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic)),
    );

    _imageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.7, curve: Curves.easeOut)),
    );
    _imageScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic)),
    );

    _infoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );
    _infoSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic)),
    );

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
                      child: RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 34.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0D1B3E),
                            fontFamily: 'Larken',
                            height: 1.149,
                            letterSpacing: 0,
                          ),
                          children: const [
                            TextSpan(text: 'You\'re not '),
                            TextSpan(
                              text: 'alone.',
                              style: TextStyle(color: Color(0xFFC83A2D)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  FadeTransition(
                    opacity: _subtitleOpacity,
                    child: SlideTransition(
                      position: _subtitleSlide,
                      child: Text(
                        'Most people spend over 200 hours every year deciding what to eat.',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFF4B5563),
                          fontFamily: 'SF Pro',
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: FadeTransition(
                opacity: _imageOpacity,
                child: Transform.scale(
                  scale: _imageScale.value,
                  child: Center(
                    child: Image.asset(
                      'assets/onboarding/step5.png',
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('assets/onboarding/step5.png missing'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: FadeTransition(
                opacity: _infoOpacity,
                child: SlideTransition(
                  position: _infoSlide,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left side
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.schedule, size: 40.sp, color: const Color(0xFF9CA3AF)),
                          SizedBox(width: 8.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '200',
                                style: TextStyle(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFC83A2D),
                                  fontFamily: 'Larken',
                                  height: 1,
                                ),
                              ),
                              Text(
                                'hours',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: const Color(0xFF0D1B3E),
                                  fontFamily: 'SF Pro',
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                'spent deciding\nwhat to eat',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF6B7280),
                                  fontFamily: 'SF Pro',
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Equal sign
                      Text(
                        '=',
                        style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFC83A2D),
                          fontFamily: 'Larken',
                          height: 1,
                        ),
                      ),
                      // Right side
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '8.3',
                                style: TextStyle(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFC83A2D),
                                  fontFamily: 'Larken',
                                  height: 1,
                                ),
                              ),
                              Text(
                                'days',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: const Color(0xFF0D1B3E),
                                  fontFamily: 'SF Pro',
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                'of your life\nevery year',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF6B7280),
                                  fontFamily: 'SF Pro',
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 8.w),
                          Icon(Icons.calendar_today_outlined, size: 40.sp, color: const Color(0xFF9CA3AF)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 20.h),
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
