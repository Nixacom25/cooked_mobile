import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/grocery_service.dart';
import '../services/recipe_service.dart';
import '../services/ingredient_service.dart';
import '../services/analytics_service.dart';
import '../models/grocery_item.dart';
import '../models/recipe.dart';
import '../core/widgets/ios_toast.dart';
import '../widgets/app_top_header.dart';
import '../widgets/red_header_background.dart';
import '../core/utils/error_helper.dart';
import '../core/extensions/string_extensions.dart';
import '../widgets/grocery_skeleton.dart';
import '../widgets/app_loading_indicator.dart';

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
  bool _isInstacartLoading = false;

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
    _hintShownThisSession = false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    GroceryService.instance.myGroceriesNotifier.removeListener(_onDataLoaded);
    _hintController.dispose();
    super.dispose();
  }

  Future<void> _loadGroceries() async {
    if (GroceryService.instance.myGroceriesNotifier.value == null) {
      try {
        await GroceryService.instance.getMyGroceries();
      } catch (e) {
        if (!mounted) return;
        IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
      }
    }
  }

  Map<String, List<GroceryItem>> _getGroupedByRecipe(List<GroceryItem> allItems) {
    final groups = <String, List<GroceryItem>>{};
    
    final sorted = List<GroceryItem>.from(allItems)..sort((a, b) {
      if (a.recipeName == null && b.recipeName == null) {
        return b.createdAt.compareTo(a.createdAt);
      }
      if (a.recipeName == null) return -1;
      if (b.recipeName == null) return 1;
      
      return a.recipeName!.compareTo(b.recipeName!);
    });

    for (final item in sorted) {
      String key = item.recipeName ?? '';
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

  Future<void> _handleInstacartShop(BuildContext context, List<GroceryItem> items) async {
    if (items.isEmpty) {
      IosToast.show(context, message: 'Your grocery list is empty', type: ToastType.error);
      return;
    }

    HapticFeedback.mediumImpact();
    AnalyticsService.instance.logInstacartCtaClicked(itemCount: items.length);

    setState(() => _isInstacartLoading = true);

    try {
      final response = await GroceryService.instance.createInstacartShoppingLink();

      if (!mounted) return;
      final Uri targetUri = Uri.parse(response.deepLinkUrl ?? response.url);
      final Uri fallbackWebUri = Uri.parse(response.url);

      bool launched = false;
      try {
        if (await canLaunchUrl(targetUri)) {
          launched = await launchUrl(targetUri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {}

      if (!launched) {
        try {
          launched = await launchUrl(fallbackWebUri, mode: LaunchMode.externalApplication);
        } catch (e) {
          launched = await launchUrl(fallbackWebUri, mode: LaunchMode.inAppBrowserView);
        }
      }

      if (launched) {
        AnalyticsService.instance.logInstacartRedirectSuccess(mode: 'launched');
      } else {
        AnalyticsService.instance.logInstacartRedirectFailed(error: 'Could not launch URL');
        _showInstacartErrorDialog(context, 'Unable to open Instacart. Please check your internet connection.', items);
      }
    } catch (e) {
      if (!mounted) return;
      final errorMsg = ErrorHelper.getFriendlyMessage(e);
      _showInstacartErrorDialog(context, errorMsg, items);
    } finally {
      if (mounted) {
        setState(() => _isInstacartLoading = false);
      }
    }
  }

  void _showInstacartErrorDialog(BuildContext context, String message, List<GroceryItem> items) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.shopping_bag_outlined, color: const Color(0xFF003D29), size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              'Instacart Connection',
              style: TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontFamily: 'Rubik', fontSize: 14.sp, color: const Color(0xFF4A4A4A)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003D29),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _handleInstacartShop(context, items);
            },
            child: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFC31E26),
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Background gradient at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 240.h,
              child: const RedHeaderBackground(),
            ),
            Column(
              children: [
                // Standard App Top Header
                const AppTopHeader(),

                // Main White Container Sheet
                Expanded(
                  child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
                  child: Stack(
                    children: [
                      // ── Main Content Column ──────────────────────────────────
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Title Row: "Grocery List"
                          Padding(
                            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
                            child: Text(
                              'Grocery List',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontWeight: FontWeight.w800,
                                fontSize: 24.sp,
                                color: const Color(0xFF0F172A),
                              ),
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
                                  padding: EdgeInsets.only(bottom: 220.h + MediaQuery.of(context).viewInsets.bottom),
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
                                                20.w,
                                                gi == 0 ? 12.h : 20.h,
                                                20.w,
                                                12.h,
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      recipeKey,
                                                      style: TextStyle(
                                                        fontFamily: 'Rubik',
                                                        fontWeight: FontWeight.w800,
                                                        fontSize: 18.sp,
                                                        color: const Color(0xFF0F172A),
                                                      ),
                                                    ),
                                                  ),
                                                  AnimatedRotation(
                                                    turns: isCollapsed ? 0 : 0.25,
                                                    duration: const Duration(milliseconds: 250),
                                                    curve: Curves.easeInOut,
                                                    child: Icon(
                                                      Icons.keyboard_arrow_right_rounded,
                                                      color: const Color(0xFF0F172A),
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
                                                    color: Color(0xFFF1F5F9),
                                                    indent: 20,
                                                    endIndent: 20,
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

                      // ── Floating Action Bar: Red Pill "+ Add" Button ────────────────
                      ValueListenableBuilder<List<GroceryItem>?>(
                        valueListenable: GroceryService.instance.myGroceriesNotifier,
                        builder: (context, allItems, _) {
                          final itemsList = allItems ?? [];
                          if (itemsList.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final bool showInstacart = true;

                          return Positioned(
                            bottom: 120.h,
                            left: 20.w,
                            right: 20.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (showInstacart && itemsList.isNotEmpty) ...[
                                  // Instacart button option if items exist
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _isInstacartLoading
                                          ? null
                                          : () => _handleInstacartShop(context, itemsList),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF003D29), Color(0xFF0D6B34)],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(30.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF003D29).withValues(alpha: 0.35),
                                              blurRadius: 14.r,
                                              offset: Offset(0, 5.h),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if (_isInstacartLoading) ...[
                                              SizedBox(
                                                width: 18.w,
                                                height: 18.w,
                                                child: const AppLoadingIndicator(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              Text(
                                                'Connecting...',
                                                style: TextStyle(
                                                  fontFamily: 'Rubik',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ] else ...[
                                              Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 18.sp),
                                              SizedBox(width: 6.w),
                                              Text(
                                                'Instacart',
                                                style: TextStyle(
                                                  fontFamily: 'Rubik',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14.sp,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                ],

                                // Red Pill "+ Add" Button
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    _showAddGrocerySheet(context, itemsList);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC31E26),
                                      borderRadius: BorderRadius.circular(28.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFC31E26).withValues(alpha: 0.35),
                                          blurRadius: 12.r,
                                          offset: Offset(0, 4.h),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add_rounded, color: Colors.white, size: 20.sp),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'Add',
                                          style: TextStyle(
                                            fontFamily: 'Rubik',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
            'Your Grocery List is empty',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'Add ingredients from a recipe or import to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 13.sp,
                color: Colors.grey[500],
              ),
            ),
          ),
          SizedBox(height: 30.h),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showAddGrocerySheet(context, allItems);
            },
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('Add ingredients', style: TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.bold)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Delete Item', style: TextStyle(fontFamily: 'Rubik', fontWeight: FontWeight.bold, fontSize: 16.sp)),
        content: Text('Are you sure you want to delete "$name" from your grocery list?', style: TextStyle(fontFamily: 'Rubik', fontSize: 14.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Rubik', color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(fontFamily: 'Rubik', color: Color(0xFFC83A2D), fontWeight: FontWeight.bold)),
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
        onSaveBatch: (draftItems, selectedRecipe, date) async {
          try {
            for (final item in draftItems) {
              await GroceryService.instance.addGroceryItem(
                name: item['name']!,
                quantity: item['qty']!,
                date: date,
                source: 'manual',
              );
            }

            if (selectedRecipe != null) {
              final fullRecipe = await RecipeService.instance.getRecipe(selectedRecipe.id);
              for (var ing in fullRecipe.ingredients) {
                await GroceryService.instance.addGroceryItem(
                  name: ing.name,
                  quantity: ing.quantity,
                  date: date,
                  icon: ing.icon,
                  recipeId: fullRecipe.id,
                  source: 'recipe',
                );
              }
            }

            if (mounted) {
              IosToast.show(
                context,
                message: 'Grocery items saved successfully',
                type: ToastType.success,
              );
            }
          } catch (e) {
            if (mounted) {
              IosToast.show(
                context,
                message: ErrorHelper.getFriendlyMessage(e),
                type: ToastType.error,
              );
            }
          }
        },
      ),
    );
  }
}

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
      onDismissed: (_) {},
      background: Container(
        color: const Color(0xFFE11D48),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24.sp),
      ),
      child: InkWell(
        onTap: isPlaceholder ? null : onToggle,
        child: Opacity(
          opacity: isPlaceholder ? 0.6 : 1.0,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            child: Row(
              children: [
                if (isPlaceholder)
                  SizedBox(
                    width: 22.r,
                    height: 22.r,
                    child: const AppLoadingIndicator(),
                  )
                else
                  _AnimatedCheckbox(isBought: item.isBought),
                SizedBox(width: 14.w),
                if (item.ingredientIcon != null && item.ingredientIcon!.isNotEmpty) ...[
                  Text(
                    item.ingredientIcon!,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(width: 8.w),
                ],
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                      color: item.isBought
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF0F172A),
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
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
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
      duration: const Duration(milliseconds: 400),
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
          width: 22.r,
          height: 22.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Color.lerp(
                const Color(0xFFCBD5E1),
                const Color(0xFFC83A2D),
                _fillAnimation.value,
              )!,
              width: 2.w,
            ),
            color: const Color(0xFFC83A2D).withValues(alpha: _fillAnimation.value),
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
    final start = Offset(size.width * 0.25, size.height * 0.5);
    final mid = Offset(size.width * 0.45, size.height * 0.7);
    final end = Offset(size.width * 0.75, size.height * 0.35);

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

// ── Add Grocery bottom sheet (Form UI matching Image 2 mockup) ────────────────
class _AddGrocerySheet extends StatefulWidget {
  final DateTime selectedDate;
  final List<GroceryItem> allItems;
  final void Function(
    List<Map<String, String>> draftItems,
    Recipe? selectedRecipe,
    DateTime selectedDate,
  ) onSaveBatch;

  const _AddGrocerySheet({
    required this.selectedDate,
    required this.allItems,
    required this.onSaveBatch,
  });

  @override
  State<_AddGrocerySheet> createState() => _AddGrocerySheetState();
}

class _AddGrocerySheetState extends State<_AddGrocerySheet> {
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  late DateTime _date;
  Recipe? _selectedRecipe;
  bool _isSaving = false;

  final List<Map<String, String>> _draftItems = [];

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

    if (query.isEmpty || query.toLowerCase() == _lastSelectedName.toLowerCase()) {
      if (_suggestedIngredients.isNotEmpty) {
        setState(() => _suggestedIngredients = []);
      }
      return;
    }
    
    _lastSelectedName = '';

    _searchDebounce = Timer(const Duration(milliseconds: 150), () async {
      final results = await IngredientService.instance.searchIngredients(query);
      if (mounted) setState(() => _suggestedIngredients = results);
    });
  }

  void _addCurrentItemToDraft() {
    final name = _nameController.text.trim();
    final qty = _qtyController.text.trim();
    if (name.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _draftItems.add({
          'name': name.toTitleCase(),
          'qty': qty.isEmpty ? '1' : qty,
        });
        _nameController.clear();
        _qtyController.clear();
        _suggestedIngredients = [];
      });
    }
  }

  void _removeDraftItem(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _draftItems.removeAt(index);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h + bottom + bottomPad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top drag handle bar
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // Header Title Row: "Add Grocery"
          Text(
            'Add Grocery',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w800,
              fontSize: 22.sp,
              color: const Color(0xFF0F172A),
            ),
          ),

          SizedBox(height: 20.h),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Field 1: Recipe
                  Text(
                    'Recipe',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w600,
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
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Recipe>(
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            value: _selectedRecipe,
                            hint: Text(
                              hasRecipes ? 'Choose a recipe' : 'No recipes found',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 14.sp,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: const Color(0xFF64748B),
                              size: 22.sp,
                            ),
                            items: !hasRecipes ? null : recipes.map((r) {
                              return DropdownMenuItem(
                                value: r,
                                child: Text(
                                  r.name,
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.sp,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: !hasRecipes ? null : (val) {
                              setState(() => _selectedRecipe = val);
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 18.h),

                  // Field 2: Item Entry Row
                  Text(
                    'Ingredient',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      // Item Name Input
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: TextField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Cheese',
                              hintStyle: TextStyle(
                                fontFamily: 'Rubik',
                                color: const Color(0xFF94A3B8),
                                fontSize: 14.sp,
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Quantity Input
                      SizedBox(
                        width: 95.w,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: TextField(
                            controller: _qtyController,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: '250 kg',
                              hintStyle: TextStyle(
                                fontFamily: 'Rubik',
                                color: const Color(0xFF94A3B8),
                                fontSize: 14.sp,
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Plus Button '+'
                      GestureDetector(
                        onTap: _addCurrentItemToDraft,
                        child: Container(
                          width: 48.r,
                          height: 48.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: const Color(0xFF0F172A),
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Ingredient Suggestions Dropdown
                  if (_suggestedIngredients.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Container(
                      constraints: BoxConstraints(maxHeight: 160.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _suggestedIngredients.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, i) {
                          final ing = _suggestedIngredients[i];
                          final name = (ing['name'] ?? '').toString().toTitleCase();
                          return ListTile(
                            dense: true,
                            title: Text(
                              name,
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 14.sp,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            onTap: () {
                              _nameController.text = name;
                              _lastSelectedName = name;
                              setState(() => _suggestedIngredients = []);
                            },
                          );
                        },
                      ),
                    ),
                  ],

                  // Chips / Tags for added draft items
                  if (_draftItems.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: List.generate(_draftItems.length, (index) {
                        final item = _draftItems[index];
                        final label = '${item['name']} ${item['qty']}';
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                label,
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              GestureDetector(
                                onTap: () => _removeDraftItem(index),
                                child: Container(
                                  width: 18.r,
                                  height: 18.r,
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
                      }),
                    ),
                  ],

                  SizedBox(height: 24.h),

                  // Large Red Save Pill Button
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC83A2D),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      onPressed: _isSaving
                          ? null
                          : () async {
                              if (_nameController.text.trim().isNotEmpty) {
                                _addCurrentItemToDraft();
                              }

                              if (_draftItems.isEmpty && _selectedRecipe == null) {
                                IosToast.show(
                                  context,
                                  message: 'Please add an item or select a recipe',
                                  type: ToastType.error,
                                );
                                return;
                              }

                              setState(() => _isSaving = true);
                              try {
                                widget.onSaveBatch(_draftItems, _selectedRecipe, _date);
                                if (mounted) Navigator.pop(context);
                              } catch (e) {
                                if (mounted) {
                                  IosToast.show(
                                    context,
                                    message: ErrorHelper.getFriendlyMessage(e),
                                    type: ToastType.error,
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _isSaving = false);
                              }
                            },
                      child: _isSaving
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const AppLoadingIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Save',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
  final _inputController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      if (!_isSaving) {
        final text = _inputController.text.trim();
        if (text.isNotEmpty) {
          _submit();
        } else {
          setState(() {
            _isEditing = false;
            _inputController.clear();
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    final rawText = _inputController.text.trim();
    if (rawText.isEmpty) {
      if (mounted) {
        setState(() {
          _isEditing = false;
        });
      }
      return;
    }

    final parts = rawText.split('-');
    if (parts.length < 2) {
      IosToast.show(
        context,
        message: 'Use format: Ingredient - Qty (e.g. Tomato - 2)',
        type: ToastType.error,
      );
      return;
    }

    final name = parts[0].trim();
    final qty = parts.sublist(1).join('-').trim();

    if (name.isEmpty) {
      IosToast.show(context, message: 'Please enter an ingredient name', type: ToastType.error);
      return;
    }
    if (qty.isEmpty) {
      IosToast.show(context, message: 'Please enter a quantity', type: ToastType.error);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await GroceryService.instance.addGroceryItem(
        name: name,
        quantity: qty,
        date: DateTime.now(),
        source: 'manual',
      );
      _inputController.clear();
      if (mounted) {
        setState(() {
          _isEditing = false;
        });
      }
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
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _focusNode.requestFocus();
                Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 300));
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  Container(
                    width: 22.r,
                    height: 22.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFCBD5E1),
                        width: 2.w,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add,
                        size: 12.sp,
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Text(
                    '🛒',
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Add an ingredient...',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            height: 0,
            thickness: 1,
            color: Color(0xFFF1F5F9),
            indent: 20,
            endIndent: 20,
          ),
        ],
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: Row(
            children: [
              Container(
                width: 22.r,
                height: 22.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC31E26),
                    width: 2.w,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 10.r,
                    height: 10.r,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFC31E26),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFCFE),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: TextField(
                    controller: _inputController,
                    focusNode: _focusNode,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 15.sp,
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Garlic - 2 cloves',
                      hintStyle: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 15.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
              ),
              if (_isSaving) ...[
                SizedBox(width: 10.w),
                SizedBox(
                  width: 18.r,
                  height: 18.r,
                  child: const AppLoadingIndicator(),
                ),
              ],
            ],
          ),
        ),
        const Divider(
          height: 0,
          thickness: 1,
          color: Color(0xFFF1F5F9),
          indent: 20,
          endIndent: 20,
        ),
      ],
    );
  }
}
