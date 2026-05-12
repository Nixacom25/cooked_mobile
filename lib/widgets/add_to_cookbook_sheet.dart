import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/recipe.dart';
import '../models/cookbook.dart';
import '../services/recipe_service.dart';
import '../services/cookbook_service.dart';
import '../routes/app_routes.dart';
import '../core/widgets/ios_toast.dart';
import '../core/utils/error_helper.dart';
import 'red_button.dart';
import 'skeleton_list.dart';

class AddToCookbookSheet extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback? onSuccess;

  const AddToCookbookSheet({
    super.key,
    required this.recipe,
    this.onSuccess,
  });

  @override
  State<AddToCookbookSheet> createState() => _AddToCookbookSheetState();
}

class _AddToCookbookSheetState extends State<AddToCookbookSheet> {
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

                ValueListenableBuilder<List<Cookbook>?>(
                  valueListenable: CookbookService.instance.myCookbooksNotifier,
                  builder: (ctx, cookbooks, _) {
                    if (cookbooks == null) {
                      CookbookService.instance.getMyCookbooks();
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: const SkeletonList(height: 60, itemCount: 3),
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
                                if (isSelected) {
                                  _selectedIds.remove(cb.id);
                                } else {
                                  _selectedIds.add(cb.id);
                                }
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
                              color: isSelected ? const Color(0xFFC83A2D) : const Color(0xFFD1D5DB),
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

          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h + bottomPad),
            child: RedButton(
              label: _selectedIds.isEmpty 
                  ? 'Select at least one book' 
                  : 'Add to selected books (${_selectedIds.length})',
              loadingLabel: 'Saving',
              isLoading: _isSaving,
              isDisabled: _selectedIds.isEmpty,
              onTap: _handleConfirm,
              height: 54.h,
              fontSize: 16.sp,
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
          color: const Color(0xFFC83A2D).withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFC83A2D).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFC83A2D), size: 22.sp),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
                color: const Color(0xFFC83A2D),
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: const Color(0xFFC83A2D), size: 20.sp),
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
        
        // If it was a suggestion, validate it so it becomes a permanent part of "My Recipes"
        if (widget.recipe.origin == 'SUGGESTED') {
          await RecipeService.instance.validateRecipe(widget.recipe.id);
        }
      }

      if (!mounted) return;
      Navigator.pop(context); // Close sheet
      widget.onSuccess?.call();
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
