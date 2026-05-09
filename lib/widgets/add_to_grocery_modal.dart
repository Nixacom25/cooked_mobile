import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/recipe.dart';
import '../services/grocery_service.dart';
import '../core/widgets/ios_toast.dart';
import '../core/utils/error_helper.dart';

class AddToGroceryModal extends StatefulWidget {
  final Recipe recipe;

  const AddToGroceryModal({super.key, required this.recipe});

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

  bool get _canSubmit => _selectedIngredients.any((selected) => selected) && !_isSaving;

  Future<void> _handleSave() async {
    if (!_canSubmit) return;

    setState(() => _isSaving = true);
    try {
      final selectedItems = <RecipeIngredient>[];
      for (int i = 0; i < widget.recipe.ingredients.length; i++) {
        if (_selectedIngredients[i]) {
          selectedItems.add(widget.recipe.ingredients[i]);
        }
      }

      for (var ing in selectedItems) {
        await GroceryService.instance.addGroceryItem(
          name: ing.name,
          quantity: ing.quantity,
          icon: ing.icon,
          recipeId: widget.recipe.id,
          date: _isSpecificDate ? (_selectedDate ?? DateTime.now()) : null,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      IosToast.show(
        context,
        message: 'Ingredients added to shopping list',
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

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: 0.85.sh),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        color: Colors.white,
        image: const DecorationImage(
          image: AssetImage('assets/images/fond1.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFC83A2D),
              const Color(0xFFC83A2D).withOpacity(0.9),
            ],
            stops: const [0.0, 1.0],
          ),
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
                color: Colors.white.withOpacity(0.3),
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
                    'Add to Shopping List',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w800,
                      fontSize: 20.sp,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, size: 24.sp, color: Colors.white70),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1, color: Colors.white.withOpacity(0.2)),

            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                children: [
                  Text(
                    'Select Ingredients',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  
                  // Ingredients List
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.recipe.ingredients.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.white.withOpacity(0.1)),
                      itemBuilder: (context, index) {
                        final ing = widget.recipe.ingredients[index];
                        return CheckboxListTile(
                          value: _selectedIngredients[index],
                          onChanged: (val) {
                            setState(() => _selectedIngredients[index] = val ?? false);
                          },
                          activeColor: Colors.white,
                          checkColor: const Color(0xFFC83A2D),
                          checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                          side: const BorderSide(color: Colors.white70),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                          title: Text(
                            ing.name,
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w600,
                              fontSize: 15.sp,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            ing.quantity,
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: 13.sp,
                              color: Colors.white70,
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
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                      ),
                      if (_isSpecificDate && _selectedDate != null)
                        Text(
                          "Date: ${_fmtDate(_selectedDate!)}",
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color: Colors.white,
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
              child: SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: _canSubmit ? _handleSave : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFC83A2D),
                    disabledBackgroundColor: Colors.white.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Color(0xFFC83A2D))
                      : Text(
                          'Add selected ingredients',
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
          color: selected ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? Colors.white : Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Colors.white70,
              size: 24.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
                color: selected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
