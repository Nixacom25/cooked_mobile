import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/app_search_field.dart';

// ══════════════════════════════════════════════════════════════════════════════
// EXPLORE SCREEN (Static Version)
// ══════════════════════════════════════════════════════════════════════════════
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: 24.h, bottom: 120.h),
              children: [
                _buildBrowseByCuisine(),
                SizedBox(height: 32.h),
                _buildPopularCategories(),
                SizedBox(height: 32.h),
                _buildPopularNow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header (Gradient + Search) ──────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
        image: const DecorationImage(
          image: AssetImage('assets/images/fond2.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(top: 50.h, bottom: 24.h, left: 20.w, right: 20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFC83A2D).withValues(alpha: 0.95),
              const Color(0xFFC83A2D).withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w800,
                fontSize: 28.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20.h),
            AppSearchField(
              controller: _searchCtrl,
              hintText: 'Search recipes, ingredients....',
            ),
          ],
        ),
      ),
    );
  }

  // ── Browse by Cuisine ───────────────────────────────────────────────────────
  Widget _buildBrowseByCuisine() {
    final cuisines = [
      ('Italian', 'assets/images/italian.png'),
      ('Mexican', 'assets/images/mexican.png'),
      ('Chinese', 'assets/images/chinese.png'),
      ('Japanese', 'assets/images/japanese.png'),
      ('East', 'assets/images/east.png'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Browse by Cuisine', onViewAll: () {}),
        SizedBox(height: 8.h),
        SizedBox(
          height: 110.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: cuisines.length,
            itemBuilder: (context, i) {
              return Padding(
                padding: EdgeInsets.only(right: 20.w),
                child: Column(
                  children: [
                    Container(
                      width: 76.w,
                      height: 76.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        image: DecorationImage(
                          image: AssetImage(cuisines[i].$2),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      cuisines[i].$1,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Popular Categories ──────────────────────────────────────────────────────
  Widget _buildPopularCategories() {
    final categories = [
      ('High Protein Low Calorie', 'assets/images/explore_autumn.png', '18 Recipes'),
      ('Easy Desserts', 'assets/images/cookbook_healthy.png', '6 Recipes'),
      ('30 Min Meals', 'assets/images/explore_spring.png', '24 Recipes'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Popular Categories', onViewAll: () {}),
        SizedBox(height: 8.h),
        SizedBox(
          height: 220.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: categories.length,
            itemBuilder: (context, i) {
              return Container(
                width: 180.w,
                margin: EdgeInsets.only(
                  left: i == 0 ? 20.w : 0,
                  right: 16.w,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.asset(
                        categories[i].$2,
                        width: 180.w,
                        height: 150.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      categories[i].$1,
                      maxLines: 2,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                        color: const Color(0xFF1A1A1A),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.favorite_border, size: 14.sp, color: const Color(0xFFBBBBBB)),
                        SizedBox(width: 4.w),
                        Text(
                          categories[i].$3,
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 12.sp,
                            color: const Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Popular Now ─────────────────────────────────────────────────────────────
  Widget _buildPopularNow() {
    final popular = [
      ('Chicken Stir-Fry', 'assets/images/recipe_stir_fry.png', '25 min', '18 Recipes'),
      ('Grilled Salmon', 'assets/images/recipe_salmon.png', '15 min', '6 Recipes'),
      ('Beef Tacos', 'assets/images/mexican.png', '25 min', '18 Recipes'),
      ('Pasta Alfredo', 'assets/images/recipe_pasta.png', '10 min', '8 Recipes'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Popular Now', onViewAll: () {}),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: popular.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 20.h,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, i) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.asset(
                        popular[i].$2,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w900,
                          fontSize: 20.sp,
                          color: const Color(0xFFEDEDED),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          popular[i].$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w800,
                            fontSize: 14.sp,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      SizedBox(width: 24.w), // Offset for number
                      Icon(Icons.access_time, size: 12.sp, color: const Color(0xFF999999)),
                      SizedBox(width: 4.w),
                      Text(
                        popular[i].$3,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 11.sp,
                          color: const Color(0xFF999999),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Icon(Icons.favorite_border, size: 12.sp, color: const Color(0xFF999999)),
                      SizedBox(width: 4.w),
                      Text(
                        popular[i].$4,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 11.sp,
                          color: const Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Shared Section Header ─────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const _SectionHeader({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w800,
              fontSize: 20.sp,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'View All',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: const Color(0xFFCC3333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
