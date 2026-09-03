import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/recipe.dart';
import '../services/grocery_service.dart';
import '../core/widgets/ios_toast.dart';
import '../core/utils/error_helper.dart';
import 'glass_icon_button.dart';
import 'red_button.dart';

class AddToGroceryModal extends StatefulWidget {
  final Recipe recipe;
  final int currentServings;
  final int originalServings;

  const AddToGroceryModal({
    super.key,
    required this.recipe,
    this.currentServings = 1,
    this.originalServings = 1,
  });

  @override
  State<AddToGroceryModal> createState() => _AddToGroceryModalState();
}

class _AddToGroceryModalState extends State<AddToGroceryModal> {
  late List<bool> _selectedIngredients;
  bool _isSaving = false;
  DateTime? _selectedDate;
  bool _isSpecificDate = false;

  @override
  void initState() {
    super.initState();
    _selectedIngredients = List.generate(widget.recipe.ingredients.length, (_) => true);
  }

  String _formatScaledQuantity(RecipeIngredient ing) {
    if (ing.amount == 0) return ing.quantity;
    
    double scaledAmount = (ing.amount * widget.currentServings) / widget.originalServings;
    
    String formattedAmount;
    if (scaledAmount == scaledAmount.toInt()) {
      formattedAmount = scaledAmount.toInt().toString();
    } else {
      formattedAmount = scaledAmount.toStringAsFixed(1);
      if (formattedAmount.endsWith('.0')) {
        formattedAmount = formattedAmount.substring(0, formattedAmount.length - 2);
      }
    }
    
    return ing.unit.isEmpty ? formattedAmount : '$formattedAmount ${ing.unit}';
  }

  bool get _canSubmit => _selectedIngredients.any((selected) => selected) && !_isSaving;

  Future<void> _handleSave() async {
    if (!_canSubmit) return;

    setState(() => _isSaving = true);
    try {
      final selectedItems = <({String name, String quantity, String? icon})>[];
      for (int i = 0; i < widget.recipe.ingredients.length; i++) {
        if (_selectedIngredients[i]) {
          final ing = widget.recipe.ingredients[i];
          selectedItems.add((
            name: ing.name,
            quantity: _formatScaledQuantity(ing),
            icon: ing.icon,
          ));
        }
      }

      final count = selectedItems.length;

      await GroceryService.instance.addMultipleGroceryItems(
        items: selectedItems,
        recipeId: widget.recipe.id,
        date: _isSpecificDate ? (_selectedDate ?? DateTime.now()) : null,
        source: 'recipe',
      );

      if (!mounted) return;

      IosToast.show(
        context,
        message: '$count ingredient${count > 1 ? 's' : ''} added to Grocery List',
        type: ToastType.success,
      );

      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: 0.85.sh),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 36.w,
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
                  'Add to Grocery List',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                GlassIconButton(
                  onTap: () => Navigator.pop(context),
                  size: 38.r,
                  child: Icon(
                    Icons.close_rounded,
                    size: 20.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              children: [
                Text(
                  'Select Ingredients',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 12.h),
                
                // Ingredients List
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.recipe.ingredients.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    itemBuilder: (context, index) {
                      final ing = widget.recipe.ingredients[index];
                      return CheckboxListTile(
                        value: _selectedIngredients[index],
                        onChanged: (val) {
                          setState(() => _selectedIngredients[index] = val ?? false);
                        },
                        activeColor: const Color(0xFFC83A2D),
                        checkColor: Colors.white,
                        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                        title: Text(
                          ing.name,
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontWeight: FontWeight.w600,
                            fontSize: 15.sp,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        subtitle: Text(
                          _formatScaledQuantity(ing),
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 13.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        secondary: ing.icon != null && ing.icon!.isNotEmpty
                            ? Text(ing.icon!, style: TextStyle(fontSize: 18.sp))
                            : null,
                      );
                    },
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Save Location',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    if (_isSpecificDate && _selectedDate != null)
                      Text(
                        "Date: ${_fmtDate(_selectedDate!)}",
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          color: const Color(0xFFC83A2D),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12.h),
                
                // Location Options
                Row(
                  children: [
                    Expanded(
                      child: _LocationOption(
                        label: 'General List',
                        icon: Icons.inventory_2_outlined,
                        selected: !_isSpecificDate,
                        onTap: () => setState(() => _isSpecificDate = false),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _LocationOption(
                        label: 'Specific Date',
                        icon: Icons.calendar_today_outlined,
                        selected: _isSpecificDate,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDate = picked;
                              _isSpecificDate = true;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Submit Button
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h + bottomPad),
            child: RedButton(
              label: 'Add selected ingredients',
              loadingLabel: 'Saving',
              isLoading: _isSaving,
              isDisabled: !_canSubmit,
              onTap: _handleSave,
              color: const Color(0xFFC83A2D),
              textColor: Colors.white,
              height: 54.h,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

class _LocationOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _LocationOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF1F0) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? const Color(0xFFC83A2D) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xFFC83A2D) : const Color(0xFF64748B),
              size: 24.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
                color: selected ? const Color(0xFFC83A2D) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
