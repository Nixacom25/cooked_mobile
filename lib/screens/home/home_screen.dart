import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/scheduler.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../routes/app_routes.dart';
import 'view_all_screen.dart';
import '../explore_screen.dart';
import '../grocery_screen.dart';
import '../import_screen.dart';
import '../scan_screen.dart';
import '../../core/api_config.dart';
import '../../widgets/app_search_field.dart';
import '../../services/recipe_service.dart';
import '../../services/cookbook_service.dart';
import '../../models/recipe.dart';
import '../../models/cookbook.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/red_button.dart';
import '../../widgets/cookbook_cover.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';

class HomeScreen extends StatefulWidget {
  final int initialTab;
  const HomeScreen({super.key, this.initialTab = 0});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
  final ValueNotifier<bool> _isScanInResultsMode = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _previousTab = 0;
    _navVisible = _currentTab != 2;
    _scanActiveNotifier.value = _currentTab == 2;

    _tabWidgets = [
      _HomeTab(
        onRefresh: () => setState(() {}),
        onScanTap: () => _switchTab(2),
      ),
      const ExploreScreen(),
      ScanScreen(
        isActiveNotifier: _scanActiveNotifier,
        isResultsModeNotifier: _isScanInResultsMode,
        onClose: () => _switchTab(_previousTab),
      ),
      const GroceryScreen(),
      const ImportScreen(),
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
  }

  @override
  void dispose() {
    _navCtrl.dispose();
    _scanActiveNotifier.dispose();
    _isScanInResultsMode.dispose();
    super.dispose();
  }

