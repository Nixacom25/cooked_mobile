import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/history_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/extensions/string_extensions.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';
import '../../widgets/add_to_grocery_modal.dart';
import '../../widgets/add_to_cookbook_sheet.dart';
import '../../widgets/skeleton_loader.dart';
import '../../models/cookbook.dart';
import '../../services/cookbook_service.dart';

enum DetailTab { steps, ingredients }

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});
  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  DetailTab _activeTab = DetailTab.steps;
  bool _isPreview = false;
  bool _isInitialized = false;
  bool _isRemoving = false;
  bool _isSaving = false;
  bool _isLoading = false;
  String? _infoMessage;
  String? _error;
  Recipe? _recipe;
  int _currentServings = 1;
  int _originalServings = 1;

  void _initRecipeData(Recipe r) {
    _recipe = r;
    _currentServings = r.servings ?? 1;
    _originalServings = r.servings ?? 1;
    debugPrint('🍳 [RecipeDetail] _initRecipeData: ${r.name} | steps=${r.steps.length} | ingredients=${r.ingredients.length}');
    HistoryService.instance.addToHistory(r);
  }

  Future<void> _fetchRecipe(String id) async {
    debugPrint('🔄 [RecipeDetail] _fetchRecipe called for id=$id');
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final r = await RecipeService.instance.getRecipe(id);
      debugPrint('✅ [RecipeDetail] getRecipe returned: ${r.name} | steps=${r.steps.length}');
      if (mounted) {
        setState(() {
          _initRecipeData(r);
        });
      }
    } catch (e) {
      debugPrint('❌ [RecipeDetail] _fetchRecipe error: $e');
      if (mounted) {
        setState(() => _error = ErrorHelper.getFriendlyMessage(e));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
          {};
      final Recipe? r = args['recipe'] as Recipe?;
      final String? id = args['recipeId'] as String?;
      _isPreview = args['isPreview'] ?? false;
      _infoMessage = args['infoMessage'] as String?;

      if (r != null) {
        _initRecipeData(r);
        // If the recipe passed from a list has no steps, re-fetch the full
        // detail from the API to get complete data (steps, equipment, tips).
        if (r.steps.isEmpty) {
          _fetchRecipe(r.id);
        }
      } else if (id != null) {
        _fetchRecipe(id);
      }

      if (_infoMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            IosToast.show(
              context,
              message: _infoMessage!,
              type: ToastType.success,
            );
            setState(() => _infoMessage = null);
          }
        });
      }

      _isInitialized = true;
    }
  }

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      _scrollOffset.value = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  void _onTabChanged(DetailTab tab) {
    if (_activeTab == tab) return;

    setState(() {
      _activeTab = tab;
    });

    final double topPadding = MediaQuery.of(context).padding.top;
    final double maxImg = 350.h;
    final double minImg = topPadding + 60.h;
    double collapseOffset = (maxImg - minImg);
    double targetOffset = collapseOffset + 150.h;

    if (_scrollController.hasClients &&
        _scrollController.offset > targetOffset) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _showAddToCookbookModal(
    BuildContext ctx,
    Recipe recipe, {
    VoidCallback? onSuccess,
  }) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddToCookbookSheet(recipe: recipe, onSuccess: onSuccess),
    );
  }

  Future<void> _handleShare() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    final Recipe? r = args['recipe'] as Recipe?;
    if (r == null) return;

    try {
      final rawLink = await RecipeService.instance.getShareLink(r.id);
      // Replace domain as requested by user
      final link = rawLink.replaceAll('cooked.nixacom.com', 'cookedapp.com');

      final name = r.name;
      final creatorStr = r.creator != null
          ? "${r.creator!.displayName}'s "
          : "";

      final template = "Check out $creatorStr$name on Cooked 🙌\n\n$link";

      final RenderBox? box = context.findRenderObject() as RenderBox?;
      Share.share(
        template,
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      );
    } catch (e) {
      if (!mounted) return;
      IosToast.show(
        context,
        message: ErrorHelper.getFriendlyMessage(e),
        type: ToastType.error,
      );
    }
  }

  Future<void> _saveRecipe(Recipe r) async {
    setState(() => _isSaving = true);
    try {
      Recipe finalRecipe = r;
      // If we are in preview mode, we need to validate/save the recipe to the user's account first
      if (_isPreview) {
        finalRecipe = await RecipeService.instance.validateRecipe(r.id);
        if (mounted) {
          setState(() {
            _isPreview = false;
            _recipe = finalRecipe;
          });
        }
      }

      if (!mounted) return;
      setState(() => _isSaving = false);

      _showAddToCookbookModal(
        context,
        finalRecipe,
        onSuccess: () {
          // Additional safety: ensure we are out of preview mode
          if (mounted && _isPreview) {
            setState(() {
              _isPreview = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        IosToast.show(
          context,
          message: ErrorHelper.getFriendlyMessage(e),
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _removeFromCookbooks(Recipe r) async {
    setState(() => _isRemoving = true);
    try {
      final cookbooks = CookbookService.instance.myCookbooksNotifier.value;
      if (cookbooks == null) return;

      final containing = cookbooks
          .where((cb) => cb.recipes.any((rec) => rec.id == r.id))
          .toList();

      for (var cb in containing) {
        await CookbookService.instance.removeRecipeFromCookbook(cb.id, r.id);
      }

      // Force refresh My Recipes to show it "live" in saved recipes
      await RecipeService.instance.getMyRecipes(forceRefresh: true);

      if (!mounted) return;
      setState(() => _isRemoving = false);
      IosToast.show(
        context,
        message: 'Recipe removed from cookbooks',
        type: ToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRemoving = false);
      IosToast.show(
        context,
        message: ErrorHelper.getFriendlyMessage(e),
        type: ToastType.error,
      );
    }
  }

  Widget _buildServingsSelector(Recipe? r) {
    if (r == null) return const SizedBox.shrink();
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Servings',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    'Quantities adjust automatically',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 11.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    _ServingsButton(
                      icon: Icons.remove_rounded,
                      onTap: () {
                        if (_currentServings > 1) {
                          HapticFeedback.lightImpact();
                          setState(() => _currentServings--);
                        }
                      },
                    ),
                    Container(
                      width: 30.w,
                      alignment: Alignment.center,
                      child: Text(
                        '$_currentServings',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w800,
                          fontSize: 14.sp,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    _ServingsButton(
                      icon: Icons.add_rounded,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _currentServings++);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    final Recipe? r = _recipe ?? args['recipe'] as Recipe?;
    debugPrint('🏗️ [RecipeDetail] build: r=${r?.name}, steps=${r?.steps.length}, _recipe=${_recipe?.name}');
    final String img = r?.image ?? args['img'] as String? ?? '';
    final String name = (r?.name ??
            args['name'] as String? ??
            (_isLoading ? 'Loading...' : 'Recipe'))
        .toTitleCase();
    final String time = r != null
        ? '${r.cookTime} min'
        : (args['time'] as String? ?? '');
    final String kcal = r != null
        ? '${r.kcal} kcal'
        : (args['kcal'] as String? ?? '');
    final String prep = r?.prepTime != null ? '${r!.prepTime} min prep' : '';

    final bool isTrend = args['isTrend'] ?? false;
    final VoidCallback? onImport = args['onImport'] as VoidCallback?;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48.sp,
                      color: const Color(0xFFC83A2D),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'SF Pro', fontSize: 14.sp),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  if (_isLoading && r == null)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFC83A2D),
                      ),
                    )
                  else
                    CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _RecipeDetailHeaderDelegate(
                            img: img,
                            name: name,
                            time: time,
                            kcal: kcal,
                            isPreview: _isPreview,
                            onValidate: () async {
                              if (r == null) return;
                              await _saveRecipe(r);
                            },
                            onShare: _handleShare,
                            recipeId: r?.id,
                            recipe: r,
                            topPadding: MediaQuery.of(context).padding.top,
                          ),
                        ),

                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ValueListenableBuilder<double>(
                                  valueListenable: _scrollOffset,
                                  builder: (context, offset, child) {
                                    double threshold = 150.0;
                                    double opacity =
                                        (1.0 - (offset / threshold)).clamp(
                                          0.0,
                                          1.0,
                                        );
                                    if (opacity == 0) {
                                      return const SizedBox.shrink();
                                    }
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Opacity(
                                          opacity: opacity,
                                          child: child!,
                                        ),
                                      ],
                                    );
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20.sp,
                                            color: const Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 5.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  alignment: WrapAlignment.start,
                                  runAlignment: WrapAlignment.start,
                                  children: [
                                    if (prep.isNotEmpty)
                                      _TagPill(icon: Icons.timer, label: prep),
                                    if (time.isNotEmpty)
                                      _TagPill(
                                        icon: Icons.access_time_rounded,
                                        label: '$time cook',
                                      ),
                                    if (kcal.isNotEmpty)
                                      _TagPill(
                                        icon: Icons.local_fire_department_rounded,
                                        label: kcal,
                                      ),
                                  ],
                                ),
                                // Removed _infoMessage banner
                              ],
                            ),
                          ),
                        ),

                        _buildServingsSelector(r),

                        if (!_isPreview)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 15.h,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (r != null) {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) =>
                                                AddToGroceryModal(
                                                  recipe: r,
                                                  currentServings:
                                                      _currentServings,
                                                  originalServings:
                                                      _originalServings,
                                                ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        height: 50.h,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFC83A2D),
                                          borderRadius: BorderRadius.circular(
                                            30.r,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.shopping_cart_outlined,
                                              color: Colors.white,
                                              size: 18.sp,
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              'Add to Grocery',
                                              style: TextStyle(
                                                fontFamily: 'SF Pro',
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SimplePinnedHeaderDelegate(
                            height: 50.h,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(30.r),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      _TabPill(
                                        label: 'Steps',
                                        active: _activeTab == DetailTab.steps,
                                        onTap: () =>
                                            _onTabChanged(DetailTab.steps),
                                      ),
                                      _TabPill(
                                        label: 'Ingredients',
                                        active:
                                            _activeTab == DetailTab.ingredients,
                                        onTap: () => _onTabChanged(
                                          DetailTab.ingredients,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            20.w,
                            16.h,
                            20.w,
                            100.h + bottomPad,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: 400.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_activeTab == DetailTab.ingredients)
                                    _IngredientsList(
                                      ingredients: r?.ingredients ?? [],
                                      currentServings: _currentServings,
                                      originalServings: _originalServings,
                                    )
                                  else
                                    _StepsList(
                                      steps: r?.steps ?? [],
                                      equipment: r?.equipment ?? [],
                                      tips: r?.tips,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10 + bottomPad),
                      child: (_isPreview || (r?.origin == 'SUGGESTED'))
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Removed preview mode banner
                                GestureDetector(
                                  onTap: () {
                                    if (isTrend && onImport != null) {
                                      Navigator.pop(context);
                                      onImport();
                                    } else {
                                      if (r != null) {
                                        _saveRecipe(r);
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: 56.h,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC83A2D),
                                      borderRadius: BorderRadius.circular(16.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFC83A2D,
                                          ).withOpacity(0.2),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: _isSaving
                                          ? SizedBox(
                                              width: 20.w,
                                              height: 20.w,
                                              child:
                                                  const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  isTrend
                                                      ? Icons.cloud_download_rounded
                                                      : Icons.bookmark_add_rounded,
                                                  color: Colors.white,
                                                  size: 20.sp,
                                                ),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  isTrend
                                                      ? 'Import this recipe'
                                                      : 'Save Recipe',
                                                  style: TextStyle(
                                                    fontFamily: 'SF Pro',
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16.sp,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ValueListenableBuilder<List<Cookbook>?>(
                              valueListenable:
                                  CookbookService.instance.myCookbooksNotifier,
                              builder: (context, cookbooks, _) {
                                bool isInCookbook = false;
                                if (cookbooks != null && r != null) {
                                  isInCookbook = cookbooks.any(
                                    (cb) =>
                                        cb.recipes.any((rec) => rec.id == r.id),
                                  );
                                }

                                final buttonText = isInCookbook
                                    ? 'Remove from Cookbook'
                                    : 'Add to Cookbook';

                                return GestureDetector(
                                  onTap: () async {
                                    if (r == null) return;
                                    if (isInCookbook) {
                                      // Show confirmation dialog
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20.r,
                                            ),
                                          ),
                                          title: Text(
                                            'Remove Recipe',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w800,
                                              fontSize: 18.sp,
                                            ),
                                          ),
                                          content: const Text(
                                            'Are you sure you want to remove this recipe from all your cookbooks?',
                                            style: TextStyle(
                                              fontFamily: 'SF Pro',
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text(
                                                'Remove',
                                                style: TextStyle(
                                                  color: Color(0xFFC83A2D),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmed == true) {
                                        _removeFromCookbooks(r);
                                      }
                                    } else {
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: Colors.transparent,
                                        isScrollControlled: true,
                                        builder: (_) => AddToCookbookSheet(
                                          recipe: r,
                                          title: buttonText,
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 50.h,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC83A2D),
                                      borderRadius: BorderRadius.circular(30.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFC83A2D,
                                          ).withOpacity(0.2),
                                          blurRadius: 10.r,
                                          offset: Offset(0, 4.h),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: _isRemoving || _isSaving
                                          ? SizedBox(
                                              width: 20.w,
                                              height: 20.w,
                                              child:
                                                  const CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                            )
                                          : Text(
                                              buttonText,
                                              style: TextStyle(
                                                fontFamily: 'SF Pro',
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SimplePinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  _SimplePinnedHeaderDelegate({required this.child, required this.height});
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(covariant _SimplePinnedHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}

class _RecipeDetailHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String img;
  final String name;
  final String time;
  final String kcal;
  final bool isPreview;
  final VoidCallback onValidate;
  final VoidCallback onShare;
  final String? recipeId;
  final Recipe? recipe;
  final double topPadding;

  const _RecipeDetailHeaderDelegate({
    required this.img,
    required this.name,
    required this.time,
    required this.kcal,
    required this.isPreview,
    required this.onValidate,
    required this.onShare,
    this.recipeId,
    this.recipe,
    required this.topPadding,
  });

  @override
  double get maxExtent => 350.h;
  @override
  double get minExtent => topPadding + 60.h;
  @override
  bool shouldRebuild(covariant _RecipeDetailHeaderDelegate oldDelegate) {
    return img != oldDelegate.img ||
        name != oldDelegate.name ||
        isPreview != oldDelegate.isPreview ||
        topPadding != oldDelegate.topPadding;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double maxShrinkOffset = maxExtent - minExtent;
    final double progress = (shrinkOffset / maxShrinkOffset).clamp(0.0, 1.0);
    final Color bgColor = Color.lerp(
      Colors.transparent,
      Colors.white,
      progress,
    )!;
    final double expandedImageHeight = 350.h;
    final double collapsedImageSize = 38.h;
    final double currentImageHeight =
        expandedImageHeight -
        (expandedImageHeight - collapsedImageSize) * progress;
    final double expandedWidth = MediaQuery.of(context).size.width;
    final double currentImageWidth =
        expandedWidth - (expandedWidth - collapsedImageSize) * progress;
    final double expandedTop = 0.0;
    final double collapsedTop =
        topPadding + (minExtent - topPadding - collapsedImageSize) / 2;
    final double currentTop =
        expandedTop - (expandedTop - collapsedTop) * progress;
    final double expandedLeft = 0.0;
    final double collapsedLeft = 48.w;
    final double currentLeft =
        expandedLeft - (expandedLeft - collapsedLeft) * progress;
    final double expandedRadius = 0.0;
    final double collapsedRadius = 8.r;
    final double currentRadius =
        expandedRadius - (expandedRadius - collapsedRadius) * progress;
    final double titleOpacity = progress > 0.8 ? (progress - 0.8) / 0.2 : 0.0;

    return Container(
      color: bgColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: currentTop,
            left: currentLeft,
            width: currentImageWidth,
            height: currentImageHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(currentRadius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(
                    img,
                    currentImageWidth,
                    currentImageHeight,
                    progress,
                  ),
                ],
              ),
            ),
          ),
          if (titleOpacity > 0)
            Positioned(
              left: collapsedLeft + collapsedImageSize + 12.w,
              right: 100.w,
              top: topPadding,
              bottom: 0,
              child: Opacity(
                opacity: titleOpacity,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: topPadding,
            left: 0,
            right: 0,
            height: minExtent - topPadding,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20.sp,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: onShare,
                        child: Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.ios_share,
                            size: 20.sp,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Large border radius overlap at the bottom of the image
          Positioned(
            bottom: -1,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: (1.0 - progress * 1.5).clamp(0.0, 1.0),
              child: Container(
                height: 32.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(
    String path,
    double width,
    double height,
    double progress,
  ) {
    const fit = BoxFit.cover;
    if (path.isEmpty) {
      return Image.asset(
        'assets/images/recipes.png',
        width: width,
        height: height,
        fit: fit,
      );
    }
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        width: width,
        height: height,
        fit: fit,
        errorWidget: (_, __, ___) => Image.asset(
          'assets/images/recipes.png',
          width: width,
          height: height,
          fit: fit,
        ),
        placeholder: (_, __) => Container(
          width: width,
          height: height,
          color: const Color(0xFFF2F1EF),
          child: Center(
            child: SkeletonLoader(
              width: 40.w,
              height: 40.w,
              borderRadius: 20.r,
            ),
          ),
        ),
      );
    }
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/recipes.png',
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TagPill({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF2C94C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: const Color(0xFF111827)),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabPill({
    required this.label,
    required this.active,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 6.h),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFC83A2D) : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
                color: active ? Colors.white : const Color(0xFF5B7C85),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 16.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 13.sp,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientsList extends StatelessWidget {
  final List<RecipeIngredient> ingredients;
  final int currentServings;
  final int originalServings;
  const _IngredientsList({
    required this.ingredients,
    required this.currentServings,
    required this.originalServings,
  });

  String _formatQuantity(RecipeIngredient ing) {
    if (ing.amount == 0) return ing.quantity;
    double scaledAmount = (ing.amount * currentServings) / originalServings;
    String formattedAmount;
    if (scaledAmount == scaledAmount.toInt()) {
      formattedAmount = scaledAmount.toInt().toString();
    } else {
      formattedAmount = scaledAmount.toStringAsFixed(1);
      if (formattedAmount.endsWith('.0')) {
        formattedAmount = formattedAmount.substring(
          0,
          formattedAmount.length - 2,
        );
      }
    }
    return ing.unit.isEmpty ? formattedAmount : '$formattedAmount ${ing.unit}';
  }

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return _EmptyState(
        icon: Icons.shopping_basket_outlined,
        title: "No ingredients listed",
        subtitle: "Check the recipe description for details.",
      );
    }
    return Column(
      children: List.generate(ingredients.length, (i) {
        final ing = ingredients[i];
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Row(
                children: [
                  if (ing.icon != null && ing.icon!.isNotEmpty) ...[
                    Container(
                      width: 30.w,
                      height: 30.w,
                      margin: EdgeInsets.only(right: 10.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF6D6),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(ing.icon!, style: TextStyle(fontSize: 18.sp)),
                    ),
                  ],
                  Expanded(
                    flex: 3,
                    child: Text(
                      ing.name.toTitleCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 2,
                    child: Text(
                      _formatQuantity(ing),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i < ingredients.length - 1)
              const Divider(height: 0, color: Color(0xFFF0F0F0)),
          ],
        );
      }),
    );
  }
}

class _EquipmentList extends StatelessWidget {
  final List<String> equipment;
  const _EquipmentList({required this.equipment});
  @override
  Widget build(BuildContext context) {
    if (equipment.isEmpty) {
      return _EmptyState(
        icon: Icons.soup_kitchen_outlined,
        title: "No specific equipment listed",
        subtitle: "Standard kitchen tools should be enough.",
      );
    }
    return Column(
      children: List.generate(equipment.length, (i) {
        final item = equipment[i];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.toTitleCase(),
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
              Icon(
                Icons.check_circle_outline_rounded,
                size: 18.sp,
                color: const Color(0xFFCBD5E1),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StepsList extends StatelessWidget {
  final List<String> steps;
  final List<String> equipment;
  final String? tips;
  const _StepsList({required this.steps, required this.equipment, this.tips});
  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return _EmptyState(
        icon: Icons.format_list_numbered_rtl,
        title: "No steps listed",
        subtitle: "Follow your intuition or check the source.",
      );
    }
    return Column(
      children: [
        ...List.generate(steps.length, (i) {
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC83A2D).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w800,
                      fontSize: 13.sp,
                      color: const Color(0xFFC83A2D),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) {
                          String content = steps[i];
                          final stepPrefixRegex = RegExp(
                            r'^Step\s*\d+\s*[:.-]?\s*',
                            caseSensitive: false,
                          );
                          content = content.replaceFirst(stepPrefixRegex, '');
                          return Text(
                            content.capitalize(),
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: 14.sp,
                              height: 1.6,
                              color: const Color(0xFF111827),
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        if (equipment.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Text(
            'Required Equipment',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 12.h),
          _EquipmentList(equipment: equipment),
        ],
        if (tips != null && tips!.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: const Color(0xFFD97706),
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Notes / Tips',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  tips!.capitalize(),
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 14.sp,
                    height: 1.5,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ServingsButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ServingsButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32.w,
        height: 32.w,
        alignment: Alignment.center,
        child: Icon(icon, size: 18.sp, color: const Color(0xFF1A1A1A)),
      ),
    );
  }
}
