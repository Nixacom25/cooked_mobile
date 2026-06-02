import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooked/core/widgets/ios_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/app_search_field.dart';
import '../routes/app_routes.dart';
import '../services/recipe_service.dart';
import '../models/recipe.dart';
import '../models/view_all_type.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/recipe_grid_skeleton.dart';
import '../widgets/recipe_card.dart';
import '../core/extensions/string_extensions.dart';
import '../widgets/add_to_cookbook_sheet.dart';
import '../core/utils/error_helper.dart';

// ══════════════════════════════════════════════════════════════════════════════
// EXPLORE SCREEN (Backend Driven)
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
  bool _isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  OverlayEntry? _searchOverlayEntry;

  late Future<List<Map<String, dynamic>>> _cuisinesFuture;
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  late Future<List<Recipe>> _popularFuture;
  List<Recipe> _allPopularRecipes = [];
  List<Recipe> _allExploreRecipes = [];
  final List<Recipe> _recentRecipes = [];

  @override
  void initState() {
    super.initState();
    _cuisinesFuture = RecipeService.instance.getExploreCuisines();
    _categoriesFuture = RecipeService.instance.getExploreCategories();
    _popularFuture = RecipeService.instance.getPopularRecipes(size: 10);

    RecipeService.instance.getExploreRecipes(size: 100).then((recipes) {
      if (mounted) {
        setState(() {
          _allExploreRecipes = recipes;
        });
      }
    }).catchError((_) {});

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
      setState(() {
        _isSearching = true;
      });
      _animationController.forward();
      _showOverlay();
    } else {
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _searchCtrl.clear();
            _overlaySearchCtrl.clear();
          });
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

  @override
  void dispose() {
    _searchCtrl.dispose();
    _overlaySearchCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }


  void _handleValidation(Recipe r, bool isSaved) {
    if (isSaved) {
      IosToast.show(
        context,
        message: "Already in your recipes",
        type: ToastType.success,
      );
      return;
    }

    // 1. Optimistic Save immediately 'In Direct'
    RecipeService.instance.validateRecipe(r.id).catchError((e) {
      if (mounted) {
        IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
      }
      return r;
    });
    _updateLocalStateForValidation(r);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddToCookbookSheet(
        recipe: r,
        onSuccess: () => _updateLocalStateForValidation(r),
      ),
    );
  }

  void _updateLocalStateForValidation(Recipe r) {
    if (!mounted) return;
    
    final validatedRecipe = r.copyWith(origin: 'MANUAL', isValidated: true, isSuggested: false);

    // Update global state via notifiers
    final currentSaved = RecipeService.instance.myRecipesNotifier.value ?? [];
    if (!currentSaved.any((item) => item.id == r.id)) {
      RecipeService.instance.myRecipesNotifier.value = [validatedRecipe, ...currentSaved];
    }

    // Refresh backgrounds
    RecipeService.instance.getMyRecipes(forceRefresh: true).catchError((_) => <Recipe>[]);
    RecipeService.instance.getPopularRecipes(forceRefresh: true).catchError((_) => <Recipe>[]);
    
    setState(() {}); // Local refresh
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
              SizedBox(height: 50.h),
            ],
          ),
        ),
      ],
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
            Opacity(
              opacity: (_isSearching || _animationController.isAnimating)
                  ? 0.0
                  : 1.0,
              child: GestureDetector(
                onTap: () => _toggleSearch(true),
                child: AbsorbPointer(
                  child: AppSearchField(
                    controller: _searchCtrl,
                    hintText: 'Search recipes, ingredients....',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Browse by Cuisine ───────────────────────────────────────────────────────
  Widget _buildBrowseByCuisine() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _cuisinesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(title: 'Browse by Cuisine', onViewAll: () {}),
              SizedBox(height: 8.h),
              SizedBox(
                height: 90.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: 5,
                  itemBuilder: (_, __) => Padding(
                    padding: EdgeInsets.only(right: 15.w),
                    child: Column(
                      children: [
                        SkeletonLoader(
                          width: 65.w,
                          height: 65.h,
                          borderRadius: 32.5,
                        ),
                        SizedBox(height: 5.h),
                        SkeletonLoader(width: 50.w, height: 12.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final filteredList = snapshot.data!;

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
                itemCount: filteredList.length,
                itemBuilder: (context, i) {
                  final item = filteredList[i];
                  final name = item['name'] as String;
                  final imageUrl = item['image'] as String?;

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
                              color: const Color(0xFFF2F1EF),
                              image: imageUrl != null && imageUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: CachedNetworkImageProvider(imageUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: imageUrl == null || imageUrl.isEmpty
                                ? Center(
                                    child: Icon(
                                      Icons.restaurant_menu,
                                      color: const Color(0xFFC83A2D),
                                      size: 24.sp,
                                    ),
                                  )
                                : null,
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            name.toTitleCase(),
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(title: 'Popular Categories', onViewAll: () {}),
              SizedBox(height: 8.h),
              SizedBox(
                height: 200.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: 3,
                  itemBuilder: (_, __) => Container(
                    width: 160.w,
                    margin: EdgeInsets.only(right: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoader(
                          width: 160.w,
                          height: 130.h,
                          borderRadius: 16,
                        ),
                        SizedBox(height: 10.h),
                        SkeletonLoader(width: 120.w, height: 14.h),
                        SizedBox(height: 4.h),
                        SkeletonLoader(width: 80.w, height: 12.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final filteredList = snapshot.data!;

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
                itemCount: filteredList.length,
                itemBuilder: (context, i) {
                  final item = filteredList[i];
                  final name = item['name'] as String;
                  final count = item['recipeCount'] ?? 0;
                  final imageUrl = item['image'] as String?;
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
                            child: imageUrl != null && imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    width: 160.w,
                                    height: 130.h,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => SkeletonLoader(
                                      width: 160.w,
                                      height: 130.h,
                                      borderRadius: 16,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      'assets/images/others.png',
                                      width: 160.w,
                                      height: 130.h,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Image.asset(
                                    'assets/images/others.png',
                                    width: 160.w,
                                    height: 130.h,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            name.toTitleCase(),
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
        if (snapshot.hasError) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.grey),
                SizedBox(height: 8.h),
                Text(
                  'Could not load popular recipes.',
                  style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _popularFuture = RecipeService.instance.getPopularRecipes(
                        size: 10,
                        forceRefresh: true,
                      );
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: const SkeletonLoader(width: 120, height: 18),
              ),
              SizedBox(height: 12.h),
              const RecipeGridSkeleton(
                itemCount: 4,
                padding: EdgeInsets.symmetric(horizontal: 20),
                childAspectRatio: 0.72,
              ),
            ],
          );
        }

        final popular = snapshot.data ?? [];
        if (_allPopularRecipes.isEmpty && popular.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _allPopularRecipes = popular);
          });
        }

        final displayList = popular.length > 10
            ? popular.sublist(0, 10)
            : popular;

        if (displayList.isEmpty) {
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
              child: ValueListenableBuilder<List<Recipe>?>(
                valueListenable: RecipeService.instance.myRecipesNotifier,
                builder: (context, savedRecipes, _) {
                  final savedIds = (savedRecipes ?? []).map((r) => r.id).toSet();
                  final savedNames = (savedRecipes ?? [])
                      .map((r) => r.name.toLowerCase())
                      .toSet();

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: popular.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 20.h,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, i) {
                      final recipe = popular[i];
                      final isSaved = savedIds.contains(recipe.id) ||
                          savedNames.contains(recipe.name.toLowerCase());

                      return RecipeCard(
                        recipe: recipe,
                        rank: i + 1,
                        useValidationIcon: true,
                        isValidated: isSaved,
                        animationDelay: Duration(milliseconds: i * 800),
                        useExploreButton: true,
                        disableSlide: true,
                        onValidateTap: () => _handleValidation(recipe, isSaved),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.recipeDetail,
                            arguments: {
                              'recipe': recipe,
                              'isPreview': !isSaved,
                            },
                          );
                        },
                        onAddToCookbookTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) => AddToCookbookSheet(recipe: recipe),
                          );
                        },
                        onShareTap: () {
                          // Share logic
                        },
                        onPinTap: isSaved
                            ? () {
                                // Pin logic
                              }
                            : null,
                        onDeleteTap: isSaved
                            ? () async {
                                final success = await RecipeService.instance
                                    .deleteRecipe(recipe.id);
                                if (success && context.mounted) {
                                  IosToast.show(
                                    context,
                                    message: 'Recipe deleted',
                                    type: ToastType.success,
                                  );
                                }
                              }
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Search Overlay ──────────────────────────────────────────────────────────
  Widget _buildSearchOverlay() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Use a sharper curve for an even faster feel
        final curvedValue = CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutQuart,
        ).value;

        final topPos = lerpDouble(135.h, 100.h, curvedValue)!;
        final horizontalPadding = lerpDouble(20.w, 12.w, curvedValue)!;
        final borderRadius = lerpDouble(50.r, 32.r, curvedValue)!;
        final screenHeight = MediaQuery.of(context).size.height;
        final bottomLimit = topPos / 2; // User requested: bottom = top / 2
        final maxModalHeight = screenHeight - topPos - bottomLimit;
        
        // Dynamic height: expand only if needed, but limited by maxModalHeight
        final height = curvedValue < 1.0 
            ? lerpDouble(50.h, 450.h, curvedValue)!
            : maxModalHeight;
        final bgColor = Color.lerp(
          Colors.white,
          const Color(0xFFF7F7F7),
          curvedValue,
        )!;

        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Backdrop Blur
              GestureDetector(
                onTap: () => _toggleSearch(false),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(color: Colors.black.withOpacity(0.3)),
                  ),
                ),
              ),
              // Expanding Search Card
              Positioned(
                top: topPos,
                left: horizontalPadding,
                right: horizontalPadding,
                child: Container(
                  constraints: BoxConstraints(maxHeight: height),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08 * curvedValue),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: curvedValue > 0.9
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header when expanded
                        if (curvedValue > 0.5)
                          FadeTransition(
                            opacity: _animationController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Explore',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22.sp,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                              ],
                            ),
                          ),

                        // The Search Input (Morphs size/style)
                        AppSearchField(
                          controller: _overlaySearchCtrl,
                          hintText: curvedValue > 0.5
                              ? 'Search recipes, ingredients...'
                              : 'Start your search',
                          backgroundColor: Colors.white,
                          borderColor: curvedValue > 0.5
                              ? const Color(0xFFDDDDDD)
                              : Colors.transparent,
                          onChanged: (val) {
                            _searchOverlayEntry?.markNeedsBuild();
                          },
                        ),

                        if (curvedValue > 0.8)
                          FadeTransition(
                            opacity: _animationController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 24.h),
                                if (_overlaySearchCtrl.text.length >= 3) ...[
                                  Text(
                                    'Search results',
                                    style: TextStyle(
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                ],
                                if (_overlaySearchCtrl.text.length < 3) ...[
                                  Text(
                                    'Recommended',
                                    style: TextStyle(
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.sp,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  SizedBox(
                                    height: 34.h,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      children:
                                          [
                                                'Chicken',
                                                'Beef',
                                                'Fish',
                                                'Dessert',
                                                'Pasta',
                                                'Vegetarian',
                                                'Healthy',
                                                'Breakfast',
                                              ]
                                              .map(
                                                (tag) => GestureDetector(
                                                  onTap: () {
                                                    _overlaySearchCtrl.text = tag;
                                                    _searchOverlayEntry
                                                        ?.markNeedsBuild();
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                      right: 8.w,
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 14.w,
                                                        ),
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20.r,
                                                          ),
                                                      border: Border.all(
                                                        color: const Color(
                                                          0xFFEEEEEE,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      tag,
                                                      style: TextStyle(
                                                        fontFamily: 'SF Pro',
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: const Color(
                                                          0xFF4B5563,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                  Text(
                                    'Recents',
                                    style: TextStyle(
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.sp,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                ],
                                if (_overlaySearchCtrl.text.length < 3)
                                  ...(_recentRecipes.isEmpty
                                      ? [
                                          Text(
                                            'No recent searches',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ]
                                      : _recentRecipes.map(
                                          (r) => _buildRecentSearchItem(r),
                                        ))
                                else
                                  ...(() {
                                    final q = _overlaySearchCtrl.text
                                        .toLowerCase();
                                    final sourceList = _allExploreRecipes.isNotEmpty
                                        ? _allExploreRecipes
                                        : _allPopularRecipes;
                                    final filtered = sourceList
                                        .where(
                                          (r) =>
                                              r.name.toLowerCase().contains(q),
                                        )
                                        .toList();
                                    if (filtered.isEmpty) {
                                      return [
                                        Text(
                                          'No results found',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ];
                                    }
                                    return filtered.map(
                                      (r) => _buildRecentSearchItem(r),
                                    );
                                  }()),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Close Button
              Positioned(
                top: MediaQuery.of(context).padding.top + 10.h,
                right: 16.w,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: GestureDetector(
                    onTap: () => _toggleSearch(false),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.black87,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentSearchItem(Recipe recipe) {
    return GestureDetector(
      onTap: () {
        if (!_recentRecipes.contains(recipe)) {
          setState(() {
            _recentRecipes.insert(0, recipe);
            if (_recentRecipes.length > 5) _recentRecipes.removeLast();
          });
        }
        _toggleSearch(false);
        Navigator.pushNamed(
          context,
          AppRoutes.recipeDetail,
          arguments: {'recipe': recipe},
        );
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: _buildItemImage(recipe.image),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    '${recipe.kcal} kcal • ${recipe.cookTime} min',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 12.sp,
                      color: const Color(0xFF6B7280),
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

  Widget _buildItemImage(String? path) {
    final imagePath = path ?? '';
    if (imagePath.isEmpty || imagePath == 'null') {
      return Image.asset(
        'assets/images/recipes.png',
        fit: BoxFit.cover,
      );
    }

    if (imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: const Color(0xFFF3F4F6),
        ),
        errorWidget: (context, url, error) => Image.asset(
          'assets/images/recipes.png',
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        'assets/images/recipes.png',
        fit: BoxFit.cover,
      ),
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
