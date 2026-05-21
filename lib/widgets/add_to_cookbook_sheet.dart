import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import '../core/extensions/string_extensions.dart';
import '../models/recipe.dart';
import '../models/cookbook.dart';
import '../services/recipe_service.dart';
import '../services/cookbook_service.dart';
import '../core/widgets/ios_toast.dart';
import '../core/utils/error_helper.dart';
import 'cookbook_form_modal.dart';

enum _SheetMode { list, create }

class AddToCookbookSheet extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback? onSuccess;
  final String? title;

  const AddToCookbookSheet({
    super.key,
    required this.recipe,
    this.onSuccess,
    this.title,
  });

  @override
  State<AddToCookbookSheet> createState() => _AddToCookbookSheetState();
}

class _AddToCookbookSheetState extends State<AddToCookbookSheet> {
  _SheetMode _mode = _SheetMode.list;
  final Set<String> _selectedIds = {};
  final _newCookbookCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Initialize selected IDs from current cookbooks
    final cookbooks = CookbookService.instance.myCookbooksNotifier.value;
    if (cookbooks != null && widget.recipe.id.isNotEmpty) {
      for (var cb in cookbooks) {
        if (cb.recipes.any((r) => r.id == widget.recipe.id)) {
          _selectedIds.add(cb.id);
        }
      }
    } else {
      // Trigger load if null
      CookbookService.instance.getMyCookbooks();
    }
  }

  @override
  void dispose() {
    _newCookbookCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _mode == _SheetMode.list
                      ? _buildListView(scrollController)
                      : _buildCreateView(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListView(ScrollController scrollController) {
    final hasAnySelection = _selectedIds.isNotEmpty;

    return Column(
      key: const ValueKey('list'),
      children: [
        // Top Recipe Row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: widget.recipe.image != null && widget.recipe.image!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.recipe.image!,
                      width: 50.w,
                      height: 50.w,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: const Color(0xFFF3F4F6)),
                      errorWidget: (_, __, ___) => Container(
                        width: 50.w,
                        height: 50.w,
                        color: const Color(0xFFF3F4F6),
                        child: Icon(Icons.fastfood_rounded, color: const Color(0xFFD1D5DB), size: 20.sp),
                      ),
                    )
                  : Container(
                      width: 50.w,
                      height: 50.w,
                      color: const Color(0xFFF3F4F6),
                      child: Icon(Icons.fastfood_rounded, color: const Color(0xFFD1D5DB), size: 20.sp),
                    ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe.name.toTitleCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF1A1A1A),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                    Text(
                      '${widget.recipe.kcal} kcal • ${widget.recipe.cookTime} min',
                      style: TextStyle(
                        color: const Color(0xFF6B7280),
                        fontSize: 13.sp,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        Divider(color: const Color(0xFFE5E7EB), height: 32.h),

        // Cookbooks Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cookbooks',
                style: TextStyle(
                  color: const Color(0xFF111827),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SF Pro',
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _mode = _SheetMode.create),
                child: Text(
                  'New Cookbook',
                  style: TextStyle(
                    color: const Color(0xFFC83A2D), // Red as requested
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro',
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        Expanded(
          child: ValueListenableBuilder<List<Cookbook>?>(
            valueListenable: CookbookService.instance.myCookbooksNotifier,
            builder: (context, cookbooks, _) {
              if (cookbooks == null) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFC83A2D)));
              }

              return ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: cookbooks.length,
                itemBuilder: (context, index) {
                  final cb = cookbooks[index];
                  final isSelected = _selectedIds.contains(cb.id);
                  
                  // Hide plus icon for others if one is already selected
                  final shouldShowAction = isSelected || !hasAnySelection;

                  return _buildCookbookTile(cb, isSelected, shouldShowAction);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCookbookTile(Cookbook cb, bool isSelected, bool shouldShowAction) {
    return GestureDetector(
      onTap: () {
        if (shouldShowAction) _toggleSelection(cb.id);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: cb.recipes.isNotEmpty && cb.recipes.first.image != null && cb.recipes.first.image!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: cb.recipes.first.image!,
                      width: 54.w,
                      height: 54.w,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: const Color(0xFFF3F4F6)),
                      errorWidget: (_, __, ___) => Container(
                        width: 54.w,
                        height: 54.w,
                        color: const Color(0xFFF3F4F6),
                        child: Icon(Icons.menu_book_rounded, color: const Color(0xFFD1D5DB), size: 24.sp),
                      ),
                    )
                  : Container(
                      width: 54.w,
                      height: 54.w,
                      color: const Color(0xFFF3F4F6),
                      child: Icon(Icons.menu_book_rounded, color: const Color(0xFFD1D5DB), size: 24.sp),
                    ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cb.name.toTitleCase(),
                    style: TextStyle(
                      color: const Color(0xFF1F2937),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'SF Pro',
                    ),
                  ),
                  Text(
                    '${cb.recipes.length} recipes',
                    style: TextStyle(
                      color: const Color(0xFF6B7280),
                      fontSize: 13.sp,
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ],
              ),
            ),
            if (shouldShowAction)
              Icon(
                isSelected ? Icons.remove_circle_outline_rounded : Icons.add_circle_outline_rounded,
                color: isSelected ? const Color(0xFFC83A2D) : const Color(0xFFD1D5DB),
                size: 26.sp,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateView() {
    return CookbookFormModal(
      isEmbedded: true,
      initialName: _newCookbookCtrl.text,
      initialRecipes: [widget.recipe],
      onCancel: () => setState(() => _mode = _SheetMode.list),
      onComplete: (cb) {
        if (mounted) {
          setState(() {
            _mode = _SheetMode.list;
            _selectedIds.add(cb.id);
          });
          // Also trigger the success callback if needed, 
          // but we stay in the sheet to show the new cookbook selected
          widget.onSuccess?.call();
        }
      },
    );
  }

  Future<void> _toggleSelection(String cookbookId) async {
    if (_isProcessing) return;
    _isProcessing = true;
    
    HapticFeedback.lightImpact();
    
    final isSelected = _selectedIds.contains(cookbookId);
    setState(() {
      if (isSelected) {
        _selectedIds.remove(cookbookId);
      } else {
        // Enforce single selection as requested: "enleve l'icone plus des autres"
        _selectedIds.clear();
        _selectedIds.add(cookbookId);
      }
    });

    try {
      if (!isSelected) {
        await CookbookService.instance.addRecipeToCookbook(cookbookId, widget.recipe.id).catchError((e) {
           // Revert UI on error
           if (mounted) {
             setState(() {
              _selectedIds.remove(cookbookId);
            });
            IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
           }
           throw e;
        });
        if (widget.recipe.isSuggested) {
          RecipeService.instance.validateRecipe(widget.recipe.id).catchError((_) => widget.recipe);
        }
        
        // AUTO CLOSE after success (optimistic)
        widget.onSuccess?.call();
        if (mounted) Navigator.of(context).maybePop();
        
      } else {
        await CookbookService.instance.removeRecipeFromCookbook(cookbookId, widget.recipe.id).catchError((e) {
           // Revert UI on error
           if (mounted) {
             setState(() {
              _selectedIds.add(cookbookId);
            });
            IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
           }
           throw e;
        });
      }
    } catch (e) {
       // Revert UI on error
       if (mounted) {
         setState(() {
          if (!isSelected) {
            _selectedIds.remove(cookbookId);
          } else {
            _selectedIds.add(cookbookId);
          }
        });
        IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
       }
    } finally {
      _isProcessing = false;
    }
  }
}
