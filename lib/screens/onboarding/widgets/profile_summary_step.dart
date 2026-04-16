import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileSummaryStep extends StatelessWidget {
  final String firstName;
  final List<String> favoriteCuisines;
  final List<String> flavorDna;
  final VoidCallback onContinue;

  const ProfileSummaryStep({
    super.key,
    required this.firstName,
    required this.favoriteCuisines,
    required this.flavorDna,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$firstName, your profile is ready!',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0D1B36),
              fontFamily: 'SF Pro',
              height: 1.2,
            ),
          ),
          SizedBox(height: 10.h),
          
          // Stats Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '1,847',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFC83A2D),
                    fontFamily: 'SF Pro',
                  ),
                ),
                Text(
                  'recipes personalized just for you',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro',
                  ),
                ),
                SizedBox(height: 24.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your favorite cuisines:',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                        fontFamily: 'SF Pro',
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: favoriteCuisines.take(6).map((item) => _buildChip(item)).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 30.h),
          Text(
            "You'll Be Able To",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 15.h),
          
          _buildFeatureCard(
            icon: 'scan.svg',
            title: 'Scan Ingredients',
            desc: 'Point your camera at ingredients in your fridge or pantry and instantly get recipe ideas',
            iconColor: const Color(0xFFC83A2D),
          ),
          _buildFeatureCard(
            icon: 'import.svg',
            title: 'Import from Social Media',
            desc: 'Save recipes directly from Instagram, TikTok, or any platform in one tap.',
            iconColor: const Color(0xFFC83A2D),
          ),
          _buildFeatureCard(
            icon: 'personalized.svg',
            title: 'Personalized for You',
            desc: 'Get recipe recommendations tailored to your taste, diet, and preferences.',
            iconColor: const Color(0xFFC83A2D),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          color: const Color(0xFF111827),
          fontWeight: FontWeight.w600,
          fontFamily: 'SF Pro',
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String icon,
    required String title,
    required String desc,
    required Color iconColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: SvgPicture.asset(
              'assets/icones/$icon',
              height: 24.sp,
              width: 24.sp,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              placeholderBuilder: (context) => SizedBox(
                height: 24.sp,
                width: 24.sp,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0D1B3E),
                    fontFamily: 'SF Pro',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF7B8190),
                    fontFamily: 'SF Pro',
                    height: 1.4,
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
