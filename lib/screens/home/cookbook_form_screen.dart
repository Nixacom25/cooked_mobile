import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/recipe.dart';
import '../../models/cookbook.dart';
import '../../services/cookbook_service.dart';
import '../../services/recipe_service.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';
import '../../routes/app_routes.dart';

class CookbookFormScreen extends StatefulWidget {
  const CookbookFormScreen({super.key});
  @override
  State<CookbookFormScreen> createState() => _CookbookFormScreenState();
}

class _CookbookFormScreenState extends State<CookbookFormScreen> {
  late TextEditingController _nameCtrl;
  late List<Recipe> _recipes;
  bool _initialised = false;
  bool _saving = false;
  Cookbook? _cookbook;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialised) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
          {};

      _cookbook = args['cookbook'] as Cookbook?;
      final String? name = _cookbook?.name ?? args['name'] as String?;
      final List<Recipe>? recipes =
          _cookbook?.recipes ?? args['recipes'] as List<Recipe>?;

      _nameCtrl = TextEditingController(text: name ?? '');
      _recipes = recipes != null ? List<Recipe>.from(recipes) : [];
      _initialised = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    final String mode = args['mode'] as String? ?? 'add';
    final bool isEdit = mode == 'edit';
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Scrollable content ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ─────────────────────────────────────────────
                      Padding(
                        padding: EdgeInsets.only(top: 30.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                isEdit ? 'Edit Cookbook' : 'Add Cookbook',
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18.sp,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                            if (isEdit)
                              GestureDetector(
                                onTap: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Cookbook'),
                                      content: const Text(
                                        'Are you sure you want to delete this cookbook?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    try {
                                      await CookbookService.instance.deleteCookbook(
                                        _cookbook!.id,
                                      );
                                      if (mounted) Navigator.pop(context, true);
                                    } catch (e) {
                                      if (mounted) {
                                        IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
                                      }
                                    }
                                  }
                                },
                                child: Container(
                                  width: 36.r,
                                  height: 36.r,
                                  margin: EdgeInsets.only(right: 8.w),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFE5E5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20.sp,
                                    color: const Color(0xFFCC3333),
                                  ),
                                ),
                              ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 36.r,
                                height: 36.r,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF0F0F0),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 20.sp,
                                  color: const Color(0xFF555555),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
    
                      SizedBox(height: 24.h),
    
                      // ── Name field ─────────────────────────────────────────
                      Text(
                        'Name',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                          color: const Color(0xFF999999),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 13.sp,
                          color: const Color(0xFF1A1A1A),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Everyday meal',
                          hintStyle: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 13.sp,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFCC3333),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
    
                      SizedBox(height: 28.h),
    
                      // ── Recipes section ────────────────────────────────────
                      Text(
                        'Recipes',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w800,
                          fontSize: 15.sp,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
    
                      SizedBox(height: 12.h),
    
                      // Grid of recipe mini-cards + add slot
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recipes.length + 1, // +1 for add slot
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14.h,
                          crossAxisSpacing: 14.w,
                          childAspectRatio: 0.82,
                        ),
                        itemBuilder: (_, i) {
                          // Last item = add slot
                          if (i == _recipes.length) {
                            return _AddRecipeSlot(
                              onTap: () async {
                                final List<Recipe>? selected =
                                    await showModalBottomSheet<List<Recipe>>(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (ctx) =>
                                          _RecipePicker(alreadySelected: _recipes),
                                    );
                                if (selected != null && mounted) {
                                  setState(() {
                                    _recipes.addAll(selected);
                                  });
                                }
                              },
                            );
                          }
                          final r = _recipes[i];
                          return _FormRecipeCard(
                            recipe: r,
                            onDelete: () => setState(() => _recipes.removeAt(i)),
                          );
                        },
                      ),
                      SizedBox(height: 12.h),
                      
                      // Manual keyboard spacer
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                    ],
                  ),
                ),
              ),
            ),
    
            // ── Save button (fixed bottom) ──────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, bottomPad + 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: _saving
                    ? null
                    : () async {
                        if (_nameCtrl.text.trim().isEmpty) {
                          IosToast.show(context, message: 'Please enter a name.', type: ToastType.success);
                          return;
                        }
                        setState(() => _saving = true);
                        try {
                          final List<String> recipeIds = _recipes
                              .map((r) => r.id)
                              .toList();
                          if (isEdit) {
                            await CookbookService.instance.updateCookbook(
                              _cookbook!.id,
                              _nameCtrl.text.trim(),
                              recipeIds,
                            );
                          } else {
                            await CookbookService.instance.createCookbook(
                              _nameCtrl.text.trim(),
                              recipeIds,
                            );
                          }
                          if (mounted) Navigator.pop(context, true);
                        } catch (e) {
                          if (mounted) {
                            IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
                          }
                        } finally {
                          if (mounted) setState(() => _saving = false);
                        }
                      },
                child: Container(
                  height: 42.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCC3333),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Center(
                    child: _saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Save',
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w700,
                              fontSize: 13.sp,
                              color: Colors.white,
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

// ── Recipe mini-card in form (with trash icon) ─────────────────────────────────
class _FormRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onDelete;
  const _FormRecipeCard({required this.recipe, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image area
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF5F5F5),
                  child: _buildImage(recipe.image),
                ),
              ),
              // Trash icon
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE5E5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: Color(0xFFCC3333),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          recipe.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w700,
            fontSize: 11.sp,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String? path) {
    const fallback = 'assets/images/recipes.png';
    if (path == null || path.isEmpty) {
      return Image.asset(fallback, fit: BoxFit.cover);
    }
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFCC3333)),
        ),
        errorWidget: (_, __, ___) => Image.asset(fallback, fit: BoxFit.cover),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(fallback, fit: BoxFit.cover),
    );
  }
}

