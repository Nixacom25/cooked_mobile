import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../routes/app_routes.dart';
import '../explore_screen.dart';
import '../grocery_screen.dart';
import '../import_screen.dart';
import '../scan_screen.dart';
import '../../widgets/app_search_field.dart';
import '../../services/recipe_service.dart';
import '../../services/cookbook_service.dart';
import '../../models/recipe.dart';
import '../../models/cookbook.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/cookbook_cover.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';
import '../../core/utils/tutorial_helper.dart';
import '../../widgets/add_to_cookbook_sheet.dart';
import '../../core/services/tutorial_service.dart';
import '../../main.dart';
import '../../services/history_service.dart';
import '../../models/view_all_type.dart';

class HomeScreen extends StatefulWidget {
  final int initialTab;
  const HomeScreen({super.key, this.initialTab = 0});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, RouteAware {
  // Tab indices: 0=Home 1=Explore 2=SCAN 3=Grocery 4=Import
  late int _currentTab;
  late int _previousTab;
  late bool _navVisible;
  final bool _scrollBusy = false; // debounce guard
  late final AnimationController _navCtrl;
  late final Animation<Offset> _navSlide;
  final GlobalKey _scanTabKey = GlobalKey();
  final GlobalKey _importTabKey = GlobalKey();
  final GlobalKey _groceryTabKey = GlobalKey();

  // Persistent tab widgets and notifier to prevent infinite rebuilds
  late final List<Widget> _tabWidgets;
  final ValueNotifier<bool> _scanActiveNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _importActiveNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isScanInResultsMode = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isImportLoading = ValueNotifier<bool>(false);

  // Tutorial keys
  final GlobalKey _firstCookbookKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _previousTab = 0;
    _navVisible = _currentTab != 2;
    _scanActiveNotifier.value = _currentTab == 2;
    _importActiveNotifier.value = _currentTab == 4;

    _tabWidgets = [
      _HomeTab(
        onRefresh: () => setState(() {}),
        onScanTap: () => _switchTab(2),
        firstCookbookKey: _firstCookbookKey,
      ),
      const ExploreScreen(),
      ScanScreen(
        isActiveNotifier: _scanActiveNotifier,
        isResultsModeNotifier: _isScanInResultsMode,
        onTabSwitch: _switchTab,
        onClose: () => _switchTab(_previousTab),
      ),
      const GroceryScreen(),
      ImportScreen(
        isActiveNotifier: _importActiveNotifier,
        isImportingNotifier: _isImportLoading,
      ),
    ];

    _navCtrl = AnimationController(
      vsync: this,
      value: _navVisible ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 320),
    );
    _navSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1.6),
    ).animate(CurvedAnimation(parent: _navCtrl, curve: Curves.easeInOut));

    // Listen for cookbooks to become available before starting tutorial
    CookbookService.instance.myCookbooksNotifier.addListener(
      _tutorialDataListener,
    );

    // Initial trigger attempt if home tutorial never seen
    if (!TutorialService.instance.hasSeenHome) {
      _startTutorial(delayMs: 1500);
    }

    // Load initial data
    if (RecipeService.instance.myRecipesNotifier.value == null) {
      RecipeService.instance.getMyRecipes();
    }
    if (CookbookService.instance.myCookbooksNotifier.value == null) {
      CookbookService.instance.getMyCookbooks();
    }
  }

  void _tutorialDataListener() {
    if (mounted &&
        !TutorialService.instance.hasSeenHome &&
        CookbookService.instance.myCookbooksNotifier.value != null) {
      // Show tutorial if cookbooks are loaded (even if empty, as it will point to "+" button)
      _startTutorial(delayMs: 500);
    }
  }

  Timer? _tutorialTimer;

  void _startTutorial({int delayMs = 500, int retries = 0}) {
    // Only show Home tutorial if on Home tab
    if (_currentTab != 0) return;

    _tutorialTimer?.cancel();
    _tutorialTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted || _currentTab != 0) return;
      if (TutorialHelper.isShowing) return;

      // Ensure all keys are ready before showing
      final hasCookbook = _firstCookbookKey.currentContext != null;
      final hasScan = _scanTabKey.currentContext != null;
      final hasImport = _importTabKey.currentContext != null;

      if (!hasCookbook || !hasScan || !hasImport) {
        if (retries < 10) {
          _startTutorial(delayMs: 300, retries: retries + 1);
        }
        return;
      }

      final firstCb = CookbookService.instance.myCookbooksNotifier.value?.firstOrNull;
      TutorialHelper.showTutorial(
        context,
        cookbookKey: _firstCookbookKey,
        scanKey: _scanTabKey,
        importKey: _importTabKey,
        firstCookbook: firstCb,
        onTabSwitch: (idx) => _switchTab(idx),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    CookbookService.instance.myCookbooksNotifier.removeListener(
      _tutorialDataListener,
    );
    _navCtrl.dispose();
    _scanActiveNotifier.dispose();
    _isScanInResultsMode.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    if (TutorialService.instance.isTutorialActive) {
      if (TutorialService.instance.currentStep == 0) {
        TutorialService.instance.setStep(1);
      }
      _startTutorial(delayMs: 500); // Fast resumption
    }
  }

  void _switchTab(int i) {
    if (_scrollBusy) return;

    // Support for hiding nav during tutorial completion (-1)
    if (i == -1) {
      setState(() {
        _navVisible = false;
        _navCtrl.forward();
      });
      return;
    }

    final prev = _currentTab;
    setState(() {
      _navVisible = (i != 2); // Default to hidden for Scan tab
      if (_currentTab != i) _previousTab = _currentTab;
      _currentTab = i;
      _scanActiveNotifier.value = i == 2;
      _importActiveNotifier.value = i == 4;
      _isScanInResultsMode.value = false;

      if (i == 2) {
        _navCtrl.forward(); // Hide nav
      } else {
        _navCtrl.reverse(); // Show nav
      }
    });

    // If returning to Home during tutorial, advance step based on where we came from
    if (TutorialService.instance.isTutorialActive && i == 0 && prev != 0) {
      final service = TutorialService.instance;
      if (prev == 2 && service.currentStep == 1) {
        service.setStep(2); // Move to Import Target
      } else if (prev == 4 && service.currentStep == 2) {
        service.setStep(3); // Move to Completion Target
      }

      _startTutorial(delayMs: 200);
    } else if (i != 0 && prev == 0) {
      // Switching away from home - dismiss Home tutorial if showing
      TutorialHelper.dismissCurrent();
    }
  }

  void _toggleNav() {
    setState(() => _navVisible = !_navVisible);
    if (_navVisible) {
      _navCtrl.reverse();
    } else {
      _navCtrl.forward();
    }
  }

  // Called by scroll notifications from child scrollables
  bool _handleScroll(ScrollNotification notif) {
    // Disabled nav hiding as requested – bottom nav stays visible except on Scan tab
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScroll,
        child: Stack(
          children: [
            IndexedStack(index: _currentTab, children: _tabWidgets),

            ValueListenableBuilder<bool>(
              valueListenable: _isScanInResultsMode,
              builder: (context, inResultsMode, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _isImportLoading,
                  builder: (context, isImportLoading, _) {
                    // Hide ONLY while actively scanning (Scan Tab + NOT in results mode) OR while importing
                    // We also want to hide it in results mode as requested
                    final isScanningTab = (_currentTab == 2);
                    // Hide nav entirely on Scan tab as requested
                    final hideNav = isScanningTab || isImportLoading;

                    return Stack(
                      children: [
                        // Peek handle – only shown when nav is hidden AND not in results mode
                        /* 
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeInOut,
                          bottom: (isScanningTab && !inResultsMode && !_navVisible)
                              ? 12.h
                              : -60.h,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: _toggleNav,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCC3333),
                                  borderRadius: BorderRadius.circular(30.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFCC3333,
                                      ).withValues(alpha: 0.4),
                                      blurRadius: 14.r,
                                      offset: Offset(0, 4.h),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.keyboard_arrow_up_rounded,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Menu',
                                      style: TextStyle(
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        */

                        // Custom Bottom Navigation Bar overlaid entirely on top
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: SlideTransition(
                            position: _navSlide,
                            child: hideNav || isKeyboardOpen
                                ? const SizedBox.shrink()
                                : _GlassBottomNav(
                                    currentIndex: _currentTab,
                                    onTap: _switchTab,
                                    onCameraTap: () {
                                      if (_currentTab == 2) {
                                        _toggleNav();
                                      } else {
                                        _switchTab(2);
                                      }
                                    },
                                    scanTabKey: _scanTabKey,
                                    groceryTabKey: _groceryTabKey,
                                    importTabKey: _importTabKey,
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Glassmorphic bottom nav ───────────────────────────────────────────────────
class _GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final VoidCallback onCameraTap;
  final GlobalKey scanTabKey;
  final GlobalKey groceryTabKey;
  final GlobalKey importTabKey;

  const _GlassBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.onCameraTap,
    required this.scanTabKey,
    required this.groceryTabKey,
    required this.importTabKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Glass background
          ClipRRect(
            borderRadius: BorderRadius.circular(40.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(40.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 30.r,
                      offset: Offset(0, 10.h),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        // Fluid animated indicator
                        _FluidIndicator(
                          currentIndex: currentIndex,
                          maxWidth: constraints.maxWidth,
                        ),
                        Row(
                          children: [
                            _NavItem(
                              icon: Icons.home_outlined,
                              activeIcon: Icons.home_rounded,
                              label: 'Home',
                              index: 0,
                              current: currentIndex,
                              onTap: onTap,
                            ),
                            _NavItem(
                              icon: Icons.search_rounded,
                              activeIcon: Icons.search_rounded,
                              label: 'Explore',
                              index: 1,
                              current: currentIndex,
                              onTap: onTap,
                            ),
                            const Expanded(child: SizedBox()),
                            _NavItem(
                              iconKey: groceryTabKey,
                              icon: Icons.shopping_bag_outlined,
                              activeIcon: Icons.shopping_bag_rounded,
                              label: 'Grocery',
                              index: 3,
                              current: currentIndex,
                              onTap: onTap,
                            ),
                            _NavItem(
                              iconKey: importTabKey,
                              icon: Icons.file_download_outlined,
                              activeIcon: Icons.file_download_rounded,
                              label: 'Import',
                              index: 4,
                              current: currentIndex,
                              onTap: onTap,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // Camera FAB elevated
          Positioned(
            top: -20.h,
            child: GestureDetector(
              onTap: onCameraTap,
              child: Container(
                key: scanTabKey,
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: currentIndex == 2
                      ? Colors.black87
                      : const Color(0xFFCC3333),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (currentIndex == 2
                              ? Colors.black87
                              : const Color(0xFFCC3333))
                          .withValues(alpha: 0.3),
                      blurRadius: 20.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: Icon(
                  currentIndex == 2
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: currentIndex == 2 ? 32.sp : 24.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FluidIndicator extends StatelessWidget {
  final int currentIndex;
  final double maxWidth;
  const _FluidIndicator({
    required this.currentIndex,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final slotWidth = maxWidth / 5;
    final targetSlot = currentIndex;
    
    // We adjust padding to make it feel like it wraps the content
    final horizontalPadding = 4.w;
    final verticalPadding = 4.h;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.fastOutSlowIn,
      left: (targetSlot * slotWidth) + horizontalPadding,
      top: verticalPadding,
      child: Container(
        width: slotWidth - (horizontalPadding * 2),
        height: 56.h - (verticalPadding * 2), // Total header height is around 60h
        decoration: BoxDecoration(
          color: const Color(0xFFCC3333).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int current;
  final void Function(int) onTap;
  final GlobalKey? iconKey;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
    this.iconKey,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? activeIcon : icon,
              key: iconKey,
              size: 22.sp, // Slightly reduced
              color: active ? const Color(0xFFCC3333) : const Color(0xFF8E8E8E),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 11.sp, // Slightly reduced
                fontWeight: active ? FontWeight.w600 : FontWeight.w500, // Medium bold
                color: active
                    ? const Color(0xFFCC3333)
                    : const Color(0xFF8E8E8E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HOME TAB
// ══════════════════════════════════════════════════════════════════════════════
class _HomeTab extends StatefulWidget {
  final VoidCallback? onRefresh;
  final VoidCallback? onScanTap;
  final GlobalKey? firstCookbookKey;
  const _HomeTab({this.onRefresh, this.onScanTap, this.firstCookbookKey});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    HistoryService.instance.recentlyViewedNotifier.addListener(_onHistoryChanged);
  }

  @override
  void dispose() {
    _searchQueryNotifier.dispose();
    HistoryService.instance.recentlyViewedNotifier.removeListener(_onHistoryChanged);
    super.dispose();
  }

  void _onHistoryChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _goViewAll(BuildContext ctx, ViewAllType type, String title) {
    Navigator.pushNamed(
      ctx,
      AppRoutes.viewAll,
      arguments: {'type': type, 'title': title},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            SizedBox(height: 14.h),
            _SearchBar(
              onChanged: (val) {
                _searchQueryNotifier.value = val;
              },
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _searchQueryNotifier,
                builder: (context, searchQuery, _) {
                  return ListView(
                    padding: EdgeInsets.only(bottom: 40.h, top: 15.h),
                    children: [
                      if (searchQuery.isEmpty) ...[
                    ValueListenableBuilder<List<Cookbook>?>(
                      valueListenable:
                          CookbookService.instance.myCookbooksNotifier,
                      builder: (context, cookbooks, _) {
                        final countBadge =
                            (cookbooks != null && cookbooks.isNotEmpty)
                            ? ' (${cookbooks.length})'
                            : '';
                        return _SectionRow(
                          title: 'Your cookbooks$countBadge',
                          onViewAll: (cookbooks != null && cookbooks.length > 5)
                              ? () {
                                  _goViewAll(
                                    context,
                                    ViewAllType.cookbooks,
                                    'Cookbooks',
                                  );
                                }
                              : null,
                        );
                      },
                    ),
                    SizedBox(height: 12.h),
                    _CookbooksRow(
                      onRefresh: widget.onRefresh,
                      firstCookbookKey: widget.firstCookbookKey,
                    ),
                  ],
                  if (searchQuery.isEmpty) ...[
                    ValueListenableBuilder<List<Recipe>>(
                      valueListenable: HistoryService.instance.recentlyViewedNotifier,
                      builder: (context, recent, _) {
                        if (recent.isEmpty) return const SizedBox.shrink();
                        return Column(
                          children: [
                            SizedBox(height: 30.h),
                            _SectionRow(
                              title: 'Recently Viewed',
                              onViewAll: recent.length > 5
                                  ? () => _goViewAll(
                                        context,
                                        ViewAllType.recentlyViewed,
                                        'Recently Viewed',
                                      )
                                  : null,
                            ),
                            SizedBox(height: 12.h),
                            _RecentlyViewedRow(
                              key: ValueKey(recent.first.id),
                              recipes: recent,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                  ValueListenableBuilder<List<Recipe>?>(
                    valueListenable: RecipeService.instance.myRecipesNotifier,
                    builder: (context, recipes, _) {
                      final allRecipes = recipes ?? [];
                      final savedRecipes = allRecipes.where((r) => r.origin != 'SUGGESTED').toList();
                      final hasSaved = savedRecipes.isNotEmpty;

                      return Column(
                        children: [
                          if (hasSaved) ...[
                            SizedBox(height: 30.h),
                            _SectionRow(
                              title: 'Saved Recipes',
                              onViewAll: savedRecipes.length > 6 ? () {
                                _goViewAll(context, ViewAllType.savedRecipes, 'Saved Recipes');
                              } : null,
                            ),
                            SizedBox(height: 12.h),
                            _SavedRecipesGrid(
                              searchQuery: searchQuery,
                              recipes: savedRecipes,
                            ),
                          ],
                          
                          _SuggestedRecipesSection(
                            searchQuery: searchQuery,
                            isCompact: hasSaved,
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 50.h), 
                ],
              );
             },
            ),
          ),
        ],
      ),
    ),
  );
}
}

// ── Header ─────────────────────────────────────────────────────────────────────
class _Header extends StatefulWidget {
  const _Header();

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 0),
      child: ValueListenableBuilder<Map<String, dynamic>?>(
        valueListenable: UserService.instance.currentUserNotifier,
        builder: (context, userMap, _) {
          return Row(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/logo1.png',
                  height: 25.h,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const Spacer(),
              SizedBox(width: 4.w),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: const Color(0xFF1A1A1A),
                  size: 24.sp,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                color: Colors.white,
                elevation: 8,
                onSelected: (value) async {
                  if (value == 'settings') {
                    Navigator.pushNamed(context, AppRoutes.profile);
                  } else if (value == 'logout') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        title: Text(
                          'Log out',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1A1A),
                            fontSize: 18.sp,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to log out of your account? You will need to enter your credentials to log back in.',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 15.sp,
                            color: const Color(0xFF555555),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Log out',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFCC3333),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      if (!context.mounted) return;
                      await AuthService.instance.logout();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.welcome,
                        (route) => false,
                      );
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings_outlined,
                          size: 20.sp,
                          color: const Color(0xFF1A1A1A),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 20.sp,
                          color: const Color(0xFFCC3333),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFCC3333),
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Search bar ─────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  const _SearchBar({this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: AppSearchField(onChanged: onChanged),
    );
  }
}

// ── Section row ────────────────────────────────────────────────────────────────
class _SectionRow extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  const _SectionRow({required this.title, this.onViewAll});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View All',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600, // Increased from w500
                  fontSize: 12.sp,
                  color: const Color(0xFFC83A2D),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// COOKBOOKS ROW
// ══════════════════════════════════════════════════════════════════════════════

class _CookbooksRow extends StatefulWidget {
  final VoidCallback? onRefresh;
  final GlobalKey? firstCookbookKey;
  const _CookbooksRow({this.onRefresh, this.firstCookbookKey});

  @override
  State<_CookbooksRow> createState() => _CookbooksRowState();
}

class _CookbooksRowState extends State<_CookbooksRow> {
  @override
  void initState() {
    super.initState();
    if (CookbookService.instance.myCookbooksNotifier.value == null) {
      CookbookService.instance.getMyCookbooks();
    }
  }

  void _loadData() {
    CookbookService.instance.getMyCookbooks();
  }

  @override
  void didUpdateWidget(_CookbooksRow oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Cookbook>?>(
      valueListenable: CookbookService.instance.myCookbooksNotifier,
      builder: (context, cookbooks, _) {
        if (cookbooks == null) {
          return SizedBox(
            height: 188.h,
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFFCC3333)),
            ),
          );
        }

        return SizedBox(
          height: 200.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            itemCount: cookbooks.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) {
                // The "+" Card for creating a new cookbook
                return Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: GestureDetector(
                    key: widget.firstCookbookKey,
                    onTap: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        AppRoutes.cookbookForm,
                        arguments: {'mode': 'add'},
                      );
                      if (result == true) {
                        setState(() => _loadData());
                        widget.onRefresh?.call();
                      }
                    },
                    child: SizedBox(
                      width: 150.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15.r),
                                border: Border.all(
                                  color: const Color(0xFFCC3333).withValues(alpha: 0.3),
                                  width: 0.8, // Thinner border
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.add_rounded,
                                  size: 28.sp, // Even smaller and thinner
                                  color: const Color(0xFFCC3333),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 7.h),
                          Text(
                            "New cookbook",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp, // Reduced from 16
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          // Placeholder for alignment with recipes count
                          SizedBox(height: 2.h),
                          Opacity(
                            opacity: 0,
                            child: Row(
                              children: [
                                Icon(Icons.restaurant_outlined, size: 13.sp),
                                SizedBox(width: 4.w),
                                Text(
                                  '0 Recipes',
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              final cb = cookbooks[i - 1];
              return Padding(
                padding: EdgeInsets.only(
                  right: i < cookbooks.length ? 16.w : 0,
                ),
                child: GestureDetector(
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      AppRoutes.cookbookDetail,
                      arguments: {'cookbook': cb},
                    );
                    if (result == true) {
                      setState(() => _loadData());
                    }
                  },
                  child: SizedBox(
                    width: 180.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 12.r,
                                  offset: Offset(0, 6.h),
                                ),
                              ],
                            ),
                            child: CookbookCover(cookbook: cb),
                          ),
                        ),
                        SizedBox(height: 7.h),
                        Text(
                          cb.name.isEmpty
                              ? cb.name
                              : cb.name[0].toUpperCase() +
                                    cb.name.substring(1).toLowerCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Icon(
                              Icons.restaurant_outlined,
                              size: 11.sp,
                              color: const Color(0xFF999999),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${cb.recipes.length} Recipes',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontSize: 11.sp,
                                color: const Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// RECENTLY VIEWED (home horizontal row)
// ══════════════════════════════════════════════════════════════════════════════
class _RecentlyViewedRow extends StatelessWidget {
  final List<Recipe> recipes;
  const _RecentlyViewedRow({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        itemCount: recipes.length,
        itemBuilder: (_, i) {
          final r = recipes[i];
          return Padding(
            padding: EdgeInsets.only(right: i < recipes.length - 1 ? 12 : 0),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.recipeDetail,
                arguments: {'recipe': r},
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 250.w),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.h,
                          padding: EdgeInsets.all(2.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: _buildThumbnail(r.image),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Flexible(
                          child: Text(
                            r.name.isEmpty
                                ? r.name
                                : r.name[0].toUpperCase() +
                                      r.name.substring(1).toLowerCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                              color: const Color(0xFF1A1A1A),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumbnail(String? image) {
    const fallback = 'assets/images/recipes.png';
    if (image == null || image.isEmpty) {
      return Image.asset(fallback, fit: BoxFit.contain);
    }
    if (image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: image,
        width: 40.w,
        height: 40.h,
        fit: BoxFit.contain,
        placeholder: (_, __) => Container(color: const Color(0xFFEEEEEE)),
        errorWidget: (_, __, ___) => Image.asset(fallback, fit: BoxFit.contain),
      );
    }
    return Image.asset(
      image,
      width: 40.w,
      height: 40.h,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Image.asset(fallback, fit: BoxFit.contain),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SAVED RECIPES GRID
// ══════════════════════════════════════════════════════════════════════════════
class _SavedRecipesGrid extends StatelessWidget {
  final String searchQuery;
  final List<Recipe> recipes;

  const _SavedRecipesGrid({
    required this.searchQuery,
    required this.recipes,
  });

  @override
  Widget build(BuildContext context) {
    List<Recipe> displayList = recipes;
    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      displayList = recipes.where((r) => r.name.toLowerCase().contains(query)).toList();
    }

    if (displayList.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14.h,
          crossAxisSpacing: 14.w,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (ctx, i) {
          final r = displayList[i];
          return RecipeCard(
            recipe: r,
            onHeartTap: () async {
              try {
                await RecipeService.instance.toggleFavorite(r.id);
              } catch (e) {
                IosToast.show(
                  ctx,
                  message: ErrorHelper.getFriendlyMessage(e),
                  type: ToastType.error,
                );
              }
            },
            onTap: () async {
              await Navigator.pushNamed(
                ctx,
                AppRoutes.recipeDetail,
                arguments: {'recipe': r},
              );
            },
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SUGGESTED RECIPES SECTION
// ══════════════════════════════════════════════════════════════════════════════
class _SuggestedRecipesSection extends StatefulWidget {
  final String searchQuery;
  final bool isCompact;

  const _SuggestedRecipesSection({
    required this.searchQuery,
    required this.isCompact,
  });

  @override
  State<_SuggestedRecipesSection> createState() => _SuggestedRecipesSectionState();
}

class _SuggestedRecipesSectionState extends State<_SuggestedRecipesSection> {
  List<Recipe>? _suggestions;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
    RecipeService.instance.myRecipesNotifier.addListener(_syncSuggestions);
  }

  @override
  void dispose() {
    RecipeService.instance.myRecipesNotifier.removeListener(_syncSuggestions);
    super.dispose();
  }

  void _syncSuggestions() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchSuggestions() async {
    setState(() => _isLoading = true);
    try {
      final daysSinceEpoch = DateTime.now().difference(DateTime(2024, 1, 1)).inDays;
      final page = daysSinceEpoch ~/ 3;
      final results = await RecipeService.instance.getExploreRecipes(page: page, size: 8);
      if (mounted) {
        setState(() {
          _suggestions = results.map((r) => r.copyWith(origin: 'SUGGESTED')).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _suggestions == null) {
      return SizedBox(
        height: 150.h,
        child: const Center(child: CircularProgressIndicator(color: Color(0xFFCC3333))),
      );
    }

    final allSaved = RecipeService.instance.myRecipesNotifier.value ?? [];
    final savedNames = allSaved.map((r) => r.name.toLowerCase()).toSet();

    List<Recipe> displayList = _suggestions ?? [];
    if (widget.searchQuery.trim().isNotEmpty) {
      final query = widget.searchQuery.trim().toLowerCase();
      displayList = displayList.where((r) => r.name.toLowerCase().contains(query)).toList();
    }

    if (displayList.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(height: 30.h),
        _SectionRow(title: 'Suggested Recipes'),
        SizedBox(height: 12.h),
        if (widget.isCompact)
          _buildHorizontalList(displayList, savedNames)
        else
          _buildGrid(displayList, savedNames),
      ],
    );
  }

  Widget _buildHorizontalList(List<Recipe> items, Set<String> savedNames) {
    return SizedBox(
      height: 240.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 14.w),
        itemBuilder: (ctx, i) {
          final r = items[i];
          final isSaved = savedNames.contains(r.name.toLowerCase());
          return SizedBox(
            width: 160.w,
            child: RecipeCard(
              recipe: r,
              useValidationIcon: true,
              isValidated: isSaved,
              onValidateTap: () => _handleValidation(r, isSaved),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.recipeDetail,
                arguments: {'recipe': r, 'isPreview': !isSaved},
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid(List<Recipe> items, Set<String> savedNames) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14.h,
          crossAxisSpacing: 14.w,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (ctx, i) {
          final r = items[i];
          final isSaved = savedNames.contains(r.name.toLowerCase());
          return RecipeCard(
            recipe: r,
            useValidationIcon: true,
            isValidated: isSaved,
            onValidateTap: () => _handleValidation(r, isSaved),
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.recipeDetail,
              arguments: {'recipe': r, 'isPreview': !isSaved},
            ),
          );
        },
      ),
    );
  }

  void _handleValidation(Recipe r, bool isSaved) {
    if (isSaved) {
      IosToast.show(
        context,
        message: "This recipe is already present in your recipes",
        type: ToastType.success,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddToCookbookSheet(
        recipe: r,
        onSuccess: () {
          // Success! myRecipesNotifier will refresh and sync state.
        },
      ),
    );
  }
}
