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
import '../../core/utils/tutorial_helper.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
          {};
      _cookbook = args['cookbook'] as Cookbook?;
      if (_cookbook != null) {
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
    setState(() => _loading = true);
    try {
      final updated = await CookbookService.instance.getCookbook(_cookbook!.id);
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
    final String name = _cookbook?.name ?? 'Cookbook';
    final List<Recipe> recipes = _cookbook?.recipes ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
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
                      name.isEmpty 
                          ? name 
                          : name[0].toUpperCase() + name.substring(1).toLowerCase(),
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
                        if (result == true) _load();
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
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFCC3333),
                      ),
                    )
                  : recipes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/cookbook.png',
                            width: 140,
                            height: 140,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "No recipes yet",
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                              fontSize: 18,
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
                        mainAxisExtent: 240.h,
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
  }
}
