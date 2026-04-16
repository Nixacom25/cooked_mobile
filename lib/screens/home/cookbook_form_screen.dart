import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/recipe.dart';
import '../../models/cookbook.dart';
import '../../services/cookbook_service.dart';
import '../../services/recipe_service.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';

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
      body: Stack(
        children: [
          // ── Scrollable content ───────────────────────────────────────────
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 90 + bottomPad),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ─────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            isEdit ? 'Edit Cookbook' : 'Add Cookbook',
                            style: const TextStyle(
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                              color: Color(0xFF1A1A1A),
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
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE5E5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: Color(0xFFCC3333),
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0F0F0),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Name field ─────────────────────────────────────────
                  const Text(
                    'Name',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF999999),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameCtrl,
                    style: const TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Everyday meal',
                      hintStyle: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 15,
                        color: Colors.grey[400],
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFCC3333),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Recipes section ────────────────────────────────────
                  const Text(
                    'Recipes',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),

                  const SizedBox(height: 12),

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
                ],
              ),
            ),
          ),

          // ── Save button (sticky bottom) ──────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPad + 12),
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
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCC3333),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: _saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save',
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 12,
              color: Color(0xFF999999),
            ),
            const SizedBox(width: 3),
            Text(
              '${recipe.cookTime} min',
              style: const TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 11,
                color: Color(0xFF999999),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.local_fire_department_rounded,
              size: 12,
              color: Color(0xFF999999),
            ),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                '${recipe.kcal} kcal',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 11,
                  color: Color(0xFF999999),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return const Center(
        child: Icon(Icons.fastfood_rounded, size: 40, color: Color(0xFFCCCCCC)),
      );
    }
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(
            Icons.broken_image_rounded,
            size: 40,
            color: Color(0xFFCCCCCC),
          ),
        ),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.fastfood_rounded, size: 40, color: Color(0xFFCCCCCC)),
      ),
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
                const Text(
                  'Select Recipes',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, _selected),
                  child: const Text(
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
                ? const Center(child: Text('No recipes found'))
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
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFFF5F5F5),
                            image: r.image != null
                                ? DecorationImage(
                                    image: r.image!.startsWith('http')
                                        ? NetworkImage(r.image!)
                                        : AssetImage(r.image!) as ImageProvider,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: r.image == null
                              ? const Icon(
                                  Icons.fastfood_rounded,
                                  size: 20,
                                  color: Color(0xFFCCCCCC),
                                )
                              : null,
                        ),
                        title: Text(
                          r.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
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
}
