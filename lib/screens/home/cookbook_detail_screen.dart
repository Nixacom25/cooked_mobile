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
import '../../widgets/glass_icon_button.dart';
import '../../widgets/app_top_header.dart';
import '../../widgets/red_header_background.dart';
import '../../widgets/saved_recipe_card.dart';

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
                            GlassIconButton(
                              onTap: () => Navigator.pop(context),
                              size: 42.r,
                              child: Icon(
                                Icons.arrow_back_rounded,
                                size: 20.sp,
                                color: const Color(0xFF0F172A),
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
                              GlassIconButton(
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
                                size: 42.r,
                                child: Icon(
                                  Icons.add_rounded,
                                  color: const Color(0xFF0F172A),
                                  size: 22.sp,
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
                                      return SavedRecipeCard(
                                        recipe: r,
                                        isPinned: r.isPinned,
                                        onPinTap: () {
                                          RecipeService.instance.togglePin(r.id);
                                        },
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          AppRoutes.recipeDetail,
                                          arguments: {
                                            'recipe': r,
                                            'isPreview': false
                                          },
                                        ),
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
              barrierColor: Colors.transparent,
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

