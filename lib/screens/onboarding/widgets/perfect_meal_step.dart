import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PerfectMealStep extends StatefulWidget {
  final List<String> favoriteCuisines;
  final List<String> goals;
  final String cookingTime;
  final VoidCallback onStartCooking;
  final VoidCallback onViewMore;

  const PerfectMealStep({
    super.key,
    required this.favoriteCuisines,
    required this.goals,
    required this.cookingTime,
    required this.onStartCooking,
    required this.onViewMore,
  });

  @override
  State<PerfectMealStep> createState() => _PerfectMealStepState();
}

class _PerfectMealStepState extends State<PerfectMealStep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;

  late Animation<double> _imageScale;
  late Animation<double> _imageOpacity;

  late Animation<double> _bottomOpacity;
  late Animation<Offset> _bottomSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400));

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic)));

    _imageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)));
    _imageScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic)));

    _bottomOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.9, curve: Curves.easeOut)));
    _bottomSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.9, curve: Curves.easeOutCubic)));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Subtitle
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                      child: FadeTransition(
                        opacity: _titleOpacity,
                        child: SlideTransition(
                          position: _titleSlide,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Perfect meal for you',
                                style: GoogleFonts.rubik(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF111827),
                                  height: 1.15)),
                              SizedBox(height: 8.h),
                              Text(
                                'Based on your goals, taste, and cooking',
                                style: GoogleFonts.poppins(
                                  fontSize: 15.sp,
                                  color: const Color(0xFF111827),
                                  height: 1.3)),
                            ])))),
                    SizedBox(height: 8.h),

                    // Image Graphic in center (step28.png)
                    FadeTransition(
                      opacity: _imageOpacity,
                      child: Transform.scale(
                        scale: _imageScale.value,
                        child: Center(
                          child: Image.asset(
                            'assets/onboarding/step28.png',
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 300.h,
                              color: const Color(0xFFF1F5F9),
                              alignment: Alignment.center,
                              child: const Icon(Icons.restaurant, color: Color(0xFFCBD5E1))))))),
                    SizedBox(height: 16.h),

                    // Why we picked this section
                    FadeTransition(
                      opacity: _bottomOpacity,
                      child: SlideTransition(
                        position: _bottomSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              child: Text(
                                'Why we picked this',
                                style: GoogleFonts.rubik(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF111827)))),
                            SizedBox(height: 12.h),

                            // Horizontal scroll chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              clipBehavior: Clip.none,
                              child: Row(
                                children: [
                                  _buildReasonChip(
                                    icon: Icons.favorite_outline_rounded,
                                    label: 'Matches your taste',
                                    bgColor: const Color(0xFFFFF7ED),
                                    borderColor: const Color(0xFFFFEDD5),
                                    iconColor: const Color(0xFFC31E26)),
                                  SizedBox(width: 10.w),
                                  _buildReasonChip(
                                    icon: Icons.flash_on_outlined,
                                    label: 'Quick dinner',
                                    bgColor: const Color(0xFFFFF7ED),
                                    borderColor: const Color(0xFFFFEDD5),
                                    iconColor: const Color(0xFFC31E26)),
                                  SizedBox(width: 10.w),
                                  _buildReasonChip(
                                    icon: Icons.restaurant_menu_rounded,
                                    label: 'Uses your ingredients',
                                    bgColor: const Color(0xFFFFF7ED),
                                    borderColor: const Color(0xFFFFEDD5),
                                    iconColor: const Color(0xFFC31E26)),
                                ])),
                          ]))),
                    SizedBox(height: 20.h),
                  ]))),

            // Bottom Action Button
            FadeTransition(
              opacity: _bottomOpacity,
              child: SlideTransition(
                position: _bottomSlide,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 4.h, 24.w, 20.h),
                  child: SafeArea(
                    top: false,
                    bottom: true,
                    child: SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: widget.onStartCooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC31E26),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.r))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant_rounded, color: Colors.white, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text(
                              "Start Cookin'",
                              style: GoogleFonts.rubik(fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                          ]))))))),
          ]);
      });
  }

  Widget _buildReasonChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color borderColor,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(50.r),
        border: Border.all(color: borderColor, width: 1.w)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 18.sp),
          SizedBox(width: 8.w),
          Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF111827))),
        ]));
  }
}
