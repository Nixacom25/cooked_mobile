import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import '../../core/api_config.dart';
import '../../core/utils/tutorial_helper.dart';
import '../../widgets/add_to_cookbook_sheet.dart';
import '../../widgets/cookbook_form_modal.dart';
import '../../widgets/haptic_context_menu.dart';
import '../../core/services/tutorial_service.dart';
import '../../main.dart';
import '../../services/history_service.dart';
import '../../models/view_all_type.dart';
import '../../core/utils/error_helper.dart';
import '../../services/sharing_service.dart';
import '../../widgets/skeleton_loader.dart';

class HomeScreen extends StatefulWidget {
  final int initialTab;
  final String? initialUrl;
  const HomeScreen({super.key, this.initialTab = 0, this.initialUrl});
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

  // Global Keys to trigger hints
  final GlobalKey<_CookbooksRowState> _cookbooksRowKey = GlobalKey();
  final GlobalKey _firstCookbookKey = GlobalKey();
  final GlobalKey<GroceryScreenState> _groceryScreenKey = GlobalKey();

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
        onImportTap: () => _switchTab(4),
        firstCookbookKey: _firstCookbookKey,
        cookbooksRowKey: _cookbooksRowKey,
      ),
      const ExploreScreen(),
      ScanScreen(
        isActiveNotifier: _scanActiveNotifier,
        isResultsModeNotifier: _isScanInResultsMode,
        onTabSwitch: _switchTab,
        onClose: () => _switchTab(_previousTab),
      ),
      GroceryScreen(key: _groceryScreenKey),
      ImportScreen(
        isActiveNotifier: _importActiveNotifier,
        isImportingNotifier: _isImportLoading,
        initialUrl: widget.initialUrl,
      ),
    ];

    _navCtrl = AnimationController(
      vsync: this,
      value: _navVisible ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 320),
    );
    _navVisible = (widget.initialTab != 2);
    if (widget.initialTab == 2) _navCtrl.value = 1.0;

    _navSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1.6),
    ).animate(CurvedAnimation(parent: _navCtrl, curve: Curves.easeInOut));

    // Initial tutorial check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTutorial(delayMs: 1500);
    });

    if (CookbookService.instance.myCookbooksNotifier.value == null) {
      CookbookService.instance.getMyCookbooks();
    }

    // 🔗 Auto-trigger pending shared URL after login/startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // If we didn't get a URL via constructor, check the service for any 'parked' URL
        if (widget.initialUrl == null) {
          final pendingUrl = SharingService.instance.sharedTextNotifier.value;
          if (pendingUrl != null && pendingUrl.isNotEmpty) {
            debugPrint("HomeScreen: Found pending shared URL: $pendingUrl");
            _switchTab(4);
            // The ImportScreen (tab 4) will be built/active.
            // We'll update it to listen to the service as well.
          }
        }
      }
    });
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

      // Safety: Don't show tutorial if a modal/sheet is currently open on top of HomeScreen
      // This prevents the !_debugLocked crash when the modal is closing while the tutorial starts
      final isTopRoute = ModalRoute.of(context)?.isCurrent ?? true;

      if (!hasCookbook || !hasScan || !hasImport || !isTopRoute) {
        if (retries < 15) {
          _startTutorial(delayMs: 500, retries: retries + 1);
        }
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _currentTab != 0 || TutorialHelper.isShowing) return;

        final firstCb =
            CookbookService.instance.myCookbooksNotifier.value?.firstOrNull;

        try {
          TutorialHelper.showTutorial(
            context,
            cookbookKey: _firstCookbookKey,
            scanKey: _scanTabKey,
            importKey: _importTabKey,
            firstCookbook: firstCb,
            onTabSwitch: (idx) => _switchTab(idx),
          );
        } catch (e) {
          debugPrint("Silent tutorial error: $e");
        }
      });
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
    _navCtrl.dispose();
    _scanActiveNotifier.dispose();
    _isScanInResultsMode.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Only restart tutorial if it was already active or should be
    if (TutorialService.instance.isTutorialActive) {
      _startTutorial(
        delayMs: 800,
      ); // More delay to allow pop transition to finish
    }
  }

  void _switchTab(int i) {
    if (_scrollBusy) return;

    // Haptic feedback for tab change
    HapticFeedback.selectionClick();

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

    // Trigger hints when rejoining tabs
    if (i == 0) {
      _cookbooksRowKey.currentState?.triggerHint();
    } else if (i == 3) {
      _groceryScreenKey.currentState?.triggerHint();
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
      backgroundColor: Colors.white,
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
                        // Custom Bottom Navigation Bar overlaid entirely on top
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: SlideTransition(
                            position: _navSlide,
                            child: hideNav || isKeyboardOpen
                                ? const SizedBox.shrink()
                                : _FloatingBottomNav(
                                    currentIndex: _currentTab,
                                    navVisible: _navVisible,
                                    onTap: _switchTab,
                                    onCameraTap: () {
                                      if (_currentTab == 2) {
                                        _toggleNav(); // hide nav if already on scan tab
                                      } else {
                                        _switchTab(2); // go to scan tab
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

// ── Floating pill bottom nav ───────────────────────────────────────────────────
class _FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final bool navVisible;
  final void Function(int) onTap;
  final VoidCallback onCameraTap;
  final GlobalKey scanTabKey;
  final GlobalKey groceryTabKey;
  final GlobalKey importTabKey;
  const _FloatingBottomNav({
    required this.currentIndex,
    required this.navVisible,
    required this.onTap,
    required this.onCameraTap,
    required this.scanTabKey,
    required this.groceryTabKey,
    required this.importTabKey,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // White pill
            Container(
              height: 68.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _NavItem(
                    svgPath: 'assets/nav/home.svg',
                    activeSvgPath: 'assets/nav/home_active.svg',
                    label: 'Home',
                    index: 0,
                    current: currentIndex,
                    onTap: onTap,
                  ),
                  _NavItem(
                    svgPath: 'assets/nav/explore.svg',
                    activeSvgPath: 'assets/nav/explore_active.svg',
                    label: 'Explore',
                    index: 1,
                    current: currentIndex,
                    onTap: onTap,
                  ),
                  const Expanded(child: SizedBox()),
                  _NavItem(
                    iconKey: groceryTabKey,
                    svgPath: 'assets/nav/grocery.svg',
                    activeSvgPath: 'assets/nav/grocery_active.svg',
                    label: 'Grocery',
                    index: 3,
                    current: currentIndex,
                    onTap: (idx) {
                      onTap(idx);
                    },
                  ),
                  _NavItem(
                    iconKey: importTabKey,
                    svgPath: 'assets/nav/import.svg',
                    activeSvgPath: 'assets/nav/import_active.svg',
                    label: 'Import',
                    index: 4,
                    current: currentIndex,
                    onTap: (idx) {
                      onTap(idx);
                    },
                  ),
                ],
              ),
            ),

            // Camera FAB elevated
            Positioned(
              top: -18.h,
              child: GestureDetector(
                onTap: onCameraTap,
                child: Container(
                  key: scanTabKey,
                  width: 58.w,
                  height: 58.h,
                  decoration: BoxDecoration(
                    color: currentIndex == 2
                        ? Colors.black87
                        : const Color(0xFFC83A2D),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (currentIndex == 2
                                    ? Colors.black87
                                    : const Color(0xFFC83A2D))
                                .withValues(alpha: 0.4),
                        blurRadius: 16.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    currentIndex == 2
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: currentIndex == 2 ? 32.sp : 26.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String svgPath;
  final String activeSvgPath;
  final String label;
  final int index;
  final int current;
  final void Function(int) onTap;
  final GlobalKey? iconKey;

  const _NavItem({
    required this.svgPath,
    required this.activeSvgPath,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
    this.iconKey,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    // 1. Scale down
    await _anim.forward();
    // 2. Scale back up
    await _anim.reverse();
    // 3. Trigger action (turns red)
    widget.onTap(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.index == widget.current;
    return Expanded(
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          key: widget.iconKey,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scale,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: SvgPicture.asset(
                  active ? widget.activeSvgPath : widget.svgPath,
                  key: ValueKey(active),
                  width: 22.w,
                  height: 22.h,
                  colorFilter: ColorFilter.mode(
                    active ? const Color(0xFFC83A2D) : const Color(0xFF8E8E8E),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 12.sp,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active
                    ? const Color(0xFFC83A2D)
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
  final VoidCallback? onImportTap;
  final GlobalKey? firstCookbookKey;
  final GlobalKey<_CookbooksRowState>? cookbooksRowKey;
  const _HomeTab({
    this.onRefresh,
    this.onScanTap,
    this.onImportTap,
    this.firstCookbookKey,
    this.cookbooksRowKey,
  });

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    HistoryService.instance.recentlyViewedNotifier.addListener(
      _onHistoryChanged,
    );
  }

  @override
  void dispose() {
    _searchQueryNotifier.dispose();
    HistoryService.instance.recentlyViewedNotifier.removeListener(
      _onHistoryChanged,
    );
    super.dispose();
  }

  void _onHistoryChanged() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
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
      color: Colors.white,
      child: ValueListenableBuilder<String>(
        valueListenable: _searchQueryNotifier,
        builder: (context, searchQuery, _) {
          return CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _HomeHeaderDelegate(
                  topPadding: MediaQuery.of(context).padding.top,
                  onSearchChanged: (val) {
                    _searchQueryNotifier.value = val;
                  },
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(bottom: 40.h, top: 0.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (searchQuery.isEmpty) ...[
                      const _SavingsCard(),
                      ValueListenableBuilder<List<Cookbook>?>(
                        valueListenable:
                            CookbookService.instance.myCookbooksNotifier,
                        builder: (context, cookbooks, _) {
                          final countBadge =
                              (cookbooks != null && cookbooks.isNotEmpty)
                              ? ' (${cookbooks.length})'
                              : '';
                          return _SectionRow(
                            title: 'Your Cookbooks$countBadge',
                            onViewAll:
                                (cookbooks != null && cookbooks.length > 5)
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
                        key: widget.cookbooksRowKey,
                        onRefresh: widget.onRefresh,
                        firstCookbookKey: widget.firstCookbookKey,
                      ),
                    ],
                    if (searchQuery.isEmpty) ...[
                      ValueListenableBuilder<List<Recipe>>(
                        valueListenable:
                            HistoryService.instance.recentlyViewedNotifier,
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
                    if (searchQuery.isEmpty) ...[
                      SizedBox(height: 25.h),
                      _SectionRow(title: 'Add New Recipe'),
                      SizedBox(height: 12.h),
                      _QuickActionsRow(
                        onScanTap: widget.onScanTap,
                        onImportTap: widget.onImportTap,
                      ),
                      SizedBox(height: 5.h),
                    ],
                    ValueListenableBuilder<List<Recipe>?>(
                      valueListenable: RecipeService.instance.myRecipesNotifier,
                      builder: (context, recipes, _) {
                        if (recipes == null) {
                          return Column(
                            children: [
                              SizedBox(height: 30.h),
                              _SectionRow(title: 'Saved Recipes'),
                              SizedBox(height: 20.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18.w),
                                child: GridView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 4,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 14.h,
                                        crossAxisSpacing: 14.w,
                                        childAspectRatio: 0.72,
                                      ),
                                  itemBuilder: (_, __) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SkeletonLoader(
                                        width: double.infinity,
                                        height: 145.h,
                                        borderRadius: 20,
                                      ),
                                      SizedBox(height: 10.h),
                                      SkeletonLoader(
                                        width: 140.w,
                                        height: 16.h,
                                      ),
                                      SizedBox(height: 6.h),
                                      SkeletonLoader(width: 80.w, height: 12.h),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        final savedRecipes = recipes
                            .where((r) => !r.isInCookbook && !r.isSuggested)
                            .toList();
                        final hasSaved = savedRecipes.isNotEmpty;

                        return Column(
                          children: [
                            if (hasSaved) ...[
                              SizedBox(height: 30.h),
                              _SectionRow(
                                title: 'Saved Recipes',
                                onViewAll: savedRecipes.length > 6
                                    ? () {
                                        _goViewAll(
                                          context,
                                          ViewAllType.savedRecipes,
                                          'Saved Recipes',
                                        );
                                      }
                                    : null,
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
                    SizedBox(height: 100.h),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────
class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final ValueChanged<String>? onSearchChanged;
  final double topPadding;

  _HomeHeaderDelegate({this.onSearchChanged, required this.topPadding});

  @override
  double get maxExtent => 240.h + topPadding;
  @override
  double get minExtent => 80.h + topPadding;

  @override
  bool shouldRebuild(covariant _HomeHeaderDelegate oldDelegate) {
    return topPadding != oldDelegate.topPadding;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double maxShrinkOffset = maxExtent - minExtent;
    final double progress = (shrinkOffset / maxShrinkOffset).clamp(0.0, 1.0);

    return Container(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -(shrinkOffset).clamp(0.0, 200.h),
            left: 0,
            right: 0,
            height: 200.h + topPadding,
            child: Opacity(
              opacity: (1 - progress).clamp(0.0, 1.0),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(20.r),
                          ),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/home.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 15.h, 10.w, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ValueListenableBuilder<Map<String, dynamic>?>(
                              valueListenable:
                                  UserService.instance.currentUserNotifier,
                              builder: (context, user, _) {
                                String firstName = user?['firstname'] ?? 'User';
                                String? photo = user?['profilePictureUrl'];
                                String? photoUrl;
                                if (photo != null && photo.isNotEmpty) {
                                  photoUrl = photo.startsWith('http')
                                      ? photo
                                      : '${ApiConfig.baseUrl}$photo';
                                }
                                return Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20.r,
                                      backgroundColor: Colors.white24,
                                      backgroundImage: photoUrl != null
                                          ? NetworkImage(photoUrl)
                                          : null,
                                      child: photoUrl == null
                                          ? Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 28.sp,
                                            )
                                          : null,
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                      'Hi, $firstName',
                                      style: TextStyle(
                                        fontFamily: 'SF Pro',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Spacer(),
                                    PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.more_vert_rounded,
                                        color: Colors.white,
                                        size: 25.sp,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                      ),
                                      color: Colors.white,
                                      elevation: 8,
                                      onSelected: (value) async {
                                        if (value == 'settings') {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.profile,
                                          );
                                        } else if (value == 'logout') {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.r),
                                              ),
                                              title: Text(
                                                'Log out',
                                                style: TextStyle(
                                                  fontFamily: 'SF Pro',
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color(
                                                    0xFF1A1A1A,
                                                  ),
                                                  fontSize: 18.sp,
                                                ),
                                              ),
                                              content: Text(
                                                'Are you sure you want to log out of your account? You will need to enter your credentials to log back in.',
                                                style: TextStyle(
                                                  fontFamily: 'SF Pro',
                                                  fontSize: 15.sp,
                                                  color: const Color(
                                                    0xFF555555,
                                                  ),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF888888),
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: const Text(
                                                    'Log out',
                                                    style: TextStyle(
                                                      fontFamily: 'SF Pro',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFFC83A2D),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await AuthService.instance.logout();
                                            if (context.mounted)
                                              Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                AppRoutes.welcome,
                                                (_) => false,
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
                                                Icons.settings_rounded,
                                                color: const Color(0xFF1A1A1A),
                                                size: 20.sp,
                                              ),
                                              SizedBox(width: 12.w),
                                              Text(
                                                'Settings',
                                                style: TextStyle(
                                                  fontFamily: 'SF Pro',
                                                  fontSize: 15.sp,
                                                  color: const Color(
                                                    0xFF1A1A1A,
                                                  ),
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
                                                color: const Color(0xFFC83A2D),
                                                size: 20.sp,
                                              ),
                                              SizedBox(width: 12.w),
                                              Text(
                                                'Logout',
                                                style: TextStyle(
                                                  fontFamily: 'SF Pro',
                                                  fontSize: 15.sp,
                                                  color: const Color(
                                                    0xFFC83A2D,
                                                  ),
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
                            SizedBox(height: 20.h),
                            Padding(
                              padding: EdgeInsets.only(right: 30.w),
                              child: Text(
                                'What would you like to\ncook today?',
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 25.sp,
                                  color: const Color(0xFFFFF6D6),
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: _SearchBar(onChanged: onSearchChanged),
          ),
        ],
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
                  fontWeight: FontWeight.w800,
                  fontSize: 18.sp,
                  color: const Color(0xFF111827),
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
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
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
  const _CookbooksRow({super.key, this.onRefresh, this.firstCookbookKey});

  @override
  State<_CookbooksRow> createState() => _CookbooksRowState();
}

class _CookbooksRowState extends State<_CookbooksRow> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (CookbookService.instance.myCookbooksNotifier.value == null) {
      CookbookService.instance.getMyCookbooks();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    CookbookService.instance.getMyCookbooks();
  }

  void triggerHint() {
    _showScrollHint();
  }

  void _showScrollHint() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        _scrollController
            .animateTo(
              60.w,
              duration: const Duration(milliseconds: 1200),
              curve: Curves.elasticOut,
            )
            .then((_) {
              if (!mounted) return;
              _scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutQuart,
              );
            });
      }
    });
  }

  @override
  void didUpdateWidget(_CookbooksRow oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Cookbook>?>(
      valueListenable: CookbookService.instance.myCookbooksNotifier,
      builder: (context, rawCookbooks, _) {
        if (rawCookbooks != null && rawCookbooks.length > 2) {
          _showScrollHint();
        }

        if (rawCookbooks == null) {
          return SizedBox(
            height: 200.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              itemCount: 4,
              itemBuilder: (_, __) => Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      width: 150.w,
                      height: 150.h,
                      borderRadius: 16,
                    ),
                    SizedBox(height: 8.h),
                    SkeletonLoader(width: 100.w, height: 16.h),
                  ],
                ),
              ),
            ),
          );
        }

        final cookbooks = List<Cookbook>.from(rawCookbooks)
          ..sort((a, b) {
            if (a.isPinned && !b.isPinned) return -1;
            if (!a.isPinned && b.isPinned) return 1;
            return b.updatedAt.compareTo(a.updatedAt);
          });

        return SizedBox(
          height: 200.h,
          child: ClipRRect(
            child: ListView.builder(
              controller: _scrollController,
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
                        final result = await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const CookbookFormModal(),
                        );
                        if (result != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              _loadData();
                              widget.onRefresh?.call();
                            }
                          });
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
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFC83A2D,
                                    ).withValues(alpha: 0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: 40.sp,
                                    color: const Color(0xFFC83A2D),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 7.h),
                            Text(
                              "New Cookbook",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
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
                    behavior: HitTestBehavior.opaque,
                    onLongPressStart: (details) {
                      HapticFeedback.heavyImpact();
                      HapticContextMenu.show(
                        context,
                        targetPosition: details.globalPosition,
                        actions: [
                          HapticMenuAction(
                            title: 'Add Recipes',
                            icon: Icons.add_circle_outline_rounded,
                            onTap: () async {
                              final result = await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) =>
                                    CookbookFormModal(cookbook: cb),
                              );
                              if (result != null) {
                                setState(() => _loadData());
                              }
                            },
                          ),
                          HapticMenuAction(
                            title: 'Edit Cookbook',
                            icon: Icons.edit_outlined,
                            onTap: () async {
                              final result = await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) =>
                                    CookbookFormModal(cookbook: cb),
                              );
                              if (result != null) {
                                setState(() => _loadData());
                              }
                            },
                          ),
                          HapticMenuAction(
                            title: cb.isPinned
                                ? 'Unpin Cookbook'
                                : 'Pin Cookbook',
                            icon: cb.isPinned
                                ? Icons.push_pin_rounded
                                : Icons.push_pin_outlined,
                            onTap: () {
                              // FIRE AND FORGET - Optimistic
                              CookbookService.instance
                                  .togglePin(cb.id)
                                  .then((updated) {
                                    if (mounted) {
                                      IosToast.show(
                                        context,
                                        message: updated.isPinned
                                            ? 'Cookbook pinned'
                                            : 'Cookbook unpinned',
                                        type: ToastType.success,
                                      );
                                    }
                                  })
                                  .catchError((e) {
                                    if (mounted) {
                                      IosToast.show(
                                        context,
                                        message: 'Operation failed',
                                        type: ToastType.error,
                                      );
                                    }
                                  });
                            },
                          ),
                          HapticMenuAction(
                            title: 'Delete Cookbook',
                            icon: Icons.delete_outline_rounded,
                            isDestructive: true,
                            onTap: () {
                              // FIRE AND FORGET - Optimistic
                              CookbookService.instance
                                  .deleteCookbook(cb.id)
                                  .then((_) {
                                    if (mounted) {
                                      IosToast.show(
                                        context,
                                        message: 'Cookbook deleted',
                                        type: ToastType.success,
                                      );
                                    }
                                  })
                                  .catchError((e) {
                                    if (mounted) {
                                      IosToast.show(
                                        context,
                                        message: 'Failed to delete cookbook',
                                        type: ToastType.error,
                                      );
                                    }
                                  });
                            },
                          ),
                        ],
                      );
                    },
                    child: SizedBox(
                      width: 180.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: CookbookCover(cookbook: cb)),
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
                                size: 13.sp,
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
      height: 55.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        itemCount: recipes.length,
        itemBuilder: (_, i) {
          final r = recipes[i];
          return Padding(
            padding: EdgeInsets.only(right: i < recipes.length - 1 ? 12 : 0),
            child: GestureDetector(
              onTap: () {
                HistoryService.instance.addToHistory(r);
                Navigator.pushNamed(
                  context,
                  AppRoutes.recipeDetail,
                  arguments: {'recipe': r},
                );
              },
              child: Container(
                constraints: BoxConstraints(maxWidth: 180.w),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F1EF),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: const Color(0xFFEDEDED),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38.w,
                      height: 38.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.r),
                        child: _buildThumbnail(r.image),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Flexible(
                      child: Text(
                        r.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w800,
                          fontSize: 14.sp,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ],
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
    if (image == null || image.isEmpty || image == 'null') {
      return Image.asset(fallback, fit: BoxFit.cover);
    }
    if (image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: image,
        width: 38.w,
        height: 38.h,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: const Color(0xFFEEEEEE)),
        errorWidget: (_, __, ___) => Image.asset(fallback, fit: BoxFit.cover),
      );
    }
    return Image.asset(
      image,
      width: 38.w,
      height: 38.h,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(fallback, fit: BoxFit.cover),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SAVED RECIPES GRID
// ══════════════════════════════════════════════════════════════════════════════
class _SavedRecipesGrid extends StatelessWidget {
  final String searchQuery;
  final List<Recipe> recipes;

  const _SavedRecipesGrid({required this.searchQuery, required this.recipes});

  @override
  Widget build(BuildContext context) {
    List<Recipe> displayList = List<Recipe>.from(recipes);
    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      displayList = displayList
          .where((r) => r.name.toLowerCase().contains(query))
          .toList();
    }

    if (displayList.isEmpty) return const SizedBox.shrink();

    // Sort displayList: pinned first, then by date
    displayList.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14.h,
          crossAxisSpacing: 14.w,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (ctx, i) {
          final r = displayList[i];
          return RecipeCard(
            recipe: r,
            onTap: () {
              HistoryService.instance.addToHistory(r);
              Navigator.pushNamed(
                ctx,
                AppRoutes.recipeDetail,
                arguments: {'recipe': r, 'isPreview': false},
              );
            },
            onAddToCookbookTap: () {
              showModalBottomSheet(
                context: ctx,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => AddToCookbookSheet(recipe: r),
              );
            },
            onPinTap: () {
              // FIRE AND FORGET - Optimistic
              RecipeService.instance
                  .togglePin(r.id)
                  .then((updated) {
                    if (ctx.mounted) {
                      IosToast.show(
                        ctx,
                        message: updated.isPinned
                            ? 'Recipe pinned'
                            : 'Recipe unpinned',
                        type: ToastType.success,
                      );
                    }
                  })
                  .catchError((e) {
                    if (ctx.mounted) {
                      IosToast.show(
                        ctx,
                        message: 'Failed to pin recipe',
                        type: ToastType.error,
                      );
                    }
                  });
            },
            onShareTap: () async {
              try {
                final RenderBox? box = context.findRenderObject() as RenderBox?;
                final Rect? sharePositionOrigin = box != null
                    ? box.localToGlobal(Offset.zero) & box.size
                    : null;
                final rawLink = await RecipeService.instance.getShareLink(r.id);
                final link = rawLink
                    .replaceAll('cooked.nixacom.com', 'link.cookedapp.com')
                    .replaceAll(
                      'https://cookedapp.app',
                      'https://link.cookedapp.com',
                    );
                final name = r.name;
                final creatorStr = r.creator != null
                    ? "${r.creator!.displayName}'s "
                    : "";
                final template =
                    "Check out $creatorStr$name on Cooked 🙌\n$link";

                Share.share(template, sharePositionOrigin: sharePositionOrigin);
              } catch (e) {
                if (ctx.mounted) {
                  IosToast.show(
                    ctx,
                    message: ErrorHelper.getFriendlyMessage(e),
                    type: ToastType.error,
                  );
                }
              }
            },
            onDeleteTap: () {
              // FIRE AND FORGET - Optimistic
              RecipeService.instance.deleteRecipe(r.id).then((success) {
                if (success && ctx.mounted) {
                  IosToast.show(
                    ctx,
                    message: 'Recipe deleted',
                    type: ToastType.success,
                  );
                }
              });
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
  State<_SuggestedRecipesSection> createState() =>
      _SuggestedRecipesSectionState();
}

class _SuggestedRecipesSectionState extends State<_SuggestedRecipesSection> {
  Timer? _pollingTimer;
  bool _isPolling = true;

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();

    // Polling: If suggestions are empty, check every 10 seconds for 2 minutes
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    int attempts = 0;
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      attempts++;
      final current = RecipeService.instance.homeSuggestionsNotifier.value;
      if (current != null && current.isNotEmpty) {
        timer.cancel();
        if (mounted) setState(() => _isPolling = false);
        return;
      }

      if (attempts > 12) {
        // Stop after 2 minutes (12 attempts of 10 seconds)
        timer.cancel();
        if (mounted) setState(() => _isPolling = false);
        return;
      }

      await _fetchSuggestions(force: true);
    });
  }

  Future<void> _fetchSuggestions({bool force = false}) async {
    try {
      await RecipeService.instance.getHomeSuggestions(forceRefresh: force);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Recipe>?>(
      valueListenable: RecipeService.instance.homeSuggestionsNotifier,
      builder: (context, suggestions, _) {
        if (suggestions == null && widget.searchQuery.trim().isNotEmpty) {
          return const SizedBox.shrink();
        }

        final allSaved = RecipeService.instance.myRecipesNotifier.value ?? [];
        final savedIds = allSaved.map((r) => r.id).toSet();
        final savedNames = allSaved.map((r) => r.name.toLowerCase()).toSet();

        List<Recipe>? displayList = suggestions;

        // If we have an empty list but we are still polling, treat it as loading (null) to show skeletons
        if (displayList != null && displayList.isEmpty && _isPolling) {
          displayList = null;
        }

        if (displayList != null && widget.searchQuery.trim().isNotEmpty) {
          final query = widget.searchQuery.trim().toLowerCase();
          displayList = displayList
              .where((r) => r.name.toLowerCase().contains(query))
              .toList();
        }

        if (displayList != null && displayList.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            SizedBox(height: 22.h),
            _SectionRow(title: 'Suggested Recipes'),
            SizedBox(height: 12.h),
            widget.isCompact
                ? _buildHorizontalList(displayList, savedIds, savedNames)
                : _buildGridList(displayList, savedIds, savedNames),
          ],
        );
      },
    );
  }

  Widget _buildGridList(
    List<Recipe>? items,
    Set<String> savedIds,
    Set<String> savedNames,
  ) {
    // Show only first 4 in grid as requested
    final List<Recipe> gridItems = items != null ? items.take(4).toList() : [];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14.w,
          mainAxisSpacing: 14.h,
          mainAxisExtent: 220.h,
        ),
        itemCount: items == null ? 4 : gridItems.length,
        itemBuilder: (ctx, index) {
          if (items == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: double.infinity,
                  height: 160.h,
                  borderRadius: 20,
                ),
                SizedBox(height: 12.h),
                SkeletonLoader(width: double.infinity, height: 18.h),
                SizedBox(height: 6.h),
                SkeletonLoader(width: 80.w, height: 14.h),
              ],
            );
          }
          final r = gridItems[index];
          final i = index;
          final isSaved =
              (r.id.isNotEmpty && savedIds.contains(r.id)) ||
              (r.name.isNotEmpty && savedNames.contains(r.name.toLowerCase()));
          return RecipeCard(
            recipe: r,
            index: i,
            useValidationIcon: true,
            isValidated: isSaved,
            disableSlide: true,
            onValidateTap: () => _handleValidation(r, isSaved),
            onTap: () {
              HistoryService.instance.addToHistory(r);
              Navigator.pushNamed(
                context,
                AppRoutes.recipeDetail,
                arguments: {'recipe': r, 'isPreview': !isSaved},
              );
            },
            onAddToCookbookTap: () {
              showModalBottomSheet(
                context: ctx,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => AddToCookbookSheet(recipe: r),
              );
            },
            onShareTap: () async {
              try {
                final RenderBox? box = context.findRenderObject() as RenderBox?;
                final Rect? sharePositionOrigin = box != null
                    ? box.localToGlobal(Offset.zero) & box.size
                    : null;
                final rawLink = await RecipeService.instance.getShareLink(r.id);
                final link = rawLink
                    .replaceAll('cooked.nixacom.com', 'link.cookedapp.com')
                    .replaceAll(
                      'https://cookedapp.app',
                      'https://link.cookedapp.com',
                    );
                final name = r.name;
                final creatorStr = r.creator != null
                    ? "${r.creator!.displayName}'s "
                    : "";
                final template =
                    "Check out $creatorStr$name on Cooked 🙌\n$link";

                Share.share(template, sharePositionOrigin: sharePositionOrigin);
              } catch (e) {
                if (ctx.mounted) {
                  IosToast.show(
                    ctx,
                    message: ErrorHelper.getFriendlyMessage(e),
                    type: ToastType.error,
                  );
                }
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildHorizontalList(
    List<Recipe>? items,
    Set<String> savedIds,
    Set<String> savedNames,
  ) {
    final List<Recipe> listItems = items ?? [];
    // Only show skeletons if items is null (loading state)
    final itemCount = items == null ? 3 : listItems.length;

    return SizedBox(
      height: 215.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(width: 14.w),
        itemBuilder: (ctx, i) {
          if (items == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: 250.w, height: 150.h, borderRadius: 20),
                SizedBox(height: 12.h),
                SkeletonLoader(width: 180.w, height: 18.h),
                SizedBox(height: 6.h),
                SkeletonLoader(width: 100.w, height: 14.h),
              ],
            );
          }

          final r = listItems[i];
          final isSaved =
              (r.id.isNotEmpty && savedIds.contains(r.id)) ||
              (r.name.isNotEmpty && savedNames.contains(r.name.toLowerCase()));
          return SizedBox(
            width: 160.w,
            child: RecipeCard(
              recipe: r,
              index: i,
              useValidationIcon: true,
              isValidated: isSaved,
              disableSlide: true,
              onValidateTap: () => _handleValidation(r, isSaved),
              onTap: () {
                HistoryService.instance.addToHistory(r);
                Navigator.pushNamed(
                  context,
                  AppRoutes.recipeDetail,
                  arguments: {'recipe': r, 'isPreview': !isSaved},
                );
              },
              onAddToCookbookTap: () {
                showModalBottomSheet(
                  context: ctx,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => AddToCookbookSheet(recipe: r),
                );
              },
              onShareTap: () async {
                try {
                  final RenderBox? box =
                      context.findRenderObject() as RenderBox?;
                  final Rect? sharePositionOrigin = box != null
                      ? box.localToGlobal(Offset.zero) & box.size
                      : null;

                  final rawLink = await RecipeService.instance.getShareLink(
                    r.id,
                  );
                  final link = rawLink
                      .replaceAll('cooked.nixacom.com', 'link.cookedapp.com')
                      .replaceAll(
                        'https://cookedapp.app',
                        'https://link.cookedapp.com',
                      );
                  final name = r.name;
                  final creatorStr = r.creator != null
                      ? "${r.creator!.displayName}'s "
                      : "";
                  final template =
                      "Check out $creatorStr$name on Cooked 🙌\n$link";

                  Share.share(
                    template,
                    sharePositionOrigin: sharePositionOrigin,
                  );
                } catch (e) {
                  if (ctx.mounted) {
                    IosToast.show(
                      ctx,
                      message: ErrorHelper.getFriendlyMessage(e),
                      type: ToastType.error,
                    );
                  }
                }
              },
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

    // 1. Optimistic Save immediately 'In Direct'
    if (r.id.isEmpty) {
      RecipeService.instance.createRecipe(r).catchError((e) {
        if (mounted) {
          IosToast.show(
            context,
            message: ErrorHelper.getFriendlyMessage(e),
            type: ToastType.error,
          );
        }
        return r;
      });
    } else {
      RecipeService.instance.validateRecipe(r.id).catchError((e) {
        if (mounted) {
          IosToast.show(
            context,
            message: ErrorHelper.getFriendlyMessage(e),
            type: ToastType.error,
          );
        }
        return r;
      });
    }
    _updateLocalStateForValidation(r);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddToCookbookSheet(
        recipe: r,
        onSuccess: () => _updateLocalStateForValidation(r),
      ),
    );
  }

  void _updateLocalStateForValidation(Recipe r) {
    if (!mounted) return;

    final validatedRecipe = r.copyWith(
      origin: r.origin ?? 'IMPORT',
      isValidated: true,
      isSuggested: false,
    );
    // 1. Update global suggestions: Mark as MANUAL and MOVE to the end
    final suggestions = RecipeService.instance.homeSuggestionsNotifier.value;
    if (suggestions != null) {
      final idx = suggestions.indexWhere((item) => item.id == r.id);
      if (idx != -1) {
        final newList = List<Recipe>.from(suggestions);
        newList.removeAt(idx);
        newList.add(validatedRecipe);
        RecipeService.instance.homeSuggestionsNotifier.value = newList;
      }
    }

    // 2. Inject directly into the global notifier so it appears in "Saved" lists instantly
    final currentSaved = RecipeService.instance.myRecipesNotifier.value ?? [];
    if (!currentSaved.any((item) => item.id == r.id)) {
      RecipeService.instance.myRecipesNotifier.value = [
        validatedRecipe,
        ...currentSaved,
      ];
    }

    // 3. Background sync to ensure server consistency
    RecipeService.instance
        .getMyRecipes(forceRefresh: true)
        .catchError((_) => <Recipe>[]);
    RecipeService.instance
        .getHomeSuggestions(forceRefresh: true)
        .catchError((_) => <Recipe>[]);
  }
}

class _SavingsCard extends StatefulWidget {
  const _SavingsCard();

  static bool isDismissed = false;

  @override
  State<_SavingsCard> createState() => _SavingsCardState();
}

class _SavingsCardState extends State<_SavingsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  bool _hasTriggeredAnimation = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      reverseDuration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInBack,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.elasticOut,
            reverseCurve: Curves.easeInBack,
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismissCard() {
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() {
          _SavingsCard.isDismissed = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_SavingsCard.isDismissed) return const SizedBox.shrink();

    return ValueListenableBuilder<List<Recipe>?>(
      valueListenable: RecipeService.instance.myRecipesNotifier,
      builder: (context, recipes, _) {
        final myRecipes = recipes ?? [];
        double totalSaved = 0.0;
        for (var r in myRecipes) {
          if (r.totalPrice != null && r.totalPrice! > 0) {
            double makeAtHome = r.totalPrice!;
            double orderNearby = makeAtHome * 2.5 + 5.0;
            totalSaved += (orderNearby - makeAtHome);
          }
        }

        if (totalSaved <= 0) return const SizedBox.shrink();

        if (!_hasTriggeredAnimation && !_SavingsCard.isDismissed) {
          _hasTriggeredAnimation = true;
          Future.microtask(() {
            if (mounted) _controller.forward();
          });
        }

        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: EdgeInsets.only(
                left: 22.w,
                right: 22.w,
                bottom: 20.h,
                top: 0.h,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF8F0),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: const Color(0xFFF3EBE0),
                        width: 1,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.savingsDetails);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "You've saved",
                                    style: TextStyle(
                                      fontFamily: 'SF Pro',
                                      fontSize: 14.sp,
                                      color: const Color(0xFF7D562D),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        "~\$${totalSaved.toStringAsFixed(0)}",
                                        style: TextStyle(
                                          fontFamily: 'SF Pro',
                                          fontSize: 28.sp,
                                          color: const Color(0xFF00C40A),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        "this month",
                                        style: TextStyle(
                                          fontFamily: 'SF Pro',
                                          fontSize: 16.sp,
                                          color: const Color(0xFF1A1A1A),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "Compared to ordering takeout.",
                                    style: TextStyle(
                                      fontFamily: 'SF Pro',
                                      fontSize: 14.sp,
                                      color: const Color(
                                        0xFF7D562D,
                                      ).withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              'assets/images/logo2.png',
                              height: 47.h,
                              width: 47.w,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -10.h,
                    right: -6.w,
                    child: GestureDetector(
                      onTap: _dismissCard,
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: Color(0xFFC83A2D),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16.sp,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final VoidCallback? onScanTap;
  final VoidCallback? onImportTap;

  const _QuickActionsRow({this.onScanTap, this.onImportTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionCard(
              title: "Scan Recipe",
              subtitle: "Use your camera to scan a recipe",
              icon: Icons.camera_alt_outlined,
              onTap: () {
                if (onScanTap != null) onScanTap!();
              },
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: _QuickActionCard(
              title: "Import Recipe",
              subtitle: "Import from link, photo, or file",
              icon: Icons.file_upload_outlined,
              onTap: () {
                if (onImportTap != null) onImportTap!();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFF6C8CB), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFDF0D5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Icon(icon, color: const Color(0xFFC83A2D), size: 22.sp),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 14.sp,
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 10.sp,
                color: const Color(0xFF7A8499),
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