// ── Empty add slot ─────────────────────────────────────────────────────────────
class _AddRecipeSlot extends StatelessWidget {
  final VoidCallback onTap;
  const _AddRecipeSlot({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
        ),
        child: const Center(
          child: Icon(Icons.add_rounded, size: 36, color: Color(0xFFCCCCCC)),
        ),
      ),
    );
  }
}

// ── Recipe Picker Modal ────────────────────────────────────────────────────────
class _RecipePicker extends StatefulWidget {
  final List<Recipe> alreadySelected;
  const _RecipePicker({required this.alreadySelected});

  @override
  State<_RecipePicker> createState() => _RecipePickerState();
}

class _RecipePickerState extends State<_RecipePicker> {
  List<Recipe>? _allRecipes;
  final List<Recipe> _selected = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cached = RecipeService.instance.myRecipesNotifier.value;
    if (cached != null) {
      if (!mounted) return;
      setState(() {
        _allRecipes = cached;
        _loading = false;
      });
      return;
    }

    try {
      final list = await RecipeService.instance.getMyRecipes();
      if (!mounted) return;
      setState(() {
        _allRecipes = list;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Recipes',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w800,
                    fontSize: 15.sp,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, _selected),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFCC3333),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _allRecipes == null || _allRecipes!.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF5F5F5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            size: 40,
                            color: Color(0xFFCCCCCC),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No recipes found',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add recipes to your cookbook by scanning,\nimporting, or exploring.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 11.sp,
                            color: Color(0xFF999999),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _EmptyStateButton(
                              icon: Icons.qr_code_scanner_rounded,
                              label: 'Scan',
                              onTap: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.home,
                                  (route) => false,
                                  arguments: {'initialTab': 2},
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            _EmptyStateButton(
                              icon: Icons.file_download_outlined,
                              label: 'Import',
                              onTap: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.home,
                                  (route) => false,
                                  arguments: {'initialTab': 4},
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            _EmptyStateButton(
                              icon: Icons.search_rounded,
                              label: 'Explore',
                              onTap: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.home,
                                  (route) => false,
                                  arguments: {'initialTab': 1},
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _allRecipes!.length,
                    itemBuilder: (ctx, i) {
                      final r = _allRecipes![i];
                      final isAlready = widget.alreadySelected.any(
                        (x) => x.id == r.id,
                      );
                      final isSelected = _selected.any((x) => x.id == r.id);

                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFFF5F5F5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildThumbnail(r.image),
                          ),
                        ),
                        title: Text(
                          r.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600
                            ),
                        ),
                        subtitle: Text('${r.cookTime} min • ${r.kcal} kcal'),
                        trailing: isAlready
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.grey,
                              )
                            : Checkbox(
                                value: isSelected,
                                activeColor: const Color(0xFFCC3333),
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selected.add(r);
                                    } else {
                                      _selected.removeWhere(
                                        (x) => x.id == r.id,
                                      );
                                    }
                                  });
                                },
                              ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(String? image) {
    const fallback = 'assets/images/recipes.png';
    if (image == null || image.isEmpty) {
      return Image.asset(fallback, fit: BoxFit.cover);
    }
    if (image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: const Color(0xFFEEEEEE)),
        errorWidget: (_, __, ___) => Image.asset(fallback, fit: BoxFit.cover),
      );
    }
    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(fallback, fit: BoxFit.cover),
    );
  }
}

class _EmptyStateButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _EmptyStateButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFEBEB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFFCC3333)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                fontSize: 11.sp,
                color: Color(0xFFCC3333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
