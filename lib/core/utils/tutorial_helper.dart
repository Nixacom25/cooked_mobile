import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../services/tutorial_service.dart';
import '../../models/cookbook.dart';

class TutorialHelper {
  static TutorialCoachMark? _activeCoachMark;

  static void dismissCurrent() {
    if (_activeCoachMark != null) {
      _activeCoachMark!.finish();
      _activeCoachMark = null;
    }
  }

  static bool get isShowing => _activeCoachMark != null;

  static void showTutorial(
    BuildContext context, {
    required GlobalKey cookbookKey,
    required GlobalKey scanKey,
    required GlobalKey importKey,
    Cookbook? firstCookbook,
    Function(int)? onTabSwitch,
  }) {
    final service = TutorialService.instance;
    if (!service.isTutorialActive || isShowing) return;

    // Ensure we don't have overlapping tutorials
    dismissCurrent();

    final targets = _createTargets(
      context: context,
      cookbookKey: cookbookKey,
      scanKey: scanKey,
      importKey: importKey,
      currentStep: service.currentStep,
      onTabSwitch: onTabSwitch,
    );

    final allContextsReady = targets.every((target) {
      final key = target.keyTarget;
      return (key is GlobalKey && key.currentContext != null);
    });

    if (!allContextsReady) {
      debugPrint("TutorialHelper: Not all target contexts are ready yet.");
      return;
    }

    _activeCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.6,
      textSkip: "SKIP",
      paddingFocus: 10.r,
      focusAnimationDuration: const Duration(milliseconds: 500),
      unFocusAnimationDuration: const Duration(milliseconds: 500),
      onClickTarget: (target) {
        // Do nothing - user MUST click the "Next" button in the content
      },
      onClickOverlay: (target) {
        // Do nothing - user MUST click the "Next" button in the content
      },
      onSkip: () {
        service.completeHome();
        _activeCoachMark = null;
        return true;
      },
      onFinish: () async {
        await service.completeHome();
        _activeCoachMark = null;
      },
    );

    _activeCoachMark!.show(context: context);
  }

  // Specialized onboarding for Cookbook screen
  static void showCookbookOnboardingDialog(BuildContext context) {
    final service = TutorialService.instance;
    if (!service.isTutorialActive || service.currentStep != 0) return;

    // Ensure we don't have overlapping tutorials
    dismissCurrent();

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return const CookbookOnboardingModal();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(anim1),
            child: child,
          ),
        );
      },
    );
  }

  // Specialized onboarding for Scan screen
  static void showScanOnboardingDialog(
    BuildContext context, {
    Function(int)? onTabSwitch,
  }) {
    final service = TutorialService.instance;
    if (service.hasSeenScan) return;

    // Ensure we don't have overlapping tutorials
    dismissCurrent();

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return ScanOnboardingModal(onTabSwitch: onTabSwitch);
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(anim1),
            child: child,
          ),
        );
      },
    );
  }

  // Specialized onboarding for Import screen
  static void showImportOnboardingDialog(BuildContext context) {
    final service = TutorialService.instance;
    if (service.hasSeenImport) return;

    // Ensure we don't have overlapping tutorials
    dismissCurrent();

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return const ImportOnboardingModal();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(anim1),
            child: child,
          ),
        );
      },
    );
  }

  // Target clicking handled via _TutorialContent Next buttons

  static List<TargetFocus> _createTargets({
    required BuildContext context,
    required GlobalKey cookbookKey,
    required GlobalKey scanKey,
    required GlobalKey importKey,
    required int currentStep,
    Function(int)? onTabSwitch,
  }) {
    final List<TargetFocus> targets = [];

    // Step 1: Import Recipes (Image 1)
    targets.add(
      TargetFocus(
        identify: "import",
        keyTarget: importKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 30.r,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _TutorialContent(
                title: "Import Recipes",
                description: "Import recipes from TikTok,\nInstagram, or any Link",
                step: 1,
                totalSteps: 3,
                arrowAlignment: const Alignment(0.7, 1.0),
                isArrowPointingDown: true,
                onNext: () {
                  controller.next();
                },
                onSkip: () {
                  TutorialService.instance.completeHome();
                  controller.skip();
                },
              );
            },
          ),
        ],
      ),
    );

    // Step 2: Scan Ingredients (Image 2)
    targets.add(
      TargetFocus(
        identify: "scan",
        keyTarget: scanKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        radius: 35.r,
        paddingFocus: 5,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _TutorialContent(
                title: "Scan Ingredients",
                description: "Scan and get instant recipes",
                step: 2,
                totalSteps: 3,
                arrowAlignment: Alignment.bottomCenter,
                isArrowPointingDown: true,
                onNext: () {
                  controller.next();
                },
                onSkip: () {
                  TutorialService.instance.completeHome();
                  controller.skip();
                },
              );
            },
          ),
        ],
      ),
    );

    // Step 3: Your Cookbooks (Image 3)
    targets.add(
      TargetFocus(
        identify: "cookbook",
        keyTarget: cookbookKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 20.r,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _TutorialContent(
                title: "Your Cookbooks",
                description: "Save and organize your recipes here.",
                step: 3,
                totalSteps: 3,
                isLast: true,
                arrowAlignment: const Alignment(-0.6, 1.0),
                isArrowPointingDown: true,
                onNext: () {
                  TutorialService.instance.completeHome();
                  controller.next();
                },
                onSkip: () {
                  TutorialService.instance.completeHome();
                  controller.skip();
                },
              );
            },
          ),
        ],
      ),
    );

    return targets;
  }
}

