import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/red_button.dart';

class CookingSystemStep extends StatelessWidget {
  final VoidCallback onContinue;

  const CookingSystemStep({super.key, required this.onContinue});

  Widget _buildListItem(String text, {bool isChecked = false, bool isCurrent = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isChecked ? const Color(0xFFC83A2D) : Colors.transparent,
              border: Border.all(
                color: isChecked || isCurrent ? const Color(0xFFC83A2D) : const Color(0xFFD1D5DB),
                width: isCurrent ? 2.w : 1.w,
              ),
            ),
            child: isChecked
                ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: isChecked || isCurrent ? const Color(0xFF1B1C1C) : const Color(0xFF7B8190),
                fontFamily: 'SF Pro',
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0D1B36),
                    fontFamily: 'SF Pro',
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                  children: const [
                    TextSpan(text: 'Let\'s build your\ncooking '),
                    TextSpan(
                      text: 'profile.',
                      style: TextStyle(color: Color(0xFFC83A2D)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'The more we learn, the better your recommendations.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF7B8190),
                  fontFamily: 'SF Pro',
                ),
              ),
              SizedBox(height: 32.h),
              _buildListItem('Understanding your cooking challenges', isChecked: true),
              _buildListItem('Calculating your potential savings', isChecked: true),
              _buildListItem('Understanding your dietary preferences', isCurrent: true),
              _buildListItem('Learning your cuisine preferences'),
            ],
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(top: 20.h),
            child: Image.asset(
              'assets/images/step9.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 15.h),
          child: RedButton(
            label: 'Start →',
            onTap: onContinue,
            height: 55.h,
            fontSize: 18.sp,
          ),
        ),
      ],
    );
  }
}
