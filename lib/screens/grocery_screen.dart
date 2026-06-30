import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/grocery_service.dart';
import '../services/recipe_service.dart';
import '../services/ingredient_service.dart';
import '../models/grocery_item.dart';
import '../models/recipe.dart';
import '../core/widgets/ios_toast.dart';
import '../widgets/red_button.dart';
import '../core/utils/error_helper.dart';
import '../core/extensions/string_extensions.dart';
import '../widgets/grocery_skeleton.dart';

// ══════════════════════════════════════════════════════════════════════════════
// GROCERY SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});
  @override
  State<GroceryScreen> createState() => GroceryScreenState();
}

class GroceryScreenState extends State<GroceryScreen> with SingleTickerProviderStateMixin {
  final Set<String> _collapsedGroups = {};
  bool _initializedDefaults = false;

  late AnimationController _hintController;
  late Animation<Offset> _hintAnimation;
  bool _hintShownThisSession = false;

  @override
  void initState() {
    super.initState();
    _loadGroceries();

    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _hintAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset.zero, end: const Offset(-0.3, 0.0))
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(-0.3, 0.0), end: const Offset(-0.25, 0.0))
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(-0.25, 0.0), end: const Offset(-0.35, 0.0))
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(-0.35, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 35,
      ),
    ]).animate(_hintController);

    // Show hint after a short delay once data is loaded
    GroceryService.instance.myGroceriesNotifier.addListener(_onDataLoaded);
    if (GroceryService.instance.myGroceriesNotifier.value != null && 
        GroceryService.instance.myGroceriesNotifier.value!.isNotEmpty) {
      _onDataLoaded();
    }
  }

  void _onDataLoaded() {
    final items = GroceryService.instance.myGroceriesNotifier.value;
    if (items != null && items.isNotEmpty) {
      GroceryService.instance.myGroceriesNotifier.removeListener(_onDataLoaded);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) _hintController.forward(from: 0);
      });
    }
  }

  void triggerHint() {
    _hintShownThisSession = false; // Allow it to show again
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    GroceryService.instance.myGroceriesNotifier.removeListener(_onDataLoaded);
    _hintController.dispose();
    super.dispose();
  }

  Future<void> _loadGroceries() async {
    // Initial fetch if null
    if (GroceryService.instance.myGroceriesNotifier.value == null) {
      try {
        await GroceryService.instance.getMyGroceries();
      } catch (e) {
        if (!mounted) return;
        IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
      }
    }
  }

  // Grouped by Recipe
  Map<String, List<GroceryItem>> _getGroupedByRecipe(List<GroceryItem> allItems) {
    final groups = <String, List<GroceryItem>>{};
    
    // Sort items: Manual Adds first (newest first), then by recipe name
    final sorted = List<GroceryItem>.from(allItems)..sort((a, b) {
      if (a.recipeName == null && b.recipeName == null) {
        return b.createdAt.compareTo(a.createdAt);
      }
      if (a.recipeName == null) return -1;
      if (b.recipeName == null) return 1;
      
      return a.recipeName!.compareTo(b.recipeName!);
    });

    for (final item in sorted) {
      String key = item.recipeName ?? ''; // Empty key for manual adds
      if (!groups.containsKey(key)) groups[key] = [];
      groups[key]!.add(item);
    }
    return groups;
  }

  Future<void> _toggleItem(GroceryItem item) async {
    HapticFeedback.selectionClick();
    try {
      await GroceryService.instance.toggleBought(item.id);
    } catch (e) {
      if (mounted) {
        IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
      }
    }
  }

  Future<void> _deleteItem(GroceryItem item) async {
    HapticFeedback.mediumImpact();
    try {
      await GroceryService.instance.deleteGroceryItem(item.id);
    } catch (e) {
      if (mounted) {
        IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
      }
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder<List<GroceryItem>?>(
                    valueListenable: GroceryService.instance.myGroceriesNotifier,
                    builder: (context, allItems, _) {
                      if (allItems == null) {
                        return const GrocerySkeleton();
                      }

                      if (allItems.isEmpty) return _buildEmpty(allItems);

                      if (allItems.isNotEmpty && !_hintShownThisSession) {
                        _hintShownThisSession = true;
                        Future.delayed(const Duration(milliseconds: 1000), () async {
                          if (mounted) {
                            await _hintController.forward(from: 0);
                            await Future.delayed(const Duration(milliseconds: 400));
                            if (mounted) await _hintController.forward(from: 0);
                          }
                        });
                      }

                      final grouped = _getGroupedByRecipe(allItems);

                      // Initialize defaults: Manual Adds open, or first recipe if general is empty
                      if (!_initializedDefaults && grouped.isNotEmpty) {
                        final keys = grouped.keys.toList();
                        final hasGeneral = keys.contains('');
                        final openKey = hasGeneral ? '' : keys.first;
                        
                        for (final key in keys) {
                          if (key != openKey) {
                            _collapsedGroups.add(key);
                          }
                        }
                        _initializedDefaults = true;
                      }

                      return ListView.builder(
                        padding: EdgeInsets.only(bottom: 200.h + MediaQuery.of(context).viewInsets.bottom),
                        itemCount: grouped.length + 1,
                        itemBuilder: (_, gi) {
                          if (gi == grouped.length) {
                            return const _InlineAddRow();
                          }
                          final recipeKey = grouped.keys.elementAt(gi);
                          final items = grouped[recipeKey]!;
                          final isCollapsed = _collapsedGroups.contains(recipeKey);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (recipeKey.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    if (_collapsedGroups.contains(recipeKey)) {
                                      _collapsedGroups.remove(recipeKey);
                                    } else {
                                      _collapsedGroups.add(recipeKey);
                                    }
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  color: Colors.transparent, 
                                  padding: EdgeInsets.fromLTRB(
                                    18,
                                    gi == 0 ? 14 : 24,
                                    18,
                                    12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          recipeKey,
                                          style: TextStyle(
                                            fontFamily: 'SF Pro',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.sp,
                                            color: const Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      ),
                                      AnimatedRotation(
                                        turns: isCollapsed ? 0 : 0.25,
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                        child: Icon(
                                          Icons.keyboard_arrow_right_rounded,
                                          color: const Color(0xFF1A1A1A),
                                          size: 22.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 300),
                                sizeCurve: Curves.easeInOut,
                                firstChild: Column(
                                  children: items.map((item) {
                                    return Column(
                                      children: [
                                        // Animate only the very first item of the very first group as a hint
                                        gi == 0 && item == items.first
                                            ? AnimatedBuilder(
                                                animation: _hintAnimation,
                                                builder: (context, child) => SlideTransition(
                                                  position: _hintAnimation,
                                                  child: child,
                                                ),
                                                child: _ItemRow(
                                                  item: item,
                                                  onToggle: () => _toggleItem(item),
                                            onDelete: (item) async {
                                                    final confirm = await _showDeleteConfirm(context, item.ingredientName);
                                                    if (confirm == true) {
                                                      await _deleteItem(item);
                                                      return true;
                                                    }
                                                    return false;
                                                  },
                                                ),
                                              )
                                            : _ItemRow(
                                                item: item,
                                                onToggle: () => _toggleItem(item),
                                                onDelete: (item) async {
                                                  final confirm = await _showDeleteConfirm(context, item.ingredientName);
                                                  if (confirm == true) {
                                                    await _deleteItem(item);
                                                    return true;
                                                  }
                                                  return false;
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
                                ),
                                secondChild: const SizedBox(width: double.infinity),
                                crossFadeState: isCollapsed 
                                    ? CrossFadeState.showSecond 
                                    : CrossFadeState.showFirst,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            // ── Floating Add button (above the transparent nav bar) ────────
            ValueListenableBuilder<List<GroceryItem>?>(
              valueListenable: GroceryService.instance.myGroceriesNotifier,
              builder: (context, allItems, _) {
                if (allItems == null || allItems.isEmpty) return const SizedBox.shrink();
                
                return Positioned(
                  bottom: 130.h,
                  right: 20.w,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showAddGrocerySheet(context, allItems);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC83A2D),
                        borderRadius: BorderRadius.circular(30.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC83A2D).withOpacity(0.4),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(List<GroceryItem> allItems) {
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
            'Your grocery list is empty',
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
            onPressed: () {
              HapticFeedback.lightImpact();
              _showAddGrocerySheet(context, allItems);
            },
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('Add ingredients'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC83A2D),
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

  Future<bool?> _showDeleteConfirm(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "$name" from your grocery list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFC83A2D), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddGrocerySheet(BuildContext context, List<GroceryItem> allItems) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddGrocerySheet(
        selectedDate: DateTime.now(),
        allItems: allItems,
        onSave: (name, qty, date, icon, recipeId) {
          // Fire and forget (optimistic update is inside the service)
          GroceryService.instance.addGroceryItem(
            name: name,
            quantity: qty,
            date: date,
            icon: icon,
            recipeId: recipeId,
          ).catchError((e) {
            if (mounted) {
              IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
            }
            return Future<GroceryItem>.error(e);
          });
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
  final Future<bool?> Function(GroceryItem) onDelete;
  const _ItemRow({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPlaceholder = item.isPlaceholder;

    return Dismissible(
      key: Key(item.id),
      confirmDismiss: (direction) => isPlaceholder ? Future.value(false) : onDelete(item),
      onDismissed: (_) {
        // The deletion logic is already handled in _deleteItem if confirmDismiss returns true
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(Icons.delete_outline, color: Colors.white, size: 24.sp),
      ),
      child: InkWell(
        onTap: isPlaceholder ? null : onToggle,
        child: Opacity(
          opacity: isPlaceholder ? 0.6 : 1.0,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
            child: Row(
              children: [
                if (isPlaceholder)
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC83A2D)),
                    ),
                  )
                else
                  _AnimatedCheckbox(isBought: item.isBought),
                SizedBox(width: 14.w),
                Text(
                  item.ingredientIcon ?? '🛒',
                  style: TextStyle(fontSize: 15.sp),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                      color: item.isBought
                          ? const Color(0xFFAAAAAA)
                          : const Color(0xFF1A1A1A),
                      decoration: item.isBought
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                    child: Text(item.ingredientName.capitalize()),
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
      ),
    );
  }
}

class _AnimatedCheckbox extends StatefulWidget {
  final bool isBought;
  const _AnimatedCheckbox({required this.isBought});

  @override
  State<_AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<_AnimatedCheckbox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fillAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    );

    _checkAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeInOutCubic),
    );

    if (widget.isBought) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBought != oldWidget.isBought) {
      if (widget.isBought) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Color.lerp(
                const Color(0xFFCCCCCC),
                const Color(0xFFC83A2D),
                _fillAnimation.value,
              )!,
              width: 2.w,
            ),
            color: const Color(0xFFC83A2D).withOpacity(_fillAnimation.value),
          ),
          child: CustomPaint(
            painter: _CheckmarkPainter(
              progress: _checkAnimation.value,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Checkmark coordinates relative to size
    final start = Offset(size.width * 0.25, size.height * 0.5);
    final mid = Offset(size.width * 0.45, size.height * 0.7);
    final end = Offset(size.width * 0.75, size.height * 0.35);

    // We split the progress: first half for the first segment, second half for the second
    if (progress < 0.5) {
      final p = progress / 0.5;
      path.moveTo(start.dx, start.dy);
      path.lineTo(
        start.dx + (mid.dx - start.dx) * p,
        start.dy + (mid.dy - start.dy) * p,
      );
    } else {
      final p = (progress - 0.5) / 0.5;
      path.moveTo(start.dx, start.dy);
      path.lineTo(mid.dx, mid.dy);
      path.lineTo(
        mid.dx + (end.dx - mid.dx) * p,
        mid.dy + (end.dy - mid.dy) * p,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) => oldDelegate.progress != progress;
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
    _qtyController.text = '1';
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
            primary: Color(0xFFC83A2D),
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
      padding: EdgeInsets.zero,
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
                    'Add to Grocery',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w800,
                      fontSize: 18.sp,
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
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h + bottom + bottomPad),
                children: [
                  // ── Mode Toggle ───────────────────────────────────────
                  Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        _buildToggleButton(
                          label: 'Single Item',
                          isActive: !_isRecipeMode,
                          onTap: () => setState(() => _isRecipeMode = false),
                        ),
                        _buildToggleButton(
                          label: 'Whole Recipe',
                          isActive: _isRecipeMode,
                          onTap: () => setState(() => _isRecipeMode = true),
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
                        fontSize: 13.sp,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ValueListenableBuilder<List<Recipe>?>(
                      valueListenable: RecipeService.instance.myRecipesNotifier,
                      builder: (context, recipes, _) {
                        final hasRecipes = recipes != null && recipes.isNotEmpty;

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Recipe>(
                              isExpanded: true,
                              dropdownColor: const Color(0xFFC83A2D),
                              value: _selectedRecipe,
                              hint: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Text(
                                  hasRecipes ? 'Pick a recipe' : 'No recipes found.',
                                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14.sp),
                                ),
                              ),
                              icon: Padding(
                                padding: EdgeInsets.only(right: 12.w),
                                child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
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
                                        color: Colors.white,
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
                        fontSize: 13.sp,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 14.sp,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. Garlic',
                          hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    if (_suggestedIngredients.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Material(
                          elevation: 4,
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            constraints: BoxConstraints(maxHeight: 200.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC83A2D),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _suggestedIngredients.length,
                              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.white.withOpacity(0.1)),
                              itemBuilder: (context, i) {
                                final item = _suggestedIngredients[i];
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    _capitalize(item['name'] ?? ''),
                                    style: const TextStyle(color: Colors.white),
                                  ),
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
                        fontSize: 13.sp,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: TextField(
                        controller: _qtyController,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 14.sp,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. 2 cloves',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
                        fontSize: 13.sp,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _fmt(_date),
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.white70,
                              size: 22.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 20.h),

                  // ── Save button ──────────────────────────────────────────
                  RedButton(
                    label: 'Save to grocery list',
                    loadingLabel: 'Saving',
                    isLoading: _isSaving,
                    onTap: () async {
                      try {
                        if (_isRecipeMode) {
                          setState(() => _isSaving = true);
                          if (_selectedRecipe == null) {
                            IosToast.show(context, message: 'Please select a recipe', type: ToastType.error);
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
                          if (name.isNotEmpty) {
                            widget.onSave(
                              name,
                              qty,
                              null, 
                              null,
                              null,
                            );
                          }
                        }
                        
                        if (!mounted) return;
                        IosToast.show(
                          context,
                          message: _isRecipeMode 
                              ? 'Recipe ingredients added successfully' 
                              : 'Item added successfully',
                          type: ToastType.success,
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        if (!mounted) return;
                        IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
                      } finally {
                        if (mounted) setState(() => _isSaving = false);
                      }
                    },
                    color: Colors.white,
                    textColor: const Color(0xFFC83A2D),
                    height: 50.h,
                    fontSize: 15.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
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
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13.sp,
                color: isActive ? const Color(0xFFC83A2D) : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Inline Add Row ──────────────────────────────────────────────────────────
class _InlineAddRow extends StatefulWidget {
  const _InlineAddRow();

  @override
  State<_InlineAddRow> createState() => _InlineAddRowState();
}

class _InlineAddRowState extends State<_InlineAddRow> {
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _qtyFocusNode = FocusNode();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _qtyController.text = '1';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _nameFocusNode.dispose();
    _qtyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final qty = _qtyController.text.trim();
    if (name.isEmpty) {
      IosToast.show(context, message: 'Please enter an ingredient name', type: ToastType.error);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await GroceryService.instance.addGroceryItem(
        name: name,
        quantity: qty.isEmpty ? '1' : qty,
        date: DateTime.now(),
      );
      // Reset state on success
      _nameController.clear();
      _qtyController.text = '1';
      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      if (mounted) {
        IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isEditing) {
      return Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isEditing = true;
              });
              // Focus name field after build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _nameFocusNode.requestFocus();
                Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 300));
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              child: Row(
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFCCCCCC),
                        width: 2.w,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add,
                        size: 12.sp,
                        color: const Color(0xFFCCCCCC),
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Text(
                    '🛒',
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    'Add an ingredient...',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                      color: const Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
            ),
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
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          child: Row(
            children: [
              // Check icon in edit mode
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC83A2D),
                    width: 2.w,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFC83A2D),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Text(
                '🛒',
                style: TextStyle(fontSize: 15.sp),
              ),
              SizedBox(width: 5.w),
              // Name text field
              Expanded(
                child: TextField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Ingredient name',
                    hintStyle: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 15.sp,
                      color: const Color(0xFFAAAAAA),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w500,
                    fontSize: 15.sp,
                    color: const Color(0xFF1A1A1A),
                  ),
                  onSubmitted: (_) => _qtyFocusNode.requestFocus(),
                ),
              ),
              SizedBox(width: 10.w),
              // Quantity text field
              Container(
                width: 60.w,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: TextField(
                  controller: _qtyController,
                  focusNode: _qtyFocusNode,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Qty',
                    hintStyle: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 13.sp,
                      color: const Color(0xFFAAAAAA),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 6.h),
                  ),
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 13.sp,
                    color: const Color(0xFF1A1A1A),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              SizedBox(width: 8.w),
              // Validate button or loading indicator
              _isSaving
                  ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC83A2D)),
                      ),
                    )
                  : GestureDetector(
                      onTap: _submit,
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: const Color(0xFFC83A2D),
                        size: 26.sp,
                      ),
                    ),
              SizedBox(width: 4.w),
              // Cancel button
              if (!_isSaving)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isEditing = false;
                      _nameController.clear();
                      _qtyController.text = '1';
                    });
                  },
                  child: Icon(
                    Icons.cancel_rounded,
                    color: const Color(0xFF888888),
                    size: 26.sp,
                  ),
                ),
            ],
          ),
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
  }
}
