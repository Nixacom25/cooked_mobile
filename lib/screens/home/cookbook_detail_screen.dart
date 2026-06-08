import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/recipe_card.dart';
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
import 'package:flutter_svg/flutter_svg.dart';

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

    // Only show loading if we don't have recipes yet
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
        // If the global list updated, find our cookbook to stay in sync
        if (cookbooks != null) {
          final updated = cookbooks
              .where((c) => c.id == _cookbookId)
              .firstOrNull;
          if (updated != null) {
            _cookbook = updated;
          }
        }

        final String name = _cookbook?.name ?? 'Cookbook';
        final List<Recipe> recipes = _cookbook?.recipes != null
            ? List.from(_cookbook!.recipes)
            : [];
        recipes.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return 0; // maintain original order for others
        });

        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Column(
              children: [
                // ── AppBar ──────────────────────────────────────────────────────
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
                        child: Text(
                          name.toTitleCase(),
                          style: const TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      // + button opens Edit Cookbook form
                      if (_cookbook != null &&
                          !_cookbook!.id.startsWith('static_'))
                        GestureDetector(
                          onTap: () async {
                            final result = await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) =>
                                  CookbookFormModal(cookbook: _cookbook),
                            );
                            if (result == 'deleted') {
                              if (mounted) Navigator.pop(context, true);
                            } else if (result is Cookbook) {
                              _load();
                            }
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

                // ── Search bar ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: AppSearchField(
                    controller: _searchCtrl,
                    hintText: 'Search recipes...',
                  ),
                ),

                const SizedBox(height: 16),

                // ── Recipes grid ────────────────────────────────────────────────
                Expanded(
                  child: _loading
                      ? GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                          itemCount: 4,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 14.h,
                                crossAxisSpacing: 14.w,
                                childAspectRatio: 0.72,
                              ),
                          itemBuilder: (_, __) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonLoader(
                                width: double.infinity,
                                height: 145.h,
                                borderRadius: 20,
                              ),
                              SizedBox(height: 10.h),
                              SkeletonLoader(width: 140.w, height: 16.h),
                              SizedBox(height: 6.h),
                              SkeletonLoader(width: 80.w, height: 12.h),
                            ],
                          ),
                        )
                      : recipes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildShortcutButton(
                                      context,
                                      icon: Icons.camera_alt_rounded,
                                      label: 'Scan',
                                      tabIndex: 2,
                                    ),
                                    _buildShortcutButton(
                                      context,
                                      svgPath: 'assets/nav/import.svg',
                                      label: 'Import',
                                      tabIndex: 4,
                                    ),
                                    _buildShortcutButton(
                                      context,
                                      svgPath: 'assets/nav/explore.svg',
                                      label: 'Explore',
                                      tabIndex: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 35),
                              Text(
                                "No recipes yet",
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1A1A1A),
                                  fontSize: 22.sp,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40.w),
                                child: Text(
                                  "Start adding recipes to this cookbook by scanning, importing or exploring.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'SF Pro',
                                    color: Colors.grey[500],
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                          itemCount: recipes.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 14.h,
                                crossAxisSpacing: 14.w,
                                childAspectRatio: 0.72,
                              ),
                          itemBuilder: (ctx, i) {
                            final r = recipes[i];
                            return RecipeCard(
                              recipe: r,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.recipeDetail,
                                arguments: {'recipe': r, 'isPreview': false},
                              ),
                              onAddToCookbookTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: true,
                                  builder: (_) => AddToCookbookSheet(recipe: r),
                                );
                              },
                              onPinTap: () {
                                // Optimistic local update
                                setState(() {
                                  final idx = _cookbook!.recipes.indexWhere(
                                    (req) => req.id == r.id,
                                  );
                                  if (idx != -1) {
                                    _cookbook!.recipes[idx] = _cookbook!
                                        .recipes[idx]
                                        .copyWith(
                                          isPinned:
                                              !_cookbook!.recipes[idx].isPinned,
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
                                      // Revert on error
                                      if (mounted) {
                                        setState(() {
                                          final idx = _cookbook!.recipes
                                              .indexWhere(
                                                (req) => req.id == r.id,
                                              );
                                          if (idx != -1) {
                                            _cookbook!.recipes[idx] = _cookbook!
                                                .recipes[idx]
                                                .copyWith(
                                                  isPinned: !_cookbook!
                                                      .recipes[idx]
                                                      .isPinned,
                                                );
                                          }
                                        });
                                        IosToast.show(
                                          context,
                                          message: 'Failed to pin recipe',
                                          type: ToastType.error,
                                        );
                                      }
                                    });
                              },
                              onShareTap: () async {
                                try {
                                  final RenderBox? box =
                                      context.findRenderObject() as RenderBox?;
                                  final Rect? sharePositionOrigin = box != null
                                      ? box.localToGlobal(Offset.zero) &
                                            box.size
                                      : null;

                                  final rawLink = await RecipeService.instance.getShareLink(r.id);
                                  final link = rawLink.replaceAll('cooked.nixacom.com', 'link.cookedapp.com').replaceAll('https://cooked.nixacom.app', 'https://link.cookedapp.com');
                                  final name = r.name;
                                  final creatorStr = r.creator != null ? "${r.creator!.displayName}'s " : "";
                                  final template = "Check out $creatorStr$name on Cooked 🙌\n$link";

                                  Share.share(
                                    template,
                                    sharePositionOrigin: sharePositionOrigin,
                                  );
                                } catch (e) {
                                  if (mounted) {
                                    IosToast.show(
                                      context,
                                      message: ErrorHelper.getFriendlyMessage(
                                        e,
                                      ),
                                      type: ToastType.error,
                                    );
                                  }
                                }
                              },
                              onRemoveFromCookbookTap: () {
                                // Optimistic action
                                CookbookService.instance.removeRecipeFromCookbook(
                                  _cookbook!.id,
                                  r.id,
                                ).catchError((e) {
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
                              onDeleteTap: () {
                                // Optimistic deletion
                                RecipeService.instance.deleteRecipe(r.id).catchError((_) => false);
                                IosToast.show(
                                  context,
                                  message: 'Recipe deleted',
                                  type: ToastType.success,
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShortcutButton(
    BuildContext context, {
    IconData? icon,
    String? svgPath,
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
        width: 100.w,
        height: 105.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46.w,
              height: 46.h,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Center(
                child: svgPath != null
                    ? SvgPicture.asset(
                        svgPath,
                        width: 22.w,
                        height: 22.h,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFC83A2D),
                          BlendMode.srcIn,
                        ),
                      )
                    : Icon(icon, color: const Color(0xFFC83A2D), size: 24.sp),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
