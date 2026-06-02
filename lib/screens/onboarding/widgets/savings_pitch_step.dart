import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SavingsPitchStep extends StatefulWidget {
  final VoidCallback onContinue;

  const SavingsPitchStep({
    super.key,
    required this.onContinue,
  });

  @override
  State<SavingsPitchStep> createState() => _SavingsPitchStepState();
}

class _SavingsPitchStepState extends State<SavingsPitchStep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;

  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _subtitleSlide;

  late Animation<double> _imageOpacity;
  late Animation<double> _imageScale;

  late List<Animation<double>> _featureOpacities;
  late List<Animation<Offset>> _featureSlides;

  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;

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

    _subtitleOpacity = createOpacity(0.1, 0.4);
    _subtitleSlide = createSlide(0.1, 0.4);

    _imageOpacity = createOpacity(0.2, 0.5);
    _imageScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic)),
    );

    _featureOpacities = [];
    _featureSlides = [];
    double currentDelay = 0.3;
    for (int i = 0; i < 3; i++) {
      _featureOpacities.add(createOpacity(currentDelay, currentDelay + 0.3));
      _featureSlides.add(createSlide(currentDelay, currentDelay + 0.3));
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
                              fontSize: 25.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0D1B3E),
                              fontFamily: 'SF Pro',
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                            children: [
                              const TextSpan(text: 'Save '),
                              TextSpan(
                                text: 'Money',
                                style: TextStyle(color: const Color(0xFFC83A2D)),
                              ),
                              const TextSpan(text: '. Save '),
                              TextSpan(
                                text: 'Time\n',
                                style: TextStyle(color: const Color(0xFFE48E88)), // Lighter red
                              ),
                              const TextSpan(text: 'Every Week'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Subtitle
                    FadeTransition(
                      opacity: _subtitleOpacity,
                      child: SlideTransition(
                        position: _subtitleSlide,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: const Color(0xFF7B8190),
                              fontFamily: 'SF Pro',
                              height: 1.3,
                            ),
                            children: [
                              const TextSpan(text: 'The average user saves '),
                              TextSpan(
                                text: '\$65/month',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              const TextSpan(text: ' on food'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // Center Image (step31.png)
                    FadeTransition(
                      opacity: _imageOpacity,
                      child: Transform.scale(
                        scale: _imageScale.value,
                        child: Center(
                          child: Image.asset(
                            'assets/images/step31.png',
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // Feature List
                    FadeTransition(
                      opacity: _featureOpacities[0],
                      child: SlideTransition(
                        position: _featureSlides[0],
                        child: _buildFeatureItem(Icons.shopping_cart_outlined, 'Spend less on groceries'),
                      ),
                    ),
                    FadeTransition(
                      opacity: _featureOpacities[1],
                      child: SlideTransition(
                        position: _featureSlides[1],
                        child: _buildFeatureItem(Icons.ramen_dining_outlined, 'Fewer takeouts, more home\ncooked meals'),
                      ),
                    ),
                    FadeTransition(
                      opacity: _featureOpacities[2],
                      child: SlideTransition(
                        position: _featureSlides[2],
                        child: _buildFeatureItem(Icons.receipt_long_outlined, 'Better planning, less waste', isLast: true),
                      ),
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
                    padding: EdgeInsets.fromLTRB(24.w, 0.h, 24.w, 20.h),
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
                          'Start Saving',
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

  Widget _buildFeatureItem(IconData icon, String text, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 24.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFC83A2D), size: 24.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111827),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
