import 'home/home_screen.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/widgets/ios_toast.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/app_search_field.dart';
import '../widgets/app_top_header.dart';
import '../widgets/red_header_background.dart';
import '../widgets/saved_recipe_card.dart';
import '../widgets/recipe_shortcut_card.dart';
import '../widgets/scroll_blur_header_overlay.dart';
import '../routes/app_routes.dart';
import '../services/recipe_service.dart';
import '../models/recipe.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../models/view_all_type.dart';
import '../core/api_config.dart';
import '../core/utils/recipe_filters.dart';
import '../core/theme/app_theme.dart';

// ══════════════════════════════════════════════════════════════════════════════
// EXPLORE SCREEN (Full Width Cards Parity with Home & Reusable Components)
// ══════════════════════════════════════════════════════════════════════════════
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocusNode = FocusNode();

  late Future<List<Map<String, dynamic>>> _cuisinesFuture;
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  late Future<List<Recipe>> _popularFuture;
  // Wider recipe pool the quick-filter chips (High Protein, Under 30 Min,
  // Chicken, ...) run their predicate against - the 10-recipe "Popular Now"
  // pool used for plain text search is too small for these to find much.
  late Future<List<Recipe>> _filterPoolFuture;
  Timer? _refreshTimer;

  // Background refreshes (the periodic timer, pull-to-refresh) keep showing
  // this last-known-good data instead of resetting to a loading spinner -
  // only the very first load (cache still null) shows one.
  List<Map<String, dynamic>>? _cuisinesCache;
  List<Map<String, dynamic>>? _categoriesCache;
  List<Recipe>? _popularCache;

  String? _activeFilterId;

  int _refreshTimestamp = DateTime.now().millisecondsSinceEpoch;

  String _bustedUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}t=$_refreshTimestamp';
  }

  void _refreshData({bool force = false}) {
    if (!mounted) return;
    if (force) {
      _refreshTimestamp = DateTime.now().millisecondsSinceEpoch;
      try {
        DefaultCacheManager().emptyCache();
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
      } catch (_) {}
    }
    setState(() {
      _cuisinesFuture = RecipeService.instance.getExploreCuisines(forceRefresh: force);
      _popularFuture = RecipeService.instance.getPopularRecipes(size: 10, forceRefresh: force);
      _categoriesFuture = RecipeService.instance.getExploreCategories(forceRefresh: force);
      _filterPoolFuture = RecipeService.instance.getExploreRecipes(size: 150, forceRefresh: force);
    });
    _cuisinesFuture.then((v) { if (mounted) setState(() => _cuisinesCache = v); }).catchError((_) {});
    _popularFuture.then((v) { if (mounted) setState(() => _popularCache = v); }).catchError((_) {});
    _categoriesFuture.then((v) { if (mounted) setState(() => _categoriesCache = v); }).catchError((_) {});
  }

  @override
  void initState() {
    super.initState();
    // First load only: fetch fresh data but don't touch the image cache -
    // there's nothing to bust yet.
    _refreshData(force: false);

    HomeScreen.activeTabNotifier.addListener(_onTabChanged);

    // Periodically re-fetch data so new content shows up, but never with
    // force: true here - that clears the entire image cache and cache-busts
    // every image URL, which was making recipe photos re-download from
    // scratch every couple of minutes and on every tab switch.
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _refreshData(force: false);
    });

    _searchCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _onTabChanged() {
    if (HomeScreen.activeTabNotifier.value == 1) {
      _refreshData(force: false);
    }
  }

  @override
  void dispose() {
    HomeScreen.activeTabNotifier.removeListener(_onTabChanged);
    _refreshTimer?.cancel();
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
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


  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.pageBackground,
      child: AppRefreshIndicator(
        onRefresh: _handleRefresh,
        child: ScrollBlurHeaderOverlay(
          isDarkBackground: false,
          primaryGradientColor: context.colors.border,
          secondaryGradientColor: context.colors.border,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Stack(
              children: [
                // ── Red Top Header Background (Gradient) - Scrolls with content ──
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 260.h,
                  child: const RedHeaderBackground(),
                ),

              // ── Scrollable Body Column ──
              Column(
                children: [
                  // 1. Shared App Header over red background
                  const AppTopHeader(textColor: Colors.white),

                  SizedBox(height: 8.h),

                  // 2. Fused Top Card: Explore Header, Search, Filters & "For You" Section
                  _buildTopExploreAndForYouCard(),

                  SizedBox(height: 16.h),

                  // 3. Card 2: Cuisines Card
                  _buildCuisinesSectionCard(),

                  SizedBox(height: 16.h),

                  // 4. Card 3: Popular Now Card
                  _buildPopularNowSectionCard(),

                  SizedBox(height: 140.h + MediaQuery.of(context).padding.bottom),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  // ── Fused Top Card: Explore Header, Search, Filters & "For You" Section ───────
  Widget _buildTopExploreAndForYouCard() {
    final searchQuery = _searchCtrl.text.trim();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Explore Title & Search Field Bar ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Explore",
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),

                // Live, inline search field (like Home) instead of a tap
                // target that launched a full-screen overlay/modal.
                AppSearchField(
                  key: const ValueKey('explore_search_field'),
                  controller: _searchCtrl,
                  focusNode: _searchFocusNode,
                  backgroundColor: context.colors.pageBackground,
                  borderColor: context.colors.pageBackground,
                  hintText: 'Search your recipes',
                  suffixIcon: searchQuery.isNotEmpty ? Icons.close_rounded : null,
                  onSuffixTap: searchQuery.isNotEmpty
                      ? () => _searchCtrl.clear()
                      : null,
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // ── Filter Tags Row (Full Width Across Card) - always visible so
          // the active filter (if any) stays selectable/deselectable ──
          SizedBox(
            height: 38.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: kRecipeFilters.length,
              itemBuilder: (context, i) {
                final filter = kRecipeFilters[i];
                final isActive = _activeFilterId == filter.id;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeFilterId = isActive ? null : filter.id;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isActive ? context.colors.accent : context.colors.surface,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isActive ? context.colors.accent : context.colors.border,
                          width: 1.w,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            filter.emoji,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            filter.label,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: isActive ? Colors.white : context.colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 14.h),

          if (searchQuery.isNotEmpty || _activeFilterId != null)
            _buildInlineSearchResults(searchQuery)
          else ...[
          SizedBox(height: 10.h),

          // ── "For You" Section ──
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              // Background refreshes keep showing the last-known-good list
              // instead of flashing back to a spinner; only the true first
              // load (no cache yet) shows one.
              final categories = _categoriesCache ?? snapshot.data ?? [];
              if (categories.isEmpty) {
                if (_categoriesCache == null &&
                    snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SizedBox(
                      height: 200.h,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          color: context.colors.accent,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "For You",
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: context.colors.textPrimary,
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
                              color: context.colors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // ── For You Category Cards (Horizontal Scrollable) ──
                  SizedBox(
                    height: 200.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: categories.length,
                      itemBuilder: (context, i) {
                        final item = categories[i];
                        final name = (item['name'] as String?) ?? "Category";
                        final count = item['recipeCount'] != null
                            ? "${item['recipeCount']} recipes"
                            : "0 recipes";
                        final img = (item['image'] as String?) ?? "";

                        return Padding(
                          padding: EdgeInsets.only(right: 14.w),
                          child: SizedBox(
                            width: 160.w,
                            child: _buildCategoryCard(
                              title: name,
                              subtitle: count,
                              imagePath: img,
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
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          ],
        ],
      ),
    );
  }

  // ── Inline Search Results (replaces the old full-screen overlay) ──────────
  // Also serves quick-filter chip results: when a filter is active, this
  // draws from the wider `_filterPoolFuture` pool and applies its predicate,
  // combined with any typed text (AND) rather than the small popular-recipes
  // pool plain text search alone would use.
  Widget _buildInlineSearchResults(String query) {
    final activeFilter = _activeFilterId != null ? findRecipeFilter(_activeFilterId!) : null;
    return FutureBuilder<List<Recipe>>(
      future: activeFilter != null ? _filterPoolFuture : _popularFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 32.h),
            child: const Center(child: AppLoadingIndicator()),
          );
        }

        final lowerQuery = query.toLowerCase();
        final matches = (snapshot.data ?? [])
            .where((r) {
              if (activeFilter != null && !activeFilter.matches(r)) return false;
              if (lowerQuery.isEmpty) return true;
              return r.name.toLowerCase().contains(lowerQuery) ||
                  (r.cuisine?.toLowerCase().contains(lowerQuery) ?? false) ||
                  (r.categories?.any((c) => c.toLowerCase().contains(lowerQuery)) ?? false);
            })
            .toList();

        if (matches.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 32.h),
            child: Column(
              children: [
                Icon(Icons.search_off_rounded, size: 40.sp, color: context.colors.border),
                SizedBox(height: 12.h),
                Text(
                  'No recipes found',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  activeFilter != null && lowerQuery.isEmpty
                      ? 'No recipes match "${activeFilter.label}" yet.'
                      : 'Try a different search term.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 13.sp,
                    color: context.colors.textMuted,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    RecipeShortcutCard(
                      title: 'Scan',
                      icon: Icons.crop_free_rounded,
                      onTap: () => HomeScreen.tabRequestNotifier.value = 2,
                    ),
                    SizedBox(width: 12.w),
                    RecipeShortcutCard(
                      title: 'Import',
                      icon: Icons.file_download_outlined,
                      onTap: () => HomeScreen.tabRequestNotifier.value = 4,
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: matches.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, i) {
              final r = matches[i];
              return SavedRecipeCard(
                recipe: r,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.recipeDetail,
                    arguments: {'recipe': r, 'isPreview': true},
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    final String resolvedUrl = imagePath.startsWith('/')
        ? '${ApiConfig.baseUrl}$imagePath'
        : imagePath;
    final isNetwork = resolvedUrl.startsWith('http://') || resolvedUrl.startsWith('https://');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
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
                        imageUrl: _bustedUrl(resolvedUrl),
                        fit: BoxFit.cover,
                        memCacheWidth: 500,
                        fadeInDuration: const Duration(milliseconds: 150),
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
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
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
                      color: context.colors.textPrimary,
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
                      color: context.colors.textSecondary,
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

  String _getCuisineImagePath(String name, String? img) {
    if (img != null && img.trim().isNotEmpty) {
      final trimmed = img.trim();
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return trimmed;
      }
      if (trimmed.startsWith('/')) {
        return '${ApiConfig.baseUrl}$trimmed';
      }
      if (trimmed.startsWith('assets/')) {
        return trimmed;
      }
    }

    final lower = name.toLowerCase().trim();
    if (lower.contains('french')) return 'assets/cuisine/french.png';
    if (lower.contains('italian')) return 'assets/cuisine/italian.png';
    if (lower.contains('mexican')) return 'assets/cuisine/mexican.png';
    if (lower.contains('greek')) return 'assets/cuisine/greek.png';
    if (lower.contains('japanese')) return 'assets/cuisine/japanese.png';
    if (lower.contains('korean')) return 'assets/cuisine/korean.png';
    if (lower.contains('mediterranean')) return 'assets/cuisine/mediterranean.png';
    if (lower.contains('caribbean')) return 'assets/cuisine/caribbean.png';
    if (lower.contains('asian') || lower.contains('chinese')) return 'assets/cuisine/chinese.png';
    if (lower.contains('indian')) return 'assets/cuisine/indian.png';
    if (lower.contains('west african')) return 'assets/cuisine/west-african.png';
    if (lower.contains('east african')) return 'assets/cuisine/east-african.png';
    if (lower.contains('middle')) return 'assets/cuisine/middle-east.png';
    if (lower.contains('thai')) return 'assets/cuisine/thai.png';
    if (lower.contains('spanish')) return 'assets/cuisine/spanish.png';

    return 'assets/cuisine/others.png';
  }

  // ── Section 2: Cuisines Card (Full Width) ───────────────────────────────────
  Widget _buildCuisinesSectionCard() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _cuisinesFuture,
      builder: (context, snapshot) {
        final list = _cuisinesCache ?? snapshot.data ?? [];
        if (list.isEmpty) {
          if (_cuisinesCache == null &&
              snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20.h),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: SizedBox(
                height: 125.h,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    color: context.colors.accent,
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cuisines",
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
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
                      color: context.colors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          SizedBox(
                height: 125.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final item = list[i];
                    final name = (item['name'] as String?) ?? 'Cuisine';
                    final count = item['count'] != null
                        ? item['count'].toString()
                        : (item['recipeCount'] != null ? "${item['recipeCount']} recipes" : "0 recipes");
                    final rawImgPath = item['image'] as String?;
                    final imgPath = _getCuisineImagePath(name, rawImgPath);
                    final isNetwork = imgPath.startsWith('http');

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
                                  color: context.colors.accent,
                                  width: 2.5.w,
                                ),
                              ),
                              child: ClipOval(
                                child: isNetwork
                                    ? CachedNetworkImage(
                                        imageUrl: _bustedUrl(imgPath),
                                        fit: BoxFit.cover,
                                        memCacheWidth: 160,
                                        fadeInDuration: const Duration(milliseconds: 150),
                                        placeholder: (_, __) => Container(color: Colors.grey[200]),
                                        errorWidget: (_, __, ___) => Image.asset(
                                          _getCuisineImagePath(name, null),
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
                                color: context.colors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              count,
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400,
                                color: context.colors.textSecondary,
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
        );
      },
    );
  }

  // ── Section 3: Popular Now Card (Full Width & Shared Cards) ────────────────
  Widget _buildPopularNowSectionCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: context.colors.surface,
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
                  color: context.colors.textPrimary,
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
                    color: context.colors.accent,
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
                      isRegistered: RecipeService.instance.isRecipeSaved(r),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.recipeDetail,
                          arguments: {'recipe': r},
                        );
                      },
                      onFavoriteTap: () {
                        HapticFeedback.lightImpact();
                        final wasRegistered = RecipeService.instance.isRecipeSaved(r);
                        final newFavState = !wasRegistered;
                        setState(() {
                          r.isFavorite = newFavState;
                        });
                        if (newFavState) {
                          RecipeService.instance.markRecipeAsSaved(r);
                          IosToast.show(context, message: 'Recipe saved to favorites!', type: ToastType.success);
                        } else {
                          RecipeService.instance.markRecipeAsUnsaved(r);
                          if (r.id.isNotEmpty) {
                            RecipeService.instance.deleteRecipe(r.id);
                          }
                          r.isFavorite = false;
                          r.isInCookbook = false;
                          IosToast.show(context, message: 'Recipe removed from saved', type: ToastType.success);
                        }
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

}