// ── SCAN ONBOARDING MODAL widget ─────────────────────────────────────────────
class ScanOnboardingModal extends StatefulWidget {
  final Function(int)? onTabSwitch;
  const ScanOnboardingModal({super.key, this.onTabSwitch});

  @override
  State<ScanOnboardingModal> createState() => _ScanOnboardingModalState();
}

class _ScanOnboardingModalState extends State<ScanOnboardingModal> {
  int _currentPage = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Get the best scan',
      'image': 'assets/images/scan.png',
      'items': [
        {
          'svg': 'assets/icones/phones.svg',
          'text': 'Hold your phone steady',
        },
        {
          'svg': 'assets/icones/good.svg',
          'text': 'Use good lighting',
        },
        {
          'svg': 'assets/icones/cook.svg',
          'text': 'Make sure all ingredients are visible',
        },
      ],
      'btnText': 'Next',
      'showCard': false,
    },
    {
      'title': 'We instantly find your ingredients',
      'image': null,
      'items': [
        {
          'svg': 'assets/icones/scan1.svg',
          'text': 'Snap a photo of your ingredients',
        },
        {
          'svg': 'assets/icones/detect.svg',
          'text': 'We detect what\'s inside instantly',
        },
        {
          'svg': 'assets/icones/edit.svg',
          'text': 'Edit anything that looks off',
        },
      ],
      'btnText': 'Next',
      'showCard': true,
    },
    {
      'title': 'Ready to scan',
      'image': 'assets/images/scan.png',
      'items': [
        {
          'svg': 'assets/icones/scan1.svg',
          'text': 'Scan your fridge, pantry, or ingredients',
        },
        {
          'svg': 'assets/icones/result.svg',
          'text': 'Try different angles for better results',
        },
        {
          'svg': 'assets/icones/eyes.svg',
          'text': 'The more visible, the better your recipes',
        },
      ],
      'btnText': 'Scan Now',
      'showCard': false,
    },
  ];

  void _onNext() {
    if (_currentPage < _steps.length - 1) {
      setState(() => _currentPage++);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentPage];
    final String? imageAsset = step['image'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      body: Stack(
        children: [
          // Background with cross-fade (for slides 1 & 3 with food photo)
          if (imageAsset != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 260.h,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Image.asset(
                  imageAsset,
                  key: ValueKey(imageAsset),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

          // Soft overlay for photo readability
          if (imageAsset != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 260.h,
              child: Container(color: Colors.black.withValues(alpha: 0.1)),
            ),

          // Logo Top Left
          Positioned(
            top: 50.h,
            left: 20.w,
            child: Image.asset(
              'assets/images/logo2.png',
              width: 38.w,
              height: 38.w,
            ),
          ),

          // Skip button (white pill)
          Positioned(
            top: 50.h,
            right: 20.w,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
          ),

          // Step 2 Floating Ingredients Card
          if (step['showCard'] == true)
            Positioned(
              top: 110.h,
              left: 20.w,
              right: 20.w,
              child: _IngredientsDetectedCard(),
            ),

          // Bottom Content Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                24.w,
                28.h,
                24.w,
                (MediaQuery.of(context).padding.bottom > 0
                    ? MediaQuery.of(context).padding.bottom + 12.h
                    : 34.h),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title'] as String,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 18.h),

                    ...List.generate(
                      (step['items'] as List).length,
                      (i) {
                        final item = (step['items'] as List)[i] as Map<String, dynamic>;
                        final String? svgPath = item['svg'] as String?;
                        final IconData? iconData = item['icon'] as IconData?;

                        return Padding(
                          padding: EdgeInsets.only(bottom: 14.h),
                          child: Row(
                            children: [
                              if (svgPath != null)
                                SvgPicture.asset(
                                  svgPath,
                                  width: 22.sp,
                                  height: 22.sp,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFF475569),
                                    BlendMode.srcIn,
                                  ),
                                )
                              else if (iconData != null)
                                Icon(
                                  iconData,
                                  size: 22.sp,
                                  color: const Color(0xFF475569),
                                ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Text(
                                  item['text'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 16.h),

                    // Page Indicator (Active pill + inactive dots)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _steps.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: EdgeInsets.symmetric(horizontal: 3.w),
                          width: _currentPage == i ? 28.w : 6.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? const Color(0xFFC83A2D)
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Bottom Button
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: _onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC83A2D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26.r),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_currentPage == 2) ...[
                              Icon(
                                Icons.crop_free_rounded,
                                size: 20.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8.w),
                            ],
                            Text(
                              step['btnText'] as String,
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
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
        ],
      ),
    );
  }
}

// ── IMPORT ONBOARDING MODAL widget ───────────────────────────────────────────
class ImportOnboardingModal extends StatefulWidget {
  const ImportOnboardingModal({super.key});

  @override
  State<ImportOnboardingModal> createState() => _ImportOnboardingModalState();
}

class _ImportOnboardingModalState extends State<ImportOnboardingModal> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _platforms = [
    {
      'name': 'Instagram2',
      'asset': 'assets/icones/instagram.svg',
    },
    {
      'name': 'TikTok',
      'asset': 'assets/icones/tiktok2.svg',
    },
    {
      'name': 'YouTube',
      'asset': 'assets/icones/youtube.svg',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image scan.png
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 260.h,
            child: Image.asset(
              'assets/images/scan.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Soft overlay for photo readability
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 260.h,
            child: Container(color: Colors.black.withValues(alpha: 0.1)),
          ),

          // Logo Top Left
          Positioned(
            top: 50.h,
            left: 20.w,
            child: Image.asset(
              'assets/images/logo2.png',
              width: 38.w,
              height: 38.w,
            ),
          ),

          // Skip Button Top Right
          Positioned(
            top: 50.h,
            right: 20.w,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
          ),

          // Main White Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                24.w,
                20.h,
                24.w,
                (MediaQuery.of(context).padding.bottom > 0
                    ? MediaQuery.of(context).padding.bottom + 12.h
                    : 30.h),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 25,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Close (X) Button
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32.r,
                          height: 32.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18.sp,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Mockup Input Field
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        'Paste a recipe link...',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 14.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Mockup Import Button
                    Container(
                      width: double.infinity,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC83A2D),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Center(
                        child: Text(
                          'Import Recipes',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Title
                    Text(
                      'Import recipes from anywhere',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Bullets
                    const _ImportBulletItem(
                      svg: 'assets/icones/paste.svg',
                      icon: Icons.link_rounded,
                      text: 'Paste a link from TikTok, Instagram, or any site',
                    ),
                    const _ImportBulletItem(
                      svg: 'assets/icones/imports1.svg',
                      icon: Icons.share_outlined,
                      text: 'Or share directly from social apps to import instantly',
                    ),
                    const _ImportBulletItem(
                      svg: 'assets/icones/turn.svg',
                      icon: Icons.auto_awesome_rounded,
                      text: 'We\'ll turn it into a full recipe automatically',
                    ),
                    const _ImportBulletItem(
                      svg: 'assets/icones/coeur1.svg',
                      icon: Icons.favorite_border_rounded,
                      text: 'Save it to your cookbook',
                    ),

                    SizedBox(height: 20.h),

                    // Swipeable Diagram Flow Carousel
                    SizedBox(
                      height: 80.h,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemCount: _platforms.length,
                        itemBuilder: (context, index) {
                          return _ImportFlowDiagram(platform: _platforms[index]);
                        },
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Page Indicator (3 Dots)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _platforms.length,
                        (i) => GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              i,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: EdgeInsets.symmetric(horizontal: 3.w),
                            width: _currentPage == i ? 28.w : 6.w,
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: _currentPage == i
                                  ? const Color(0xFFC83A2D)
                                  : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportBulletItem extends StatelessWidget {
  final IconData? icon;
  final String? svg;
  final String text;
  const _ImportBulletItem({this.icon, this.svg, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          if (svg != null)
            SvgPicture.asset(
              svg!,
              width: 22.sp,
              height: 22.sp,
              colorFilter: const ColorFilter.mode(
                Color(0xFF475569),
                BlendMode.srcIn,
              ),
            )
          else if (icon != null)
            Icon(
              icon,
              size: 22.sp,
              color: const Color(0xFF475569),
            ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportFlowDiagram extends StatelessWidget {
  final Map<String, dynamic> platform;
  const _ImportFlowDiagram({required this.platform});

  @override
  Widget build(BuildContext context) {
    final String name = platform['name'] as String;
    final String asset = platform['asset'] as String;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Card 1: Platform
        _FlowCard(
          label: name,
          child: Container(
            width: 30.r,
            height: 30.r,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                asset,
                width: 16.r,
                height: 16.r,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
        ),
        Icon(Icons.arrow_forward_rounded, size: 12.sp, color: const Color(0xFFC83A2D)),

        // Card 2: Share
        _FlowCard(
          label: 'Share',
          child: SvgPicture.asset(
            'assets/icones/shared.svg',
            width: 26.w,
            height: 26.w,
            colorFilter: const ColorFilter.mode(Color(0xFFC83A2D), BlendMode.srcIn),
          ),
        ),
        Icon(Icons.arrow_forward_rounded, size: 12.sp, color: const Color(0xFFC83A2D)),

        // Card 3: Cooked
        _FlowCard(
          label: 'Cooked',
          child: Image.asset('assets/images/logoo.png', width: 34.w, height: 34.w),
        ),
        Icon(Icons.arrow_forward_rounded, size: 12.sp, color: const Color(0xFFC83A2D)),

        // Card 4: Import
        _FlowCard(
          label: 'Import',
          child: SvgPicture.asset(
            'assets/icones/import2.svg',
            width: 24.w,
            height: 24.w,
            colorFilter: const ColorFilter.mode(Color(0xFFC83A2D), BlendMode.srcIn),
          ),
        ),
      ],
    );
  }
}

class _FlowCard extends StatelessWidget {
  final Widget child;
  final String label;
  const _FlowCard({required this.child, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.w,
      height: 68.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          child,
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialContent extends StatelessWidget {
  final String title;
  final String description;
  final int step;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool isLast;
  final Alignment arrowAlignment;
  final bool isArrowPointingDown;

  const _TutorialContent({
    required this.title,
    required this.description,
    required this.step,
    required this.totalSteps,
    required this.onNext,
    required this.onSkip,
    this.isLast = false,
    this.arrowAlignment = Alignment.bottomCenter,
    this.isArrowPointingDown = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isArrowPointingDown)
          _TrianglePointer(
            isPointingDown: false,
            alignment: arrowAlignment,
          ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title & Step Count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '$step/$totalSteps',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              // Description
              Text(
                description,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
              SizedBox(height: 20.h),

              // Action Buttons Row (Skip & Next)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip Pill Button
                  GestureDetector(
                    onTap: onSkip,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),

                  // Next Pill Button
                  GestureDetector(
                    onTap: onNext,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC83A2D),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Next',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isArrowPointingDown)
          _TrianglePointer(
            isPointingDown: true,
            alignment: arrowAlignment,
          ),
      ],
    );
  }
}

class _TrianglePointer extends StatelessWidget {
  final bool isPointingDown;
  final Alignment alignment;

  const _TrianglePointer({
    required this.isPointingDown,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: CustomPaint(
          size: Size(18.w, 12.h),
          painter: _TrianglePainterCanvas(isPointingDown: isPointingDown),
        ),
      ),
    );
  }
}

class _TrianglePainterCanvas extends CustomPainter {
  final bool isPointingDown;
  _TrianglePainterCanvas({required this.isPointingDown});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    if (isPointingDown) {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CookbookOnboardingModal extends StatefulWidget {
  const CookbookOnboardingModal({super.key});

  @override
  State<CookbookOnboardingModal> createState() =>
      _CookbookOnboardingModalState();
}

class _CookbookOnboardingModalState extends State<CookbookOnboardingModal> {
  int _currentPage = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Your Organised Recipes',
      'items': [
        'Explore all recipes saved in this cookbook',
        'Quickly browse through categories',
        'Access your favorites in one tap',
      ],
      'image': 'assets/images/fond2.png',
      'illustration': 'assets/images/cookbook.png',
      'btnText': 'Next',
    },
    {
      'title': 'Complete Control',
      'items': [
        'Edit cookbook details anytime',
        'Add new recipes using the plus button',
        'Tap any recipe to see full details',
      ],
      'image': 'assets/images/fond3.png',
      'illustration': 'assets/images/logo2.png',
      'btnText': 'Explore Now',
    },
  ];

  void _onNext() {
    if (_currentPage < _steps.length - 1) {
      setState(() => _currentPage++);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentPage];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image fond_page.png
          Positioned.fill(
            child: Image.asset(
              'assets/images/fond_page.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Close button
          Positioned(
            top: 50.h,
            right: 20.w,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 20.sp,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Logo Top Left
          Positioned(
            top: 50.h,
            left: 20.w,
            child: Image.asset(
              'assets/images/logo2.png',
              width: 40.w,
              height: 40.h,
            ),
          ),

          // Bottom Content
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: 0.5.sh),
              padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 40.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Steps Illustration
                    Center(
                      child: Image.asset(
                        step['illustration'],
                        height: 100.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      step['title'],
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // List items
                    ...List.generate(
                      step['items'].length,
                      (i) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18.sp,
                              color: const Color(0xFFC83A2D),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                step['items'][i],
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF555555),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(
                            _steps.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.only(right: 6.w),
                              width: _currentPage == i ? 18.w : 6.w,
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: _currentPage == i
                                    ? const Color(0xFFC83A2D)
                                    : const Color(0xFFFFD1D1),
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC83A2D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 32.w,
                              vertical: 12.h,
                            ),
                          ),
                          child: Text(
                            step['btnText'],
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientsDetectedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ingredients detected',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                'Edit',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFC83A2D),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF5E8),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              children: const [
                _IngredientDetectedRow(emoji: '🍅', name: 'Tomatoes'),
                Divider(color: Color(0xFFE2E8F0), height: 20),
                _IngredientDetectedRow(emoji: '🍗', name: 'Chicken breast'),
                Divider(color: Color(0xFFE2E8F0), height: 20),
                _IngredientDetectedRow(emoji: '🧄', name: 'Garlic'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientDetectedRow extends StatelessWidget {
  final String emoji;
  final String name;
  const _IngredientDetectedRow({required this.emoji, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: TextStyle(fontSize: 18.sp)),
        SizedBox(width: 10.w),
        Text(
          name,
          style: TextStyle(
            fontFamily: 'Rubik',
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
