import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/app_search_field.dart';
import '../routes/app_routes.dart';
import '../services/recipe_service.dart';
import '../models/recipe.dart';
import '../models/view_all_type.dart';

// ══════════════════════════════════════════════════════════════════════════════
// EXPLORE SCREEN (Backend Driven)
// ══════════════════════════════════════════════════════════════════════════════
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  static const Map<String, String> cuisineImages = {
    'Italian': 'assets/images/italian.png',
    'Mexican': 'assets/images/mexican1.png',
    'Chinese': 'assets/images/chinese.png',
    'Japanese': 'assets/images/japanese.png',
    'Thai': 'assets/images/thai.png',
    'Indian': 'assets/images/indian.png',
    'Korean': 'assets/images/korean.png',
    'Mediterranean': 'assets/images/mediterranean.png',
    'Middle Eastern': 'assets/images/east.png',
    'French': 'assets/images/french1.png',
    'Spanish': 'assets/images/mexican.png',
    'Greek': 'assets/images/greek1.png',
    'Caribbean': 'assets/images/caribbean1.png',
    'West African': 'assets/images/west-african.png',
  };

  static const Map<String, String> nicheImages = {
    'High Protein Picks': 'assets/images/higth-proteins.png',
    'Easy Desserts': 'assets/images/easy-desserts.png',
    '30-Minute Meals': 'assets/images/30-Minutes.png',
    'Healthy Breakfasts': 'assets/images/explore_summer.png',
    'Plant-Based Essentials': 'assets/images/Plant-Based.png',
    'Low-Carb Meals': 'assets/images/low-cards.png',
  };

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchCtrl = TextEditingController();
  // int _selectedCategory = 0;

  // static const _categories = [
  //   ('🍕', 'Italian'),
  //   ('🥗', 'Healthy'),
  //   ('🥦', 'Vegetarian'),
  //   ('💪', 'High Protein'),
  //   ('🍜', 'Asian'),
  //   ('🥐', 'Bakery'),
  // ];

  late Future<Map<String, int>> _cuisinesFuture;
  late Future<Map<String, int>> _categoriesFuture;
  late Future<List<Recipe>> _popularFuture;

  @override
  void initState() {
    super.initState();
    _cuisinesFuture = RecipeService.instance.getExploreCuisines();
    _categoriesFuture = RecipeService.instance.getExploreCategories();
    _popularFuture = RecipeService.instance.getPopularRecipes(size: 10);
    
    _searchCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static const List<String> _allowedCuisines = [
    'Italian',
    'Mexican',
    'Chinese',
    'Japanese',
    'Thai',
    'Indian',
    'Korean',
    'Mediterranean',
    'Middle Eastern',
    'French',
    'Spanish',
    'Greek',
    'Caribbean',
    'West African',
  ];

  static const List<String> _allowedNiches = [
    'High Protein Picks',
    'Easy Desserts',
    '30-Minute Meals',
    'Healthy Breakfasts',
    'Plant-Based Essentials',
    'Low-Carb Meals',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: ListView(
        padding: EdgeInsets.only(bottom: 120.h),
        children: [
          _buildHeader(),
          SizedBox(height: 20.h),
          if (_searchCtrl.text.isEmpty) ...[
            _buildBrowseByCuisine(),
            SizedBox(height: 20.h),
            _buildPopularCategories(),
          ],
          _buildPopularNow(),
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
          image: AssetImage('assets/images/explore.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(
          top: 60.h,
          bottom: 20.h,
          left: 20.w,
          right: 20.w,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w800,
                fontSize: 24.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20.h),
            AppSearchField(
              controller: _searchCtrl,
              hintText: 'Search recipes, ingredients....',
            ),
            // SizedBox(height: 16.h),
            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: Row(
            //     children: List.generate(_categories.length, (i) {
            //       final (emoji, label) = _categories[i];
            //       final active = _selectedCategory == i;
            //       return GestureDetector(
            //         onTap: () {
            //           setState(() => _selectedCategory = i);
            //           // _loadPopularRecipes(label); // Note: Removed in recent cleanup
            //         },
            //         child: AnimatedContainer(
            //           duration: const Duration(milliseconds: 200),
            //           margin: EdgeInsets.only(right: 8.w),
            //           padding:
            //               EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            //           decoration: BoxDecoration(
            //             color:
            //                 active
            //                     ? const Color(0xFFFFF6D6)
            //                     : Colors.white.withOpacity(0.18),
            //             borderRadius: BorderRadius.circular(30.r),
            //             border: Border.all(
            //               color:
            //                   active
            //                       ? const Color(0xFFF2C94C)
            //                       : Colors.white.withOpacity(0.35),
            //             ),
            //           ),
            //           child: Row(
            //             children: [
            //               Text(emoji, style: TextStyle(fontSize: 13.sp)),
            //               SizedBox(width: 6.w),
            //               Text(
            //                 label,
            //                 style: TextStyle(
            //                   fontFamily: 'SF Pro',
            //                   fontWeight: FontWeight.w600,
            //                   fontSize: 13.sp,
            //                   color:
            //                       active
            //                           ? const Color(0xFFCC3333)
            //                           : Colors.white,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       );
            //     }),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // ── Browse by Cuisine ───────────────────────────────────────────────────────
  Widget _buildBrowseByCuisine() {
    return FutureBuilder<Map<String, int>>(
      future: _cuisinesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final cuisinesMap = snapshot.data!;
        final names = cuisinesMap.keys
            .where(
              (name) => _allowedCuisines.any(
                (c) => c.toLowerCase() == name.toLowerCase(),
              ),
            )
            .toList();

        if (names.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: 'Browse by Cuisine',
              onViewAll: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.viewAll,
                  arguments: {
                    'type': ViewAllType.exploreCuisines,
                    'title': 'Browse by Cuisine',
                  },
                );
              },
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 90.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: names.length,
                itemBuilder: (context, i) {
                  final name = names[i];

                  // Use local mapping for image
                  String imgPath =
                      ExploreScreen.cuisineImages[name] ??
                      'assets/images/others.png';

                  return Padding(
                    padding: EdgeInsets.only(right: 15.w),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.viewAll,
                          arguments: {
                            'type': ViewAllType.exploreRecipesByCuisine,
                            'title': name,
                            'cuisine': name,
                          },
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 65.w,
                            height: 65.h,
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
                                image: AssetImage(imgPath),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            name,
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w700,
                              fontSize: 12.sp,
                              color: const Color(0xFF191C1E),
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
      },
    );
  }

  // ── Popular Categories ──────────────────────────────────────────────────────
  Widget _buildPopularCategories() {
    return FutureBuilder<Map<String, int>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final categoriesMap = snapshot.data!;
        final names = categoriesMap.keys
            .where(
              (name) => _allowedNiches.any(
                (n) => n.toLowerCase() == name.toLowerCase(),
              ),
            )
            .toList();

        if (names.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: 'Popular Categories',
              onViewAll: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.viewAll,
                  arguments: {
                    'type': ViewAllType.exploreCategories,
                    'title': 'Popular Categories',
                  },
                );
              },
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 200.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: names.length,
                itemBuilder: (context, i) {
                  final name = names[i];
                  final count = categoriesMap[name] ?? 0;
                  final imgPath =
                      ExploreScreen.nicheImages[name] ??
                      'assets/images/explore_autumn.png';

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.viewAll,
                        arguments: {
                          'type': ViewAllType.exploreRecipesByCategory,
                          'title': name,
                          'category': name,
                        },
                      );
                    },
                    child: Container(
                      width: 160.w,
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
                              imgPath,
                              width: 160.w,
                              height: 130.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            name,
                            maxLines: 2,
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w800,
                              fontSize: 14.sp,
                              color: const Color(0xFF222222),
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 13.sp,
                                color: const Color(0xFF9CA3AF),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '$count Recipes',
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontSize: 11.sp,
                                  color: const Color(0xFF9CA3AF),
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
      },
    );
  }

  // ── Popular Now ─────────────────────────────────────────────────────────────
  Widget _buildPopularNow() {
    return FutureBuilder<List<Recipe>>(
      future: _popularFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 0.h),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFFC83A2D)),
            ),
          );
        }

        final query = _searchCtrl.text.trim().toLowerCase();
        var popular = snapshot.data ?? [];
        if (popular.length > 10) popular = popular.sublist(0, 10);

        if (query.isNotEmpty) {
          popular = popular
              .where((r) => r.name.toLowerCase().contains(query))
              .toList();
        }

        if (popular.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: const Center(child: Text('No recipes found.')),
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
                  fontSize: 18.sp,
                  color: const Color(0xFF111827),
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
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.r),
                              child:
                                  recipe.image != null &&
                                      recipe.image!.startsWith('http')
                                  ? Image.network(
                                      recipe.image!,
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Image.asset(
                                        'assets/images/recipes.png',
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                  : Image.asset(
                                      recipe.image ?? 'assets/images/recipes.png',
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                    ),
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
                                fontSize: 18.sp,
                                color: const Color(0xFFD8D8D8),
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
                                  color: const Color(0xFF222222),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(width: 20.w), // Offset for number
                            Icon(
                              Icons.timer,
                              size: 12.sp,
                              color: const Color(0xFF9CA3AF),
                            ),
                            Text(
                              '${recipe.cookTime} min',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontSize: 11.sp,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Icon(
                              Icons.local_fire_department,
                              size: 12.sp,
                              color: const Color(0xFF9CA3AF),
                            ),
                            Text(
                              '${recipe.kcal} kcal',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontSize: 11.sp,
                                color: const Color(0xFF9CA3AF),
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
      },
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
              fontSize: 18.sp,
              color: const Color(0xFF111827),
            ),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'View All',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: const Color(0xFFC83A2D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
