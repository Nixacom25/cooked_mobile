import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../routes/app_routes.dart';
import '../models/recipe.dart';
import '../core/extensions/string_extensions.dart';
import '../models/cookbook.dart';
import '../services/cookbook_service.dart';
import '../services/recipe_service.dart';
import '../core/widgets/ios_toast.dart';
import '../core/utils/error_helper.dart';
import '../widgets/glass_icon_button.dart';
import '../widgets/skeleton_list.dart';

class CookbookFormModal extends StatefulWidget {
  final Cookbook? cookbook;
  final String? initialName;
  final List<Recipe>? initialRecipes;
  final Function(Cookbook)? onComplete;
  final VoidCallback? onCancel;
  final bool isEmbedded;

  const CookbookFormModal({
    super.key,
    this.cookbook,
    this.initialName,
    this.initialRecipes,
    this.onComplete,
    this.onCancel,
    this.isEmbedded = false,
  });

  @override
  State<CookbookFormModal> createState() => _CookbookFormModalState();
}

class _CookbookFormModalState extends State<CookbookFormModal> {
  late TextEditingController _nameCtrl;
  late List<Recipe> _selectedRecipes;
  bool _isSaving = false;
  bool _isPickingRecipes = false;
  bool _isPopping = false;
  final DraggableScrollableController _dragCtrl = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
        text: widget.cookbook?.name ?? widget.initialName ?? '');
    _selectedRecipes = widget.cookbook?.recipes != null
        ? List.from(widget.cookbook!.recipes)
        : (widget.initialRecipes != null ? List.from(widget.initialRecipes!) : []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool get _isEdit => widget.cookbook != null;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    if (widget.isEmbedded) {
      return AnimatedPadding(
        padding: EdgeInsets.only(bottom: bottomInset),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: _buildContent(context, null),
      );
    }

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: DraggableScrollableSheet(
        controller: _dragCtrl,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _buildContent(context, scrollController);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ScrollController? scrollController) {
    final bool canSave = _nameCtrl.text.trim().isNotEmpty && !_isSaving;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: widget.isEmbedded
            ? BorderRadius.zero
            : BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        children: [
          // ── Header Row ──
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Left Circle Back Button
                GlassIconButton(
                  onTap: () {
                    if (_isPickingRecipes) {
                      setState(() => _isPickingRecipes = false);
                      if (!widget.isEmbedded) {
                        _dragCtrl.animateTo(0.85,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut);
                      }
                    } else if (widget.onCancel != null) {
                      widget.onCancel!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  size: 42.r,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: const Color(0xFF0F172A),
                    size: 20.sp,
                  ),
                ),

                // Center Title
                Text(
                  _isPickingRecipes
                      ? (_nameCtrl.text.trim().isNotEmpty
                          ? _nameCtrl.text.trim().toTitleCase()
                          : 'Select Recipes')
                      : (_isEdit ? 'Edit Cookbook' : 'New Cookbook'),
                  style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Rubik',
                  ),
                ),

                // Top Right Circle Action Button (+ when picking recipes, Close X when on form)
                GlassIconButton(
                  onTap: () {
                    if (_isPickingRecipes) {
                      // Shortcut to add new recipe/scan
                      Navigator.pushNamed(context, AppRoutes.scan);
                    } else if (widget.onCancel != null) {
                      widget.onCancel!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  size: 42.r,
                  child: Icon(
                    _isPickingRecipes ? Icons.add_rounded : Icons.close_rounded,
                    color: const Color(0xFF0F172A),
                    size: 22.sp,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.only(
                top: 8.h,
                bottom: 20.h,
              ),
              children: [
                if (!_isPickingRecipes) ...[
                  // Cookbook Name field input
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameCtrl,
                              autofocus: !widget.isEmbedded && !_isEdit,
                              style: TextStyle(
                                color: const Color(0xFF0F172A),
                                fontFamily: 'Rubik',
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Cookbook name',
                                hintStyle: TextStyle(
                                  color: const Color(0xFF94A3B8),
                                  fontFamily: 'Rubik',
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          if (_nameCtrl.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _nameCtrl.clear();
                                setState(() {});
                              },
                              child: Icon(
                                Icons.close_rounded,
                                color: const Color(0xFF94A3B8),
                                size: 18.sp,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Add recipes action tile
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: GestureDetector(
                      onTap: _pickRecipes,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40.r,
                              height: 40.r,
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
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Add recipes',
                                    style: TextStyle(
                                      color: const Color(0xFF0F172A),
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Rubik',
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Select recipes for this cookbook',
                                    style: TextStyle(
                                      color: const Color(0xFF64748B),
                                      fontSize: 13.sp,
                                      fontFamily: 'Rubik',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: const Color(0xFF0F172A),
                              size: 22.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (_selectedRecipes.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'Selected recipes',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _selectedRecipes
                            .map(
                              (r) => Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: _SelectedRecipePill(
                                  recipe: r,
                                  onRemove: () => setState(
                                    () => _selectedRecipes.removeWhere((x) => x.id == r.id),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ],

                if (_isPickingRecipes)
                  _InlineRecipePicker(
                    alreadySelected: _selectedRecipes,
                    onToggleRecipe: (r) {
                      setState(() {
                        if (_selectedRecipes.any((x) => x.id == r.id)) {
                          _selectedRecipes.removeWhere((x) => x.id == r.id);
                        } else {
                          _selectedRecipes.add(r);
                        }
                      });
                    },
                  ),
              ],
            ),
          ),

          // ── Bottom Fixed Save Button ──
          SafeArea(
            top: false,
            bottom: true,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16.w,
                12.h,
                16.w,
                12.h,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _isPickingRecipes
                      ? () => setState(() => _isPickingRecipes = false)
                      : (canSave ? _save : null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC31E26),
                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Rubik',
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

  Future<void> _pickRecipes() async {
    setState(() => _isPickingRecipes = true);
    if (!widget.isEmbedded) {
      _dragCtrl.animateTo(0.85,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart);
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final List<String> validRecipeIds = [];
      for (int i = 0; i < _selectedRecipes.length; i++) {
        Recipe r = _selectedRecipes[i];
        if (r.id.isEmpty) {
          r = await RecipeService.instance.createRecipe(r);
          _selectedRecipes[i] = r;
        } else {
          r = await RecipeService.instance.validateRecipe(r.id).catchError((_) => r);
          _selectedRecipes[i] = r;
        }
        RecipeService.instance.markRecipeAsSaved(r);
        validRecipeIds.add(r.id);
      }

      Cookbook cb;
      if (_isEdit) {
        cb = await CookbookService.instance
            .updateCookbook(widget.cookbook!.id, name, validRecipeIds);
      } else {
        cb = await CookbookService.instance.createCookbook(name, validRecipeIds);
      }

      if (!mounted) return;
      if (mounted) {
        IosToast.show(context,
            message: _isEdit ? 'Cookbook updated!' : 'Cookbook created!',
            type: ToastType.success);
      }

      if (!mounted || _isPopping) return;
      _isPopping = true;

      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;

      if (!widget.isEmbedded) {
        try {
          Navigator.of(context).pop(cb);
        } catch (e) {
          debugPrint('Silent error during modal pop: $e');
        }
      }
      widget.onComplete?.call(cb);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        IosToast.show(context,
            message: ErrorHelper.getFriendlyMessage(e),
            type: ToastType.error);
      }
    }
  }
}

class _SelectedRecipePill extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onRemove;

  const _SelectedRecipePill({required this.recipe, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: const Color(0xFFF3E8D3),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: recipe.image != null && recipe.image!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: recipe.image!,
                    width: 28.r,
                    height: 28.r,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 28.r,
                      height: 28.r,
                      color: const Color(0xFFCBD5E1),
                      child: Icon(Icons.fastfood_rounded,
                          size: 14.sp, color: Colors.white),
                    ),
                  )
                : Container(
                    width: 28.r,
                    height: 28.r,
                    color: const Color(0xFFCBD5E1),
                    child: Icon(Icons.fastfood_rounded,
                        size: 14.sp, color: Colors.white),
                  ),
          ),
          SizedBox(width: 10.w),
          Flexible(
            child: Text(
              recipe.name.toTitleCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF0F172A),
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20.r,
              height: 20.r,
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineRecipePicker extends StatefulWidget {
  final List<Recipe> alreadySelected;
  final Function(Recipe) onToggleRecipe;
  const _InlineRecipePicker(
      {required this.alreadySelected, required this.onToggleRecipe});

  @override
  State<_InlineRecipePicker> createState() => _InlineRecipePickerState();
}

class _InlineRecipePickerState extends State<_InlineRecipePicker> {
  List<Recipe>? _allRecipes;
  bool _loading = true;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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

  void _handleShortcutTap(String target) {
    Navigator.of(context).pop();
    if (target == 'scan') {
      Navigator.pushNamed(context, AppRoutes.scan);
    } else if (target == 'import') {
      Navigator.pushNamed(context, AppRoutes.import);
    } else if (target == 'explore') {
      Navigator.pushNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = (_allRecipes ?? [])
        .where((r) =>
            r.name.toLowerCase().contains(_searchQuery.trim().toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar (Matching Image 3)
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: const Color(0xFF94A3B8),
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0F172A),
                    ),
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search your recipes',
                      hintStyle: TextStyle(
                        fontFamily: 'Rubik',
                        color: const Color(0xFF94A3B8),
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Icon(
                      Icons.close_rounded,
                      color: const Color(0xFF94A3B8),
                      size: 18.sp,
                    ),
                  ),
              ],
            ),
          ),
        ),

        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SkeletonList(height: 60, itemCount: 6),
          )
        else if (_allRecipes == null || _allRecipes!.isEmpty) ...[
          // Shortcut Buttons Row (Scan, Import, Explore) matching Image 3
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                _buildShortcutCard(
                  title: 'Scan',
                  icon: Icons.crop_free_rounded,
                  onTap: () => _handleShortcutTap('scan'),
                ),
                SizedBox(width: 12.w),
                _buildShortcutCard(
                  title: 'Import',
                  icon: Icons.file_download_outlined,
                  onTap: () => _handleShortcutTap('import'),
                ),
                SizedBox(width: 12.w),
                _buildShortcutCard(
                  title: 'Explore',
                  icon: Icons.search_rounded,
                  onTap: () => _handleShortcutTap('explore'),
                ),
              ],
            ),
          ),
          SizedBox(height: 48.h),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                children: [
                  Text(
                    'No recipes yet',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w800,
                      fontSize: 20.sp,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Start adding recipes to this cookbook by scanning, importing or exploring.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      height: 1.4,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 32.h),
        ] else if (filtered.isEmpty) ...[
          Center(
            child: Padding(
              padding: EdgeInsets.all(40.r),
              child: Text(
                'No recipes found matching "$_searchQuery"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  color: const Color(0xFF64748B),
                  fontSize: 14.sp,
                ),
              ),
            ),
          )
        ] else ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              'Explore recipes',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w800,
                fontSize: 16.sp,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: filtered.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (ctx, i) {
              final r = filtered[i];
              final isSelected = widget.alreadySelected.any(
                (x) => x.id == r.id,
              );

              return GestureDetector(
                onTap: () {
                  widget.onToggleRecipe(r);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF6EE),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFC31E26) : Colors.transparent,
                      width: 1.5.w,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(4.r),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: Container(
                              width: double.infinity,
                              color: const Color(0xFFF2F1EF),
                              child: (r.image != null && r.image!.isNotEmpty)
                                  ? (r.image!.startsWith('http')
                                      ? CachedNetworkImage(
                                          imageUrl: r.image!,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) => Image.asset(
                                            'assets/images/recipes.png',
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Image.asset(
                                          r.image!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Image.asset(
                                            'assets/images/recipes.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ))
                                  : Image.asset(
                                      'assets/images/recipes.png',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                r.name.toTitleCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Container(
                              width: 20.r,
                              height: 20.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? const Color(0xFFC31E26) : Colors.transparent,
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: const Color(0xFFCBD5E1),
                                        width: 1.5.w,
                                      ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 13.sp,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ]
      ],
    );
  }

  Widget _buildShortcutCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF0F172A),
                  size: 20.sp,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                title,
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
      ),
    );
  }
}
