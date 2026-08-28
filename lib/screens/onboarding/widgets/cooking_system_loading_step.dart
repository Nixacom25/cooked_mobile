import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/red_button.dart';

class CookingSystemLoadingStep extends StatefulWidget {
  final VoidCallback onContinue;

  const CookingSystemLoadingStep({super.key, required this.onContinue});

  @override
  State<CookingSystemLoadingStep> createState() => _CookingSystemLoadingStepState();
}

class _CookingSystemLoadingStepState extends State<CookingSystemLoadingStep> with SingleTickerProviderStateMixin {
  int _currentLoadingStep = 0; // 0 to 3 for the 4 steps, 4 means all completed
  Timer? _timer;

  final List<String> _loadingTasks = [
    'Understanding your cooking challenges',
    'Calculating your potential savings',
    'Understanding your dietary preferences',
    'Learning your cuisine preferences',
  ];

  @override
  void initState() {
    super.initState();
    
    // Automatically progress through the loading steps
    _timer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      if (!mounted) return;
      if (_currentLoadingStep < 4) {
        setState(() {
          _currentLoadingStep++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildTaskItem(int index, String text) {
    int state = 0; // 0 = pending, 1 = loading, 2 = done
    if (_currentLoadingStep > index) {
      state = 2;
    } else if (_currentLoadingStep == index) {
      state = 1;
    }

    Widget leadingIcon;
    if (state == 2) {
      leadingIcon = Container(
        width: 22.r,
        height: 22.r,
        decoration: const BoxDecoration(
          color: Color(0xFFC31E26),
          shape: BoxShape.circle),
        child: Icon(Icons.check, color: Colors.white, size: 13.sp));
    } else if (state == 1) {
      leadingIcon = SizedBox(
        width: 22.r,
        height: 22.r,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC31E26)),
          backgroundColor: const Color(0xFFFFEDD5)));
    } else {
      leadingIcon = Container(
        width: 22.r,
        height: 22.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.8)));
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leadingIcon,
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.rubik(
                fontSize: 15.sp,
                color: state == 0 ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                fontWeight: state == 0 ? FontWeight.w500 : FontWeight.w700,
                height: 1.2))),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Food Background Image (starts under description with white gradient overlay behind checklist)
        Positioned.fill(
          top: 135.h,
          child: Stack(
            children: [
              Image.asset(
                'assets/onboarding/step9.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFF1F5F9),
                  alignment: Alignment.center,
                  child: const Icon(Icons.restaurant_menu, size: 60, color: Color(0xFFCBD5E1)))),
              // White gradient overlay covering top area behind auto-checks
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white.withValues(alpha: 0.96),
                      Colors.white.withValues(alpha: 0.75),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.22, 0.42, 0.62]))),
            ])),

        // Foreground Content (Title, Subtitle, Tasks Checklist)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section (Title & Subtitle)
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
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
                        TextSpan(text: 'Let’s build your\ncooking '),
                        TextSpan(
                          text: 'profile',
                          style: TextStyle(color: Color(0xFFC31E26))),
                      ])),
                  SizedBox(height: 10.h),
                  Text(
                    'The more we learn, the better your recommendations',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      color: const Color(0xFF111827),
                      height: 1.3)),
                ])),

            SizedBox(height: 28.h),

            // Tasks Checklist (Floats over the food image)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: List.generate(
                  _loadingTasks.length,
                  (index) => _buildTaskItem(index, _loadingTasks[index])))),
          ]),

        // Start Button (Animated in at bottom)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedOpacity(
            opacity: _currentLoadingStep >= 2 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 400),
            child: SafeArea(
              top: false,
              bottom: true,
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
                child: RedButton(
                  label: 'Start \u2192',
                  color: const Color(0xFFC31E26),
                  onTap: widget.onContinue,
                  height: 52.h,
                  fontSize: 16.sp))))),
      ]);
  }
}
