import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/recipe.dart';
import '../../models/cookbook.dart';
import '../../services/recipe_service.dart';
import '../../services/cookbook_service.dart';
import '../../services/grocery_service.dart';
import '../../routes/app_routes.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});
  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _isIngredientsTab = true; // false = Steps
  late bool _isFavorited;
  DateTime? _selectedDate;



  @override
  void initState() {
    super.initState();
    _isFavorited = false;
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

  Future<void> _addToGrocery(
    BuildContext context,
    Recipe r, [
    DateTime? date,
  ]) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      for (var ing in r.ingredients) {
        await GroceryService.instance.addGroceryItem(
          name: ing.name,
          quantity: ing.quantity,
          icon: ing.icon,
          recipeId: r.id,
          date: date,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      IosToast.show(
        context,
        message: date == null
            ? 'Ingredients added to your grocery list!'
            : 'Recipe scheduled for ${_fmtDate(date)}!',
        type: ToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      IosToast.show(
        context,
        message: ErrorHelper.getFriendlyMessage(e),
        type: ToastType.error,
      );
    }
  }

  String _fmtDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
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

    _isFavorited = r?.isFavorite ?? args['hearted'] ?? false;

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
                                        _isFavorited = !_isFavorited;
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
                                  _isFavorited
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
                                      _addToGrocery(
                                        context,
                                        r,
                                        _selectedDate ?? DateTime.now(),
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
                              const SizedBox(width: 15),
                              GestureDetector(
                                onTap: () async {
                                  final DateTime? pickedDate =
                                      await showDatePicker(
                                        context: context,
                                        initialDate:
                                            _selectedDate ?? DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(
                                          const Duration(days: 365),
                                        ),
                                      );
                                  if (pickedDate != null) {
                                    setState(() {
                                      _selectedDate = pickedDate;
                                    });
                                  }
                                },
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: _selectedDate != null
                                        ? const Color(0xFFCC3333)
                                        : const Color(0xFFEAEAEA),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today_outlined,
                                    color: _selectedDate != null
                                        ? Colors.white
                                        : const Color(0xFF111827),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Steps / Ingredients toggle
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEF),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              _TabPill(
                                label: 'Steps',
                                active: !_isIngredientsTab,
                                onTap: () =>
                                    setState(() => _isIngredientsTab = false),
                              ),
                              _TabPill(
                                label: 'Ingredients',
                                active: _isIngredientsTab,
                                onTap: () =>
                                    setState(() => _isIngredientsTab = true),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Content based on tab
                        if (_isIngredientsTab)
                          _IngredientsList(ingredients: r?.ingredients ?? [])
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
                child: (isPreview || (r?.isSuggested ?? false))
                    ? GestureDetector(
                        onTap: () => _showAddToCookbookModal(context, r!),
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
                              const Icon(
                                Icons.bookmark_add_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Add to recipe book',
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
                      Text(
                        'Step ${i + 1}',
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
                        steps[i],
                        style: const TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 15,
                          height: 1.6,
                          color: Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w500,
                        ),
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
      constraints: BoxConstraints(maxHeight: 0.8.sh),
      decoration: BoxDecoration(
        color: const Color(0xFFC83A2D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              child: Opacity(
                opacity: 0.12,
                child: Image.asset(
                  'assets/images/fond.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(22.w, 14.h, 22.w, bottomPad + 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Add to Recipe Books',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w800,
                          fontSize: 20.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),

                Flexible(
                  child: FutureBuilder<List<Cookbook>>(
                    future: CookbookService.instance.getMyCookbooks(),
                    builder: (ctx, snapshot) {
                      final cookbooks = snapshot.data ?? [];
                      
                      return Column(
                        mainAxisSize: MainAxisSize.min,
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
                          SizedBox(height: 12.h),

                          if (snapshot.connectionState == ConnectionState.waiting && cookbooks.isEmpty)
                             const Center(child: CircularProgressIndicator(color: Colors.white))
                          else if (cookbooks.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: Text(
                                "No recipe books found. Create one above!",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14.sp,
                                  fontFamily: 'SF Pro',
                                ),
                              ),
                            )
                          else
                            Flexible(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: cookbooks.length,
                                itemBuilder: (lCtx, i) {
                                  final cb = cookbooks[i];
                                  final isSelected = _selectedIds.contains(cb.id);
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 10.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(isSelected ? 0.25 : 0.1),
                                      borderRadius: BorderRadius.circular(15.r),
                                      border: Border.all(
                                        color: isSelected ? Colors.white : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) _selectedIds.remove(cb.id);
                                          else _selectedIds.add(cb.id);
                                        });
                                      },
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
                                      title: Text(
                                        cb.name,
                                        style: TextStyle(
                                          fontFamily: 'SF Pro',
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          fontSize: 15.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                      trailing: isSelected 
                                          ? Icon(Icons.check_circle_rounded, color: Colors.white, size: 24.sp)
                                          : Icon(Icons.radio_button_unchecked_rounded, color: Colors.white30, size: 24.sp),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),

                SizedBox(height: 20.h),

                // Confirm button
                GestureDetector(
                  onTap: (_isSaving || _selectedIds.isEmpty) ? null : _handleConfirm,
                  child: Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: _selectedIds.isEmpty 
                          ? Colors.white.withOpacity(0.5) 
                          : Colors.white,
                      borderRadius: BorderRadius.circular(15.r),
                      boxShadow: [
                        if (_selectedIds.isNotEmpty)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Center(
                      child: _isSaving 
                        ? const CircularProgressIndicator(color: Color(0xFFCC3333))
                        : Text(
                            _selectedIds.isEmpty 
                                ? 'Select at least one book' 
                                : 'Confirm (${_selectedIds.length})',
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                              color: const Color(0xFFCC3333),
                            ),
                          ),
                    ),
                  ),
                ),
              ],
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
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
                fontSize: 14.sp,
                color: const Color(0xFFCC3333),
              ),
            ),
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
