import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
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
          final updated = cookbooks.where((c) => c.id == _cookbookId).firstOrNull;
          if (updated != null) {
            _cookbook = updated;
          }
        }

        final String name = _cookbook?.name ?? 'Cookbook';
        final List<Recipe> recipes = _cookbook?.recipes ?? [];

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
                      if (_cookbook != null && !_cookbook!.id.startsWith('static_'))
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              AppRoutes.cookbookForm,
                              arguments: {'mode': 'edit', 'cookbook': _cookbook},
                            );
                            if (result == 'deleted') {
                              if (mounted) Navigator.pop(context, true);
                            } else if (result == true) {
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
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14.h,
                            crossAxisSpacing: 14.w,
                            childAspectRatio: 0.72,
                          ),
                          itemBuilder: (_, __) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonLoader(width: double.infinity, height: 145.h, borderRadius: 20),
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
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20.r),
                                child: Container(
                                  width: 200.w,
                                  height: 200.h,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: _buildThemedEmptyImage(name),
                                ),
                              ),
                              const SizedBox(height: 30),
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
                                  "Tap the + button above to add recipes to this cookbook.",
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
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14.h,
                            crossAxisSpacing: 14.w,
                            childAspectRatio: 0.72,
                          ),
                          itemBuilder: (ctx, i) {
                            final r = recipes[i];
                            return RecipeCard(
                              recipe: r,
                              onHeartTap: () async {
                                try {
                                  await RecipeService.instance.toggleFavorite(r.id);
                                  setState(() {
                                    r.isFavorite = !r.isFavorite;
                                  });
                                } catch (e) {
                                  IosToast.show(ctx, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
                                }
                              },
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.recipeDetail,
                                arguments: {'recipe': r},
                              ),
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

  Widget _buildThemedEmptyImage(String name) {
    final lowerName = name.toLowerCase();
    String assetPath = 'assets/images/cookbook_everyday.png';

    if (lowerName.contains('protein')) {
      assetPath = 'assets/images/higth-proteins.png';
    } else if (lowerName.contains('dessert')) {
      assetPath = 'assets/images/cookbook_dessert.png';
    } else if (lowerName.contains('healthy')) {
      assetPath = 'assets/images/cookbook_healthy.png';
    } else if (lowerName.contains('italian')) {
      assetPath = 'assets/images/cookbook_italian.png';
    } else if (lowerName.contains('lunch')) {
      assetPath = 'assets/images/cookbook_lunch.png';
    } else if (lowerName.contains('meat')) {
      assetPath = 'assets/images/cookbook_meat.png';
    } else if (lowerName.contains('veggie')) {
      assetPath = 'assets/images/cookbook_veggie.png';
    }

    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFF5F5F5),
        child: const Center(
          child: Icon(Icons.menu_book_rounded, size: 60, color: Color(0xFFCCCCCC)),
        ),
      ),
    );
  }
}
