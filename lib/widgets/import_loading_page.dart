import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImportLoadingPage extends StatefulWidget {
  const ImportLoadingPage({super.key});

  @override
  State<ImportLoadingPage> createState() => _ImportLoadingPageState();
}

class _ImportLoadingPageState extends State<ImportLoadingPage> {
  int _dotCount = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = '.' * _dotCount;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Logo at Top Left
            Positioned(
              top: 20.h,
              left: 20.w,
              child: Image.asset(
                'assets/images/logo2.png',
                width: 40.w,
                height: 40.h,
                fit: BoxFit.contain,
              ),
            ),

            // 2. Center Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Vegetable Illustration
                  Image.asset(
                    'assets/images/import_load.png',
                    width: 170.w,
                    height: 170.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 32.h),

                  // Animated Title
                  SizedBox(
                    height: 40.h, // Fixed height to prevent jumping
                    child: Text(
                      'Importing your recipe$dots',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),

                  // Subtitle
                  Text(
                    'Building your recipe step-by-step',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
