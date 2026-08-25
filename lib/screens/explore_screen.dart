import 'home/home_screen.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/app_search_field.dart';
import '../widgets/app_top_header.dart';
import '../widgets/saved_recipe_card.dart';
import '../routes/app_routes.dart';
import '../services/recipe_service.dart';
import '../models/recipe.dart';
import '../models/view_all_type.dart';

// ══════════════════════════════════════════════════════════════════════════════
// EXPLORE SCREEN (Full Width Cards Parity with Home & Reusable Components)
// ══════════════════════════════════════════════════════════════════════════════
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _overlaySearchCtrl = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  OverlayEntry? _searchOverlayEntry;

  late Future<List<Map<String, dynamic>>> _cuisinesFuture;
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  late Future<List<Recipe>> _popularFuture;
  Timer? _refreshTimer;

  int _refreshTimestamp = DateTime.now().millisecondsSinceEpoch;

  String _bustedUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}t=$_refreshTimestamp';
  }

  void _refreshData({bool force = false}) {
    if (!mounted) return;
    setState(() {
      if (force) {
        _refreshTimestamp = DateTime.now().millisecondsSinceEpoch;
      }
      _cuisinesFuture = RecipeService.instance.getExploreCuisines(forceRefresh: force);
      _categoriesFuture = RecipeService.instance.getExploreCategories(forceRefresh: force);
      _popularFuture = RecipeService.instance.getPopularRecipes(size: 10, forceRefresh: force);
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData(force: false);

    HomeScreen.activeTabNotifier.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData(force: true);
    });

    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _refreshData(force: true);
    });

    _searchCtrl.addListener(() {
      if (mounted) setState(() {});
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  void _toggleSearch(bool searching) {
    if (searching) {
      _animationController.forward();
      _showOverlay();
    } else {
      _animationController.reverse().then((_) {
        if (mounted) {
          _searchCtrl.clear();
          _overlaySearchCtrl.clear();
          _removeOverlay();
        }
      });
    }
  }

  void _showOverlay() {
    _removeOverlay();
    _searchOverlayEntry = OverlayEntry(
      builder: (context) => _buildSearchOverlay(),
    );
    Overlay.of(context, rootOverlay: true).insert(_searchOverlayEntry!);
  }

  void _removeOverlay() {
    _searchOverlayEntry?.remove();
    _searchOverlayEntry = null;
  }

  void _onTabChanged() {
    if (HomeScreen.activeTabNotifier.value == 1) {
      _refreshData(force: true);
    }
  }

  @override
  void dispose() {
    HomeScreen.activeTabNotifier.removeListener(_onTabChanged);
    _refreshTimer?.cancel();
    _searchCtrl.dispose();
    _overlaySearchCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    _refreshData(force: true);
    await Future.wait<dynamic>([
      _cuisinesFuture,
      _categoriesFuture,
      _popularFuture,
    ]).catchError((_) => <dynamic>[]);
  }

  static const List<Map<String, String>> _filterTags = [
    {"icon": "🍝", "name": "Italian"},
    {"icon": "🥗", "name": "Healthy"},
    {"icon": "🌱", "name": "Vegetarian"},
    {"icon": "🥐", "name": "Bakery"},
    {"icon": "🍗", "name": "Poultry"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F1F3),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: const Color(0xFFC31E26),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Shared App Header (Home, Explore, Grocery, Import)
              const SliverToBoxAdapter(
                child: AppTopHeader(),
              ),

              // 2. Sticky Header (Explore Title, Search Field, Filter Suggestions)
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyExploreHeaderDelegate(
                  onSearchTap: () => _toggleSearch(true),
                  filterTags: _filterTags,
                ),
              ),

              // 3. Main Body Content
              SliverPadding(
                padding: EdgeInsets.only(bottom: 140.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Bottom half of Explore Card ("For You" section)
                    _buildForYouSectionCard(),

                    SizedBox(height: 14.h),

                    // Section 2: Cuisines Card (Full Width like Home)
                    _buildCuisinesSectionCard(),

                    SizedBox(height: 14.h),

                    // Section 3: Popular Now Card (Full Width like Home & Shared Recipe Cards)
                    _buildPopularNowSectionCard(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section 1 (Bottom): "For You" Categories Card (Full Width) ──────────────
  Widget _buildForYouSectionCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "For You" Section (Categories)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "For You",
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.viewAll,
                    arguments: {
                      'type': ViewAllType.exploreCategories,
                      'title': 'Popular Categories',
                    },
                  );
                },
                child: Text(
                  "View All",
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC31E26),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // For You Cards (First 2 categories displayed dynamically)
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              final categories = snapshot.data ?? [];
              
              final List<Map<String, String>> fallbackCategories = [
                {
                  "name": "Autumn's Favorite",
                  "count": "18 recipes",
                  "image": "assets/images/explore_autumn.png",
                },
                {
                  "name": "Spring Delights",
                  "count": "24 recipes",
                  "image": "assets/images/explore_summer.png",
                },
              ];

              final cat1 = categories.isNotEmpty ? categories[0] : null;
              final cat2 = categories.length > 1 ? categories[1] : null;

              final name1 = cat1 != null ? (cat1['name'] as String? ?? "Autumn's Favorite") : fallbackCategories[0]["name"]!;
              final count1 = cat1 != null ? "${cat1['recipeCount'] ?? 18} recipes" : fallbackCategories[0]["count"]!;
              final img1 = cat1 != null ? (cat1['image'] as String? ?? fallbackCategories[0]["image"]!) : fallbackCategories[0]["image"]!;

              final name2 = cat2 != null ? (cat2['name'] as String? ?? "Spring Delights") : fallbackCategories[1]["name"]!;
              final count2 = cat2 != null ? "${cat2['recipeCount'] ?? 24} recipes" : fallbackCategories[1]["count"]!;
              final img2 = cat2 != null ? (cat2['image'] as String? ?? fallbackCategories[1]["image"]!) : fallbackCategories[1]["image"]!;

              return Row(
                children: [
                  Expanded(
                    child: _buildCategoryCard(
                      title: name1,
                      subtitle: count1,
                      imagePath: img1,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.viewAll,
                          arguments: {
                            'type': ViewAllType.exploreRecipesByCategory,
                            'title': name1,
                            'category': name1,
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: _buildCategoryCard(
                      title: name2,
                      subtitle: count2,
                      imagePath: img2,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.viewAll,
                          arguments: {
                            'type': ViewAllType.exploreRecipesByCategory,
                            'title': name2,
                            'category': name2,
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    final isNetwork = imagePath.startsWith('http');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAF6EE),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: SizedBox(
                height: 130.h,
                width: double.infinity,
                child: isNetwork
                    ? CachedNetworkImage(
                        imageUrl: _bustedUrl(imagePath),
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: Colors.grey[200]),
                        errorWidget: (_, __, ___) => Image.asset(
                          'assets/images/explore_autumn.png',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.restaurant, color: Colors.grey[400]),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section 2: Cuisines Card (Full Width) ───────────────────────────────────
  Widget _buildCuisinesSectionCard() {
    final List<Map<String, String>> fallbackCuisines = [
      {"name": "Italian", "count": "21 recipes", "image": "assets/images/italian.png"},
      {"name": "Mexican", "count": "28 recipes", "image": "assets/images/mexican.png"},
      {"name": "Asian", "count": "17 recipes", "image": "assets/images/chinese.png"},
      {"name": "Indian", "count": "32 recipes", "image": "assets/images/indian.png"},
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Cuisines",
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.viewAll,
                    arguments: {
                      'type': ViewAllType.exploreCuisines,
                      'title': 'Cuisines',
                    },
                  );
                },
                child: Text(
                  "View All",
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC31E26),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: _cuisinesFuture,
            builder: (context, snapshot) {
              final list = (snapshot.hasData && snapshot.data!.isNotEmpty)
                  ? snapshot.data!
                  : fallbackCuisines;

              return SizedBox(
                height: 125.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final item = list[i];
                    final name = (item['name'] as String?) ?? fallbackCuisines[i % fallbackCuisines.length]['name']!;
                    final count = item['count'] != null
                        ? item['count'].toString()
                        : fallbackCuisines[i % fallbackCuisines.length]['count']!;
                    final imgPath = item['image'] ?? fallbackCuisines[i % fallbackCuisines.length]['image']!;
                    final isNetwork = imgPath is String && imgPath.startsWith('http');

                    return Padding(
                      padding: EdgeInsets.only(right: 18.w),
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
                              width: 72.r,
                              height: 72.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFC31E26),
                                  width: 2.5.w,
                                ),
                              ),
                              child: ClipOval(
                                child: isNetwork
                                    ? CachedNetworkImage(
                                        imageUrl: _bustedUrl(imgPath),
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Container(color: Colors.grey[200]),
                                        errorWidget: (_, __, ___) => Image.asset(
                                          fallbackCuisines[i % fallbackCuisines.length]['image']!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Image.asset(
                                        imgPath,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.grey[200],
                                          child: Icon(Icons.restaurant, color: Colors.grey[400]),
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              name,
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              count,
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Section 3: Popular Now Card (Full Width & Shared Cards) ────────────────
  Widget _buildPopularNowSectionCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Popular Now",
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.viewAll,
                    arguments: {
                      'type': ViewAllType.explore,
                      'title': 'Popular Now',
                    },
                  );
                },
                child: Text(
                  "View All",
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC31E26),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Using Reusable SavedRecipeCard (Extracted from Saved Recipes)
          FutureBuilder<List<Recipe>>(
            future: _popularFuture,
            builder: (context, snapshot) {
              final recipes = snapshot.data ?? [];

              if (recipes.isNotEmpty) {
                final displayList = recipes.take(3).toList();
                return ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayList.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (ctx, i) {
                    final r = displayList[i];
                    return SavedRecipeCard(
                      recipe: r,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.recipeDetail,
                          arguments: {'recipe': r},
                        );
                      },
                    );
                  },
                );
              }

              // High Fidelity Design Fallback Cards using the SAME SavedRecipeCard from Home
              return Column(
                children: [
                  SavedRecipeCard(
                    title: "Chicken Stir-Fry",
                    time: "25 min",
                    kcal: "317 kcal",
                    image: "assets/images/plat4.png",
                    onTap: () {},
                  ),
                  SizedBox(height: 12.h),
                  SavedRecipeCard(
                    title: "Tacos",
                    time: "10 min",
                    kcal: "217 kcal",
                    image: "assets/images/plat3.png",
                    onTap: () {},
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Search Overlay ──────────────────────────────────────────────────────────
  Widget _buildSearchOverlay() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.white,
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppSearchField(
                            controller: _overlaySearchCtrl,
                            hintText: 'Search recipes...',
                            onChanged: (val) {
                              if (mounted) setState(() {});
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        GestureDetector(
                          onTap: () => _toggleSearch(false),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFC31E26),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Search results will appear here",
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 14.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Sticky Explore Header Delegate ──────────────────────────────────────────────
class _StickyExploreHeaderDelegate extends SliverPersistentHeaderDelegate {
  final VoidCallback onSearchTap;
  final List<Map<String, String>> filterTags;

  _StickyExploreHeaderDelegate({
    required this.onSearchTap,
    required this.filterTags,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isPinned = shrinkOffset > 0;
    return Container(
      color: const Color(0xFFF0F1F3),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isPinned
              ? BorderRadius.circular(24.r)
              : BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: isPinned
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Explore",
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 10.h),

            // Search Field Bar
            GestureDetector(
              onTap: onSearchTap,
              child: AbsorbPointer(
                child: Container(
                  height: 46.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 20.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        "Search your recipes",
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 15.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Filter Tags Row
            SizedBox(
              height: 36.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filterTags.length,
                itemBuilder: (context, i) {
                  final tag = filterTags[i];
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF6EE),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Text(
                            tag["icon"]!,
                            style: TextStyle(fontSize: 13.sp),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            tag["name"]!,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
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
        ),
      ),
    );
  }

  @override
  double get maxExtent => 165.h;

  @override
  double get minExtent => 165.h;

  @override
  bool shouldRebuild(covariant _StickyExploreHeaderDelegate oldDelegate) {
    return false;
  }
}
