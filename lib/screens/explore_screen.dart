import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/app_search_field.dart';
import '../data/explore_data.dart';
import '../routes/app_routes.dart';
import 'home/view_all_screen.dart';

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
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

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
                if (_searchCtrl.text.isEmpty) ...[
                  _buildBrowseByCuisine(),
                  SizedBox(height: 32.h),
                  _buildPopularCategories(),
                  SizedBox(height: 32.h),
                ],
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
    final cuisines = ExploreData.cuisines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Browse by Cuisine', onViewAll: () {
          Navigator.pushNamed(
            context,
            AppRoutes.viewAll,
            arguments: {
              'type': ViewAllType.exploreCuisines,
              'title': 'Browse by Cuisine',
            },
          );
        }),
        SizedBox(height: 8.h),
        SizedBox(
          height: 110.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: cuisines.length,
            itemBuilder: (context, i) {
              final item = cuisines[i];
              return Padding(
                padding: EdgeInsets.only(right: 20.w),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.cookbookDetail,
                      arguments: {'cookbook': item.cookbook},
                    );
                  },
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
                            image: AssetImage(item.image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        item.cookbook.name,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
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
    final categories = ExploreData.niches.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Popular Categories', onViewAll: () {
          Navigator.pushNamed(
            context,
            AppRoutes.viewAll,
            arguments: {
              'type': ViewAllType.exploreCategories,
              'title': 'Popular Categories',
            },
          );
        }),
        SizedBox(height: 8.h),
        SizedBox(
          height: 200.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final item = categories[i];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.cookbookDetail,
                    arguments: {'cookbook': item.cookbook},
                  );
                },
                child: Container(
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
                          item.image,
                          width: 180.w,
                          height: 150.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        item.cookbook.name,
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
                            '${item.cookbook.recipes.length} Recipes',
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
    final query = _searchCtrl.text.trim().toLowerCase();
    var popular = ExploreData.popularNow;
    if (query.isNotEmpty) {
      popular = popular.where((r) => r.name.toLowerCase().contains(query)).toList();
    }

    if (popular.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: const Center(child: Text('No recipes match your search.')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            'Popular Now',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w800,
              fontSize: 20.sp,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
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
              final recipe = popular[i];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.recipeDetail,
                    arguments: {'recipe': recipe},
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Image.asset(
                          recipe.image ?? 'assets/images/others.png',
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
                            recipe.name,
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
                          '${recipe.cookTime} min',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 11.sp,
                            color: const Color(0xFF999999),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Icon(Icons.local_fire_department_outlined, size: 12.sp, color: const Color(0xFF999999)),
                        SizedBox(width: 4.w),
                        Text(
                          '${recipe.kcal} kcal',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 11.sp,
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
