import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../routes/app_routes.dart';
import 'view_all_screen.dart';
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
import '../../core/services/tutorial_service.dart';
import '../../main.dart';

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
  bool _scrollBusy = false; // debounce guard
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
  }

  void _tutorialDataListener() {
    if (mounted &&
        !TutorialService.instance.hasSeenHome &&
        CookbookService.instance.myCookbooksNotifier.value != null &&
        CookbookService.instance.myCookbooksNotifier.value!.isNotEmpty) {
      _startTutorial(delayMs: 500);
    }
  }

  void _startTutorial({int delayMs = 500}) {
    // Only show Home tutorial if on Home tab
    if (_currentTab != 0) return;

    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted && _currentTab == 0) {
        final firstCb =
            CookbookService.instance.myCookbooksNotifier.value?.firstOrNull;
        TutorialHelper.showTutorial(
          context,
          cookbookKey: _firstCookbookKey,
          scanKey: _scanTabKey,
          importKey: _importTabKey,
          firstCookbook: firstCb,
          onTabSwitch: (idx) => _switchTab(idx),
        );
      }
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
      _navVisible = true; // Default to visible
      if (_currentTab != i) _previousTab = _currentTab;
      _currentTab = i;
      _scanActiveNotifier.value = i == 2;
      _importActiveNotifier.value = i == 4;
      _isScanInResultsMode.value = false;

      _navCtrl.reverse(); // Default to showing
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
                    final isScanning = (_currentTab == 2 && !inResultsMode);
                    final hideNav = isScanning || isImportLoading;
                    return Stack(
                      children: [
                        // Peek handle – only shown when nav is hidden AND not in results mode
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeInOut,
                          bottom: (_currentTab == 2 && !inResultsMode)
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

                        // Custom Bottom Navigation Bar overlaid entirely on top
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: SlideTransition(
                            position: _navSlide,
                            child: hideNav
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
    return Container(
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
                  onTap: (idx) {
                    onTap(idx);
                  },
                ),
                _NavItem(
                  iconKey: importTabKey,
                  icon: Icons.file_download_outlined,
                  activeIcon: Icons.file_download_rounded,
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
                      : const Color(0xFFCC3333),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (currentIndex == 2
                                  ? Colors.black87
                                  : const Color(0xFFCC3333))
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
              key:
                  iconKey, // Use iconKey here to avoid duplicate GlobalKey on _NavItem itself
              size: 24.sp,
              color: active ? const Color(0xFFCC3333) : const Color(0xFF8E8E8E),
            ),
            SizedBox(height: 3.h),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 12.sp,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
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
class _HomeTab extends StatelessWidget {
  final VoidCallback? onRefresh;
  final VoidCallback? onScanTap;
  final GlobalKey? firstCookbookKey;
  const _HomeTab({this.onRefresh, this.onScanTap, this.firstCookbookKey});

  void _goViewAll(BuildContext ctx, ViewAllType type, String title) {
    Navigator.pushNamed(
      ctx,
      AppRoutes.viewAll,
      arguments: {'type': type, 'title': title},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            SizedBox(height: 14.h),
            const _SearchBar(),
            SizedBox(height: 10.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 40.h, top: 10.h),
                children: [
                  _SectionRow(
                    title: 'Your Cookbooks',
                    onViewAll: () {
                      _goViewAll(context, ViewAllType.cookbooks, 'Cookbooks');
                    },
                  ),
                  SizedBox(height: 12.h),
                  _CookbooksRow(
                    onRefresh: onRefresh,
                    firstCookbookKey: firstCookbookKey,
                  ),
                  SizedBox(height: 26.h),
                  ValueListenableBuilder<List<Recipe>?>(
                    valueListenable: RecipeService.instance.myRecipesNotifier,
                    builder: (context, recipes, _) {
                      if (recipes == null || recipes.isEmpty) return const SizedBox.shrink();
                      
                      final hasSuggestions = recipes.any((r) => r.isSuggested);
                      final title = hasSuggestions
                          ? 'Suggested Recipes'
                          : 'Saved Recipes';
                      return _SectionRow(
                        title: title,
                        onViewAll: () => _goViewAll(
                          context,
                          hasSuggestions
                              ? ViewAllType.savedRecipes
                              : ViewAllType.savedRecipes, // Keeps same type for now
                          title,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12.h),
                  _SavedRecipesGrid(onScanTap: onScanTap),
                  SizedBox(height: 30.h),

                  // Bottom Scan CTA
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC83A2D), Color(0xFFE57373)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC83A2D).withValues(alpha: 0.3),
                            blurRadius: 12.r,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Search a recipe or scan",
                                  style: TextStyle(
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18.sp,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  "Let our AI find the best recipes for you",
                                  style: TextStyle(
                                    fontFamily: 'SF Pro',
                                    fontSize: 13.sp,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: onScanTap,
                            child: Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Icon(
                                Icons.qr_code_scanner_rounded,
                                color: const Color(0xFFC83A2D),
                                size: 24.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 100.h), // Extra space for nav
                  // Dynamic bottom spacer for keyboard
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
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
                  'assets/images/logo4.png',
                  height: 20.h,
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
  const _SearchBar();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: const AppSearchField(),
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
                  fontSize: 20.sp,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'View All',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: const Color(0xFFCC3333),
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
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: const Color(0xFFC83A2D), width: 1.5),
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
                            "New cookbook",
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
                                Text('0 Recipes', style: TextStyle(fontSize: 12.sp)),
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
                    key: i == 1 ? widget.firstCookbookKey : null,
                    width: 180.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: CookbookCover(cookbook: cb)),
                        SizedBox(height: 7.h),
                        Text(
                          cb.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
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
                                fontSize: 12.sp,
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
// SAVED RECIPES (home 2-col grid, uses shared RecipeCard)
// ══════════════════════════════════════════════════════════════════════════════
class _SavedRecipesGrid extends StatefulWidget {
  final VoidCallback? onScanTap;
  const _SavedRecipesGrid({this.onScanTap});
  @override
  State<_SavedRecipesGrid> createState() => _SavedRecipesGridState();
}

class _SavedRecipesGridState extends State<_SavedRecipesGrid> {
  @override
  void initState() {
    super.initState();
    if (RecipeService.instance.myRecipesNotifier.value == null) {
      RecipeService.instance.getMyRecipes();
    }
  }

  void _loadData() {
    RecipeService.instance.getMyRecipes();
  }

  @override
  void didUpdateWidget(_SavedRecipesGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Recipe>?>(
      valueListenable: RecipeService.instance.myRecipesNotifier,
      builder: (context, recipes, _) {
        if (recipes == null) {
          return SizedBox(
            height: 200.h,
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFFCC3333)),
            ),
          );
        }

        // Filter expired suggestions and limit to 4 if suggesting
        // Requirement: suggestions visible until user saves recipes
        final hasSavedRecipes = recipes.any((r) => !r.isSuggested);

        List<Recipe> filteredRecipes = recipes.where((r) {
          if (r.isSuggested) {
            if (hasSavedRecipes)
              return false; // Hide suggestions if user has saved recipes
            if (r.expiresAt != null && r.expiresAt!.isBefore(DateTime.now()))
              return false; // Filter expired
          }
          return true;
        }).toList();

        final isSuggesting =
            filteredRecipes.isNotEmpty &&
            filteredRecipes.every((r) => r.isSuggested);
        if (isSuggesting) {
          filteredRecipes = filteredRecipes.take(4).toList();
        }

        if (filteredRecipes.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredRecipes.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14.h,
              crossAxisSpacing: 14.w,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (ctx, i) {
              final r = filteredRecipes[i];
              return RecipeCard(
                recipe: r,
                onHeartTap: () async {
                  try {
                    await RecipeService.instance.toggleFavorite(r.id);
                    // Just refresh this specific list if needed, or rely on future reload
                    setState(() => _loadData());
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
                  // Refresh on return in case it was unfavorited or deleted
                  setState(() => _loadData());
                },
              );
            },
          ),
        );
      },
    );
  }
}
