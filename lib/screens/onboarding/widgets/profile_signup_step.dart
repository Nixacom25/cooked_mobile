import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileSignupStep extends StatefulWidget {
  final VoidCallback onSignupEmail;
  final VoidCallback onSignupGoogle;
  final VoidCallback onSignupApple;
  final VoidCallback onGuest;
  final bool isAppleEnabled;

  const ProfileSignupStep({
    super.key,
    required this.onSignupEmail,
    required this.onSignupGoogle,
    required this.onSignupApple,
    required this.onGuest,
    this.isAppleEnabled = true,
  });

  @override
  State<ProfileSignupStep> createState() => _ProfileSignupStepState();
}

class _ProfileSignupStepState extends State<ProfileSignupStep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;

  late Animation<double> _infoOpacity;
  late Animation<Offset> _infoSlide;

  late List<Animation<double>> _btnOpacities;
  late List<Animation<Offset>> _btnSlides;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    Animation<double> createOpacity(double start, double end) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut)),
      );
    }

    Animation<Offset> createSlide(double start, double end) {
      return Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutCubic)),
      );
    }

    _titleOpacity = createOpacity(0.0, 0.3);
    _titleSlide = createSlide(0.0, 0.3);

    _infoOpacity = createOpacity(0.2, 0.5);
    _infoSlide = createSlide(0.2, 0.5);

    _btnOpacities = [];
    _btnSlides = [];
    double currentDelay = 0.4;
    for (int i = 0; i < 3; i++) {
      _btnOpacities.add(createOpacity(currentDelay, currentDelay + 0.3));
      _btnSlides.add(createSlide(currentDelay, currentDelay + 0.3));
      currentDelay += 0.15;
    }

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
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _titleOpacity,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Save your profile,',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0D1B3E),
                          fontFamily: 'SF Pro',
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Your 22-step profile is ready to save',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF7B8190),
                          fontFamily: 'SF Pro',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              FadeTransition(
                opacity: _infoOpacity,
                child: SlideTransition(
                  position: _infoSlide,
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Pick up exactly where you left off on any device',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF6B7280),
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 28.h),

              FadeTransition(
                opacity: _btnOpacities[0],
                child: SlideTransition(
                  position: _btnSlides[0],
                  child: _buildAuthButton(
                    onPressed: widget.onSignupGoogle,
                    icon: 'google.svg',
                    label: 'Sign up with Google',
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              FadeTransition(
                opacity: _btnOpacities[1],
                child: SlideTransition(
                  position: _btnSlides[1],
                  child: _buildAuthButton(
                    onPressed: widget.onSignupApple,
                    icon: 'apple.svg',
                    label: 'Sign up with Apple',
                    isEnabled: widget.isAppleEnabled,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              FadeTransition(
                opacity: _btnOpacities[2],
                child: SlideTransition(
                  position: _btnSlides[2],
                  child: _buildAuthButton(
                    onPressed: widget.onSignupEmail,
                    icon: 'email1.svg',
                    label: 'Sign up with Email',
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildAuthButton({
    required VoidCallback onPressed,
    required String icon,
    required String label,
    bool isEnabled = true,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 18.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.r),
              side: BorderSide(
                color: isEnabled ? const Color(0xFFC83A2D) : Colors.grey,
              ),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icones/$icon',
                height: 24.sp,
                width: 24.sp,
                placeholderBuilder: (context) => const SizedBox.shrink(),
              ),
              SizedBox(width: 12.w),
              Text(
                isEnabled ? label : '$label (Soon)',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SF Pro',
                  color: isEnabled ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
