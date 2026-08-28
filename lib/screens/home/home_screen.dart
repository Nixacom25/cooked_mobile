import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/scan_animation_overlay.dart';
import '../explore_screen.dart';
import '../grocery_screen.dart';
import '../import_screen.dart';
import '../scan_screen.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/app_top_header.dart';
import '../../widgets/saved_recipe_card.dart';
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

  static final ValueNotifier<int> activeTabNotifier = ValueNotifier<int>(0);

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
        onExploreTap: () => _switchTab(1),
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
    precacheImage(const AssetImage('assets/images/home.png'), context);
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

    HomeScreen.activeTabNotifier.value = i;

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

            // Test animation FAB raised above bottom nav
            if (kDebugMode && _currentTab == 0)
              Positioned(
                right: 16.w,
                bottom: 95.h,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          body: ScanAnimationOverlay(
                            showTestControls: true,
                            imagePath: 'assets/images/fridge_mockup.png',
                            detectedIngredients: [
                              RecipeIngredient(
                                id: 'i1',
                                name: "Tomates",
                                amount: 2.0,
                                unit: "pcs",
                                quantity: "2 pcs",
                                image: "assets/images/ing1.png",
                              ),
                              RecipeIngredient(
                                id: 'i2',
                                name: "Oignons",
                                amount: 1.0,
                                unit: "pc",
                                quantity: "1 pc",
                                image: "assets/images/ing2.png",
                              ),
                              RecipeIngredient(
                                id: 'i3',
                                name: "Ail",
                                amount: 3.0,
                                unit: "gousses",
                                quantity: "3 gousses",
                                image: "assets/images/ing3.png",
                              ),
                              RecipeIngredient(
                                id: 'i4',
                                name: "Poulet",
                                amount: 500.0,
                                unit: "g",
                                quantity: "500 g",
                                image: "assets/images/ing4.png",
                              ),
                              RecipeIngredient(
                                id: 'i5',
                                name: "Carottes",
                                amount: 2.0,
                                unit: "pcs",
                                quantity: "2 pcs",
                                image: "assets/images/ing5.png",
                              ),
                            ],
                            generatedRecipes: [
                              Recipe(
                                id: 'r1',
                                name: 'Poulet rôti aux légumes',
                                cookTime: 45,
                                kcal: 450,
                                steps: [],
                                equipment: [],
                                isPublic: true,
                                isFavorite: false,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                                image: 'assets/images/plat1.png',
                                ingredients: [],
                              ),
                              Recipe(
                                id: 'r2',
                                name: 'Salade fraîcheur',
                                cookTime: 0,
                                kcal: 200,
                                steps: [],
                                equipment: [],
                                isPublic: true,
                                isFavorite: false,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                                image: 'assets/images/plat2.png',
                                ingredients: [],
                              ),
                              Recipe(
                                id: 'r3',
                                name: 'Mijoté de poulet',
                                cookTime: 60,
                                kcal: 550,
                                steps: [],
                                equipment: [],
                                isPublic: true,
                                isFavorite: false,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                                image: 'assets/images/plat3.png',
                                ingredients: [],
                              ),
                            ],
                            onAnimationComplete: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Icon(Icons.animation),
                ),
              ),

            ValueListenableBuilder<bool>(
              valueListenable: _isScanInResultsMode,
              builder: (context, inResultsMode, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _isImportLoading,
                  builder: (context, isImportLoading, _) {
                    final isScanningTab = (_currentTab == 2);
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

// ── Floating pill bottom nav ───────────────────────────────────────────────────
// ── Helper Path Generator for Smooth Wave Notched Pill ──────────────────────
// ── Helper Path Generator for Smooth Wave Notched Pill ──────────────────────
Path _buildNotchedPillPath(Size size) {
  final double w = size.width;
  final double h = size.height;
  final double r = 28.r;

  final double centerX = w / 2;
  // Largeur et profondeur de l'encoche adaptées au FAB
  final double notchRadius = 32.r;
  final double notchDepth = 30.h;

  final Path path = Path();
  path.moveTo(r, 0);

  // Ligne jusqu'à l'épaule gauche de l'encoche
  path.lineTo(centerX - notchRadius - 12.w, 0);

  // Courbe descendante fluide vers le creux
  path.cubicTo(
    centerX - notchRadius + 2.w,
    0,
    centerX - notchRadius * 0.75,
    notchDepth,
    centerX,
    notchDepth,
  );

  // Courbe remontante fluide
  path.cubicTo(
    centerX + notchRadius * 0.75,
    notchDepth,
    centerX + notchRadius - 2.w,
    0,
    centerX + notchRadius + 12.w,
    0,
  );

  // Bord haut droit
  path.lineTo(w - r, 0);
  path.arcToPoint(Offset(w, r), radius: Radius.circular(r));

  // Bord droit
  path.lineTo(w, h - r);
  path.arcToPoint(Offset(w - r, h), radius: Radius.circular(r));

  // Bord bas
  path.lineTo(r, h);
  path.arcToPoint(Offset(0, h - r), radius: Radius.circular(r));

  // Bord gauche
  path.lineTo(0, r);
  path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));

  path.close();
  return path;
}

// ── Notched Pill Custom Clipper (for BackdropFilter) ──────────────────────────
class NotchedPillClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return _buildNotchedPillPath(size);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

// ── Notched Pill Custom Painter (Figma Spec Compliant) ──────────────────────
class NotchedPillPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Path path = _buildNotchedPillPath(size);

    // Drop shadow under bottom nav pill
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(path.shift(const Offset(0, -2)), shadowPaint);

    // Linear Gradient fill: #F8F8F8 -> #F6F6F6
    final Paint fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF8F8F8),
          Color(0xFFF6F6F6),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Border 1px: #39404E 8%
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF39404E).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Notched Pill Background with Blur (Blur 25px) & CustomPainter
            ClipPath(
              clipper: NotchedPillClipper(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: CustomPaint(
                  size: Size(double.infinity, 66.h),
                  painter: NotchedPillPainter(),
                  child: SizedBox(
                    height: 66.h,
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
                        // Center column for Scan Recipe label
                        Expanded(
                          child: GestureDetector(
                            onTap: onCameraTap,
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 6.h),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Scan Recipe',
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      fontSize: 11.sp,
                                      fontWeight: currentIndex == 2
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: currentIndex == 2
                                          ? const Color(0xFFC31E26)
                                          : const Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
                ),
              ),
            ),

            // Red Camera Floating Circle FAB (parfaitement logé dans la découpe)
            Positioned(
              top: -28.h, // Sort le cercle de moitié au-dessus de la barre
              child: GestureDetector(
                onTap: onCameraTap,
                child: Container(
                  key: scanTabKey,
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC31E26),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC31E26).withValues(alpha: 0.28),
                        blurRadius: 10.r,
                        offset: Offset(0, 5.h),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.crop_free_rounded,
                        size: 34.sp,
                        color: Colors.white,
                      ),
                      Icon(
                        Icons.camera_alt_rounded,
                        size: 18.sp,
                        color: Colors.white,
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
                    active ? const Color(0xFFC31E26) : const Color(0xFF334155),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 12.sp,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                color: active
                    ? const Color(0xFFC31E26)
                    : const Color(0xFF334155),
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
  final VoidCallback? onExploreTap;
  final GlobalKey? firstCookbookKey;
  final GlobalKey<_CookbooksRowState>? cookbooksRowKey;
  const _HomeTab({
    this.onRefresh,
    this.onScanTap,
    this.onImportTap,
    this.onExploreTap,
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
      color: const Color(0xFFF0F1F3),
      child: ValueListenableBuilder<String>(
        valueListenable: _searchQueryNotifier,
        builder: (context, searchQuery, _) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: const AppTopHeader(),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickySearchHeaderDelegate(
                  searchQueryNotifier: _searchQueryNotifier,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 150.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (searchQuery.isEmpty) ...[
                      // ── TOP WHITE CONTAINER CARD (BOTTOM HALF) ──
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(24.r),
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sous-carte 1: You've saved
                            const _SavingsCard(),
                            SizedBox(height: 12.h),

                            // Sous-carte 2: Your Cookbooks
                            ValueListenableBuilder<List<Cookbook>?>(
                              valueListenable:
                                  CookbookService.instance.myCookbooksNotifier,
                              builder: (context, cookbooks, _) {
                                final count = cookbooks?.length ?? 0;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SectionRow(
                                      title: 'Your Cookbooks',
                                      onViewAll: count > 3
                                          ? () => _goViewAll(
                                                context,
                                                ViewAllType.cookbooks,
                                                'Cookbooks',
                                              )
                                          : null,
                                    ),
                                    SizedBox(height: 12.h),
                                    (cookbooks == null || cookbooks.isEmpty)
                                        ? _EmptyCookbookCard(
                                            firstCookbookKey: widget.firstCookbookKey,
                                            onRefresh: widget.onRefresh,
                                          )
                                        : _PopulatedCookbooksLayout(
                                            cookbooks: cookbooks,
                                            onRefresh: widget.onRefresh,
                                          ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // ── RECENTLY VIEWED ──
                      ValueListenableBuilder<List<Recipe>>(
                        valueListenable: HistoryService.instance.recentlyViewedNotifier,
                        builder: (context, recent, _) {
                          if (recent.isEmpty) return const SizedBox.shrink();
                          final displayRecent = recent.take(10).toList();
                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24.r),
                                ),
                                padding: EdgeInsets.all(16.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                    _CircularRecipeAvatarRow(
                                      recipes: displayRecent,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16.h),
                            ],
                          );
                        },
                      ),

                      // ── SUGGESTED FOR YOU ──
                      ValueListenableBuilder<List<Recipe>?>(
                        valueListenable: RecipeService.instance.homeSuggestionsNotifier,
                        builder: (context, suggestions, _) {
                          final list = suggestions ?? [];
                          if (list.isEmpty) return const SizedBox.shrink();
                          final displaySuggestions = list.take(10).toList();
                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24.r),
                                ),
                                padding: EdgeInsets.all(16.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SectionRow(
                                      title: 'Suggested for you',
                                      onViewAll: list.length > 5
                                          ? () => _goViewAll(
                                                context,
                                                ViewAllType.explore,
                                                'Suggested for you',
                                              )
                                          : null,
                                    ),
                                    SizedBox(height: 12.h),
                                    _CircularRecipeAvatarRow(
                                      recipes: displaySuggestions,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16.h),
                            ],
                          );
                        },
                      ),

                      // ── SAVED RECIPES ──
                      ValueListenableBuilder<List<Recipe>?>(
                        valueListenable: RecipeService.instance.myRecipesNotifier,
                        builder: (context, recipes, _) {
                          final savedRecipes = (recipes ?? [])
                              .where((r) => !r.isInCookbook && !r.isSuggested)
                              .toList();

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  child: _SectionRow(
                                    title: 'Saved Recipes',
                                    onViewAll: savedRecipes.length > 5
                                        ? () => _goViewAll(
                                              context,
                                              ViewAllType.savedRecipes,
                                              'Saved Recipes',
                                            )
                                        : null,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                savedRecipes.isEmpty
                                    ? _EmptySavedRecipesCard(
                                        onBrowseTap: () => widget.onExploreTap?.call(),
                                      )
                                    : Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                                        child: _PopulatedSavedRecipesList(
                                          recipes: savedRecipes,
                                          searchQuery: searchQuery,
                                        ),
                                      ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16.h),

                      // ── HELP US IMPROVE COOKED ──
                      _FeedbackCard(
                        onTap: () => _showFeedbackModal(context),
                      ),
                    ] else ...[
                      // Search Active State
                      ValueListenableBuilder<List<Recipe>?>(
                        valueListenable: RecipeService.instance.myRecipesNotifier,
                        builder: (context, recipes, _) {
                          final allRecipes = recipes ?? [];
                          final filtered = allRecipes
                              .where((r) => r.name
                                  .toLowerCase()
                                  .contains(searchQuery.trim().toLowerCase()))
                              .toList();
                          return _PopulatedSavedRecipesList(
                            recipes: filtered,
                            searchQuery: searchQuery,
                          );
                        },
                      ),
                    ],
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
class _HomeHeaderWidget extends StatelessWidget {
  final double topPadding;

  const _HomeHeaderWidget({required this.topPadding});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F1F3),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: ValueListenableBuilder<Map<String, dynamic>?>(
            valueListenable: UserService.instance.currentUserNotifier,
            builder: (context, user, _) {
              String firstName = user?['firstname'] ?? 'Adeel';
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
                    radius: 16.r,
                    backgroundColor: const Color(0xFFCBD5E1),
                    backgroundImage: photoUrl != null
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl == null
                        ? Icon(Icons.person, color: Colors.white, size: 20.sp)
                        : null,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Hi, $firstName',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: const Color(0xFF0F172A),
                      size: 22.sp,
                    ),
                    onSelected: (val) async {
                      if (val == 'settings') {
                        Navigator.of(context).pushNamed(AppRoutes.profile);
                      } else if (val == 'logout') {
                        await AuthService.instance.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.login,
                            (route) => false,
                          );
                        }
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'settings',
                        child: Row(
                          children: [
                            Icon(Icons.settings_outlined, size: 18.sp, color: const Color(0xFF0F172A)),
                            SizedBox(width: 8.w),
                            Text('Settings', style: TextStyle(fontSize: 14.sp, fontFamily: 'Rubik')),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded, size: 18.sp, color: const Color(0xFFC31E26)),
                            SizedBox(width: 8.w),
                            Text('Logout', style: TextStyle(fontSize: 14.sp, fontFamily: 'Rubik', color: const Color(0xFFC31E26))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Sticky Search Header Delegate ──────────────────────────────────────────────
class _StickySearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final ValueNotifier<String> searchQueryNotifier;

  _StickySearchHeaderDelegate({required this.searchQueryNotifier});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isPinned = shrinkOffset > 0;
    return Container(
      color: const Color(0xFFF0F1F3),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isPinned
              ? BorderRadius.circular(24.r)
              : BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: isPinned
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'What would you like to cook today?',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w800,
                fontSize: 19.sp,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 10.h),
            AppSearchField(
              backgroundColor: const Color(0xFFF1F3F5),
              borderColor: const Color(0xFFF1F3F5),
              onChanged: (val) {
                searchQueryNotifier.value = val;
              },
              hintText: 'Search your recipes',
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 125.h;

  @override
  double get minExtent => 125.h;

  @override
  bool shouldRebuild(covariant _StickySearchHeaderDelegate oldDelegate) {
    return false;
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
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
              color: const Color(0xFF0F172A),
            ),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View All',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                  color: const Color(0xFFC31E26),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Empty Cookbook Card ────────────────────────────────────────────────────────
class _EmptyCookbookCard extends StatelessWidget {
  final GlobalKey? firstCookbookKey;
  final VoidCallback? onRefresh;

  const _EmptyCookbookCard({this.firstCookbookKey, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: firstCookbookKey,
      onTap: () async {
        final result = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const CookbookFormModal(),
        );
        if (result != null) {
          CookbookService.instance.getMyCookbooks();
          onRefresh?.call();
        }
      },
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: const Color(0xFFC31E26),
          borderRadius: 20.r,
          dash: 5,
          gap: 4,
          strokeWidth: 1.2,
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF3E6),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52.r,
                height: 52.r,
                decoration: const BoxDecoration(
                  color: Color(0xFFC31E26),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 30.sp,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'Start building your cookbook',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w700,
                  fontSize: 17.sp,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Save your favorite recipes and\nkeep them all in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 14.sp,
                  color: const Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Populated Cookbooks Layout ──────────────────────────────────────────────────
class _PopulatedCookbooksLayout extends StatelessWidget {
  final List<Cookbook> cookbooks;
  final VoidCallback? onRefresh;

  const _PopulatedCookbooksLayout({
    required this.cookbooks,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (cookbooks.isEmpty) return const SizedBox.shrink();

    final Cookbook mainCookbook = cookbooks[0];
    final Cookbook? secondCookbook = cookbooks.length > 1 ? cookbooks[1] : null;
    final Cookbook? thirdCookbook = cookbooks.length > 2 ? cookbooks[2] : null;

    return SizedBox(
      height: 220.h,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: _CookbookCardTile(
              cookbook: mainCookbook,
              isMain: true,
              onRefresh: onRefresh,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Expanded(
                  child: secondCookbook != null
                      ? _CookbookCardTile(
                          cookbook: secondCookbook,
                          isMain: false,
                          onRefresh: onRefresh,
                        )
                      : _AddCookbookCardTile(onRefresh: onRefresh),
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: thirdCookbook != null
                      ? _CookbookCardTile(
                          cookbook: thirdCookbook,
                          isMain: false,
                          onRefresh: onRefresh,
                        )
                      : _AddCookbookCardTile(onRefresh: onRefresh),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCookbookCardTile extends StatelessWidget {
  final VoidCallback? onRefresh;

  const _AddCookbookCardTile({this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const CookbookFormModal(),
        );
        if (result != null) {
          CookbookService.instance.getMyCookbooks();
          onRefresh?.call();
        }
      },
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: const Color(0xFFC31E26),
          borderRadius: 20.r,
          dash: 4,
          gap: 3,
          strokeWidth: 1.2,
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF3E6),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: const BoxDecoration(
                  color: Color(0xFFC31E26),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Add cookbook',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CookbookCardTile extends StatelessWidget {
  final Cookbook cookbook;
  final bool isMain;
  final VoidCallback? onRefresh;

  const _CookbookCardTile({
    required this.cookbook,
    required this.isMain,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.cookbookDetail,
          arguments: {'cookbook': cookbook},
        );
        if (result == true) {
          CookbookService.instance.getMyCookbooks();
          onRefresh?.call();
        }
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF3E6),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: isMain
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: CookbookCover(cookbook: cookbook),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    cookbook.name.isEmpty
                        ? cookbook.name
                        : cookbook.name[0].toUpperCase() +
                            cookbook.name.substring(1).toLowerCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu_rounded,
                        size: 14.sp,
                        color: const Color(0xFF475569),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${cookbook.recipes.length} Recipes',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 13.sp,
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18.sp,
                        color: const Color(0xFF475569),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOverlappingThumbnails(cookbook),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cookbook.name.isEmpty
                            ? cookbook.name
                            : cookbook.name[0].toUpperCase() +
                                cookbook.name.substring(1).toLowerCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant_menu_rounded,
                            size: 13.sp,
                            color: const Color(0xFF475569),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${cookbook.recipes.length} Recipes',
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 12.sp,
                              color: const Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16.sp,
                            color: const Color(0xFF475569),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOverlappingThumbnails(Cookbook cb) {
    final List<String> images = cb.recipes
        .map((r) => r.image)
        .where((img) => img != null && img.isNotEmpty)
        .cast<String>()
        .toList();

    if (images.isEmpty) {
      return Container(
        width: 32.r,
        height: 32.r,
        decoration: const BoxDecoration(
          color: Color(0xFFE2E8F0),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.menu_book_rounded, size: 16.sp, color: const Color(0xFF475569)),
      );
    }

    return SizedBox(
      height: 34.r,
      child: Stack(
        children: List.generate(images.take(3).length, (idx) {
          return Positioned(
            left: idx * 18.w,
            child: Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFAF3E6), width: 2),
              ),
              child: ClipOval(
                child: images[idx].startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: images[idx],
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Image.asset('assets/images/recipes.png', fit: BoxFit.cover),
                      )
                    : Image.asset(images[idx], fit: BoxFit.cover),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Circular Recipe Avatars ─────────────────────────────────────────────────────
class _CircularRecipeAvatarRow extends StatelessWidget {
  final List<Recipe> recipes;

  const _CircularRecipeAvatarRow({required this.recipes});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 105.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: recipes.length,
        separatorBuilder: (_, __) => SizedBox(width: 14.w),
        itemBuilder: (context, i) {
          final r = recipes[i];
          return GestureDetector(
            onTap: () {
              HistoryService.instance.addToHistory(r);
              Navigator.pushNamed(
                context,
                AppRoutes.recipeDetail,
                arguments: {'recipe': r},
              );
            },
            child: SizedBox(
              width: 70.w,
              child: Column(
                children: [
                  Container(
                    width: 62.r,
                    height: 62.r,
                    padding: EdgeInsets.all(2.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFC31E26),
                        width: 2.2,
                      ),
                    ),
                    child: ClipOval(
                      child: _buildThumbnail(r.image),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    r.name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                      color: const Color(0xFF0F172A),
                      height: 1.15,
                    ),
                  ),
                ],
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
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: const Color(0xFFEEEEEE)),
        errorWidget: (_, __, ___) => Image.asset(fallback, fit: BoxFit.cover),
      );
    }
    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(fallback, fit: BoxFit.cover),
    );
  }
}

// ── Empty Saved Recipes Card ────────────────────────────────────────────────────
class _EmptySavedRecipesCard extends StatefulWidget {
  final VoidCallback? onBrowseTap;

  const _EmptySavedRecipesCard({this.onBrowseTap});

  @override
  State<_EmptySavedRecipesCard> createState() => _EmptySavedRecipesCardState();
}

class _EmptySavedRecipesCardState extends State<_EmptySavedRecipesCard> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent / 2);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth;
            final itemSize = (cardWidth * 0.42).clamp(120.0, 160.0);
            final gap = 12.w;

            return SizedBox(
              height: itemSize,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildCollageThumb('assets/images/plat1.png', size: itemSize),
                    SizedBox(width: gap),
                    _buildCollageThumb('assets/images/plat2.png', size: itemSize),
                    SizedBox(width: gap),
                    _buildCollageThumb('assets/images/plat3.png', size: itemSize),
                  ],
                ),
              ),
            );
          },
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              Text(
                'No saved recipes yet',
                style: GoogleFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Explore our recipes and save your favorites\nto build your personal collection.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: const Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: widget.onBrowseTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Browse Recipes',
                      style: GoogleFonts.rubik(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                        color: const Color(0xFFC31E26),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: const Color(0xFFC31E26),
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCollageThumb(String asset, {required double size}) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFF1F5F9),
            child: Icon(Icons.restaurant, color: const Color(0xFF94A3B8), size: 30.sp),
          ),
        ),
      ),
    );
  }
}

// ── Populated Saved Recipes List ────────────────────────────────────────────────
class _PopulatedSavedRecipesList extends StatelessWidget {
  final List<Recipe> recipes;
  final String searchQuery;

  const _PopulatedSavedRecipesList({
    required this.recipes,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    List<Recipe> displayList = List<Recipe>.from(recipes);
    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      displayList = displayList
          .where((r) => r.name.toLowerCase().contains(query))
          .toList();
    } else {
      displayList = displayList.take(5).toList();
    }

    if (displayList.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayList.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (ctx, i) {
        final r = displayList[i];
        return SavedRecipeCard(
          recipe: r,
          onPinTap: () {
            RecipeService.instance.togglePin(r.id);
          },
          onTap: () {
            HistoryService.instance.addToHistory(r);
            Navigator.pushNamed(
              ctx,
              AppRoutes.recipeDetail,
              arguments: {'recipe': r, 'isPreview': false},
            );
          },
        );
      },
    );
  }
}

// ── Feedback Card ──────────────────────────────────────────────────────────────
class _FeedbackCard extends StatelessWidget {
  final VoidCallback onTap;

  const _FeedbackCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Help us improve Cooked',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w800,
              fontSize: 17.sp,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Share your thoughts, ideas, or anything that could make your experience better.',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 13.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC31E26),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Send feedback',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dashed Border Painter ──────────────────────────────────────────────────────
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dash = 5.0,
    this.gap = 4.0,
    this.borderRadius = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dash),
          Offset.zero,
        );
        distance += dash + gap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color || borderRadius != oldDelegate.borderRadius;
}

void _showFeedbackModal(BuildContext context) {
  final TextEditingController feedbackCtrl = TextEditingController();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 30.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Help us improve Cooked',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w800,
                fontSize: 18.sp,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Share your thoughts, ideas, or anything that could make your experience better.',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 13.sp,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: feedbackCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your feedback here...',
                hintStyle: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 14.sp,
                  color: const Color(0xFF94A3B8),
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: Color(0xFFC31E26)),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  if (feedbackCtrl.text.trim().isNotEmpty) {
                    Navigator.pop(context);
                    IosToast.show(
                      context,
                      message: 'Thank you for your feedback!',
                      type: ToastType.success,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC31E26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Submit Feedback',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
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
  Timer? _skeletonTimer;
  bool _isPolling = true;
  bool _showSkeletons = true;

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();

    // Limit skeleton display to 5 seconds
    _skeletonTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showSkeletons = false;
        });
      }
    });

    // Polling: If suggestions are empty, check every 10 seconds for 2 minutes
    _startPolling();
  }

  @override
  void dispose() {
    _skeletonTimer?.cancel();
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

        // Handle loading/skeleton state vs timeout
        if (displayList == null) {
          if (!_showSkeletons) {
            // Skeletons timed out (5s), hide section but keep polling in background
            return const SizedBox.shrink();
          }
        } else if (displayList.isEmpty) {
          return const SizedBox.shrink();
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

    final currentSaved = RecipeService.instance.myRecipesNotifier.value ?? [];
    if (!currentSaved.any((item) => item.id == r.id)) {
      RecipeService.instance.myRecipesNotifier.value = [
        validatedRecipe,
        ...currentSaved,
      ];
    }

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
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
        final double displayAmount = totalSaved > 0 ? totalSaved : 14.0;

        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Align(
              alignment: Alignment.topCenter,
              heightFactor: _scaleAnimation.value < 0 ? 0.0 : _scaleAnimation.value,
              child: child,
            );
          },
          child: ScaleTransition(
            alignment: Alignment.center,
            scale: _scaleAnimation,
            child: Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF3E6),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.savingsDetails);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Your saved",
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          GestureDetector(
                            onTap: _dismissCard,
                            child: Container(
                              width: 24.r,
                              height: 24.r,
                              decoration: const BoxDecoration(
                                color: Color(0xFFC31E26),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "~\$${displayAmount.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 34.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "This month",
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "Comparing to ordered takeout.",
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


