import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/grocery_service.dart';
import '../services/recipe_service.dart';
import '../models/grocery_item.dart';
import '../core/widgets/ios_toast.dart';
import '../core/utils/error_helper.dart';
import '../services/notification_service.dart';

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
                          itemCount: _grouped.length + 1,
                          itemBuilder: (_, gi) {
                            if (gi == _grouped.length) {
                              return SizedBox(height: MediaQuery.of(context).viewInsets.bottom);
                            }
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
          // Grand bouton "+ Ajouter des recettes"
          ElevatedButton.icon(
            onPressed: () => _showAddGrocerySheet(context),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('Add Recipes'),
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

// ── Planned Recipe helper model ────────────────────────────────────────────────
class _PlannedRecipe {
  final String id;
  final String name;
  final DateTime date;
  const _PlannedRecipe({
    required this.id,
    required this.name,
    required this.date,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _PlannedRecipe &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day;

  @override
  int get hashCode => id.hashCode ^ date.day.hashCode ^ date.month.hashCode;
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
    DateTime date,
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
  bool _isRecipeMode = true;
  _PlannedRecipe? _selectedPlannedRecipe;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _date = widget.selectedDate;
  }

  List<_PlannedRecipe> get _plannedRecipes {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final seen = <String>{};
    final list = <_PlannedRecipe>[];

    for (var item in widget.allItems) {
      if (item.recipeId != null && item.plannedDate != null) {
        if (!item.plannedDate!.isBefore(startOfToday)) {
          final dateStr = item.plannedDate!.toIso8601String().split('T')[0];
          final key = '${item.recipeId}_$dateStr';
          if (!seen.contains(key)) {
            seen.add(key);
            list.add(
              _PlannedRecipe(
                id: item.recipeId!,
                name: item.recipeName ?? 'Unknown',
                date: item.plannedDate!,
              ),
            );
          }
        }
      }
    }
    // Sort by date then name
    list.sort((a, b) {
      final dateCmp = a.date.compareTo(b.date);
      if (dateCmp != 0) return dateCmp;
      return a.name.compareTo(b.name);
    });
    return list;
  }

  @override
  void dispose() {
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
    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Stack(
        children: [
          // Subtle watermark background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFC83A2D), Color(0x63C83A2D)],
                ),
              ),
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
          ),

          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(22.w, 14.h, 22.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),

                // Title + X
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Add to Grocery',
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
                        width: 30.w,
                        height: 30.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
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

                // ── Mode Toggle ───────────────────────────────────────
                Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
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

                SizedBox(height: 15.h),

                // ── Recipe Selector (Always visible) ────────────────────
                Text(
                  'Attach to Recipe',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Builder(
                  builder: (context) {
                    final plans = _plannedRecipes;
                    if (plans.isEmpty) {
                      return Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Text(
                          'No active plans scheduled.',
                          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<_PlannedRecipe>(
                          isExpanded: true,
                          value: _selectedPlannedRecipe,
                          hint: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            child: const Text('Pick a planned recipe'),
                          ),
                          items: plans.map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: Text(
                                  '${p.name} (${_fmt(p.date)})',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro',
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedPlannedRecipe = val;
                              if (val != null) _date = val.date;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 15.h),

                if (!_isRecipeMode) ...[
                  // ── Ingredient Name Field ─────────────────────────────
                  Text(
                    'Ingredient Name',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: TextField(
                      controller: _nameController,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. Garlic',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 15.h),

                  // ── Quantity Field ─────────────────────────────
                  Text(
                    'Quantity',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: TextField(
                      controller: _qtyController,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. 2 cloves',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                // ── Date label + field (Only for Whole Recipe) ─────────
                if (_isRecipeMode) ...[
                  Text(
                    'Scheduled Date',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _fmt(_date),
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontSize: 14.sp,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.calendar_month_rounded,
                            color: const Color(0xFF888888),
                            size: 22.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                // ── Save button ──────────────────────────────────────────
                GestureDetector(
                  onTap: _isSaving
                      ? null
                      : () async {
                          if (_selectedPlannedRecipe == null) {
                            IosToast.show(context, message: 'Please select a recipe', type: ToastType.success);
                            return;
                          }

                          setState(() => _isSaving = true);
                          try {
                            if (_isRecipeMode) {
                              final fullRecipe = await RecipeService.instance
                                  .getRecipe(_selectedPlannedRecipe!.id);

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
                                  _selectedPlannedRecipe!.id,
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
                  child: Container(
                    width: double.infinity,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: _isSaving
                          ? const Color(0xFF888888)
                          : const Color(0xFFAA2222),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Center(
                      child: _isSaving
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.w,
                              ),
                            )
                          : Text(
                              'Save',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w700,
                                fontSize: 15.sp,
                                color: Colors.white,
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
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12.sp,
                color: isActive ? const Color(0xFFCC3333) : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
