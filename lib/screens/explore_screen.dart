import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/app_search_field.dart';
import '../services/recipe_service.dart';
import '../services/grocery_service.dart';
import '../models/recipe.dart';
import '../models/grocery_item.dart';
import '../models/creator.dart';
import '../routes/app_routes.dart';
import 'home/view_all_screen.dart';

// ══════════════════════════════════════════════════════════════════════════════
// EXPLORE SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchCtrl = TextEditingController();
  int _selectedCategory = 0;

  Recipe? _latestFavorite;
  Recipe? _latestPublic;
  Recipe? _latestGroceryRecipe;
  List<Creator> _topCreators = [];
  List<Recipe> _popularRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    RecipeService.instance.favoriteRecipesNotifier.addListener(
      _onFavoritesChanged,
    );
  }

  @override
  void dispose() {
    RecipeService.instance.favoriteRecipesNotifier.removeListener(
      _onFavoritesChanged,
    );
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onFavoritesChanged() {
    final favs = RecipeService.instance.favoriteRecipesNotifier.value;
    if (favs != null && mounted) {
      setState(() {
        _latestFavorite = favs.isNotEmpty ? favs.first : null;
      });
    }
  }

  Future<void> _loadData() async {
    try {
      final favs = await RecipeService.instance.getFavoriteRecipes(size: 1);
      final explore = await RecipeService.instance.getExploreRecipes(size: 10);
      final creators = await RecipeService.instance.getTopCreators(size: 10);
      final popular = await RecipeService.instance.getPopularRecipes(size: 10);
      final groceries = await GroceryService.instance.getMyGroceries();

      // Find the most recent grocery item with a recipe
      GroceryItem? recentGrocery;
      for (var item in groceries.reversed) {
        if (item.recipeId != null) {
          recentGrocery = item;
          break;
        }
      }

      Recipe? groceryRecipe;
      if (recentGrocery != null && recentGrocery.recipeId != null) {
        groceryRecipe = await RecipeService.instance.getRecipe(
          recentGrocery.recipeId!,
        );
      }

      if (mounted) {
        setState(() {
          if (favs.isNotEmpty) _latestFavorite = favs.first;
          if (explore.isNotEmpty) _latestPublic = explore.first;
          _topCreators = creators;
          
          // Fallback to explore recipes if popular list is empty
          _popularRecipes = popular.isNotEmpty ? popular : explore;
          
          _latestGroceryRecipe = groceryRecipe;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadPopularRecipes(String? category) async {
    try {
      final popular = await RecipeService.instance.getPopularRecipes(
        category: category,
        size: 10,
      );
      if (mounted) {
        setState(() {
          _popularRecipes = popular;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  static const _categories = [
    ('🍕', 'Italian'),
    ('🥗', 'Healthy'),
    ('🥦', 'Vegetarian'),
    ('💪', 'High Protein'),
    ('🍜', 'Asian'),
    ('🥐', 'Bakery'),
  ];

  // (Statics removed or replaced by instance members)

  // Duplicate dispose merged above.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── Body sections ──────────────────────────────────────────────────
                SliverToBoxAdapter(child: _buildForYou(context)),
                SliverToBoxAdapter(child: _buildFromCreators(context)),
                if (_popularRecipes.isNotEmpty)
                  SliverToBoxAdapter(child: _buildPopularNow(context)),
                SliverToBoxAdapter(child: SizedBox(height: 120.h)),
                // Dynamic bottom spacer for keyboard
                SliverToBoxAdapter(
                  child: SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(15.r)),
      child: Stack(
        children: [
          // ── Background image ──────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/fond2.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          // ── Diagonal gradient overlay ─────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.1, 1.0],
                  colors: [Color(0xFFC83A2D), Color(0x63C83A2D)],
                ),
              ),
            ),
          ),
          // ── Content (no global x-padding — set per child) ─────────────
          Padding(
            padding: EdgeInsets.only(top: 40.h, bottom: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Explore" title – has x padding
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    'Explore',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w800,
                      fontSize: 24.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Search bar – has x padding
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: AppSearchField(
                    controller: _searchCtrl,
                    hintText: 'Search recipes, ingredients....',
                  ),
                ),

                SizedBox(height: 16.h),

                // Category chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(left: 20.w),
                  child: Row(
                    children: List.generate(_categories.length, (i) {
                      final (emoji, label) = _categories[i];
                      final active = _selectedCategory == i;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = i);
                          _loadPopularRecipes(label);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(right: 8.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFFFFF6D6)
                                : Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(30.r),
                            border: Border.all(
                              color: active
                                  ? const Color(0xFFF2C94C)
                                  : Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(emoji, style: TextStyle(fontSize: 13.sp)),
                              SizedBox(width: 6.w),
                              Text(
                                label,
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.sp,
                                  color: active
                                      ? const Color(0xFFCC3333)
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── For You ───────────────────────────────────────────────────────────────
  Widget _buildForYou(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 22.h, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 18.w),
            child: const _SectionHeader(title: 'For You', showViewAll: false),
          ),
          SizedBox(height: 10.h),
          _isLoading
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: const CircularProgressIndicator(color: Color(0xFFCC3333)),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // 1. Autumn's Favorites (Recent Favorite)
                      SizedBox(
                        width: 200.w,
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.favorites),
                          child: _CollectionCard(
                            img: _latestFavorite?.image,
                            fallbackAsset: 'assets/images/favorites.png',
                            title: "Autumn's Favorite",
                            subtitle: 'Curated seasonal comfort food for cold nights',
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // 2. Explore More (Recent Public)
                      SizedBox(
                        width: 200.w,
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.viewAll,
                            arguments: {
                              'type': ViewAllType.explore,
                              'title': 'Explore More',
                            },
                          ),
                          child: _CollectionCard(
                            img: _latestPublic?.image,
                            fallbackAsset: 'assets/images/spring.png',
                            title: 'Spring Delights',
                            subtitle: 'Fresh and vibrant meals to celebrate the season\'s bloom',
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // 3. Recent History (Recent Grocery)
                      SizedBox(
                        width: 200.w,
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.viewAll,
                            arguments: {
                              'type': ViewAllType.groceryHistory,
                              'title': 'Recent History',
                            },
                          ),
                          child: _CollectionCard(
                            img: _latestGroceryRecipe?.image,
                            fallbackAsset: 'assets/images/explore_spring.png',
                            title: 'Recent History',
                            subtitle: 'Recipes used in your grocery list',
                          ),
                        ),
                      ),
                      SizedBox(width: 18.w), // Inner right padding
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  // ── From Creators ─────────────────────────────────────────────────────────
  Widget _buildFromCreators(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 24.h, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 18.w),
            child: _SectionHeader(
              title: 'From Creators',
              showViewAll: true,
              onViewAll: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.viewAll,
                  arguments: {
                    'type': ViewAllType.creators,
                    'title': 'All Creators',
                  },
                );
              },
            ),
          ),
          SizedBox(height: 5.h),
          _topCreators.isEmpty
              ? SizedBox(
                  height: 100.h,
                  child: const Center(child: Text('No creators found')),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _topCreators
                        .map(
                          (creator) => Padding(
                            padding: EdgeInsets.only(right: 20.w),
                            child: _CreatorCard(creator: creator),
                          ),
                        )
                        .toList(),
                  ),
                ),
        ],
      ),
    );
  }

  // ── Popular Now ───────────────────────────────────────────────────────────
  Widget _buildPopularNow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 24.h, 18.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Now',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w800,
              fontSize: 20.sp,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _popularRecipes.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (ctx, i) {
              final recipe = _popularRecipes[i];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(
                  ctx,
                  '/recipe-detail',
                  arguments: {'recipe': recipe},
                ),
                child: _PopularCard(
                  index: i + 1,
                  recipe: recipe,
                  hearted: recipe.isFavorite,
                  onHeart: () => RecipeService.instance
                      .toggleFavorite(recipe.id)
                      .then((_) {
                        setState(() {
                          recipe.isFavorite = !recipe.isFavorite;
                        });
                      }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Section header row ────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  final bool showViewAll;
  const _SectionHeader({
    required this.title,
    this.onViewAll,
    this.showViewAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
        if (showViewAll)
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
    );
  }
}

// ── For You collection card ───────────────────────────────────────────────────
class _CollectionCard extends StatelessWidget {
  final String? img;
  final String title;
  final String subtitle;
  final String fallbackAsset;

  const _CollectionCard({
    required this.img,
    required this.title,
    required this.subtitle,
    required this.fallbackAsset,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = img != null && img!.isNotEmpty && img!.startsWith('http');

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: SizedBox(
              height: 100.h,
              width: double.infinity,
              child: isNetwork
                  ? CachedNetworkImage(
                      imageUrl: img!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Image.asset(
                        fallbackAsset,
                        fit: BoxFit.cover,
                      ),
                      placeholder: (_, __) => Container(
                        color: const Color(0xFFEEEEEE),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFCC3333)),
                        ),
                      ),
                    )
                  : Image.asset(
                      fallbackAsset,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              color: const Color(0xFF2D3133),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 12.sp,
              height: 1.3,
              color: const Color(0xFF707B81),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Creator circle card ───────────────────────────────────────────────────────
// Uses profile.png for all creators with a golden ring border
class _CreatorCard extends StatelessWidget {
  final Creator creator;
  const _CreatorCard({required this.creator});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Gold ring + photo
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE8B84B), width: 3.w),
          ),
          child: Padding(
            padding: EdgeInsets.all(3.r),
            child: ClipOval(
              child: creator.photo != null && creator.photo!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: creator.photo!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _buildPlaceholder(),
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFCC3333)),
                      ),
                    )
                  : _buildPlaceholder(),
            ),
          ),
        ),
        SizedBox(height: 5.h),
        SizedBox(
          width: 80.w,
          child: Text(
            creator.displayName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_rounded,
              size: 11.sp,
              color: const Color(0xFF999999),
            ),
            SizedBox(width: 4.w),
            Text(
              '${creator.publicRecipeCount} Recipes',
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
  }

  Widget _buildPlaceholder() {
    return Image.asset(
      'assets/images/profile.png',
      fit: BoxFit.cover,
    );
  }
}

// ── Popular Now recipe card ───────────────────────────────────────────────────
class _PopularCard extends StatelessWidget {
  final int index;
  final Recipe recipe;
  final bool hearted;
  final VoidCallback onHeart;
  const _PopularCard({
    required this.index,
    required this.recipe,
    required this.hearted,
    required this.onHeart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Expanded(
            child: Stack(
              children: [
                // Food photo
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(18.r),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: recipe.image != null && recipe.image!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: recipe.image!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _buildPlaceholder(),
                            placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFCC3333)),
                            ),
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                // Heart icon top-right
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: GestureDetector(
                    onTap: onHeart,
                    child: Icon(
                      hearted
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: hearted
                          ? const Color(0xFFCC3333)
                          : const Color(0xFFBBBBBB),
                      size: 22.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
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
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12.sp,
                      color: const Color(0xFF999999),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      '${recipe.cookTime} min',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 11.sp,
                        color: const Color(0xFF999999),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 12.sp,
                      color: const Color(0xFF999999),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        '${recipe.kcal} kcal',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 11.sp,
                          color: const Color(0xFF999999),
                        ),
                      ),
                    ),
                  ],
                ),
                if (recipe.creator != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'by ${recipe.creator!.displayName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 10.sp,
                        color: const Color(0xFFC83A2D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Image.asset(
      'assets/images/recipe_omelet.png',
      fit: BoxFit.cover,
    );
  }
}
