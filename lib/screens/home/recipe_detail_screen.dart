import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/history_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/recipe.dart';
import '../../models/cookbook.dart';
import '../../services/recipe_service.dart';
import '../../services/cookbook_service.dart';
import '../../routes/app_routes.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';
import '../../widgets/add_to_grocery_modal.dart';

enum DetailTab { steps, ingredients, equipment }

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});
  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  DetailTab _activeTab = DetailTab.steps;
  bool _historyLogged = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_historyLogged) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
      final Recipe? r = args['recipe'] as Recipe?;
      if (r != null) {
        HistoryService.instance.addToHistory(r);
        _historyLogged = true;
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  // ── Add-to-Cookbook modal ─────────────────────────────────────────────────
  void _showAddToCookbookModal(BuildContext ctx, Recipe recipe) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddToCookbookSheet(recipe: recipe),
    );
  }

  Future<void> _handleShare() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final Recipe? r = args['recipe'] as Recipe?;
    if (r == null) return;

    try {
      final link = await RecipeService.instance.getShareLink(r.id);
      final name = r.name;
      final time = '${r.cookTime} min';
      final kcal = '${r.kcal} kcal';
      
      // Emojis mapping to requested mockup icons
      final template = "Discover this recipe: $name\nReady in 🕒 $time, 🔥 $kcal.\n\nSee on Cooked: $link";
      
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
    _showAddToCookbookModal(context, r);
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

    final bool isPreview = args['isPreview'] ?? false;
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
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 90 + bottomPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image header area ───────────────────────────────────
                  _ImageHeader(
                    img: img,
                    name: name,
                    time: time,
                    kcal: kcal,
                    isPreview: isPreview,
                    onValidate: () async {
                      if (r == null) return;
                      await _saveRecipe(r);
                    },
                    onShare: _handleShare,
                  ),

                  // ── Content ─────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + heart
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                            if (!isPreview) ...[
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () async {
                                  if (r != null) {
                                    try {
                                      await RecipeService.instance.toggleFavorite(
                                        r.id,
                                      );
                                      setState(() {
                                        r.isFavorite = !r.isFavorite;
                                      });
                                    } catch (e) {
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
                                child: Icon(
                                  (r?.isFavorite ?? false)
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: const Color(0xFFCC3333),
                                  size: 28,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Tag pills
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (prep.isNotEmpty)
                              _TagPill(
                                icon: Icons.timer_outlined,
                                label: prep,
                              ),
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
                              label: r?.servings != null ? '${r!.servings} People' : '2 People',
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                          if (!isPreview) ...[
                            // Buttons row
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (r != null) {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) => AddToGroceryModal(recipe: r),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                            const SizedBox(height: 20),
                          ],

                        // Tabs row
                        Container(
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
                                onTap: () => setState(() => _activeTab = DetailTab.steps),
                              ),
                              _TabPill(
                                label: 'Equipment',
                                active: _activeTab == DetailTab.equipment,
                                onTap: () => setState(() => _activeTab = DetailTab.equipment),
                              ),
                              _TabPill(
                                label: 'Ingredients',
                                active: _activeTab == DetailTab.ingredients,
                                onTap: () => setState(() => _activeTab = DetailTab.ingredients),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Content based on tab
                        if (_activeTab == DetailTab.ingredients)
                          _IngredientsList(ingredients: r?.ingredients ?? [])
                        else if (_activeTab == DetailTab.equipment)
                          _EquipmentList(equipment: r?.equipment ?? [])
                        else
                          _StepsList(steps: r?.steps ?? [], tips: r?.tips),


                        // Dynamic bottom spacer for keyboard
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10 + bottomPad),
                child: (isPreview || (r?.origin == 'SUGGESTED'))
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isPreview) ...[
                            Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.info_outline_rounded,
                                      size: 14.sp, color: const Color(0xFF64748B)),
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
                            if (r?.sourceUrl != null && r!.sourceUrl!.isNotEmpty)
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
                                _showAddToCookbookModal(context, r!);
                              }
                            },
                            child: Container(
                              height: 56.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFC83A2D),
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFC83A2D).withOpacity(0.2),
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
                                        : (isPreview
                                            ? Icons.check_circle_outline_rounded
                                            : Icons.bookmark_add_rounded),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    isTrend
                                        ? 'Import this recipe'
                                        : (isPreview
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
                          _showAddToCookbookModal(context, r);
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

// ── Image header with back + share ─────────────────────────────────────────────
class _ImageHeader extends StatelessWidget {
  final String img;
  final String name;
  final String time;
  final String kcal;
  final bool isPreview;
  final VoidCallback onValidate;
  final VoidCallback onShare;

  const _ImageHeader({
    required this.img,
    required this.name,
    required this.time,
    required this.kcal,
    required this.isPreview,
    required this.onValidate,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350.h,
      child: Stack(
        children: [
          // Food image - Full Bleed
          Positioned.fill(
            top: 50.h,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(28.r),
              ),
              child: _buildImage(img),
            ),
          ),
          // Back + Share
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 24,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: isPreview
                        ? onValidate
                        : onShare,
                    child: Container(
                      child: Icon(
                        isPreview
                            ? Icons.check_circle_rounded
                            : Icons.share_outlined,
                        size: 24,
                        color: isPreview
                            ? const Color(0xFF27AE60)
                            : const Color(0xFF1A1A1A),
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

  Widget _buildImage(String path) {
    if (path.isEmpty) {
      return Image.asset(
        'assets/images/recipes.png',
        height: 300,
        width: 300,
        fit: BoxFit.contain,
      );
    }
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        height: 300,
        width: 300,
        fit: BoxFit.contain,
        errorWidget: (_, __, ___) => Image.asset(
          'assets/images/recipes.png',
          height: 300,
          width: 300,
          fit: BoxFit.contain,
        ),
        placeholder: (_, __) => Container(
          height: 300,
          width: 300,
          color: const Color(0xFFF2F1EF),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFFCC3333)),
          ),
        ),
      );
    }
    return Image.asset(
      path,
      height: 300,
      width: 300,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/recipes.png',
        height: 300,
        width: 300,
        fit: BoxFit.contain,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2C94C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF111827)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 12,
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
          padding: const EdgeInsets.symmetric(vertical: 8),
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
                color: active ? Colors.white : const Color(0xFF888888),
              ),
            ),
          ),
        ),
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
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text("No ingredients listed."),
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
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF9C3), // Light yellow
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        ing.icon!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                  Expanded(
                    child: Text(
                      ing.name,
                      style: const TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Text(
                    ing.quantity,
                    style: const TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
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
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text("No specific equipment listed."),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: equipment.length,
        separatorBuilder: (_, __) => const Divider(height: 0, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.handyman_outlined, size: 16, color: Color(0xFF64748B)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    equipment[i],
                    style: const TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text("No steps listed."),
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
                      fontSize: 14,
                      color: Color(0xFFCC3333),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StepContent(step: steps[i], index: i),
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
                    const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFD97706), size: 20),
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

// ══════════════════════════════════════════════════════════════════════════════
// ADD-TO-COOKBOOK BOTTOM SHEET
// ══════════════════════════════════════════════════════════════════════════════
class _AddToCookbookSheet extends StatefulWidget {
  final Recipe recipe;
  const _AddToCookbookSheet({required this.recipe});
  @override
  State<_AddToCookbookSheet> createState() => _AddToCookbookSheetState();
}

class _AddToCookbookSheetState extends State<_AddToCookbookSheet> {
  final Set<String> _selectedIds = {};
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: 0.85.sh),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add to Cookbook',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w800,
                    fontSize: 20.sp,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, size: 24.sp, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              children: [
                // Create New Option
                _buildActionTile(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Create a new recipe book',
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      AppRoutes.cookbookForm,
                      arguments: {'mode': 'add'},
                    );
                    if (result == true) {
                      setState(() {});
                    }
                  },
                ),
                SizedBox(height: 20.h),

                Text(
                  'Select Recipe Books',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 12.h),

                FutureBuilder<List<Cookbook>>(
                  future: CookbookService.instance.getMyCookbooks(),
                  builder: (ctx, snapshot) {
                    final cookbooks = snapshot.data ?? [];
                    
                    if (snapshot.connectionState == ConnectionState.waiting && cookbooks.isEmpty) {
                      return SizedBox(
                        height: 100.h,
                        child: const Center(child: CircularProgressIndicator(color: Color(0xFFCC3333))),
                      );
                    }
                    
                    if (cookbooks.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Center(
                          child: Text(
                            "No recipe books found.",
                            style: TextStyle(
                              color: const Color(0xFF64748B),
                              fontSize: 14.sp,
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cookbooks.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        itemBuilder: (lCtx, i) {
                          final cb = cookbooks[i];
                          final isSelected = _selectedIds.contains(cb.id);
                          return ListTile(
                            onTap: () {
                              setState(() {
                                if (isSelected) _selectedIds.remove(cb.id);
                                else _selectedIds.add(cb.id);
                              });
                            },
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                            title: Text(
                              cb.name,
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w600,
                                fontSize: 15.sp,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            trailing: Icon(
                              isSelected 
                                  ? Icons.check_circle_rounded 
                                  : Icons.radio_button_unchecked_rounded,
                              color: isSelected ? const Color(0xFFCC3333) : const Color(0xFFD1D5DB),
                              size: 24.sp,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Confirm Button
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h + bottomPad),
            child: SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: (_isSaving || _selectedIds.isEmpty) ? null : _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCC3333),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE5E7EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _selectedIds.isEmpty 
                            ? 'Select at least one book' 
                            : 'Add to selected books (${_selectedIds.length})',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFCC3333).withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFCC3333).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFCC3333), size: 22.sp),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
                color: const Color(0xFFCC3333),
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: const Color(0xFFCC3333), size: 20.sp),
          ],
        ),
      ),
    );
  }

  Future<void> _handleConfirm() async {
    setState(() => _isSaving = true);
    final idsList = _selectedIds.toList();
    
    try {
      if (widget.recipe.id.isEmpty) {
        // Recipe is not saved yet (Preview mode)
        await RecipeService.instance.createRecipe(
          widget.recipe,
          cookbookIds: idsList,
        );
      } else {
        // Recipe exists, add to each selected cookbook
        for (final cbId in idsList) {
          await CookbookService.instance.addRecipeToCookbook(
            cbId,
            widget.recipe.id,
          );
        }
      }

      if (!mounted) return;
      Navigator.pop(context); // Close sheet
      IosToast.show(
        context,
        message: 'Successfully added to ${idsList.length} book${idsList.length > 1 ? 's' : ''}!',
        type: ToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      IosToast.show(
        context,
        message: ErrorHelper.getFriendlyMessage(e),
        type: ToastType.error,
      );
    }
  }
}
class _StepContent extends StatelessWidget {
  final String step;
  final int index;

  const _StepContent({required this.step, required this.index});

  @override
  Widget build(BuildContext context) {
    String title = 'Step ${index + 1}';
    String content = step;

    // Detect if the string already contains a title like "Step 1: Prepare..." or just "Prepare..."
    // Look for first colon within first 60 chars
    final colonIndex = step.indexOf(':');
    if (colonIndex != -1 && colonIndex < 60) {
      final prefix = step.substring(0, colonIndex).trim();
      // If prefix contains "Step" or is just a short title
      if (prefix.toLowerCase().contains('step') || prefix.split(' ').length <= 4) {
        title = prefix;
        content = step.substring(colonIndex + 1).trim();
      }
    } else {
      // Check if there's a newline separating a title
      final newlineIndex = step.indexOf('\n');
      if (newlineIndex != -1 && newlineIndex < 60) {
        title = step.substring(0, newlineIndex).trim();
        content = step.substring(newlineIndex + 1).trim();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 15,
            height: 1.6,
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
