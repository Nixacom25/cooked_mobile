import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/grocery_service.dart';
import '../services/recipe_service.dart';
import '../services/ingredient_service.dart';
import '../models/grocery_item.dart';
import '../models/recipe.dart';
import '../core/widgets/ios_toast.dart';
import '../core/utils/error_helper.dart';
import '../services/notification_service.dart';
import '../core/extensions/string_extensions.dart';

// ══════════════════════════════════════════════════════════════════════════════
// GROCERY SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});
  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  DateTime? _selectedDate = DateTime.now();
  List<GroceryItem> _allItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroceries();
  }

  Future<void> _loadGroceries() async {
    try {
      final items = await GroceryService.instance.getMyGroceries();
      if (!mounted) return;
      setState(() {
        _allItems = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
    }
  }

  // Filtered by selected date
  List<GroceryItem> get _filteredItems {
    if (_selectedDate == null) {
      return _allItems.where((item) => item.plannedDate == null).toList();
    }
    return _allItems
        .where(
          (item) =>
              item.plannedDate != null &&
              _sameDay(item.plannedDate!, _selectedDate!),
        )
        .toList();
  }

  // Grouped by recipe name (simulated grouping for display)
  Map<String, List<GroceryItem>> get _grouped {
    final groups = <String, List<GroceryItem>>{};
    for (final item in _filteredItems) {
      final key = item.recipeName ?? 'Manual Add';
      if (!groups.containsKey(key)) groups[key] = [];
      groups[key]!.add(item);
    }
    return groups;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFCC3333),
            onPrimary: Colors.white,
            onSurface: Color(0xFF1A1A1A),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      // Schedule reminder for the new date
      NotificationService.instance.scheduleShoppingReminder(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ── Main content column ────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ... header ...
                Padding(
                  padding: EdgeInsets.fromLTRB(18.w, 30.h, 24.w, 4.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Grocery List',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w800,
                                fontSize: 24.sp,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            Text(
                              _selectedDate == null 
                                  ? 'General items' 
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontSize: 13.sp,
                                color: const Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Calendar icon with selected date label
                      GestureDetector(
                        onTap: () => setState(() => _selectedDate = null),
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          child: Icon(
                            Icons.all_inclusive_rounded,
                            size: 20.sp,
                            color: _selectedDate == null ? const Color(0xFFCC3333) : Colors.grey,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          child: Icon(
                            Icons.calendar_today_outlined,
                            size: 20.sp,
                            color: _selectedDate != null ? const Color(0xFFCC3333) : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFCC3333),
                          ),
                        )
                      : _filteredItems.isEmpty
                      ? _buildEmpty()
                        : ListView.builder(
                          padding: EdgeInsets.only(bottom: 120.h),
                          itemCount: _grouped.length,
                          itemBuilder: (_, gi) {
                            final recipeName = _grouped.keys.elementAt(gi);
                            final items = _grouped[recipeName]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    18,
                                    gi == 0 ? 14 : 28,
                                    18,
                                    4,
                                  ),
                                  child: Text(
                                    recipeName,
                                    style: TextStyle(
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.sp,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ),
                                ...items.map((item) {
                                  return Column(
                                    children: [
                                      _ItemRow(
                                        item: item,
                                        onToggle: () async {
                                          try {
                                            await GroceryService.instance
                                                .toggleBought(item.id);
                                            _loadGroceries();
                                          } catch (e) {
                                            IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
                                          }
                                        },
                                        onDelete: () async {
                                          try {
                                            await GroceryService.instance
                                                .deleteGroceryItem(item.id);
                                            _loadGroceries();
                                          } catch (e) {
                                            IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
                                          }
                                        },
                                      ),
                                      const Divider(
                                        height: 0,
                                        thickness: 1,
                                        color: Color(0xFFF2F2F2),
                                        indent: 18,
                                        endIndent: 18,
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),

            // ── Floating Add button (above the transparent nav bar) ────────
            if (_filteredItems.isNotEmpty)
              Positioned(
                bottom: 100.h,
                right: 20.w,
                child: GestureDetector(
                  onTap: () => _showAddGrocerySheet(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCC3333),
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCC3333).withValues(alpha: 0.4),
                          blurRadius: 16.r,
                          offset: Offset(0, 6.h),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white, size: 18.sp),
                        SizedBox(width: 6.w),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
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
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 56.sp,
            color: Colors.grey[300],
          ),
          SizedBox(height: 14.h),
          Text(
            _selectedDate == null 
                ? 'No general items' 
                : 'No groceries planned\nfor this day',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 15.sp,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'You can enter your shopping list manually OR use ingredients from your recipes and cookbooks.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 12.sp,
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          SizedBox(height: 30.h),
          // Grand bouton "+ Ajouter des ingrédients"
          ElevatedButton.icon(
            onPressed: () => _showAddGrocerySheet(context),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('Add ingredients'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC3333),
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGrocerySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddGrocerySheet(
        selectedDate: _selectedDate ?? DateTime.now(),
        allItems: _allItems,
        onSave: (name, qty, date, icon, recipeId) async {
          try {
            await GroceryService.instance.addGroceryItem(
              name: name,
              quantity: qty,
              date: date,
              icon: icon,
              recipeId: recipeId,
            );
            _loadGroceries();
          } catch (e) {
            IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
          }
        },
      ),
    );
  }
}



// ── Empty-state widget ────────────────────────────────────────────────────────

// ── Item row ──────────────────────────────────────────────────────────────────
class _ItemRow extends StatelessWidget {
  final GroceryItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  const _ItemRow({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(Icons.delete_outline, color: Colors.white, size: 24.sp),
      ),
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          child: Row(
            children: [
              // Circle checkbox
              Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.isBought
                        ? const Color(0xFFCC3333)
                        : const Color(0xFFCCCCCC),
                    width: 2.w,
                  ),
                  color: item.isBought
                      ? const Color(0xFFCC3333)
                      : Colors.transparent,
                ),
                child: item.isBought
                    ? Icon(
                        Icons.check_rounded,
                        size: 13.sp,
                        color: Colors.white,
                      )
                    : null,
              ),
              SizedBox(width: 14.w),
              Text(
                item.ingredientIcon ?? '🛒',
                style: TextStyle(fontSize: 18.sp),
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  item.ingredientName,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                    color: item.isBought
                        ? const Color(0xFFAAAAAA)
                        : const Color(0xFF1A1A1A),
                    decoration: item.isBought
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
              Text(
                item.quantity,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 14.sp,
                  color: const Color(0xFFAAAAAA),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Add Grocery bottom sheet ──────────────────────────────────────────────────
class _AddGrocerySheet extends StatefulWidget {
  final DateTime selectedDate;
  final List<GroceryItem> allItems;
  final void Function(
    String name,
    String qty,
    DateTime? date,
    String? icon,
    String? recipeId,
  )
  onSave;

  const _AddGrocerySheet({
    required this.selectedDate,
    required this.allItems,
    required this.onSave,
  });

  @override
  State<_AddGrocerySheet> createState() => _AddGrocerySheetState();
}

class _AddGrocerySheetState extends State<_AddGrocerySheet> {
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  late DateTime _date;
  bool _isRecipeMode = false;
  Recipe? _selectedRecipe;
  bool _isSaving = false;

  Timer? _searchDebounce;
  List<Map<String, dynamic>> _suggestedIngredients = [];
  String _lastSelectedName = '';

  @override
  void initState() {
    super.initState();
    _date = widget.selectedDate;
    if (RecipeService.instance.myRecipesNotifier.value == null) {
      RecipeService.instance.getMyRecipes();
    }
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final query = _nameController.text.trim();
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();

    if (query.length < 2 || query.toLowerCase() == _lastSelectedName.toLowerCase()) {
      setState(() => _suggestedIngredients = []);
      return;
    }
    
    _lastSelectedName = '';

    _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      final results = await IngredientService.instance.searchIngredients(query);
      if (mounted) setState(() => _suggestedIngredients = results);
    });
  }

  String _capitalize(String s) {
    return s.toTitleCase();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFCC3333),
            onPrimary: Colors.white,
            onSurface: Color(0xFF1A1A1A),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottom),
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
                  'Add to Grocery',
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
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
              children: [
                // ── Mode Toggle ───────────────────────────────────────
                Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      _buildToggleButton(
                        label: 'Whole Recipe',
                        isActive: _isRecipeMode,
                        onTap: () => setState(() => _isRecipeMode = true),
                      ),
                      _buildToggleButton(
                        label: 'Single Item',
                        isActive: !_isRecipeMode,
                        onTap: () => setState(() => _isRecipeMode = false),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // ── Recipe Selector ──────────────────────────────────────────
                if (_isRecipeMode) ...[
                  Text(
                    'Attach to Recipe',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ValueListenableBuilder<List<Recipe>?>(
                    valueListenable: RecipeService.instance.myRecipesNotifier,
                    builder: (context, recipes, _) {
                      final hasRecipes = recipes != null && recipes.isNotEmpty;

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Recipe>(
                            isExpanded: true,
                            value: _selectedRecipe,
                            hint: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                hasRecipes ? 'Pick a recipe' : 'No recipes found.',
                                style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 14.sp)
                              ),
                            ),
                            icon: Padding(
                              padding: EdgeInsets.only(right: 12.w),
                              child: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                            ),
                            items: !hasRecipes ? null : recipes.map((r) {
                              return DropdownMenuItem(
                                value: r,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  child: Text(
                                    r.name,
                                    style: TextStyle(
                                      fontFamily: 'SF Pro',
                                      fontSize: 14.sp,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: !hasRecipes ? null : (val) {
                              setState(() {
                                _selectedRecipe = val;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                ],

                if (!_isRecipeMode) ...[
                  // ── Ingredient Name Field ─────────────────────────────
                  Text(
                    'Ingredient Name',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    child: TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 14.sp,
                        color: const Color(0xFF1F2937),
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. Garlic',
                        hintStyle: TextStyle(color: const Color(0xFF9CA3AF)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  if (_suggestedIngredients.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          constraints: BoxConstraints(maxHeight: 200.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _suggestedIngredients.length,
                            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[100]),
                            itemBuilder: (context, i) {
                              final item = _suggestedIngredients[i];
                              return ListTile(
                                dense: true,
                                title: Text(_capitalize(item['name'] ?? '')),
                                onTap: () {
                                  final selected = _capitalize(item['name'] ?? '');
                                  _lastSelectedName = selected;
                                  _nameController.text = selected;
                                  _searchDebounce?.cancel();
                                  setState(() => _suggestedIngredients = []);
                                  FocusScope.of(context).unfocus();
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 20.h),

                  // ── Quantity Field ─────────────────────────────
                  Text(
                    'Quantity',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    child: TextField(
                      controller: _qtyController,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 14.sp,
                        color: const Color(0xFF1F2937),
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. 2 cloves',
                        hintStyle: TextStyle(color: const Color(0xFF9CA3AF)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],

                // ── Date label + field (Only for Whole Recipe) ─────────
                if (_isRecipeMode) ...[
                  Text(
                    'Scheduled Date',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _fmt(_date),
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontSize: 14.sp,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.calendar_month_rounded,
                            color: const Color(0xFF64748B),
                            size: 22.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 10.h),
              ],
            ),
          ),

          // ── Save button ──────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h + bottomPad),
            child: SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        setState(() => _isSaving = true);
                        try {
                          if (_isRecipeMode) {
                            if (_selectedRecipe == null) {
                              IosToast.show(context, message: 'Please select a recipe', type: ToastType.success);
                              setState(() => _isSaving = false);
                              return;
                            }
                            final fullRecipe = await RecipeService.instance.getRecipe(_selectedRecipe!.id);

                            for (var ing in fullRecipe.ingredients) {
                              widget.onSave(
                                ing.name,
                                ing.quantity,
                                _date,
                                ing.icon,
                                fullRecipe.id,
                              );
                            }
                          } else {
                            final name = _nameController.text.trim();
                            final qty = _qtyController.text.trim();
                            if (name.isNotEmpty && qty.isNotEmpty) {
                              widget.onSave(
                                name,
                                qty,
                                _date,
                                null,
                                null,
                              );
                            }
                          }
                          if (mounted) Navigator.pop(context);
                        } catch (e) {
                          if (mounted) {
                            IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
                          }
                        } finally {
                          if (mounted) setState(() => _isSaving = false);
                        }
                      },
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
                        'Save to grocery list',
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

  Widget _buildToggleButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: isActive ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                fontSize: 14.sp,
                color: isActive ? const Color(0xFFCC3333) : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
