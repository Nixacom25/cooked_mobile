import 'package:cooked/widgets/recipe_grid_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/red_header_background.dart';
import '../../widgets/recipe_card.dart';
import '../../models/recipe.dart';
import '../../models/cookbook.dart';
import '../../models/creator.dart';
import '../../services/recipe_service.dart';
import '../../services/history_service.dart';
import '../../services/cookbook_service.dart';
import '../../services/grocery_service.dart';
import '../../core/widgets/ios_toast.dart';
import '../../models/view_all_type.dart';
import '../../core/extensions/string_extensions.dart';
import '../../widgets/cookbook_grid_skeleton.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/add_to_cookbook_sheet.dart';
import '../../widgets/cookbook_form_modal.dart';
import '../../widgets/haptic_context_menu.dart';
import '../../core/utils/error_helper.dart';
import '../../widgets/recent_import_tile.dart';
import '../../widgets/saved_recipe_card.dart';

// ══════════════════════════════════════════════════════════════════════════════
// VIEW ALL SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class ViewAllScreen extends StatefulWidget {
  const ViewAllScreen({super.key});
  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier('');
  Key _gridKey = UniqueKey();

  @override
  void dispose() {
    _searchQueryNotifier.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh(ViewAllType type) async {
    try {
      if (type == ViewAllType.exploreCuisines) {
        await RecipeService.instance.getExploreCuisines(forceRefresh: true);
      } else if (type == ViewAllType.exploreCategories) {
        await RecipeService.instance.getExploreCategories(forceRefresh: true);
      } else if (type == ViewAllType.savedRecipes) {
        await RecipeService.instance.getMyRecipes(forceRefresh: true);
      } else if (type == ViewAllType.imports) {
        await RecipeService.instance.getRecentImports(forceRefresh: true, size: 50);
      } else if (type == ViewAllType.exploreRecipesByCuisine) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        final cuisine = args['cuisine'] as String?;
        await RecipeService.instance.getExploreRecipes(cuisine: cuisine, forceRefresh: true, size: 50);
      } else if (type == ViewAllType.exploreRecipesByCategory) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        final category = args['category'] as String?;
        await RecipeService.instance.getExploreRecipes(category: category, forceRefresh: true, size: 50);
      } else if (type == ViewAllType.explore) {
        await RecipeService.instance.getExploreRecipes(forceRefresh: true, size: 50);
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _gridKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final ViewAllType type = args['type'] as ViewAllType;
    final String title = type == ViewAllType.exploreCuisines
        ? 'Cuisine'
        : (args['title'] as String? ?? '');
    final bool showPlus = type == ViewAllType.cookbooks;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: RedHeaderBackground(),
          ),
          SafeArea(
            bottom: false,
            child: Container(
              margin: EdgeInsets.only(top: 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32.r),
                ),
              ),
              child: Column(
                children: [
                  // ── AppBar ────────────────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 42.r,
                            height: 42.r,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 20.sp,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title.toTitleCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22.sp,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              _buildSubtitleBadge(type),
                            ],
                          ),
                        ),
                        if (showPlus)
                          GestureDetector(
                            onTap: () async {
                              await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => const CookbookFormModal(),
                              );
                            },
                            child: Container(
                              width: 42.r,
                              height: 42.r,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                color: const Color(0xFF0F172A),
                                size: 22.sp,
                              ),
                            ),
                          )
                        else
                          SizedBox(width: 42.r),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // ── Search bar (matches design mockup) ────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: AppSearchField(
                      onChanged: (val) {
                        _searchQueryNotifier.value = val;
                      },
                      hintText: type == ViewAllType.cookbooks
                          ? 'Search your recipes'
                          : type == ViewAllType.exploreCuisines
                              ? 'Search cuisine ...'
                              : type == ViewAllType.exploreCategories
                                  ? 'Search category ...'
                                  : type == ViewAllType.exploreRecipesByCuisine
                                      ? 'Search ${title.toLowerCase()} recipes...'
                                      : type == ViewAllType.recentlyViewed
                                          ? 'Search recently viewed recipes..'
                                          : 'Search recipes, cookbooks....',
                      backgroundColor: const Color(0xFFF1F5F9),
                      borderColor: Colors.transparent,
                      borderRadius: 16.r,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── Content ───────────────────────────────────────────────────
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _handleRefresh(type),
                      color: const Color(0xFFC83A2D),
                      child: ValueListenableBuilder<String>(
                        valueListenable: _searchQueryNotifier,
                        builder: (context, query, _) {
                          return _buildContent(type, query);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ViewAllType type, String query) {
    switch (type) {
      case ViewAllType.cookbooks:
        return _CookbooksGrid(key: _gridKey, searchQuery: query);
      case ViewAllType.savedRecipes:
      case ViewAllType.recentlyViewed:
      case ViewAllType.explore:
      case ViewAllType.groceryHistory:
      case ViewAllType.imports:
      case ViewAllType.exploreRecipesByCuisine:
      case ViewAllType.exploreRecipesByCategory:
        return _RecipesGrid(key: _gridKey, searchQuery: query);
      case ViewAllType.creators:
        return _CreatorsGrid(key: _gridKey, searchQuery: query);
      case ViewAllType.exploreCuisines:
      case ViewAllType.exploreCategories:
        return _StaticCookbooksGrid(key: _gridKey, type: type, searchQuery: query);
    }
  }

  Widget _buildSubtitleBadge(ViewAllType type) {
    ValueNotifier<List<Recipe>?>? notifier;
    if (type == ViewAllType.savedRecipes) {
      notifier = RecipeService.instance.myRecipesNotifier;
    } else if (type == ViewAllType.imports)
      notifier = RecipeService.instance.recentImportsNotifier;

    if (notifier == null) return const SizedBox.shrink();

    return ValueListenableBuilder<List<Recipe>?>(
      valueListenable: notifier,
      builder: (context, recipes, _) {
        final count = recipes?.length ?? 0;
        return Text(
          '$count Recipes',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// COOKBOOKS GRID
// ══════════════════════════════════════════════════════════════════════════════
class _OverlappingAvatars extends StatelessWidget {
  final List<String> imageUrls;
  const _OverlappingAvatars({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    final List<String> defaultAssets = [
      'assets/images/plat1.png',
      'assets/images/plat2.png',
      'assets/images/plat3.png',
    ];

    List<Widget> avatarWidgets = [];
    for (int i = 0; i < 3; i++) {
      String path = i < imageUrls.length && imageUrls[i].isNotEmpty
          ? imageUrls[i]
          : defaultAssets[i % defaultAssets.length];

      avatarWidgets.add(
        Positioned(
          left: (i * 22).w,
          child: Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.r),
              color: const Color(0xFFF1F5F9),
            ),
            child: ClipOval(
              child: path.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: path,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Image.asset(
                        defaultAssets[i % defaultAssets.length],
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      path,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        defaultAssets[i % defaultAssets.length],
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 36.r,
      width: (36 + 2 * 22).w,
      child: Stack(
        clipBehavior: Clip.none,
        children: avatarWidgets,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// COOKBOOKS GRID
// ══════════════════════════════════════════════════════════════════════════════
class _CookbooksGrid extends StatefulWidget {
  final String searchQuery;
  const _CookbooksGrid({super.key, this.searchQuery = ''});

  @override
  State<_CookbooksGrid> createState() => _CookbooksGridState();
}

class _CookbooksGridState extends State<_CookbooksGrid> {
  @override
  void initState() {
    super.initState();
    if (CookbookService.instance.myCookbooksNotifier.value == null) {
      CookbookService.instance.getMyCookbooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Cookbook>?>(
      valueListenable: CookbookService.instance.myCookbooksNotifier,
      builder: (context, cookbooks, _) {
        if (cookbooks == null) {
          return CookbookGridSkeleton(
            childAspectRatio: 1.15,
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
          );
        }

        if (cookbooks.isEmpty) {
          return const Center(child: Text("No cookbooks found."));
        }

        List<Cookbook> displayList = cookbooks;
        if (widget.searchQuery.trim().isNotEmpty) {
          final query = widget.searchQuery.trim().toLowerCase();
          displayList = displayList
              .where((cb) => cb.name.toLowerCase().contains(query))
              .toList();
        }

        if (displayList.isEmpty) {
          return const Center(child: Text("No cookbooks match your search."));
        }

        return GridView.builder(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
          itemCount: displayList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14.w,
            mainAxisSpacing: 14.h,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (ctx, i) {
            final cb = displayList[i];
            final imageUrls = cb.recipes
                .map((r) => r.image ?? '')
                .where((img) => img.isNotEmpty)
                .toList();

            return GestureDetector(
              onTap: () async {
                final result = await Navigator.pushNamed(
                  ctx,
                  AppRoutes.cookbookDetail,
                  arguments: {'cookbook': cb},
                );
                if (result == true) {
                  CookbookService.instance.getMyCookbooks(forceRefresh: true);
                }
              },
              onLongPressStart: (details) {
                HapticContextMenu.show(
                  ctx,
                  targetPosition: details.globalPosition,
                  actions: [
                    HapticMenuAction(
                      title: 'Add Recipes',
                      icon: Icons.add_circle_outline_rounded,
                      onTap: () async {
                        final result = await showModalBottomSheet(
                          context: ctx,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => CookbookFormModal(cookbook: cb),
                        );
                        if (result is Cookbook || result == 'deleted') {
                          CookbookService.instance.getMyCookbooks(
                            forceRefresh: true,
                          );
                        }
                      },
                    ),
                    HapticMenuAction(
                      title: 'Edit Cookbook',
                      icon: Icons.edit_outlined,
                      onTap: () async {
                        final result = await showModalBottomSheet(
                          context: ctx,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => CookbookFormModal(cookbook: cb),
                        );
                        if (result is Cookbook || result == 'deleted') {
                          CookbookService.instance.getMyCookbooks(
                            forceRefresh: true,
                          );
                        }
                      },
                    ),
                    HapticMenuAction(
                      title: 'Pin Cookbook',
                      icon: Icons.push_pin_outlined,
                      onTap: () {
                        // Pin logic
                      },
                    ),
                    HapticMenuAction(
                      title: 'Delete Cookbook',
                      icon: Icons.delete_outline_rounded,
                      isDestructive: true,
                      onTap: () async {
                        try {
                          await CookbookService.instance.deleteCookbook(cb.id);
                          if (ctx.mounted) {
                            IosToast.show(
                              ctx,
                              message: 'Cookbook deleted',
                              type: ToastType.success,
                            );
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            IosToast.show(
                              ctx,
                              message: 'Failed to delete cookbook',
                              type: ToastType.error,
                            );
                          }
                        }
                      },
                    ),
                  ],
                );
              },
              child: Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF5E8),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _OverlappingAvatars(imageUrls: imageUrls),
                    SizedBox(height: 8.h),
                    Text(
                      cb.name.toTitleCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.flatware_rounded,
                          size: 15.sp,
                          color: const Color(0xFF64748B),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            '${cb.recipes.length} Recipes',
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w500,
                              fontSize: 13.sp,
                              color: const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// RECIPES GRID  (saved recipes)
// ══════════════════════════════════════════════════════════════════════════════
class _RecipesGrid extends StatefulWidget {
  final String searchQuery;
  const _RecipesGrid({super.key, this.searchQuery = ''});

  @override
  State<_RecipesGrid> createState() => _RecipesGridState();
}

class _RecipesGridState extends State<_RecipesGrid> {
  Future<List<Recipe>>? _future;
  late ViewAllType _type;
  final Set<String> _validatedRecipeIds = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_future != null) return; // Already loading/loaded

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _type = args['type'] as ViewAllType;
    // Removed _load() call as we rely on notifiers for my recipes/favorites/imports/history
    if (_type == ViewAllType.explore ||
        _type == ViewAllType.exploreRecipesByCuisine ||
        _type == ViewAllType.exploreRecipesByCategory ||
        _type == ViewAllType.groceryHistory) {
      _load();
    }
  }

  void _load() {
    switch (_type) {
      case ViewAllType.savedRecipes:
        if (RecipeService.instance.myRecipesNotifier.value == null) {
          RecipeService.instance.getMyRecipes();
        }
        break;
      case ViewAllType.imports:
        RecipeService.instance.getRecentImports(size: 50);
        break;
      case ViewAllType.recentlyViewed:
        HistoryService.instance.loadHistory();
        break;
      case ViewAllType.explore:
        _future = RecipeService.instance.getExploreRecipes(size: 50);
        break;
      case ViewAllType.exploreRecipesByCuisine:
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        final cuisine = args['cuisine'] as String?;
        _future = RecipeService.instance
            .getExploreRecipes(cuisine: cuisine, size: 50)
            .then((results) async {
              if (results.isNotEmpty) return results;
              final myRecs = RecipeService.instance.myRecipesNotifier.value ?? [];
              final suggestions = RecipeService.instance.homeSuggestionsNotifier.value ?? [];
              final combined = [...myRecs, ...suggestions];
              if (cuisine != null && cuisine.isNotEmpty) {
                final q = cuisine.toLowerCase();
                final matches = combined
                    .where(
                      (r) =>
                          (r.cuisine != null &&
                              r.cuisine!.toLowerCase().contains(q)) ||
                          r.name.toLowerCase().contains(q),
                    )
                    .toList();
                if (matches.isNotEmpty) return matches;
              }
              return combined;
            });
        break;
      case ViewAllType.exploreRecipesByCategory:
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        final category = args['category'] as String?;
        _future = RecipeService.instance
            .getExploreRecipes(category: category, size: 50)
            .then((results) async {
              if (results.isNotEmpty) return results;
              final myRecs = RecipeService.instance.myRecipesNotifier.value ?? [];
              final suggestions = RecipeService.instance.homeSuggestionsNotifier.value ?? [];
              final combined = [...myRecs, ...suggestions];
              if (category != null && category.isNotEmpty) {
                final q = category.toLowerCase();
                final matches = combined
                    .where(
                      (r) =>
                          (r.categories != null &&
                              r.categories!.any(
                                (c) => c.toLowerCase().contains(q),
                              )) ||
                          r.name.toLowerCase().contains(q),
                    )
                    .toList();
                if (matches.isNotEmpty) return matches;
              }
              return combined;
            });
        break;
      case ViewAllType.groceryHistory:
        _future = _fetchGroceryHistory();
        break;
      default:
        if (RecipeService.instance.myRecipesNotifier.value == null) {
          RecipeService.instance.getMyRecipes();
        }
    }
  }

  Future<List<Recipe>> _fetchGroceryHistory() async {
    final groceries = await GroceryService.instance.getMyGroceries();
    final recipeIds = <String>{};
    final recipes = <Recipe>[];

    for (var item in groceries.reversed) {
      if (item.recipeId != null && !recipeIds.contains(item.recipeId)) {
        recipeIds.add(item.recipeId!);
        try {
          final r = await RecipeService.instance.getRecipe(item.recipeId!);
          recipes.add(r);
        } catch (_) {}
      }
    }
    return recipes;
  }

  Widget _buildGrid(List<Recipe> recipes) {
    List<Recipe> displayList = recipes;
    if (widget.searchQuery.trim().isNotEmpty) {
      final query = widget.searchQuery.trim().toLowerCase();
      displayList = displayList
          .where((r) => r.name.toLowerCase().contains(query))
          .toList();
    }

    if (displayList.isEmpty) {
      return const Center(child: Text("No recipes match your search."));
    }

    return ValueListenableBuilder<List<Recipe>?>(
      valueListenable: RecipeService.instance.myRecipesNotifier,
      builder: (context, savedRecipes, _) {
        final savedIds = (savedRecipes ?? []).map((r) => r.id).toSet();

        if (_type == ViewAllType.imports) {
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            itemCount: displayList.length,
            itemBuilder: (ctx, i) {
              final r = displayList[i];
              final isSaved =
                  r.isInCookbook ||
                  savedIds.contains(r.id) ||
                  _validatedRecipeIds.contains(r.id);

              String source = 'Web';
              IconData icon = Icons.language_rounded;
              Color iconColor = const Color(0xFF888888);
              String? sourceAsset;

              if (r.sourceUrl?.contains('instagram.com') ?? false) {
                source = 'Instagram';
                iconColor = const Color(0xFFe6683c);
                sourceAsset = 'assets/images/instagram.png';
              } else if (r.sourceUrl?.contains('tiktok.com') ?? false) {
                source = 'TikTok';
                iconColor = Colors.black;
                sourceAsset = 'assets/images/tiktok.png';
              } else if (r.sourceUrl?.contains('youtube.com') ?? false) {
                source = 'YouTube';
                iconColor = Colors.red;
                sourceAsset = 'assets/images/youtube.png';
              } else if (r.sourceUrl?.contains('facebook.com') ?? false) {
                source = 'Facebook';
                iconColor = Colors.blue;
                sourceAsset = 'assets/images/facebook.png';
              }

              return RecentImportTile(
                img: r.image ?? '',
                title: r.name,
                source: source,
                sourceUrl: r.sourceUrl,
                srcIcon: icon,
                srcIconColor: iconColor,
                srcAsset: sourceAsset,
                isSuggested: true,
                index: i,
                onValidate: () => _handleValidation(ctx, r, isSaved),
                isValidated: isSaved,
              );
            },
          );
        }

        if (_type == ViewAllType.exploreRecipesByCuisine ||
            _type == ViewAllType.exploreRecipesByCategory ||
            _type == ViewAllType.savedRecipes ||
            _type == ViewAllType.recentlyViewed ||
            _type == ViewAllType.explore) {
          final showSectionHeader = _type == ViewAllType.recentlyViewed;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showSectionHeader)
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 12.h),
                  child: Text(
                    'Recipes',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w800,
                      fontSize: 20.sp,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
                  itemCount: displayList.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (ctx, i) {
                    final r = displayList[i];
                    final isSaved =
                        r.isInCookbook ||
                        savedIds.contains(r.id) ||
                        _validatedRecipeIds.contains(r.id);

                    return SavedRecipeCard(
                      recipe: r,
                      isPinned: isSaved,
                      onPinTap: () async {
                        try {
                          await RecipeService.instance.getMyRecipes(forceRefresh: true);
                        } catch (_) {}
                      },
                      onTap: () async {
                        await Navigator.pushNamed(
                          ctx,
                          AppRoutes.recipeDetail,
                          arguments: {'recipe': r, 'isPreview': !isSaved},
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          itemCount: displayList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14.h,
            crossAxisSpacing: 14.w,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (ctx, i) {
            final r = displayList[i];
            final isExplore =
                _type == ViewAllType.explore ||
                _type == ViewAllType.exploreRecipesByCuisine ||
                _type == ViewAllType.exploreRecipesByCategory;
            final isCuisineOrCategory =
                _type == ViewAllType.exploreRecipesByCuisine ||
                _type == ViewAllType.exploreRecipesByCategory;
            final isSaved =
                r.isInCookbook ||
                savedIds.contains(r.id) ||
                _validatedRecipeIds.contains(r.id);

            return RecipeCard(
              recipe: r,
              useValidationIcon:
                  isExplore, // Removed isImport here as it uses ListView above
              isValidated: isSaved,
              animationDelay: Duration(milliseconds: i * 800),
              useExploreButton: isExplore,
              disableSlide: true,
              inactiveColor: isCuisineOrCategory
                  ? const Color(0xFF9CA3AF)
                  : null,
              onValidateTap: isExplore
                  ? () => _handleValidation(ctx, r, isSaved)
                  : null,
              onAddToCookbookTap: (isSaved || isExplore)
                  ? () {
                      showModalBottomSheet(
                        context: ctx,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => AddToCookbookSheet(recipe: r),
                      );
                    }
                  : null,
              onShareTap: (isSaved || isExplore)
                  ? () async {
                      try {
                        final RenderBox? box = ctx.findRenderObject() as RenderBox?;
                        final Rect? sharePositionOrigin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;
                        final rawLink = await RecipeService.instance.getShareLink(r.id);
                        final link = rawLink.replaceAll('cooked.nixacom.com','link.cookedapp.com').replaceAll('https://cookedapp.app','https://link.cookedapp.com');
                        final name = r.name;
                        final creatorStr = r.creator != null ? "${r.creator!.displayName}'s " : "";
                        final template = "Check out $creatorStr$name on Cooked 🙌\n$link";

                        Share.share(
                          template,
                          sharePositionOrigin: sharePositionOrigin,
                        );
                      } catch (e) {
                        if (ctx.mounted) {
                          IosToast.show(
                            ctx,
                            message: ErrorHelper.getFriendlyMessage(e),
                            type: ToastType.error,
                          );
                        }
                      }
                    }
                  : null,
              onPinTap: isSaved
                  ? () {
                      RecipeService.instance
                          .togglePin(r.id)
                          .then((updated) {
                            if (ctx.mounted) {
                              IosToast.show(
                                ctx,
                                message: updated.isPinned
                                    ? 'Recipe pinned'
                                    : 'Recipe unpinned',
                                type: ToastType.success,
                              );
                            }
                          })
                          .catchError((e) {
                            if (ctx.mounted) {
                              IosToast.show(
                                ctx,
                                message: 'Failed to pin recipe',
                                type: ToastType.error,
                              );
                            }
                          });
                    }
                  : null,
              onDeleteTap: isSaved
                  ? () async {
                      final success = await RecipeService.instance.deleteRecipe(
                        r.id,
                      );
                      if (success && ctx.mounted) {
                        IosToast.show(
                          ctx,
                          message: 'Recipe deleted',
                          type: ToastType.success,
                        );
                      }
                    }
                  : null,
              onTap: () async {
                await Navigator.pushNamed(
                  ctx,
                  AppRoutes.recipeDetail,
                  arguments: {'recipe': r, 'isPreview': !isSaved},
                );
              },
            );
          },
        );
      },
    );
  }

  void _handleValidation(BuildContext ctx, Recipe r, bool isSaved) async {
    if (isSaved) {
      IosToast.show(
        ctx,
        message: "Already in your recipes",
        type: ToastType.success,
      );
      return;
    }

    // 1. Update local state immediately to trigger the "falling check" animation
    _updateLocalStateForValidation(r);

    // 2. Perform backend validation
    RecipeService.instance.validateRecipe(r.id).catchError((e) {
      if (mounted) {
        IosToast.show(
          ctx,
          message: ErrorHelper.getFriendlyMessage(e),
          type: ToastType.error,
        );
      }
      return r;
    });

    // 3. Wait for the falling animation to complete (700ms in AnimatedValidationButton)
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // 4. Show the modal
    showModalBottomSheet(
      context: ctx,
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

    final validatedRecipe = r.copyWith(
      origin: r.origin ?? 'IMPORT',
      isValidated: true,
      isSuggested: false,
    );

    // Update local state via notifiers
    _validatedRecipeIds.add(r.id);

    final currentSaved = RecipeService.instance.myRecipesNotifier.value ?? [];
    if (!currentSaved.any((item) => item.id == r.id)) {
      RecipeService.instance.myRecipesNotifier.value = [
        validatedRecipe,
        ...currentSaved,
      ];
    }

    // Refresh backgrounds
    RecipeService.instance
        .getMyRecipes(forceRefresh: true)
        .catchError((_) => <Recipe>[]);
    RecipeService.instance
        .getHomeSuggestions(forceRefresh: true)
        .catchError((_) => <Recipe>[]);

    setState(() {}); // Local refresh for ViewAllScreen
  }

  @override
  Widget build(BuildContext context) {
    if (_type == ViewAllType.savedRecipes ||
        _type == ViewAllType.imports ||
        _type == ViewAllType.recentlyViewed) {
      final notifier = _type == ViewAllType.savedRecipes
          ? RecipeService.instance.myRecipesNotifier
          : _type == ViewAllType.imports
          ? RecipeService.instance.recentImportsNotifier
          : HistoryService.instance.recentlyViewedNotifier;

      return ValueListenableBuilder<List<Recipe>?>(
        valueListenable: notifier,
        builder: (context, recipes, _) {
          if (recipes == null) {
            return const RecipeGridSkeleton(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 20),
            );
          }

          final displayList = (_type == ViewAllType.savedRecipes)
              ? recipes.where((r) => !r.isInCookbook && !r.isSuggested).toList()
              : recipes;

          return _buildGrid(displayList);
        },
      );
    }

    return FutureBuilder<List<Recipe>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const RecipeGridSkeleton(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 20),
          );
        }

        final recipes = snapshot.data ?? [];
        return _buildGrid(recipes);
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CREATORS GRID
// ══════════════════════════════════════════════════════════════════════════════
class _CreatorsGrid extends StatefulWidget {
  final String searchQuery;
  const _CreatorsGrid({super.key, this.searchQuery = ''});

  @override
  State<_CreatorsGrid> createState() => _CreatorsGridState();
}

class _CreatorsGridState extends State<_CreatorsGrid> {
  Future<List<Creator>>? _future;

  @override
  void initState() {
    super.initState();
    _future = RecipeService.instance.getTopCreators(size: 50);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Creator>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 20,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (_, __) => Column(
              children: [
                const SkeletonLoader(width: 80, height: 80, borderRadius: 40),
                const SizedBox(height: 8),
                const SkeletonLoader(width: 70, height: 14),
                const SizedBox(height: 4),
                const SkeletonLoader(width: 50, height: 11),
              ],
            ),
          );
        }

        final creators = snapshot.data ?? [];

        List<Creator> displayList = creators;
        if (widget.searchQuery.trim().isNotEmpty) {
          final query = widget.searchQuery.trim().toLowerCase();
          displayList = displayList
              .where((c) => c.displayName.toLowerCase().contains(query))
              .toList();
        }

        if (displayList.isEmpty) {
          return const Center(child: Text("No creators match your search."));
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          itemCount: displayList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 20,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (ctx, i) {
            final c = displayList[i];
            return Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFF0F0F0),
                  backgroundImage: c.photo != null
                      ? NetworkImage(c.photo!)
                      : null,
                  child:
                      (c.photo == null &&
                          c.firstname.isNotEmpty &&
                          c.lastname.isNotEmpty)
                      ? Text(
                          c.firstname[0].toUpperCase() +
                              c.lastname[0].toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC83A2D),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  c.displayName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF222222),
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    const Icon(
                      Icons.restaurant_outlined,
                      size: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${c.publicRecipeCount} Recipes',
                      style: const TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DYNAMIC EXPLORE GRID (Cuisines & Categories from Backend)
// ══════════════════════════════════════════════════════════════════════════════
class _StaticCookbooksGrid extends StatefulWidget {
  final ViewAllType type;
  final String searchQuery;

  const _StaticCookbooksGrid({super.key, required this.type, this.searchQuery = ''});

  @override
  State<_StaticCookbooksGrid> createState() => _StaticCookbooksGridState();
}

class _StaticCookbooksGridState extends State<_StaticCookbooksGrid> {
  Future<List<Map<String, dynamic>>>? _future;
  late final int _refreshTimestamp;

  final List<Map<String, dynamic>> _fallbackCuisines = [
    {"name": "Italian", "image": "assets/cuisine/italian.png"},
    {"name": "Mexican", "image": "assets/cuisine/mexican.png"},
    {"name": "Asian", "image": "assets/cuisine/chinese.png"},
    {"name": "Indian", "image": "assets/cuisine/indian.png"},
    {"name": "Spanish", "image": "assets/images/plat5.png"},
    {"name": "Japanese", "image": "assets/cuisine/japanese.png"},
  ];

  @override
  void initState() {
    super.initState();
    _refreshTimestamp = DateTime.now().millisecondsSinceEpoch;
    if (widget.type == ViewAllType.exploreCategories) {
      _future = RecipeService.instance.getExploreCategories();
    } else {
      _future = RecipeService.instance.getExploreCuisines();
    }
  }

  String _getFallbackImage(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('italian')) return 'assets/cuisine/italian.png';
    if (lower.contains('mexican')) return 'assets/cuisine/mexican.png';
    if (lower.contains('asian') || lower.contains('chinese')) return 'assets/cuisine/chinese.png';
    if (lower.contains('indian')) return 'assets/cuisine/indian.png';
    if (lower.contains('japanese')) return 'assets/cuisine/japanese.png';
    if (lower.contains('spanish')) return 'assets/images/plat5.png';
    if (lower.contains('mediterranean')) return 'assets/cuisine/mediterranean.png';
    if (lower.contains('caribbean')) return 'assets/cuisine/caribbean.png';
    if (lower.contains('thai')) return 'assets/cuisine/thai.png';
    if (lower.contains('african')) return 'assets/cuisine/west-african.png';
    return 'assets/cuisine/others.png';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CookbookGridSkeleton(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 20),
          );
        }

        List<Map<String, dynamic>> items = snapshot.data ?? [];

        if (items.isEmpty && widget.type == ViewAllType.exploreCuisines) {
          items = _fallbackCuisines;
        }

        if (items.isEmpty) {
          return const Center(child: Text("No items found."));
        }

        var filteredItems = items;

        if (widget.searchQuery.trim().isNotEmpty) {
          final query = widget.searchQuery.trim().toLowerCase();
          filteredItems = filteredItems
              .where(
                (item) =>
                    (item['name'] as String).toLowerCase().contains(query),
              )
              .toList();
        }

        if (filteredItems.isEmpty) {
          return const Center(child: Text("No items match your search."));
        }

        return _buildGrid(filteredItems);
      },
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> items) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (ctx, i) {
        final item = items[i];
        final name = item['name'] as String;
        final img = item['image'] as String?;
        final count = item['recipeCount'] as int? ?? 0;

        return _buildItem(ctx, name, img, _getFallbackImage(name), count);
      },
    );
  }

  Widget _buildItem(
    BuildContext ctx,
    String name,
    String? imgUrl,
    String fallbackImg,
    int count,
  ) {
    final bustedImageUrl = imgUrl != null && imgUrl.isNotEmpty
        ? '$imgUrl${imgUrl.contains('?') ? '&' : '?'}t=$_refreshTimestamp'
        : '';
    final isNetwork = imgUrl != null && imgUrl.startsWith('http');

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          ctx,
          AppRoutes.viewAll,
          arguments: {
            'type': widget.type == ViewAllType.exploreCuisines
                ? ViewAllType.exploreRecipesByCuisine
                : ViewAllType.exploreRecipesByCategory,
            'title': name,
            if (widget.type == ViewAllType.exploreCuisines)
              'cuisine': name
            else
              'category': name,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAF6EE),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(4.r),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFF2F1EF),
                    child: isNetwork
                        ? CachedNetworkImage(
                            imageUrl: bustedImageUrl,
                            cacheKey: imgUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFC83A2D),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              fallbackImg,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            imgUrl != null && imgUrl.isNotEmpty ? imgUrl : fallbackImg,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              fallbackImg,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
              child: Text(
                name.toTitleCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
