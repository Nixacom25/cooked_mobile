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

  late Animation<double> _tag1Scale;
  late Animation<double> _tag2Scale;
  late Animation<double> _tag3Scale;

  late Animation<double> _bottomOpacity;
  late Animation<Offset> _bottomSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic)),
    );

    _imageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
    );
    _imageScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic)),
    );

    _tag1Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.6, curve: Curves.elasticOut)),
    );
    _tag2Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.7, curve: Curves.elasticOut)),
    );
    _tag3Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.8, curve: Curves.elasticOut)),
    );

    _bottomOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.9, curve: Curves.easeOut)),
    );
    _bottomSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.9, curve: Curves.easeOutCubic)),
    );

    _controller.forward();
  }

  Map<String, dynamic> _getRecommendation() {
    String title = 'Mediterranean Lemon Chicken';
    List<Map<String, dynamic>> tags = [
      {'text': 'Healthy Choice', 'icon': Icons.energy_savings_leaf_outlined, 'color': const Color(0xFFD1FAE5), 'iconColor': const Color(0xFF059669)},
    ];
    List<Map<String, dynamic>> reasons = [
      {'text': 'Matches your taste', 'icon': Icons.thumb_up_outlined},
    ];

    bool isJapanese = widget.favoriteCuisines.contains('Japanese');
    bool isMexican = widget.favoriteCuisines.contains('Mexican');
    bool isAfrican = widget.favoriteCuisines.any((c) => c.contains('African'));
    
    if (isJapanese && widget.goals.contains('lose_weight')) {
      title = 'Salmon Rice Bowl';
      tags = [
        {'text': 'High Protein', 'icon': Icons.fitness_center, 'color': const Color(0xFFDBEAFE), 'iconColor': const Color(0xFF2563EB)},
        {'text': 'Weight Loss', 'icon': Icons.monitor_weight_outlined, 'color': const Color(0xFFD1FAE5), 'iconColor': const Color(0xFF059669)},
        {'text': 'Japanese Inspired', 'icon': Icons.restaurant, 'color': const Color(0xFFFCE7F3), 'iconColor': const Color(0xFFDB2777)},
      ];
      reasons = [
        {'text': 'Low calorie', 'icon': Icons.local_fire_department_outlined},
        {'text': 'Quick dinner', 'icon': Icons.bolt},
      ];
    } else if (isMexican && widget.goals.contains('gain_muscle')) {
      title = 'Steak Burrito Bowl';
      tags = [
        {'text': 'High Protein', 'icon': Icons.fitness_center, 'color': const Color(0xFFDBEAFE), 'iconColor': const Color(0xFF2563EB)},
        {'text': 'Muscle Building', 'icon': Icons.sports_gymnastics, 'color': const Color(0xFFFCE7F3), 'iconColor': const Color(0xFFDB2777)},
        {'text': 'Meal Prep Friendly', 'icon': Icons.inventory_2_outlined, 'color': const Color(0xFFD1FAE5), 'iconColor': const Color(0xFF059669)},
      ];
      reasons = [
        {'text': 'Great for recovery', 'icon': Icons.health_and_safety_outlined},
        {'text': 'Matches your taste', 'icon': Icons.thumb_up_outlined},
      ];
    } else if (isAfrican && widget.goals.contains('save_money')) {
      title = 'Jollof Rice & Chicken';
      tags = [
        {'text': 'Budget Friendly', 'icon': Icons.local_offer_outlined, 'color': const Color(0xFFFCE7F3), 'iconColor': const Color(0xFFDB2777)},
        {'text': 'Pantry Staples', 'icon': Icons.kitchen, 'color': const Color(0xFFD1FAE5), 'iconColor': const Color(0xFF059669)},
        {'text': 'Family Friendly', 'icon': Icons.people_outline, 'color': const Color(0xFFDBEAFE), 'iconColor': const Color(0xFF2563EB)},
      ];
      reasons = [
        {'text': 'Cost effective', 'icon': Icons.savings_outlined},
        {'text': 'Uses your ingredients', 'icon': Icons.inventory_2_outlined},
      ];
    } else {
      // Dynamic fallback based on goals and time
      if (widget.goals.contains('gain_muscle')) {
        title = 'High-Protein Bowl';
        tags.add({'text': 'High Protein', 'icon': Icons.fitness_center, 'color': const Color(0xFFDBEAFE), 'iconColor': const Color(0xFF2563EB)});
      }
      if (widget.goals.contains('save_money')) {
        title = 'Budget-Friendly Feast';
        tags.add({'text': 'Budget Friendly', 'icon': Icons.local_offer_outlined, 'color': const Color(0xFFFCE7F3), 'iconColor': const Color(0xFFDB2777)});
      }
      if (widget.favoriteCuisines.isNotEmpty) {
        tags.add({'text': '${widget.favoriteCuisines.first} Inspired', 'icon': Icons.restaurant, 'color': const Color(0xFFFEF3C7), 'iconColor': const Color(0xFFD97706)});
      }
      reasons.add({'text': 'Matches your taste', 'icon': Icons.thumb_up_outlined});
      reasons.add({'text': 'Uses your ingredients', 'icon': Icons.inventory_2_outlined});
    }

    if (widget.cookingTime.contains('30') || widget.cookingTime.contains('15')) {
      tags.add({'text': '20 min', 'icon': Icons.access_time, 'color': const Color(0xFFFEF3C7), 'iconColor': const Color(0xFFD97706)});
      reasons.add({'text': 'Quick dinner', 'icon': Icons.bolt});
    }

    // Keep max 4 tags
    if (tags.length > 4) tags = tags.sublist(0, 4);

    return {
      'title': title,
      'tags': tags,
      'reasons': reasons,
    };
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
        final meal = _getRecommendation();
        final tags = meal['tags'] as List<Map<String, dynamic>>;
        final reasons = meal['reasons'] as List<Map<String, dynamic>>;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Subtitle
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal['title'],
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0D1B3E),
                                fontFamily: 'Larken',
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Based on your goals, taste, and cooking',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: const Color(0xFF4B5563),
                                fontFamily: 'SF Pro',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // Center Image with floating tags
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Main Image
                          FadeTransition(
                            opacity: _imageOpacity,
                            child: Transform.scale(
                              scale: _imageScale.value,
                              child: Image.asset(
                                'assets/onboarding/step28.png',
                                width: 300.w,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 300.h,
                                  width: 300.w,
                                  color: Colors.grey[200],
                                  alignment: Alignment.center,
                                  child: const Text('assets/onboarding/step28.png missing'),
                                ),
                              ),
                            ),
                          ),
                          
                          // The mockup implies the tags are part of the image or positioned around it.
                          // We'll leave the image to handle the lines if any, and overlay tags if needed.
                          // But if the tags are part of the image in step28.png, maybe we don't need these?
                          // Let's assume we need to render the tags.
                          
                          // Dynamic Tags
                          if (tags.isNotEmpty)
                            Positioned(
                              top: 40.h,
                              left: -20.w,
                              child: Transform.scale(
                                scale: _tag1Scale.value,
                                child: _buildFloatingTag(
                                  icon: tags[0]['icon'],
                                  text: tags[0]['text'],
                                  color: tags[0]['color'],
                                  iconColor: tags[0]['iconColor'],
                                ),
                              ),
                            ),

                          if (tags.length > 1)
                            Positioned(
                              top: 60.h,
                              right: -20.w,
                              child: Transform.scale(
                                scale: _tag2Scale.value,
                                child: _buildFloatingTag(
                                  icon: tags[1]['icon'],
                                  text: tags[1]['text'],
                                  color: tags[1]['color'],
                                  iconColor: tags[1]['iconColor'],
                                ),
                              ),
                            ),

                          if (tags.length > 2)
                            Positioned(
                              bottom: 60.h,
                              left: -10.w,
                              child: Transform.scale(
                                scale: _tag3Scale.value,
                                child: _buildFloatingTag(
                                  icon: tags[2]['icon'],
                                  text: tags[2]['text'],
                                  color: tags[2]['color'],
                                  iconColor: tags[2]['iconColor'],
                                ),
                              ),
                            ),

                          if (tags.length > 3)
                            Positioned(
                              bottom: 40.h,
                              right: -20.w,
                              child: Transform.scale(
                                scale: _tag1Scale.value, // Reusing animation
                                child: _buildFloatingTag(
                                  icon: tags[3]['icon'],
                                  text: tags[3]['text'],
                                  color: tags[3]['color'],
                                  iconColor: tags[3]['iconColor'],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 60.h),

                    // Bottom info and chips
                    FadeTransition(
                      opacity: _bottomOpacity,
                      child: SlideTransition(
                        position: _bottomSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Why We Picked This Section
                            Text(
                              'WHY WE PICKED THIS',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: const Color(0xFF7B8190),
                                fontFamily: 'SF Pro',
                              ),
                            ),
                            SizedBox(height: 16.h),

                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none,
                              child: Row(
                                children: reasons.map((r) {
                                  return Padding(
                                    padding: EdgeInsets.only(right: 12.w),
                                    child: _buildReasonChip(r['icon'], r['text']),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions Area
            FadeTransition(
              opacity: _bottomOpacity,
              child: SlideTransition(
                position: _bottomSlide,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 20.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 55.h,
                          child: ElevatedButton(
                            onPressed: widget.onStartCooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC83A2D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.r),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.restaurant, color: Colors.white, size: 20.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  'Start Cooking',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro',
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildFloatingTag({required IconData icon, required String text, required Color color, required Color iconColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 14.sp),
          ),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B1C1C),
              fontFamily: 'SF Pro',
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EB), // Light yellow bg from mockup
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: const Color(0xFFFDE6B0), width: 1.w),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC83A2D), size: 18.sp),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B1C1C),
              fontFamily: 'SF Pro',
            ),
          ),
        ],
      ),
    );
  }
}
