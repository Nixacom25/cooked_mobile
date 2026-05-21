import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IdentityStep extends StatefulWidget {
  final String initialName;
  final Function(String name) onChanged;

  const IdentityStep({
    super.key,
    required this.initialName,
    required this.onChanged,
  });

  @override
  State<IdentityStep> createState() => _IdentityStepState();
}

class _IdentityStepState extends State<IdentityStep> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome! Let\'s get started',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              height: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'First, what should we call you?',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 40.h),
          Text(
            'Your Name',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4B5563),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _controller,
            onChanged: (val) {
              widget.onChanged(val.trim());
            },
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
            decoration: InputDecoration(
              hintText: 'e.g. John',
              hintStyle: TextStyle(
                color: const Color(0xFFBDC3C7),
                fontWeight: FontWeight.w400,
                fontSize: 16.sp,
              ),
              prefixIcon: Icon(Icons.person_outline_rounded,
                  color: const Color(0xFFBDC3C7), size: 22.sp),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide:
                    BorderSide(color: const Color(0xFFC83A2D), width: 1.5.w),
              ),
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F5EF),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Row(
              children: [
                Text('✨', style: TextStyle(fontSize: 14.sp)),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'We\'ll use this to personalize your cooking experience.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF854D0E),
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
