import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Color? backgroundColor;
  final Color? borderColor;

  const AppSearchField({
    super.key,
    this.controller,
    this.hintText = 'Search your recipes',
    this.onChanged,
    this.onSubmitted,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(50.r),
        border: Border.all(color: borderColor ?? const Color(0xFFE0E0E0)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 20.sp, color: const Color(0xFFAAAAAA)),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 14.sp,
                color: const Color(0xFF1A1A1A),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 14.sp,
                  color: Colors.grey[400],
                ),
                filled: true,
                fillColor:
                    Colors.transparent, // background is handled by Container
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 16.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
