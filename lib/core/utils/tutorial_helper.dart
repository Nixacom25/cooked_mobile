import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../services/tutorial_service.dart';
import '../../models/cookbook.dart';

class TutorialHelper {
  static TutorialCoachMark? _activeCoachMark;

  static void dismissCurrent() {
    _activeCoachMark?.finish();
    _activeCoachMark = null;
  }

  static void showTutorial(
    BuildContext context, {
    required GlobalKey cookbookKey,
    required GlobalKey scanKey,
    required GlobalKey importKey,
    Cookbook? firstCookbook,
    Function(int)? onTabSwitch,
  }) {
    final service = TutorialService.instance;
    if (!service.isTutorialActive) return;

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

    // Filter out targets whose keys are not yet in the widget tree
    final validTargets = targets.where((target) {
      final key = target.keyTarget;
      return (key is GlobalKey && key.currentContext != null);
    }).toList();

    if (validTargets.isEmpty) return;

    _activeCoachMark = TutorialCoachMark(
      targets: validTargets,
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
      barrierColor: Colors.black.withOpacity(0.8),
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
      barrierColor: Colors.black.withOpacity(0.8),
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

    // Step 1: Scan
    targets.add(
      TargetFocus(
        identify: "scan",
        keyTarget: scanKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 30.r,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _TutorialContent(
                title: "Scan",
                description: "Scan your ingredients or your recipe and our AI will take care of the rest.",
                step: 1,
                totalSteps: 3,
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

    // Step 2: Import
    targets.add(
      TargetFocus(
        identify: "import",
        keyTarget: importKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        radius: 35.r,
        paddingFocus: 5,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _TutorialContent(
                title: "Import",
                description: "Import yours recipes from TikTok, Instagram, or any site link.",
                step: 2,
                totalSteps: 3,
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

    // Step 3: Cookbooks
    targets.add(
      TargetFocus(
        identify: "cookbook",
        keyTarget: cookbookKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 16.r,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _TutorialContent(
                title: "Recipe Books",
                description: "Store all yours recipes here and organize them as you want.",
                step: 3,
                totalSteps: 3,
                isLast: true,
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
      'image': 'assets/images/onboarding_scan_1.png',
      'items': [
        'Hold your phone steady',
        'Use good lighting',
        'Make sure all ingredients are visible',
      ],
      'btnText': 'Next',
    },
    {
      'title': 'We instantly find your ingredients',
      'image': 'assets/images/onboarding_scan_2.png',
      'items': [
        'Snap a photo of your ingredients',
        'We detect what\'s inside instantly',
        'Edit anything that looks off',
      ],
      'btnText': 'Next',
    },
    {
      'title': 'Ready to scan',
      'image': 'assets/images/onboarding_scan_3.png',
      'items': [
        'Scan your fridge, pantry, or ingredients',
        'Try different angles for better results',
        'The more visible, the better your recipes',
      ],
      'btnText': 'Scan Now',
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
          // Background with cross-fade
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: Image.asset(
                step['image'],
                key: ValueKey(step['image']),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // Dimmer
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.1)),
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

                    ...List.generate(
                      step['items'].length,
                      (i) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 20.sp,
                              color: const Color(0xFFCC3333),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                step['items'][i],
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontSize: 15.sp,
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

                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: _onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCC3333),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          step['btnText'],
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Page Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _steps.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          width: _currentPage == i ? 24.w : 8.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? const Color(0xFFCC3333)
                                : const Color(0xFFFFD1D1),
                            borderRadius: BorderRadius.circular(2.r),
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
      'name': 'Instagram',
      'icon': 'assets/images/insta_logo.svg',
      'shareIcon': 'assets/images/shared1.svg',
    },
    {
      'name': 'TikTok',
      'icon': 'assets/images/tiktok_logo.svg',
      'shareIcon': 'assets/images/shared2.svg',
    },
    {
      'name': 'Youtube',
      'icon': 'assets/images/you_logo.svg',
      'shareIcon': 'assets/images/shared3.svg',
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
      body: Center(
        child: Container(
          width: 0.9.sw,
          margin: EdgeInsets.symmetric(vertical: 40.h),
          padding: EdgeInsets.only(bottom: 24.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header (Fixed inside scroll for simplicity)
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/logo2.png',
                        width: 30.w,
                        height: 30.h,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF5F5F5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Mockup Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                          border: Border.all(
                            color: const Color(0xFFFFE57F),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFECB3).withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Paste a recipe link...',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontSize: 14.sp,
                                color: const Color(0xFF666666),
                              ),
                            ),
                            Icon(
                              Icons.content_paste_rounded,
                              size: 18.sp,
                              color: const Color(0xFFCC3333),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCC3333),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Center(
                          child: Text(
                            'Import Recipes',
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Import recipes from\nanywhere',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A1A1A),
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            _BulletItem(
                              text:
                                  'Paste a link from TikTok, Instagram, or any site',
                            ),
                            _BulletItem(
                              text:
                                  'Or share directly from social apps to import instantly',
                            ),
                            _BulletItem(
                              text:
                                  'We\'ll turn it into a full recipe automatically',
                            ),
                            _BulletItem(text: 'Save it to your cookbook'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Horizontal Carousel Section
                SizedBox(
                  height: 100.h,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemCount: _platforms.length,
                    itemBuilder: (context, index) {
                      final platform = _platforms[index];
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.w),
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _DiagramIcon(
                              asset: platform['icon'],
                              label: platform['name'],
                            ),
                            SvgPicture.asset(
                              'assets/images/direction.svg',
                              width: 10.w,
                              height: 10.w,
                            ),
                            _DiagramIcon(
                              asset: platform['shareIcon'],
                              label: 'Share',
                              isShare: true,
                            ),
                            SvgPicture.asset(
                              'assets/images/direction.svg',
                              width: 10.w,
                              height: 10.w,
                            ),
                            const _DiagramIcon(
                              asset: 'assets/images/logo2.png',
                              label: 'Cooked',
                            ),
                            SvgPicture.asset(
                              'assets/images/direction.svg',
                              width: 10.w,
                              height: 10.w,
                            ),
                            const _DiagramIcon(
                              icon: Icons.archive_rounded,
                              label: 'Imported\nRecipe',
                              isImported: true,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 12.h),

                // Bottom indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: _currentPage == i ? 24.w : 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? const Color(0xFFCC3333)
                            : const Color(0xFFFFDADA),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time_filled_rounded,
            size: 16.sp,
            color: const Color(0xFF444444),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF555555),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagramIcon extends StatelessWidget {
  final String? asset;
  final IconData? icon;
  final String label;
  final bool isShare;
  final bool isImported;

  const _DiagramIcon({
    this.asset,
    this.icon,
    required this.label,
    this.isShare = false,
    this.isImported = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isSvg = asset?.endsWith('.svg') ?? false;
    bool useWhiteBg = !isShare && !isSvg && label != 'Instagram';

    return Column(
      children: [
        Container(
          width: 35.w,
          height: 35.w,
          decoration: BoxDecoration(
            color: useWhiteBg ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: useWhiteBg
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: asset != null
                ? (asset!.endsWith('.svg')
                      ? SvgPicture.asset(
                          asset!,
                          width: useWhiteBg ? 20.w : 30.w,
                          height: useWhiteBg ? 20.w : 30.w,
                        )
                      : Image.asset(
                          asset!,
                          width: useWhiteBg ? 24.w : 35.w,
                          height: useWhiteBg ? 24.w : 35.w,
                        ))
                : Icon(
                    icon!,
                    size: isImported ? 25.sp : 27.sp,
                    color: isImported ? const Color(0xFFCC3333) : Colors.black,
                  ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
            height: 1.1,
          ),
        ),
      ],
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

  const _TutorialContent({
    required this.title,
    required this.description,
    required this.step,
    required this.totalSteps,
    required this.onNext,
    required this.onSkip,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A1A),
                    fontFamily: 'SF Pro',
                  ),
                ),
              ),
              Text(
                "$step/$totalSteps",
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF888888),
                  fontFamily: 'SF Pro',
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF555555),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!isLast)
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                      side: const BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 6.h,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      color: const Color(0xFF737373),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SF Pro',
                    ),
                  ),
                )
              else
                const Spacer(),
              ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCC3333),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 8.h,
                  ),
                  elevation: 0,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  isLast ? "Done" : "Next",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'SF Pro',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
          // Background
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: Image.asset(
                step['image'],
                key: ValueKey(step['image']),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // Dimmer
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.2)),
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
                              color: const Color(0xFFCC3333),
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
                                    ? const Color(0xFFCC3333)
                                    : const Color(0xFFFFD1D1),
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCC3333),
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
