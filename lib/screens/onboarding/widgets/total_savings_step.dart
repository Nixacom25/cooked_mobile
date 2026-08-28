import 'package:google_fonts/google_fonts.dart';
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
  
  late Animation<double> _imageOpacity;
  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900));

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic)));

    _amountOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.65, curve: Curves.easeOut)));
    _amountScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.65, curve: Curves.easeOutBack)));

    _imageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.85, curve: Curves.easeOut)));

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.55, 1.0, curve: Curves.easeOut)));
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic)));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total savings or fallback to default mockup value ($2,496)
    final totalSavings = widget.eatingOutSavings + widget.grocerySavings;
    final displayAmount = totalSavings > 0 ? totalSavings : 2496;
    final formattedSavings = displayAmount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]},'
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Food Image starting near top (below title) with smooth top fade
            Positioned(
              top: 90.h,
              left: 0,
              right: 0,
              bottom: 0,
              child: FadeTransition(
                opacity: _imageOpacity,
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black,
                        Colors.black,
                      ],
                      stops: [0.0, 0.38, 0.65]).createShader(rect);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    'assets/onboarding/step8.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF1F5F9),
                      alignment: Alignment.center,
                      child: const Icon(Icons.restaurant, size: 60, color: Color(0xFFCBD5E1))))))),

            // Foreground Content Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Area (Left aligned, Rubik)
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
                  child: FadeTransition(
                    opacity: _titleOpacity,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: Text(
                        'You could save\napproximately',
                        textAlign: TextAlign.start,
                        style: GoogleFonts.rubik(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF111827),
                          height: 1.15))))),
                
                SizedBox(height: 24.h),

                // Big Stat Section (Centered amount + captions)
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
                          style: GoogleFonts.rubik(
                            fontSize: 52.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF10B981),
                            height: 1.0,
                            letterSpacing: -1.0)),
                        SizedBox(height: 10.h),
                        Text(
                          'Every Year',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rubik(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF111827))),
                        SizedBox(height: 4.h),
                        Text(
                          'Just by cooking smarter',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF64748B))),
                      ]))),

                const Spacer(),

                // Continue Button
                FadeTransition(
                  opacity: _buttonOpacity,
                  child: SlideTransition(
                    position: _buttonSlide,
                    child: SafeArea(
                      top: false,
                      bottom: true,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
                        child: RedButton(
                          label: 'Continue',
                          color: const Color(0xFFC31E26),
                          onTap: widget.onContinue,
                          height: 52.h,
                          fontSize: 16.sp))))),
              ]),
          ]);
      }
    );
  }
}
