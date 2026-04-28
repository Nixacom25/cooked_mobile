import 'package:flutter/material.dart';
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
import '../../core/utils/error_helper.dart';
import '../../data/explore_data.dart';

// ── View-all type ─────────────────────────────────────────────────────────────
enum ViewAllType {
  cookbooks,
  savedRecipes,
  recentlyViewed,
  favorites,
  explore,
  groceryHistory,
  creators,
  imports,
  exploreCuisines,
  exploreCategories,
  exploreRecipesByCuisine,
  exploreRecipesByCategory,
}

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
                          title.toUpperCase(),
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
                        await Navigator.pushNamed(
                          context,
                          AppRoutes.cookbookForm,
                          arguments: {'mode': 'add'},
                        );
                        setState(() {});
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCC3333),
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
      case ViewAllType.favorites:
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
    if (type == ViewAllType.savedRecipes)
      notifier = RecipeService.instance.myRecipesNotifier;
    else if (type == ViewAllType.favorites)
      notifier = RecipeService.instance.favoriteRecipesNotifier;
    else if (type == ViewAllType.imports)
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
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFCC3333)),
          );
        }

        if (cookbooks.isEmpty) {
          return const Center(child: Text("No cookbooks found."));
        }

        List<Cookbook> displayList = cookbooks;
        if (widget.searchQuery.trim().isNotEmpty) {
          final query = widget.searchQuery.trim().toLowerCase();
          displayList = displayList.where((cb) => cb.name.toLowerCase().contains(query)).toList();
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
            childAspectRatio: 0.82,
          ),
          itemBuilder: (ctx, i) {
            final cb = displayList[i];
            return GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(
                  ctx,
                  AppRoutes.cookbookDetail,
                  arguments: {'cookbook': cb},
                );
                // If we return from detail, we might have edited it
                if (mounted) setState(() {});
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CookbookCover(cookbook: cb),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    cb.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.restaurant_outlined,
                        size: 14,
                        color: Color(0xFF999999),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${cb.recipes.length} Recipes',
                        style: const TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 12,
                          color: Color(0xFF999999),
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _type = args['type'] as ViewAllType;
    _load();
  }

  void _load() {
    switch (_type) {
      case ViewAllType.savedRecipes:
        if (RecipeService.instance.myRecipesNotifier.value == null) {
          RecipeService.instance.getMyRecipes();
        }
        break;
      case ViewAllType.favorites:
        RecipeService.instance.getFavoriteRecipes(size: 50);
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
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        final cuisine = args['cuisine'] as String?;
        // Try to get from static first for consistency if backend is empty
        final staticCuisine = ExploreData.cuisines.cast<dynamic>().firstWhere(
          (c) => c.cookbook.name.toLowerCase() == cuisine?.toLowerCase(),
          orElse: () => null,
        );
        if (staticCuisine != null) {
          _future = Future.value(staticCuisine.cookbook.recipes);
        } else {
          _future = RecipeService.instance.getExploreRecipes(cuisine: cuisine, size: 50);
        }
        break;
      case ViewAllType.exploreRecipesByCategory:
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        final category = args['category'] as String?;
        // Always use static for niches/categories as requested
        final staticNiche = ExploreData.niches.cast<dynamic>().firstWhere(
          (n) => n.cookbook.name.toLowerCase() == category?.toLowerCase(),
          orElse: () => null,
        );
        if (staticNiche != null) {
          _future = Future.value(staticNiche.cookbook.recipes);
        } else {
          _future = RecipeService.instance.getPopularRecipes(category: category, size: 50);
        }
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
      displayList = displayList.where((r) => r.name.toLowerCase().contains(query)).toList();
    }

    if (displayList.isEmpty) {
      return const Center(child: Text("No recipes match your search."));
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      itemCount: displayList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14.h,
        crossAxisSpacing: 14.w,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (ctx, i) {
        final r = displayList[i];
        return RecipeCard(
          recipe: r,
          onHeartTap: () async {
            try {
              await RecipeService.instance.toggleFavorite(r.id);
              if (mounted) setState(() => _load());
            } catch (e) {
              if (ctx.mounted) {
                IosToast.show(ctx, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
              }
            }
          },
          onTap: () async {
            final changed = await Navigator.pushNamed(
              ctx,
              AppRoutes.recipeDetail,
              arguments: {
                'recipe': r,
                'isMyRecipe': _type == ViewAllType.savedRecipes,
              },
            );
            if (changed == true) {
              if (mounted) setState(() => _load());
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_type == ViewAllType.savedRecipes || _type == ViewAllType.favorites || _type == ViewAllType.imports || _type == ViewAllType.recentlyViewed) {
      final notifier = _type == ViewAllType.savedRecipes
          ? RecipeService.instance.myRecipesNotifier
          : _type == ViewAllType.favorites 
              ? RecipeService.instance.favoriteRecipesNotifier
              : _type == ViewAllType.imports
                  ? RecipeService.instance.recentImportsNotifier
                  : HistoryService.instance.recentlyViewedNotifier;

      return ValueListenableBuilder<List<Recipe>?>(
        valueListenable: notifier,
        builder: (context, recipes, _) {
          if (recipes == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFCC3333)),
            );
          }
          return _buildGrid(recipes);
        },
      );
    }

    return FutureBuilder<List<Recipe>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFCC3333)),
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
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFCC3333)),
          );
        }

        final creators = snapshot.data ?? [];

        List<Creator> displayList = creators;
        if (widget.searchQuery.trim().isNotEmpty) {
          final query = widget.searchQuery.trim().toLowerCase();
          displayList = displayList.where((c) => c.displayName.toLowerCase().contains(query)).toList();
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
                            color: Color(0xFFCC3333),
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
                    color: Color(0xFF1B1B1B),
                  ),
                ),
                Text(
                  '${c.publicRecipeCount} Recipes',
                  style: const TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
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
class _StaticCookbooksGrid extends StatelessWidget {
  final ViewAllType type;
  final String searchQuery;

  const _StaticCookbooksGrid({required this.type, this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    if (type == ViewAllType.exploreCategories) {
      final categories = ExploreData.niches;
      var names = categories.map((n) => n.cookbook.name).toList();

      if (searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        names = names.where((name) => name.toLowerCase().contains(query)).toList();
      }

      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        itemCount: names.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (ctx, i) {
          final name = names[i];
          final item = categories.firstWhere((n) => n.cookbook.name == name);
          final count = item.cookbook.recipes.length;
          final img = item.image;

          return _buildItem(ctx, name, img, count);
        },
      );
    }

    final Future<Map<String, int>> future = type == ViewAllType.exploreCuisines 
        ? RecipeService.instance.getExploreCuisines() 
        : RecipeService.instance.getExploreCategories();

    return FutureBuilder<Map<String, int>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFCC3333)),
          );
        }

        final Map<String, int> itemsMap = snapshot.data ?? {};
        var names = itemsMap.keys.toList();

        if (searchQuery.trim().isNotEmpty) {
          final query = searchQuery.trim().toLowerCase();
          names = names.where((name) => name.toLowerCase().contains(query)).toList();
        }

        if (names.isEmpty) {
          return const Center(child: Text("No items found."));
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          itemCount: names.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (ctx, i) {
            final name = names[i];
            final count = itemsMap[name] ?? 0;
            
            String img = 'assets/images/others.png';
            if (type == ViewAllType.exploreCuisines) {
              final staticCuisine = ExploreData.cuisines.cast<dynamic>().firstWhere(
                (c) => c.cookbook.name.toLowerCase() == name.toLowerCase(),
                orElse: () => null,
              );
              if (staticCuisine != null) img = staticCuisine.image;
            } else {
              final staticNiche = ExploreData.niches.cast<dynamic>().firstWhere(
                (n) => n.cookbook.name.toLowerCase() == name.toLowerCase(),
                orElse: () => null,
              );
              if (staticNiche != null) img = staticNiche.image;
            }

            return _buildItem(ctx, name, img, count);
          },
        );
      }
    );
  }

  Widget _buildItem(BuildContext ctx, String name, String img, int count) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          ctx,
          AppRoutes.viewAll,
          arguments: {
            'type': type == ViewAllType.exploreCuisines 
                ? ViewAllType.exploreRecipesByCuisine 
                : ViewAllType.exploreRecipesByCategory,
            'title': name,
            if (type == ViewAllType.exploreCuisines) 'cuisine': name else 'category': name,
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
                child: Image.asset(img, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            name.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$count Recipes',
            style: const TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 12,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}
