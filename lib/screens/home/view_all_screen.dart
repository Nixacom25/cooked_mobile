import 'package:cooked/widgets/recipe_grid_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/recipe_card.dart';
import '../../models/recipe.dart';
import '../../models/cookbook.dart';
import '../../models/creator.dart';
import '../../widgets/cookbook_cover.dart';
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

  @override
  void dispose() {
    _searchQueryNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final ViewAllType type = args['type'] as ViewAllType;
    final String title = args['title'] as String;
    final bool showPlus = type == ViewAllType.cookbooks;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 30, 18, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.toTitleCase(),
                          style: const TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: Color(0xFF1A1A1A),
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
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC83A2D),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Search bar (matches home screen style) ────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: AppSearchField(
                onChanged: (val) {
                  _searchQueryNotifier.value = val;
                },
                hintText: 'Search recipes, cookbooks...',
              ),
            ),

            const SizedBox(height: 16),

            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _searchQueryNotifier,
                builder: (context, query, _) {
                  return _buildContent(type, query);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ViewAllType type, String query) {
    switch (type) {
      case ViewAllType.cookbooks:
        return _CookbooksGrid(searchQuery: query);
      case ViewAllType.savedRecipes:
      case ViewAllType.recentlyViewed:
      case ViewAllType.explore:
      case ViewAllType.groceryHistory:
      case ViewAllType.imports:
      case ViewAllType.exploreRecipesByCuisine:
      case ViewAllType.exploreRecipesByCategory:
        return _RecipesGrid(searchQuery: query);
      case ViewAllType.creators:
        return _CreatorsGrid(searchQuery: query);
      case ViewAllType.exploreCuisines:
      case ViewAllType.exploreCategories:
        return _StaticCookbooksGrid(type: type, searchQuery: query);
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
class _CookbooksGrid extends StatefulWidget {
  final String searchQuery;
  const _CookbooksGrid({this.searchQuery = ''});

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
          return const CookbookGridSkeleton(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 20),
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
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          itemCount: displayList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (ctx, i) {
            final cb = displayList[i];
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
                          if (mounted) {
                            IosToast.show(
                              ctx,
                              message: 'Cookbook deleted',
                              type: ToastType.success,
                            );
                          }
                        } catch (e) {
                          if (mounted) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: CookbookCover(cookbook: cb)),
                  const SizedBox(height: 7),
                  Text(
                    cb.name.toTitleCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.restaurant_outlined,
                        size: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${cb.recipes.length} Recipes',
                        style: const TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
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
  const _RecipesGrid({this.searchQuery = ''});

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
        _future = RecipeService.instance.getExploreRecipes(
          cuisine: cuisine,
          size: 50,
        );
        break;
      case ViewAllType.exploreRecipesByCategory:
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        final category = args['category'] as String?;
        _future = RecipeService.instance.getExploreRecipes(
          category: category,
          size: 50,
        );
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
  const _CreatorsGrid({this.searchQuery = ''});

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

  const _StaticCookbooksGrid({required this.type, this.searchQuery = ''});

  @override
  State<_StaticCookbooksGrid> createState() => _StaticCookbooksGridState();
}

class _StaticCookbooksGridState extends State<_StaticCookbooksGrid> {
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void initState() {
    super.initState();
    if (widget.type == ViewAllType.exploreCategories) {
      _future = RecipeService.instance.getExploreCategories();
    } else {
      _future = RecipeService.instance.getExploreCuisines();
    }
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

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No items found."));
        }

        final List<Map<String, dynamic>> items = snapshot.data!;
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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (ctx, i) {
        final item = items[i];
        final name = item['name'] as String;
        final img = item['image'] as String?;
        final count = item['recipeCount'] as int? ?? 0;

        return _buildItem(ctx, name, img, 'assets/images/others.png', count);
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
    final bool isCuisine = widget.type == ViewAllType.exploreCuisines;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF2F1EF),
                child: imgUrl != null && imgUrl.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: imgUrl,
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
                        errorWidget: (context, url, error) => isCuisine
                            ? Center(
                                child: Icon(
                                  Icons.restaurant_menu,
                                  color: const Color(0xFFC83A2D),
                                  size: 32,
                                ),
                              )
                            : Image.asset(fallbackImg, fit: BoxFit.cover),
                      )
                    : isCuisine
                    ? Center(
                        child: Icon(
                          Icons.restaurant_menu,
                          color: const Color(0xFFC83A2D),
                          size: 32,
                        ),
                      )
                    : Image.asset(fallbackImg, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            name.toTitleCase(),
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
    );
  }
}
