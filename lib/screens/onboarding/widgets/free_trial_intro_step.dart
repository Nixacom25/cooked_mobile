import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FreeTrialIntroStep extends StatefulWidget {
  final VoidCallback onContinue;

  const FreeTrialIntroStep({
    super.key,
    required this.onContinue,
  });

  @override
  State<FreeTrialIntroStep> createState() => _FreeTrialIntroStepState();
}

class _FreeTrialIntroStepState extends State<FreeTrialIntroStep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _imageOpacity;
  late Animation<Offset> _imageSlide;
  late List<Animation<double>> _itemOpacities;
  late List<Animation<Offset>> _itemSlides;
  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;

  final List<String> _benefits = [
    'Full access to 10,000+ chef-curated recipes',
    'Personalized meal plans',
    'Smart grocery lists that save you money',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
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

    _imageOpacity = createOpacity(0.1, 0.4);
    _imageSlide = createSlide(0.1, 0.4);

    _itemOpacities = [];
    _itemSlides = [];
    double currentDelay = 0.2;
    for (int i = 0; i < 3; i++) {
      _itemOpacities.add(createOpacity(currentDelay, currentDelay + 0.3));
      _itemSlides.add(createSlide(currentDelay, currentDelay + 0.3));
      currentDelay += 0.15;
    }

    _buttonOpacity = createOpacity(currentDelay, currentDelay + 0.3);
    _buttonSlide = createSlide(currentDelay, currentDelay + 0.3);

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
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 34.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0D1B3E),
                              fontFamily: 'Larken',
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                            children: const [
                              TextSpan(text: 'We want you to try\nCooked for '),
                              TextSpan(
                                text: 'free',
                                style: TextStyle(color: Color(0xFFC83A2D)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Text(
                          'Create your account to keep your recipes, meal plans, grocery lists, and savings tracker.',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0xFF4B5563),
                            fontFamily: 'SF Pro',
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Image
                    FadeTransition(
                      opacity: _imageOpacity,
                      child: SlideTransition(
                        position: _imageSlide,
                        child: Center(
                          child: Image.asset(
                            'assets/images/step28.png', // Wait, let's use a placeholder if step28 is missing, but it's not missing based on my ls
                            height: 280.h,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 280.h,
                              width: 250.w,
                              color: Colors.grey[200],
                              alignment: Alignment.center,
                              child: const Text('assets/images/step28.png missing'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Checklist
                    Column(
                      children: List.generate(_benefits.length, (index) {
                        return FadeTransition(
                          opacity: _itemOpacities[index],
                          child: SlideTransition(
                            position: _itemSlides[index],
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 24.w,
                                    height: 24.w,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFC83A2D),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.check, color: Colors.white, size: 16.sp),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      _benefits[index],
                                      style: TextStyle(
                                        fontFamily: 'SF Pro',
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1B1C1C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

            // Bottom Button Area
            FadeTransition(
              opacity: _buttonOpacity,
              child: SlideTransition(
                position: _buttonSlide,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 20.h),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55.h,
                      child: ElevatedButton(
                        onPressed: widget.onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC83A2D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Try for \$0.00',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
