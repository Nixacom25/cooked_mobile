import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileRatingStep extends StatefulWidget {
  final String firstName;
  final int initialRating;
  final Function(int rating) onChanged;
  final VoidCallback onSkip;

  const ProfileRatingStep({
    super.key,
    required this.firstName,
    required this.initialRating,
    required this.onChanged,
    required this.onSkip,
  });

  @override
  State<ProfileRatingStep> createState() => _ProfileRatingStepState();
}

class _ProfileRatingStepState extends State<ProfileRatingStep> {
  late int _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You\'re almost ready, ${widget.firstName.isNotEmpty ? widget.firstName[0].toLowerCase() : 'r'}!',
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
            'Quick question before we begin..',
            style: TextStyle(
              fontSize: 15.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            'How are you feeling about Cooked so far?',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 32.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final isFilled = index < _rating;
              return IconButton(
                onPressed: () {
                  setState(() => _rating = index + 1);
                  widget.onChanged(_rating);
                },
                iconSize: 48.sp,
                icon: Icon(
                  isFilled ? Icons.star : Icons.star_border,
                  color: isFilled
                      ? const Color(0xFFC83A2D)
                      : const Color(0xFFD1D5DB),
                ),
              );
            }),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: widget.onSkip,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF3F4F6),
                padding: EdgeInsets.symmetric(vertical: 18.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'Skip for now',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                  fontFamily: 'SF Pro',
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
