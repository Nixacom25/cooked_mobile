import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ── Shared red button ────────────────────────────────────────────────────────
class RedButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const RedButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54.h,
        decoration: BoxDecoration(
          color: const Color(0xFFC83A2D),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
