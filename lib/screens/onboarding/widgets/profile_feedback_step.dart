import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileFeedbackStep extends StatefulWidget {
  final String initialFeedback;
  final Function(String feedback) onChanged;

  const ProfileFeedbackStep({
    super.key,
    required this.initialFeedback,
    required this.onChanged,
  });

  @override
  State<ProfileFeedbackStep> createState() => _ProfileFeedbackStepState();
}

class _ProfileFeedbackStepState extends State<ProfileFeedbackStep> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialFeedback);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thanks for your honesty!',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              height: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'What could we improve?',
            style: TextStyle(
              fontSize: 15.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 32.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              maxLines: 8,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: 'Your feedback helps us improve..',
                hintStyle: TextStyle(
                  color: const Color(0xFF9CA3AF),
                  fontFamily: 'SF Pro',
                  fontSize: 16.sp,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontSize: 16.sp,
                fontFamily: 'SF Pro',
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
