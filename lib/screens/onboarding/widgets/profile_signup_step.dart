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

class _ProfileSignupStepState extends State<ProfileSignupStep>
    with SingleTickerProviderStateMixin {
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
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    }

    Animation<Offset> createSlide(double start, double end) {
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            start,
            end.clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
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
        return Column(
          children: [
            // 1. Header Text Section at top
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              child: FadeTransition(
                opacity: _titleOpacity,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Save your\npersonalized plan',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          fontFamily: 'Rubik',
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Create your account to keep your recipes, meal plans, grocery lists, and savings tracker',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: const Color(0xFF475569),
                          fontFamily: 'SF Pro',
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Middle Image Section (fading out smoothly at bottom near Google button)
            Expanded(
              child: FadeTransition(
                opacity: _infoOpacity,
                child: SlideTransition(
                  position: _infoSlide,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/onboarding/step24.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFF1F5F9),
                            alignment: Alignment.center,
                            child: const Icon(Icons.fastfood, color: Color(0xFFCBD5E1)),
                          ),
                        ),
                      ),

                      // Subtle top gradient fade
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 50.h,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white,
                                Color(0x00FFFFFF),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Smooth bottom white fade right at/above the Google button
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 70.h,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.white,
                                Color(0x00FFFFFF),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Social Buttons at bottom (clean white background)
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 4.h, 24.w, 16.h),
              child: SafeArea(
                top: false,
                bottom: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _btnOpacities[0],
                      child: SlideTransition(
                        position: _btnSlides[0],
                        child: _buildAuthButton(
                          onPressed: widget.onSignupGoogle,
                          icon: 'google.svg',
                          label: 'Sign in with Google',
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
                          label: 'Sign in with Apple',
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
                          label: 'Sign in with Email',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
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
      height: 52.h,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF1F5F9),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icones/$icon',
                height: 22.sp,
                width: 22.sp,
                placeholderBuilder: (context) => Icon(
                  Icons.login,
                  color: const Color(0xFF0F172A),
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                isEnabled ? label : '$label (Soon)',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Rubik',
                  color: isEnabled ? const Color(0xFF0F172A) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
