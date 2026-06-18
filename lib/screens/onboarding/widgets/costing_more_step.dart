import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../widgets/red_button.dart';

class CostingMoreStep extends StatefulWidget {
  final VoidCallback onContinue;

  const CostingMoreStep({super.key, required this.onContinue});

  @override
  State<CostingMoreStep> createState() => _CostingMoreStepState();
}

class _CostingMoreStepState extends State<CostingMoreStep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _subtitleSlide;
  
  late Animation<double> _imageOpacity;
  late Animation<double> _imageScale;
  
  late Animation<double> _cardOpacity;
  late Animation<Offset> _cardSlide;
  
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

    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
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
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF111827),
                            fontFamily: 'Larken',
                            height: 1.149,
                            letterSpacing: 0,
                          ),
                          children: const [
                            TextSpan(text: 'And it\'s '),
                            TextSpan(
                              text: 'costing',
                              style: TextStyle(color: Color(0xFFC83A2D)),
                            ),
                            TextSpan(text: '\nmore than '),
                            TextSpan(
                              text: 'time.',
                              style: TextStyle(color: Color(0xFFC83A2D)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  FadeTransition(
                    opacity: _subtitleOpacity,
                    child: SlideTransition(
                      position: _subtitleSlide,
                      child: Text(
                        'Small decisions become expensive habits.',
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
              padding: EdgeInsets.only(left: 25.w, right: 25.w, bottom: 20.h),
              child: FadeTransition(
                opacity: _cardOpacity,
                child: SlideTransition(
                  position: _cardSlide,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: const Color(0xFFFFE4E4),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icones/trending1.svg', 
                          width: 40.sp, 
                          height: 40.sp,
                          colorFilter: const ColorFilter.mode(Color(0xFFC83A2D), BlendMode.srcIn),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w200,
                                    color: const Color(0xFF0D1B3E),
                                    fontFamily: 'Larken',
                                  ),
                                  children: [
                                    const TextSpan(text: 'That is nearly '),
                                    TextSpan(
                                      text: '4x',
                                      style: TextStyle(
                                        color: const Color(0xFFC83A2D),
                                        fontSize: 25.sp,
                                      ),
                                    ),
                                    const TextSpan(text: ' more'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Than cooking at home',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: const Color(0xFF6B7280),
                                  fontFamily: 'SF Pro',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
