import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe.dart';
import '../core/extensions/string_extensions.dart';
import '../models/cookbook.dart';
import '../services/cookbook_service.dart';
import '../services/recipe_service.dart';
import '../core/widgets/ios_toast.dart';
import '../core/utils/error_helper.dart';
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
    if (widget.isEmbedded) {
      return _buildContent(context, null);
    }

    return DraggableScrollableSheet(
      controller: _dragCtrl,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return _buildContent(context, scrollController);
      },
    );
  }

  Widget _buildContent(BuildContext context, ScrollController? scrollController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: widget.isEmbedded
            ? BorderRadius.zero
            : BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: widget.isEmbedded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (!widget.isEmbedded)
            // Drag handle
            Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_isPickingRecipes) {
                      setState(() => _isPickingRecipes = false);
                      if (!widget.isEmbedded) {
                        _dragCtrl.animateTo(0.65,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut);
                      }
                    } else if (widget.onCancel != null) {
                      widget.onCancel!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isEmbedded || _isPickingRecipes)
                          Padding(
                            padding: EdgeInsets.only(right: 2.w),
                            child: Icon(
                              Icons.chevron_left_rounded,
                              color: const Color(0xFF0F172A),
                              size: 18.sp,
                            ),
                          ),
                        Text(
                          (_isPickingRecipes) ? 'Back' : 'Cancel',
                          style: TextStyle(
                            color: const Color(0xFF0F172A),
                            fontSize: 14.sp,
                            fontFamily: 'Rubik',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  _isPickingRecipes
                      ? 'Select Recipes'
                      : (_isEdit ? 'Edit Cookbook' : 'New Cookbook'),
                  style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Rubik',
                  ),
                ),
                GestureDetector(
                  onTap: _isPickingRecipes
                      ? () {
                          setState(() => _isPickingRecipes = false);
                          if (!widget.isEmbedded) {
                            _dragCtrl.animateTo(0.65,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut);
                          }
                        }
                      : _save,
                  child: _isSaving
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFC83A2D),
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: (_isPickingRecipes ||
                                    _nameCtrl.text.trim().isNotEmpty)
                                ? const Color(0xFFC83A2D)
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            _isPickingRecipes ? 'Done' : 'Save',
                            style: TextStyle(
                              color: (_isPickingRecipes ||
                                      _nameCtrl.text.trim().isNotEmpty)
                                  ? Colors.white
                                  : const Color(0xFF94A3B8),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Rubik',
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          Expanded(
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 40.h),
              children: [
                if (!_isPickingRecipes) ...[
                  SizedBox(height: 20.h),

                  // Name field input
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 4.h),
                      child: TextField(
                        controller: _nameCtrl,
                        autofocus: !widget.isEmbedded,
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
                  ),

                  SizedBox(height: 20.h),

                  // Add recipes action card
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: GestureDetector(
                      onTap: _pickRecipes,
                      child: Container(
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5E8),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                color: const Color(0xFFC83A2D),
                                size: 20.sp,
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
                            if (_selectedRecipes.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC83A2D),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  '${_selectedRecipes.length}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Rubik',
                                  ),
                                ),
                              ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: const Color(0xFF94A3B8),
                              size: 22.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (_selectedRecipes.isNotEmpty) ...[
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'Included Recipes (${_selectedRecipes.length})',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _selectedRecipes
                            .map((r) => _RecipeChip(
                                  recipe: r,
                                  onRemove: () => setState(() =>
                                      _selectedRecipes
                                          .removeWhere((x) => x.id == r.id)),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ],
                if (_isPickingRecipes)
                  _InlineRecipePicker(
                    alreadySelected: _selectedRecipes,
                    onSelected: (recipes) {
                      setState(() {
                        for (var r in recipes) {
                          if (!_selectedRecipes.any((x) => x.id == r.id)) {
                            _selectedRecipes.add(r);
                          }
                        }
                      });
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickRecipes() async {
    setState(() => _isPickingRecipes = true);
    if (!widget.isEmbedded) {
      _dragCtrl.animateTo(0.95,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart);
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final recipeIds = _selectedRecipes.map((r) => r.id).toList();
      Cookbook cb;
      if (_isEdit) {
        cb = await CookbookService.instance
            .updateCookbook(widget.cookbook!.id, name, recipeIds);
      } else {
        cb = await CookbookService.instance.createCookbook(name, recipeIds);
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

class _RecipeChip extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onRemove;

  const _RecipeChip({required this.recipe, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: recipe.image != null && recipe.image!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: recipe.image!,
                    width: 22.w,
                    height: 22.w,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 22.w,
                      height: 22.w,
                      color: const Color(0xFFCBD5E1),
                      child: Icon(Icons.fastfood_rounded,
                          size: 12.sp, color: Colors.white),
                    ),
                  )
                : Container(
                    width: 22.w,
                    height: 22.w,
                    color: const Color(0xFFCBD5E1),
                    child: Icon(Icons.fastfood_rounded,
                        size: 12.sp, color: Colors.white),
                  ),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              recipe.name.toTitleCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF0F172A),
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded,
                size: 16.sp, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _InlineRecipePicker extends StatefulWidget {
  final List<Recipe> alreadySelected;
  final Function(List<Recipe>) onSelected;
  const _InlineRecipePicker(
      {required this.alreadySelected, required this.onSelected});

  @override
  State<_InlineRecipePicker> createState() => _InlineRecipePickerState();
}

class _InlineRecipePickerState extends State<_InlineRecipePicker> {
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
    return Column(
      children: [
        const Divider(color: Color(0xFFF1F5F9)),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SkeletonList(height: 60, itemCount: 8),
          )
        else if (_allRecipes == null || _allRecipes!.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                'No recipes found',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  color: const Color(0xFF64748B),
                  fontSize: 14.sp,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _allRecipes!.length,
            itemBuilder: (ctx, i) {
              final r = _allRecipes![i];
              final isAlready = widget.alreadySelected.any(
                (x) => x.id == r.id,
              );
              final isSelected = _selected.any((x) => x.id == r.id);

              return ListTile(
                onTap: isAlready
                    ? null
                    : () {
                        setState(() {
                          if (isSelected) {
                            _selected.removeWhere((x) => x.id == r.id);
                          } else {
                            _selected.add(r);
                          }
                        });
                        widget.onSelected(_selected);
                      },
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: r.image != null && r.image!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: r.image!,
                          width: 48.w,
                          height: 48.w,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 48.w,
                            height: 48.w,
                            color: const Color(0xFFF1F5F9),
                            child: Icon(Icons.fastfood_rounded,
                                size: 20.sp, color: const Color(0xFF94A3B8)),
                          ),
                        )
                      : Container(
                          width: 48.w,
                          height: 48.w,
                          color: const Color(0xFFF1F5F9),
                          child: Icon(Icons.fastfood_rounded,
                              size: 20.sp, color: const Color(0xFF94A3B8)),
                        ),
                ),
                title: Text(
                  r.name.toTitleCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                subtitle: Text(
                  '${r.cookTime} min • ${r.kcal} kcal',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                trailing: isAlready
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFFCBD5E1),
                      )
                    : Checkbox(
                        value: isSelected,
                        activeColor: const Color(0xFFC83A2D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
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
                          widget.onSelected(_selected);
                        },
                      ),
              );
            },
          ),
      ],
    );
  }
}
