import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/history_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../../routes/app_routes.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';
import '../../widgets/add_to_grocery_modal.dart';
import '../../widgets/add_to_cookbook_sheet.dart';

enum DetailTab { steps, ingredients, equipment }

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});
  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  DetailTab _activeTab = DetailTab.steps;
  bool _isPreview = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
          {};
      final Recipe? r = args['recipe'] as Recipe?;
      _isPreview = args['isPreview'] ?? false;

      // Auto-detect if recipe is actually already saved (by name)
      if (_isPreview && r != null) {
        final savedRecipes = RecipeService.instance.myRecipesNotifier.value;
        if (savedRecipes != null) {
          final isAlreadySaved = savedRecipes.any(
            (sr) => sr.name.toLowerCase() == r.name.toLowerCase(),
          );
          if (isAlreadySaved) {
            _isPreview = false;
          }
        }
      }

      if (r != null) {
        HistoryService.instance.addToHistory(r);
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

    // Calculate the offset where the Tab Bar is pinned at the top.
    // This is the "beginning" of the tab content.
    final double topPadding = MediaQuery.of(context).padding.top;
    final double maxImg = 350.h;
    final double minImg = topPadding + 60.h;

    // The Name section disappears at offset 200.
    // The Image header finishes collapsing at (maxImg - minImg).
    // Let's assume the name section is approx 100px.
    // The Tags are 30.h, Buttons are 80.h.

    // A robust way to find the "content start" is to sum the scroll needed
    // to collapse everything above the tab bar.
    double collapseOffset = (maxImg - minImg);
    // Since NameSection returns shrink at 200, it basically stops contributing
    // to the total height at that point.

    // Let's use a value that ensures the TabBar is pinned.
    // Roughly 400-500 depending on screen.
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

  // ── Add-to-Cookbook modal ─────────────────────────────────────────────────
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
      final link = await RecipeService.instance.getShareLink(r.id);
      final name = r.name;
      final time = '${r.cookTime} min';
      final kcal = '${r.kcal} kcal';

      // Emojis mapping to requested mockup icons
      final template =
          "Discover this recipe: $name\nReady in 🕒 $time, 🔥 $kcal.\n\nSee on Cooked: $link";

      Share.share(template);
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
    _showAddToCookbookModal(
      context,
      r,
      onSuccess: () {
        setState(() {
          _isPreview = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};

    // If we have a recipe object, use it. Otherwise try to populate from individual args (legacy/fallback)
    final Recipe? r = args['recipe'] as Recipe?;
    final String img = r?.image ?? args['img'] as String? ?? '';
    final String name = r?.name ?? args['name'] as String? ?? 'Recipe';
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
        body: Stack(
          children: [
            // ── Scrollable body ───────────────────────────────────────────
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // ── Animated Image Header ─────────────────────────────────
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
                    isFavorite: r?.isFavorite ?? false,
                    onToggleFavorite: () async {
                      if (r != null) {
                        try {
                          await RecipeService.instance.toggleFavorite(r.id);
                        } catch (e) {
                          IosToast.show(
                            context,
                            message: ErrorHelper.getFriendlyMessage(e),
                            type: ToastType.error,
                          );
                        }
                      }
                    },
                    recipeId: r?.id,
                    recipe: r,
                    topPadding: MediaQuery.of(context).padding.top,
                  ),
                ),

                // ── Name and Heart Section ────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and Heart Row
                        ValueListenableBuilder<double>(
                          valueListenable: _scrollOffset,
                          builder: (context, offset, child) {
                            double threshold = 150.0;
                            double opacity = (1.0 - (offset / threshold)).clamp(
                              0.0,
                              1.0,
                            );
                            if (opacity == 0) return const SizedBox.shrink();
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Opacity(opacity: opacity, child: child!),
                              ],
                            );
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18.sp,
                                    color: const Color(0xFF1A1A1A),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              if (!_isPreview) ...[
                                SizedBox(width: 10.w),
                                ValueListenableBuilder<List<Recipe>?>(
                                  valueListenable: RecipeService
                                      .instance
                                      .favoriteRecipesNotifier,
                                  builder: (context, favorites, _) {
                                    bool isFav = false;
                                    if (r != null) {
                                      if (favorites != null) {
                                        isFav = favorites.any(
                                          (fav) => fav.id == r.id,
                                        );
                                      } else {
                                        isFav = r.isFavorite;
                                      }
                                    }
                                    return GestureDetector(
                                      onTap: () async {
                                        if (r != null) {
                                          try {
                                            await RecipeService.instance
                                                .toggleFavorite(r.id);
                                          } catch (e) {
                                            IosToast.show(
                                              context,
                                              message:
                                                  ErrorHelper.getFriendlyMessage(
                                                    e,
                                                  ),
                                              type: ToastType.error,
                                            );
                                          }
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isFav
                                              ? const Color(
                                                  0xFFCC3333,
                                                ).withOpacity(0.1)
                                              : const Color(0xFFF9FAFB),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isFav
                                              ? Icons.favorite_rounded
                                              : Icons.favorite_border_rounded,
                                          color: isFav
                                              ? const Color(0xFFCC3333)
                                              : const Color(0xFF1A1A1A),
                                          size: 24,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Tags Section ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                    child: Wrap(
                      spacing: 5,
                      runSpacing: 8,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (prep.isNotEmpty)
                          _TagPill(icon: Icons.timer, label: prep),
                        if (time.isNotEmpty)
                          _TagPill(
                            icon: Icons.access_time_rounded,
                            label: time,
                          ),
                        if (kcal.isNotEmpty)
                          _TagPill(
                            icon: Icons.local_fire_department_rounded,
                            label: kcal,
                          ),
                        _TagPill(
                          icon: Icons.people_rounded,
                          label: r?.servings != null
                              ? '${r!.servings} People'
                              : '2 People',
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Buttons Section ───────────────────────────────────────
                if (!_isPreview)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
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
                                        AddToGroceryModal(recipe: r),
                                  );
                                }
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCC3333),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Add to Grocery',
                                      style: TextStyle(
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
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

                // ── Sticky Tabs Header ────────────────────────────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SimplePinnedHeaderDelegate(
                    height: 50.h,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              _TabPill(
                                label: 'Steps',
                                active: _activeTab == DetailTab.steps,
                                onTap: () => _onTabChanged(DetailTab.steps),
                              ),
                              _TabPill(
                                label: 'Equipment',
                                active: _activeTab == DetailTab.equipment,
                                onTap: () => _onTabChanged(DetailTab.equipment),
                              ),
                              _TabPill(
                                label: 'Ingredients',
                                active: _activeTab == DetailTab.ingredients,
                                onTap: () =>
                                    _onTabChanged(DetailTab.ingredients),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Tab Content ──────────────────────────────────────────────
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 100 + bottomPad),
                  sliver: SliverToBoxAdapter(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        // Min height to allow headers to pin, but no more.
                        minHeight: 400.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_activeTab == DetailTab.ingredients)
                            _IngredientsList(ingredients: r?.ingredients ?? [])
                          else if (_activeTab == DetailTab.equipment)
                            _EquipmentList(equipment: r?.equipment ?? [])
                          else
                            _StepsList(steps: r?.steps ?? [], tips: r?.tips),
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
                          if (_isPreview) ...[
                            Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 14.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    "Please verify if this matches the source",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF64748B),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (r?.sourceUrl != null &&
                                r!.sourceUrl!.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.import,
                                      arguments: {'initialUrl': r.sourceUrl},
                                    );
                                  },
                                  child: Text(
                                    "View Original Source",
                                    style: TextStyle(
                                      color: const Color(0xFFC83A2D),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                          GestureDetector(
                            onTap: () {
                              if (isTrend && onImport != null) {
                                Navigator.pop(context);
                                onImport();
                              } else {
                                _saveRecipe(r!);
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isTrend
                                        ? Icons.cloud_download_rounded
                                        : (_isPreview
                                              ? Icons
                                                    .check_circle_outline_rounded
                                              : Icons.bookmark_add_rounded),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    isTrend
                                        ? 'Import this recipe'
                                        : (_isPreview
                                              ? 'Confirm and Save Recipe'
                                              : 'Add to recipe book'),
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
                        ],
                      )
                    : GestureDetector(
                        onTap: () {
                          if (r == null) return;
                          _saveRecipe(r);
                        },
                        child: Container(
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: const Center(
                            child: Text(
                              'Add to Cookbook',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                        ),
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

// ── Animated Image Header Delegate ─────────────────────────────────────────
class _RecipeDetailHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String img;
  final String name;
  final String time;
  final String kcal;
  final bool isPreview;
  final VoidCallback onValidate;
  final VoidCallback onShare;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
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
    required this.isFavorite,
    required this.onToggleFavorite,
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
        isFavorite != oldDelegate.isFavorite ||
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

    // FULL WIDTH: No horizontal margins, but keep vertical offset
    final double expandedWidth = MediaQuery.of(context).size.width;
    final double currentImageWidth =
        expandedWidth - (expandedWidth - collapsedImageSize) * progress;

    final double expandedTop = 0.0; // Start at the very top of the screen
    final double collapsedTop =
        topPadding + (minExtent - topPadding - collapsedImageSize) / 2;
    final double currentTop =
        expandedTop - (expandedTop - collapsedTop) * progress;

    final double expandedLeft = 0.0;
    final double collapsedLeft = 48.w;
    final double currentLeft =
        expandedLeft - (expandedLeft - collapsedLeft) * progress;

    final double expandedRadius = 0.0; // Sharp edges for full width look
    final double collapsedRadius = 8.r;
    final double currentRadius =
        expandedRadius - (expandedRadius - collapsedRadius) * progress;

    final double titleOpacity = progress > 0.8 ? (progress - 0.8) / 0.2 : 0.0;

    return Container(
      color: bgColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          Positioned(
            top: currentTop,
            left: currentLeft,
            width: currentImageWidth,
            height: currentImageHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(currentRadius),
              child: _buildImage(
                img,
                currentImageWidth,
                currentImageHeight,
                progress,
              ),
            ),
          ),

          // Collapsed Title in AppBar
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
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
            ),

          // AppBar Controls (Back, Share, etc.)
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
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: progress > 0.2
                            ? const Color(0xFFF9FAFB).withOpacity(progress)
                            : Colors.black12,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: progress > 0.5
                            ? const Color(0xFF1A1A1A)
                            : Colors.white,
                      ),
                    ),
                  ),

                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Heart button (only after scroll)
                      if (!isPreview && progress > 0.5 && recipeId != null) ...[
                        ValueListenableBuilder<List<Recipe>?>(
                          valueListenable: RecipeService.instance.favoriteRecipesNotifier,
                          builder: (context, favorites, _) {
                            bool isFav = false;
                            if (favorites != null) {
                              isFav = favorites.any((fav) => fav.id == recipeId);
                            } else {
                              isFav = isFavorite;
                            }
                            return GestureDetector(
                              onTap: onToggleFavorite,
                              child: Container(
                                width: 32.w,
                                height: 32.w,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB).withOpacity(progress),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  size: 18,
                                  color: isFav ? const Color(0xFFCC3333) : const Color(0xFF1A1A1A),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      // Share button (or validate if preview)
                      GestureDetector(
                        onTap: isPreview ? onValidate : onShare,
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: progress > 0.2
                                ? const Color(0xFFF9FAFB).withOpacity(progress)
                                : Colors.black12,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            isPreview
                                ? Icons.check_circle_rounded
                                : Icons.share_outlined,
                            size: 18,
                            color: isPreview
                                ? const Color(0xFF27AE60)
                                : (progress > 0.5
                                      ? const Color(0xFF1A1A1A)
                                      : Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
    final fit = BoxFit.cover;

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
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFFCC3333)),
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

// ── Yellow tag pill ─────────────────────────────────────────────────────────────
class _TagPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TagPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF2C94C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF111827)),
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab pill ───────────────────────────────────────────────────────────────────
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
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFCC3333) : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w700,
                fontSize: 14,
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
          Icon(
            icon,
            size: 48.sp,
            color: const Color(0xFFCBD5E1),
          ),
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

// ── Ingredients list ───────────────────────────────────────────────────────────
class _IngredientsList extends StatelessWidget {
  final List<RecipeIngredient> ingredients;
  const _IngredientsList({required this.ingredients});

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
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  if (ing.icon != null && ing.icon!.isNotEmpty) ...[
                    Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF9C3), // Light yellow
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        ing.icon!,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                  Expanded(
                    flex: 3,
                    child: Text(
                      ing.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF111827),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Text(
                      ing.quantity,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B7280),
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

// ── Equipment list ─────────────────────────────────────────────────────────────
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
                  item,
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

// ── Steps list ────────────────────────────────────────────────────────────────
class _StepsList extends StatelessWidget {
  final List<String> steps;
  final String? tips;
  const _StepsList({required this.steps, this.tips});

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
                // Premium step number circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCC3333).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Color(0xFFCC3333),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) {
                          String content = steps[i];
                          // Remove "Step X:" or "Step X." or "Step X - " from the start
                          final stepPrefixRegex = RegExp(r'^Step\s*\d+\s*[:.-]?\s*', caseSensitive: false);
                          content = content.replaceFirst(stepPrefixRegex, '');
                          
                          return Text(
                            content,
                            style: const TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: 14,
                              height: 1.6,
                              color: Color(0xFF111827),
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
        if (tips != null && tips!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Notes / Tips',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  tips!,
                  style: const TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF4B5563),
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