  void _switchTab(int i) {
    if (_scrollBusy) return;
    setState(() {
      if (_currentTab != i) _previousTab = _currentTab;
      _currentTab = i;
      _navVisible = i != 2;
      _scanActiveNotifier.value = i == 2;
      _isScanInResultsMode.value = false; // Reset results mode when switching tabs
      if (_navVisible) {
        _navCtrl.reverse();
      } else {
        _navCtrl.forward();
      }
    });
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
    if (_currentTab == 2) return false; // scan tab – ignore
    if (_scrollBusy) return false; // debounce
    if (notif is ScrollUpdateNotification) {
      final delta = notif.scrollDelta ?? 0;
      if (delta > 4 && _navVisible) {
        _scrollBusy = true;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _navVisible = false);
          _navCtrl.forward();
          _scrollBusy = false;
        });
      } else if (delta < -4 && !_navVisible) {
        _scrollBusy = true;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _navVisible = true);
          _navCtrl.reverse();
          _scrollBusy = false;
        });
      }
    }
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
                return Stack(
                  children: [
                    // Peek handle – only shown when nav is hidden AND not in results mode
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeInOut,
                      bottom: (_navVisible || inResultsMode) ? -60.h : 12.h,
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
                                  color: const Color(0xFFCC3333).withValues(alpha: 0.4),
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
                        child: inResultsMode
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
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
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
                  key: groceryTabKey,
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
                  key: importTabKey,
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

  const _NavItem({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
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
  const _HomeTab({
    this.onRefresh,
    this.onScanTap,
  });

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
        child: ListView(
          padding: EdgeInsets.only(bottom: 40.h),
          children: [
            const _Header(),
            SizedBox(height: 14.h),
            const _SearchBar(),
            SizedBox(height: 24.h),
            _SectionRow(
              title: 'Your Cookbooks',
              onViewAll: () {
                _goViewAll(context, ViewAllType.cookbooks, 'Cookbooks');
              },
            ),
            SizedBox(height: 12.h),
            _CookbooksRow(onRefresh: onRefresh),
            if (_homeRecent.isNotEmpty) ...[
              _SectionRow(
                title: 'Recently Viewed',
                onViewAll: () => _goViewAll(
                  context,
                  ViewAllType.recentlyViewed,
                  'Recently Viewed',
                ),
              ),
              SizedBox(height: 12.h),
              const _RecentlyViewedRow(),
            ],
            SizedBox(height: 26.h),
            _SectionRow(
              title: 'Saved Recipes',
              onViewAll: () => _goViewAll(
                context,
                ViewAllType.savedRecipes,
                'Saved Recipes',
              ),
            ),
            SizedBox(height: 12.h),
            _SavedRecipesGrid(
              onScanTap: onScanTap,
            ),
            SizedBox(height: 30.h),
            // Dynamic bottom spacer for keyboard
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
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
  String _name = '...';
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await UserService.instance.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _name = '${user['firstname'] ?? ''}'.trim();
        String? photo = user['profilePictureUrl'];
        if (photo != null && photo.isNotEmpty && !photo.startsWith('http')) {
          _photoUrl = '${ApiConfig.baseUrl}$photo';
        } else {
          _photoUrl = photo;
        }
      });
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 0),
      child: ValueListenableBuilder<Map<String, dynamic>?>(
        valueListenable: UserService.instance.currentUserNotifier,
        builder: (context, userMap, _) {
          final displayName = userMap?['firstname'] ?? _name;

          String? displayPhoto = _photoUrl;
          if (userMap != null && userMap['profilePictureUrl'] != null) {
            final photo = userMap['profilePictureUrl'].toString();
            if (photo.isNotEmpty) {
              displayPhoto = photo.startsWith('http')
                  ? photo
                  : '${ApiConfig.baseUrl}$photo';
            }
          }

          return Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                child: Container(
                  width: 46.w,
                  height: 46.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFD0D0D0),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: displayPhoto != null && displayPhoto.isNotEmpty
                      ? Image.network(
                          displayPhoto,
                          width: 46.w,
                          height: 46.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.person_rounded,
                            size: 32.sp,
                            color: const Color(0xFF888888),
                          ),
                        )
                      : Image.asset(
                          'assets/images/profile.png',
                          width: 45.w,
                          height: 45.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.person_rounded,
                            size: 32.sp,
                            color: const Color(0xFF888888),
                          ),
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Hi, ${displayName.isNotEmpty ? displayName : 'Guest'}',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w800,
                    fontSize: 22.sp,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
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
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: const AppSearchField(),
    );
  }
}

// ── Section row ────────────────────────────────────────────────────────────────
class _SectionRow extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  const _SectionRow({
    required this.title,
    this.onViewAll,
  });
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
  const _CookbooksRow({this.onRefresh});

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

        if (cookbooks.isEmpty) {
          return Container(
            height: 140.h,
            margin: EdgeInsets.symmetric(horizontal: 18.w),
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "You don't have any cookbooks yet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    color: const Color(0xFF6B7280),
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: 160.w,
                  height: 36.h,
                  child: RedButton(
                    label: 'Create a cookbook',
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
                  ),
                ),
              ],
            ),
          );
        }

        return SizedBox(
          height: 188.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            itemCount: cookbooks.length,
            itemBuilder: (_, i) {
              final cb = cookbooks[i];
              return Padding(
                padding: EdgeInsets.only(
                  right: i < cookbooks.length - 1 ? 14 : 0,
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
                    width: 158.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CookbookCover(cookbook: cb),
                        ),
                        SizedBox(height: 7.h),
                        Text(
                          cb.name.toUpperCase(),
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
// RECENTLY VIEWED (home horizontal row)
// ══════════════════════════════════════════════════════════════════════════════
const _homeRecent = [];

class _RecentlyViewedRow extends StatelessWidget {
  const _RecentlyViewedRow();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        itemCount: _homeRecent.length,
        itemBuilder: (_, i) {
          final (img, name, color) = _homeRecent[i];
          return Padding(
            padding: EdgeInsets.only(
              right: i < _homeRecent.length - 1 ? 12 : 0,
            ),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.recipeDetail,
                arguments: {
                  'img': img,
                  'name': name,
                  'time': '15 min',
                  'kcal': '250 kcal',
                },
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 8.h,
                ),
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
                        color: const Color(0xFFE1E0DD),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        img,
                        width: 38.w,
                        height: 38.h,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFEEEEEE),
                          child: Center(
                            child: Icon(
                              Icons.fastfood_rounded,
                              size: 42.sp,
                              color: const Color(0xFFCCCCCC),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w800,
                        fontSize: 14.sp,
                        color: const Color(0xFF1A1A1A),
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

        if (recipes.isEmpty) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Text(
                  "You don't have any saved recipes yet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    color: const Color(0xFF6B7280),
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: 180.w,
                  height: 44.h,
                  child: RedButton(
                    label: 'Scan',
                    onTap: widget.onScanTap ?? () {},
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recipes.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14.h,
              crossAxisSpacing: 14.w,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (ctx, i) {
              final r = recipes[i];
              return RecipeCard(
                recipe: r,
                onHeartTap: () async {
                  try {
                    await RecipeService.instance.toggleFavorite(r.id);
                    // Just refresh this specific list if needed, or rely on future reload
                    setState(() => _loadData());
                  } catch (e) {
                    IosToast.show(ctx, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
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
