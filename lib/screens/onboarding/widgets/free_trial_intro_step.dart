import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/red_button.dart';

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
      duration: const Duration(milliseconds: 1200));

    Animation<double> createOpacity(double start, double end) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut)));
    }

    Animation<Offset> createSlide(double start, double end) {
      return Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutCubic)));
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
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.rubik(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF111827),
                            height: 1.15),
                          children: const [
                            TextSpan(text: 'We want you to try\nCooked for '),
                            TextSpan(
                              text: 'free',
                              style: TextStyle(color: Color(0xFFC31E26))),
                          ])),
                      SizedBox(height: 10.h),
                      Text(
                        'Create your account to keep your recipes, meal plans, grocery lists, and savings tracker.',
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          color: const Color(0xFF111827),
                          height: 1.3)),
                    ])))),

            // 2. Middle Image Section (confined to middle area like previous step)
            Expanded(
              child: FadeTransition(
                opacity: _imageOpacity,
                child: SlideTransition(
                  position: _imageSlide,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/onboarding/step25.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFF1F5F9),
                            alignment: Alignment.center,
                            child: const Icon(Icons.fastfood, color: Color(0xFFCBD5E1))))),
                      // Top White Fade
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 40.h,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white,
                                Color(0x00FFFFFF),
                              ])))),
                      // Bottom White Fade
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 50.h,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.white,
                                Color(0x00FFFFFF),
                              ])))),
                    ])))),

            // 3. Bottom Checklist & Action Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  Column(
                    children: List.generate(_benefits.length, (index) {
                      return FadeTransition(
                        opacity: _itemOpacities[index],
                        child: SlideTransition(
                          position: _itemSlides[index],
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 22.r,
                                  height: 22.r,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFC31E26),
                                    shape: BoxShape.circle),
                                  child: Icon(Icons.check_rounded, color: Colors.white, size: 14.sp)),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    _benefits[index],
                                    style: GoogleFonts.rubik(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF111827)))),
                              ]))));
                    })),
                  SizedBox(height: 8.h),
                  FadeTransition(
                    opacity: _buttonOpacity,
                    child: SlideTransition(
                      position: _buttonSlide,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: SafeArea(
                          top: false,
                          bottom: true,
                          child: RedButton(
                            label: 'Try for \$0.00',
                            color: const Color(0xFFC31E26),
                            onTap: widget.onContinue,
                            height: 52.h,
                            fontSize: 16.sp))))),
                ])),
          ]);
      });
  }
}
