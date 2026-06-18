import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/red_button.dart';

class CookMoreSaveMoneyStep extends StatelessWidget {
  final VoidCallback onContinue;

  const CookMoreSaveMoneyStep({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You could save approximately',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0D1B36),
                  fontFamily: 'SF Pro',
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                '\$2,496',
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF00C40A),
                  fontFamily: 'SF Pro',
                  height: 1.0,
                  letterSpacing: -1.0,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Every Year',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF7B8190),
                  fontFamily: 'SF Pro',
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Just by cooking smarter.',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: const Color(0xFF7B8190),
                  fontFamily: 'SF Pro',
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/images/step9.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 15.h),
          child: RedButton(
            label: 'Continue',
            onTap: onContinue,
            height: 55.h,
            fontSize: 18.sp,
          ),
        ),
      ],
    );
  }
}
