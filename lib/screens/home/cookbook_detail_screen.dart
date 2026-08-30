import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';

import '../../routes/app_routes.dart';
import '../../widgets/app_search_field.dart';
import '../../models/cookbook.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../../services/cookbook_service.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';
import '../../core/extensions/string_extensions.dart';
import '../../core/utils/tutorial_helper.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/cookbook_form_modal.dart';
import '../../widgets/add_to_cookbook_sheet.dart';
import '../../widgets/haptic_context_menu.dart';
import '../../widgets/app_top_header.dart';
import '../../widgets/red_header_background.dart';

class CookbookDetailScreen extends StatefulWidget {
  const CookbookDetailScreen({super.key});

  @override
  State<CookbookDetailScreen> createState() => _CookbookDetailScreenState();
}

class _CookbookDetailScreenState extends State<CookbookDetailScreen> {
  final _searchCtrl = TextEditingController();
  Cookbook? _cookbook;
  bool _loading = false;
  bool _initialized = false;
  late final String _cookbookId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
              {};
      _cookbook = args['cookbook'] as Cookbook?;
      if (_cookbook != null) {
        _cookbookId = _cookbook!.id;
        _load();
      }
      _initialized = true;

      // Trigger onboarding if active
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          TutorialHelper.showCookbookOnboardingDialog(context);
        }
      });
    }
  }

  Future<void> _load() async {
    if (_cookbook == null || _cookbook!.id.startsWith('static_')) return;

    final bool showSpinner = _cookbook!.recipes.isEmpty;
    if (showSpinner) {
      setState(() => _loading = true);
    }

    try {
      final updated = await CookbookService.instance.getCookbook(_cookbookId);
      if (mounted) {
        setState(() {
          _cookbook = updated;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        IosToast.show(
          context,
          message: ErrorHelper.getFriendlyMessage(e),
          type: ToastType.error,
        );
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Cookbook>?>(
      valueListenable: CookbookService.instance.myCookbooksNotifier,
      builder: (context, cookbooks, _) {
        if (cookbooks != null) {
          final updated =
              cookbooks.where((c) => c.id == _cookbookId).firstOrNull;
          if (updated != null) {
            _cookbook = updated;
          }
        }

        final String name = _cookbook?.name ?? 'Cookbook';
        final List<Recipe> allRecipes = _cookbook?.recipes != null
            ? List.from(_cookbook!.recipes)
            : [];

        allRecipes.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return 0;
        });

        // Filter by search query
        final query = _searchCtrl.text.trim().toLowerCase();
        final List<Recipe> recipes = query.isEmpty
            ? allRecipes
            : allRecipes
                .where((r) => r.name.toLowerCase().contains(query))
                .toList();

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
                  margin: EdgeInsets.only(top: 25.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32.r),
                    ),
                  ),
                  child: Column(
                    children: [
                      // ── Top Bar ─────────────────────────────────────────────
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
                              child: Text(
                                name.toTitleCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22.sp,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            if (_cookbook != null &&
                                !_cookbook!.id.startsWith('static_'))
                              GestureDetector(
                                onTap: () async {
                                  final result = await showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => CookbookFormModal(
                                      cookbook: _cookbook,
                                    ),
                                  );
                                  if (result == 'deleted') {
                                    if (mounted) Navigator.pop(context, true);
                                  } else if (result is Cookbook) {
                                    _load();
                                  }
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

                      // ── Search bar ──────────────────────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: AppSearchField(
                          controller: _searchCtrl,
                          onChanged: (_) {
                            setState(() {});
                          },
                          hintText: 'Search your recipes',
                          backgroundColor: const Color(0xFFF1F5F9),
                          borderColor: Colors.transparent,
                          borderRadius: 16.r,
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // ── Recipes List / Skeleton / Empty State ───────────────
                      Expanded(
                        child: _loading
                            ? ListView.separated(
                                padding: EdgeInsets.fromLTRB(
                                  16.w,
                                  4.h,
                                  16.w,
                                  20.h,
                                ),
                                itemCount: 4,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 14.h),
                                itemBuilder: (_, __) => SkeletonLoader(
                                  width: double.infinity,
                                  height: 140.h,
                                  borderRadius: 24,
                                ),
                              )
                            : recipes.isEmpty
                                ? _buildEmptyState(context)
                                : ListView.separated(
                                    padding: EdgeInsets.fromLTRB(
                                      16.w,
                                      4.h,
                                      16.w,
                                      20.h,
                                    ),
                                    itemCount: recipes.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: 14.h),
                                    itemBuilder: (ctx, i) {
                                      final r = recipes[i];
                                      return _HorizontalRecipeCard(
                                        recipe: r,
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          AppRoutes.recipeDetail,
                                          arguments: {
                                            'recipe': r,
                                            'isPreview': false
                                          },
                                        ),
                                        onFavoriteTap: () {
                                          setState(() {
                                            r.isFavorite = !r.isFavorite;
                                          });
                                        },
                                        onLongPressStart: (details) {
                                          _showRecipeContextMenu(
                                            ctx,
                                            r,
                                            details.globalPosition,
                                          );
                                        },
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRecipeContextMenu(
    BuildContext context,
    Recipe r,
    Offset position,
  ) {
    HapticContextMenu.show(
      context,
      targetPosition: position,
      actions: [
        HapticMenuAction(
          title: r.isPinned ? 'Unpin Recipe' : 'Pin Recipe',
          icon: r.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
          onTap: () {
            setState(() {
              final idx =
                  _cookbook!.recipes.indexWhere((req) => req.id == r.id);
              if (idx != -1) {
                _cookbook!.recipes[idx] = _cookbook!.recipes[idx].copyWith(
                  isPinned: !_cookbook!.recipes[idx].isPinned,
                );
              }
            });
            RecipeService.instance
                .togglePin(r.id)
                .then((updated) {
                  if (mounted) {
                    IosToast.show(
                      context,
                      message: updated.isPinned
                          ? 'Recipe pinned'
                          : 'Recipe unpinned',
                      type: ToastType.success,
                    );
                  }
                })
                .catchError((e) {
                  if (mounted) {
                    IosToast.show(
                      context,
                      message: 'Failed to pin recipe',
                      type: ToastType.error,
                    );
                  }
                });
          },
        ),
        HapticMenuAction(
          title: 'Add to Cookbook',
          icon: Icons.add_circle_outline_rounded,
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => AddToCookbookSheet(recipe: r),
            );
          },
        ),
        HapticMenuAction(
          title: 'Remove from Cookbook',
          icon: Icons.remove_circle_outline_rounded,
          isDestructive: true,
          onTap: () {
            CookbookService.instance
                .removeRecipeFromCookbook(_cookbook!.id, r.id)
                .catchError((e) {
                  if (mounted) {
                    IosToast.show(
                      context,
                      message: ErrorHelper.getFriendlyMessage(e),
                      type: ToastType.error,
                    );
                  }
                  return _cookbook!;
                });

            IosToast.show(
              context,
              message: 'Removed from cookbook',
              type: ToastType.success,
            );
          },
        ),
        HapticMenuAction(
          title: 'Share Recipe',
          icon: Icons.ios_share_rounded,
          onTap: () async {
            try {
              final rawLink =
                  await RecipeService.instance.getShareLink(r.id);
              final link = rawLink
                  .replaceAll('cooked.nixacom.com', 'link.cookedapp.com')
                  .replaceAll('https://cooked.nixacom.app',
                      'https://link.cookedapp.com');
              final name = r.name;
              final creatorStr =
                  r.creator != null ? "${r.creator!.displayName}'s " : "";
              final template = "Check out $creatorStr$name on Cooked 🙌\n$link";

              Share.share(template);
            } catch (e) {
              if (mounted) {
                IosToast.show(
                  context,
                  message: ErrorHelper.getFriendlyMessage(e),
                  type: ToastType.error,
                );
              }
            }
          },
        ),
        HapticMenuAction(
          title: 'Delete Recipe',
          icon: Icons.delete_outline_rounded,
          isDestructive: true,
          onTap: () {
            RecipeService.instance
                .deleteRecipe(r.id)
                .catchError((_) => false);
            IosToast.show(
              context,
              message: 'Recipe deleted',
              type: ToastType.success,
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
      child: Column(
        children: [
          // 3 Shortcut Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShortcutButton(
                context,
                icon: Icons.crop_free_rounded,
                label: 'Scan',
                tabIndex: 2,
              ),
              _buildShortcutButton(
                context,
                icon: Icons.file_download_outlined,
                label: 'Import',
                tabIndex: 4,
              ),
              _buildShortcutButton(
                context,
                icon: Icons.search_rounded,
                label: 'Explore',
                tabIndex: 1,
              ),
            ],
          ),

          const Spacer(),

          // Text Section
          Text(
            "No recipes yet",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              fontSize: 22.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              "Start adding recipes to this cookbook by scanning, importing or exploring.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Rubik',
                color: const Color(0xFF64748B),
                fontSize: 14.sp,
                height: 1.35,
              ),
            ),
          ),

          const Spacer(),

          // Bottom Save Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              height: 54.h,
              decoration: BoxDecoration(
                color: const Color(0xFFC83A2D),
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: Center(
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int tabIndex,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
          arguments: {'initialTab': tabIndex},
        );
      },
      child: Container(
        width: 104.w,
        height: 114.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50.r,
              height: 50.r,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: const Color(0xFF0F172A),
                  size: 22.sp,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final Function(LongPressStartDetails)? onLongPressStart;

  const _HorizontalRecipeCard({
    required this.recipe,
    required this.onTap,
    required this.onFavoriteTap,
    this.onLongPressStart,
  });

  @override
  Widget build(BuildContext context) {
    final String imagePath = recipe.image ?? 'assets/images/plat1.png';
    final int rawTime = (recipe.prepTime ?? 0) > 0
        ? recipe.prepTime!
        : (recipe.cookTime > 0 ? recipe.cookTime : 10);
    final int calories = recipe.kcal > 0 ? recipe.kcal : 217;

    return GestureDetector(
      onTap: onTap,
      onLongPressStart: onLongPressStart,
      child: Container(
        height: 140.h,
        decoration: BoxDecoration(
          color: const Color(0xFFFAF5E8),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          children: [
            // Left content area
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14.w, 12.h, 12.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Favorite heart button
                    GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          recipe.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18.sp,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                    ),

                    SizedBox(height: 6.h),

                    // Recipe Title
                    Text(
                      recipe.name.toTitleCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w800,
                        fontSize: 16.sp,
                        color: const Color(0xFF0F172A),
                        height: 1.25,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Badges row: time & calories
                    Row(
                      children: [
                        // Time pill
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1EAD9),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 13.sp,
                                color: const Color(0xFF475569),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '$rawTime min',
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11.sp,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 6.w),

                        // Calories pill
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1EAD9),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department_rounded,
                                size: 13.sp,
                                color: const Color(0xFF475569),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '$calories kcal',
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11.sp,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Right image area with chevron overlay button
            SizedBox(
              width: 145.w,
              height: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(24.r),
                      ),
                      child: imagePath.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: imagePath,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Image.asset(
                                'assets/images/plat1.png',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/plat1.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),

                  // Overlay chevron button
                  Positioned(
                    top: 10.r,
                    right: 10.r,
                    child: Container(
                      width: 34.r,
                      height: 34.r,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20.sp,
                        color: const Color(0xFF0F172A),
                      ),
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
}
