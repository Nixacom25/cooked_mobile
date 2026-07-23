import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/recipe.dart';

class ScanAnimationOverlay extends StatefulWidget {
  final List<RecipeIngredient>? detectedIngredients;
  final List<Recipe>? generatedRecipes;
  final VoidCallback onAnimationComplete;
  final String? imagePath;
  final bool showTestControls;

  const ScanAnimationOverlay({
    Key? key,
    required this.detectedIngredients,
    required this.generatedRecipes,
    required this.onAnimationComplete,
    this.imagePath,
    this.showTestControls = false,
  }) : super(key: key);

  @override
  State<ScanAnimationOverlay> createState() => _ScanAnimationOverlayState();
}

class _ScanAnimationOverlayState extends State<ScanAnimationOverlay>
    with TickerProviderStateMixin {
  int _currentStep =
      0; 

  // Cooking step checklist
  final List<String> _checklist = [
    "Checking ingredients",
    "Matching preferences",
    "Finding meals",
    "Finalizing picks",
  ];
  int _checkedCount = 0;
  Timer? _checklistTimer;
  final List<Timer> _activeTimers = [];
  bool _autoPlay =
      true;
  bool _isShaking =
      false;
  bool _showCreatingContent =
      false;
  bool _isScannerTransitioning =
      false; // Prevents restarting the final laser scan descent animation multiple times
  bool _didTriggerStep2Transition =
      false; // Prevents double-triggering step 2 transition during falling animation

  // Animation controllers
  late AnimationController _fallingController;
  late AnimationController _scannerController;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();

    _fallingController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 2000,
      ), // Slightly slower for a more measured (dosé) natural cascade
    )..addListener(() {
        if (mounted && _currentStep == 1 && !_didTriggerStep2Transition) {
          final totalCount = widget.detectedIngredients?.length ?? 1;
          final double triggerValue = 1.0 - 0.5 / totalCount;
          if (_fallingController.value >= triggerValue) {
            _didTriggerStep2Transition = true;
            _transitionToStep2();
          }
        }
      });

    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    ); // Do NOT start repeating in initState to save CPU/battery

    // Initial check to see if we already have ingredients (which we might not at ms 0)
    _checkStateTransitions();
  }

  @override
  void didUpdateWidget(ScanAnimationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkStateTransitions();

    if (!widget.showTestControls &&
        _currentStep == 2 &&
        _checkedCount == 3 &&
        widget.generatedRecipes != null &&
        widget.generatedRecipes!.isNotEmpty) {
      _completeFinalizingPicks();
    }
  }

  void _transitionToStep2() {
    if (!mounted || _currentStep != 1) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _currentStep = 2;
      _isShaking = false;
      _showCreatingContent = true;
    });
    _shakeController.stop();
    _shakeController.reset();

    // Wait 300ms (until lid closes) before starting loading/shaking
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _currentStep == 2) {
        _startChecklistTimer();
        setState(() {
          _isShaking = true;
        });
        _shakeController.repeat(reverse: true);
      }
    });
  }

  void _checkStateTransitions() {
    if (!_autoPlay) return;

    if (_currentStep == 0 && widget.detectedIngredients != null && !_isScannerTransitioning) {
      _isScannerTransitioning = true;
      _scannerController.stop();
      _scannerController.value = 0.0;
      _scannerController.animateTo(1.0, duration: const Duration(milliseconds: 1000), curve: Curves.easeInOut).then((_) {
        if (mounted && _currentStep == 0 && _autoPlay) {
          HapticFeedback.mediumImpact();
          setState(() {
            _currentStep = 1;
            _isShaking = false;
            _showCreatingContent = false;
          });
          _scannerController.stop();
          _shakeController.stop();
          _shakeController.reset();

          // Start falling immediately
          if (mounted && _currentStep == 1 && _autoPlay) {
            _didTriggerStep2Transition = false;
            _fallingController.forward();
          }
        }
      });
    }
  }

  void _goToNextStep() {
    if (_currentStep == 0) {
      if (_isScannerTransitioning) return;
      _isScannerTransitioning = true;
      HapticFeedback.mediumImpact();
      _scannerController.stop();
      _scannerController.value = 0.0;
      _scannerController.animateTo(1.0, duration: const Duration(milliseconds: 1000), curve: Curves.easeInOut).then((_) {
        if (mounted && _currentStep == 0) {
          setState(() {
            _currentStep = 1;
            _isShaking = false;
            _showCreatingContent = false;
          });
          _scannerController.stop();
          _shakeController.stop();
          _shakeController.reset();

          // Start falling immediately
          if (mounted && _currentStep == 1) {
            _didTriggerStep2Transition = false;
            _fallingController.forward();
          }
        }
      });
    } else if (_currentStep == 1) {
      _didTriggerStep2Transition = true;
      _transitionToStep2();
    } else if (_currentStep == 2) {
      widget.onAnimationComplete();
    }
  }

  void _resetAnimation() {
    _clearActiveTimers();
    _fallingController.reset();
    _shakeController.stop();
    _shakeController.reset();
    _scannerController.stop();
    _scannerController.reset();

    setState(() {
      _currentStep = 0;
      _checkedCount = 0;
      _isShaking = false;
      _showCreatingContent = false;
      _isScannerTransitioning = false;
      _didTriggerStep2Transition = false;
    });

    _scannerController.repeat(reverse: true);

    if (_autoPlay) {
      _checkStateTransitions();
    }
  }

  void _clearActiveTimers() {
    _checklistTimer?.cancel();
    for (var t in _activeTimers) {
      t.cancel();
    }
    _activeTimers.clear();
  }

  void _completeFinalizingPicks() {
    if (!mounted || _currentStep != 2 || _checkedCount >= 4) return;

    // Timer to set checkedCount = 4 (1s delay so they see the checkmark check)
    _activeTimers.add(
      Timer(const Duration(seconds: 1), () {
        if (!mounted || _currentStep != 2) return;
        setState(() {
          _checkedCount = 4;
        });

        // Final completion timer: 1s
        _activeTimers.add(
          Timer(const Duration(seconds: 1), () {
            if (mounted && _currentStep == 2) {
              widget.onAnimationComplete();
            }
          }),
        );
      }),
    );
  }

  void _startChecklistTimer() {
    _clearActiveTimers();
    _checkedCount = 0;

    // Timer 1: 1s -> Checked count = 1
    _activeTimers.add(
      Timer(const Duration(seconds: 1), () {
        if (!mounted || _currentStep != 2) return;
        setState(() {
          _checkedCount = 1;
        });

        // Timer 2: 1s (total 2s) -> Checked count = 2
        _activeTimers.add(
          Timer(const Duration(seconds: 1), () {
            if (!mounted || _currentStep != 2) return;
            setState(() {
              _checkedCount = 2;
            });

            // Timer 3: 1s (total 3s) -> Checked count = 3
            _activeTimers.add(
              Timer(const Duration(seconds: 1), () {
                if (!mounted || _currentStep != 2) return;
                setState(() {
                  _checkedCount = 3;
                });

                if (widget.showTestControls) {
                  // In test mode: lasts exactly 5 seconds
                  _activeTimers.add(
                    Timer(const Duration(seconds: 5), () {
                      if (!mounted || _currentStep != 2) return;
                      setState(() {
                        _checkedCount = 4;
                      });

                      _activeTimers.add(
                        Timer(const Duration(seconds: 1), () {
                          if (mounted && _currentStep == 2) {
                            widget.onAnimationComplete();
                          }
                        }),
                      );
                    }),
                  );
                } else {
                  // In production mode: validate last check only if recipes are generated & ready
                  if (widget.generatedRecipes != null && widget.generatedRecipes!.isNotEmpty) {
                    _completeFinalizingPicks();
                  }
                }
              }),
            );
          }),
        );
      }),
    );
  }

  @override
  void dispose() {
    _clearActiveTimers();
    _fallingController.dispose();
    _scannerController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isScanning = _currentStep == 0;

    Widget mainContent = Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white, // Always white background
      child: Stack(
        children: [
          isScanning
              ? _buildScanningFrame()
              : SafeArea(
                  child: Column(
                    children: [
                      SizedBox(height: 30.h),
                      _buildHeaderLogo(),
                      SizedBox(height: 40.h),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: (_currentStep == 1 || _currentStep == 2)
                            ? (_showCreatingContent ? 1.0 : 0.0)
                            : 1.0,
                        child: _buildTitles(),
                      ),
                      SizedBox(height: 30.h),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [_buildPotAndContent(constraints)],
                            );
                          },
                        ),
                      ),
                      _buildFooterIndicator(),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
          if (widget.showTestControls)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.h,
              right: 20.w,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _autoPlay = !_autoPlay;
                        if (_autoPlay) {
                          _checkStateTransitions();
                          if (_currentStep == 2) {
                            _startChecklistTimer();
                          }
                        } else {
                          _checklistTimer?.cancel();
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: _autoPlay
                            ? const Color(0xFFC83A2D)
                            : Colors.grey[700],
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Text(
                        _autoPlay ? "Auto: ON" : "Auto: OFF",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SF Pro',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: _goToNextStep,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Text(
                        "Next",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SF Pro',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: _resetAnimation,
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
    return mainContent;
  }

  Widget _buildScanningFrame() {
    return Container(
      color: Colors.white, // Solid white background matching Figma mock
      child: Stack(
        children: [
          // Content Layout
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20.h),
                _buildHeaderLogo(),
                SizedBox(height: 30.h),
                _buildTitles(),
                // No spacing here to let the image start immediately after description text
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Actual photo or fallback mockup photo
                      if (widget.imagePath != null &&
                          widget.imagePath!.isNotEmpty &&
                          widget.imagePath!.startsWith('/'))
                        Image.file(File(widget.imagePath!), fit: BoxFit.cover)
                      else
                        Image.asset(
                          'assets/images/onboarding_scan_1.png',
                          fit: BoxFit.cover,
                        ),

                      // Camera 3x3 Grid Overlay
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: const SizedBox()),
                        ],
                      ),
                      Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: const SizedBox()),
                        ],
                      ),

                      // Top Fade Overlay (blends image edge with white background)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 90.h,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Bottom Fade Overlay (blends image edge with white background and covers pagination area)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 140.h,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Scanning Laser Bar (moves within image box)
                      AnimatedBuilder(
                        animation: _scannerController,
                        builder: (context, child) {
                          return Align(
                            alignment: Alignment(
                              0,
                              -1.0 + (_scannerController.value * 2.0),
                            ),
                            child: Container(
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: Colors.white, // Glowing white core
                                borderRadius: BorderRadius.circular(3.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFC83A2D,
                                    ), // Neon red aura
                                    blurRadius: 12.r,
                                    spreadRadius: 4.r,
                                  ),
                                  BoxShadow(
                                    color: const Color(
                                      0xFFC83A2D,
                                    ).withOpacity(0.8),
                                    blurRadius: 4.r,
                                    spreadRadius: 1.r,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Ambient red glow on the bottom half of the image when laser is low
                      AnimatedBuilder(
                        animation: _scannerController,
                        builder: (context, child) {
                          return Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: 180.h,
                            child: Opacity(
                              opacity: (_scannerController.value * 0.12).clamp(
                                0.0,
                                0.12,
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Color(0xFFC83A2D),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Pagination Dots Row positioned on top of the bottom fade overlay
                      Positioned(
                        bottom: 24.h,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFC83A2D), // Active red dot
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE2E8F0), // Inactive dot
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE2E8F0), // Inactive dot
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Top Left floating close button (matches camera screen back navigation)
          if (widget.showTestControls)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.h,
              left: 10.w,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: const Color(0xFF1E293B),
                  size: 28.sp,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderLogo() {
    // Cooked logo placeholder or real image
    return Image.asset(
      'assets/images/logo1.png', // Assuming this exists based on previous code
      height: 35.h,
      errorBuilder: (context, error, stackTrace) => Text(
        "Cooked",
        style: TextStyle(
          color: const Color(0xFFC83A2D),
          fontSize: 40.sp,
          fontWeight: FontWeight.w900,
          fontFamily: 'Larken',
        ),
      ),
    );
  }

  Widget _buildTitles() {
    if (_currentStep == 0) {
      return Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Detecting\n",
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1E293B),
                    fontFamily: 'Larken',
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: "ingredients",
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFC83A2D),
                    fontFamily: 'Larken',
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "Analyzing your photo",
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF6B7280), // Perfect Figma grey description
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400, // Lighter, clean look
            ),
          ),
        ],
      );
    }

    if (_currentStep == 3) {
      return Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Recipes ",
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1E293B),
                    fontFamily: 'Larken',
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: "ready!",
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFC83A2D),
                    fontFamily: 'Larken',
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "Your personalized meals are ready to cook.",
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF4B5563),
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    if (_currentStep == 1 || _currentStep == 2) {
      return Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Creating\n",
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1E293B),
                    fontFamily: 'Larken',
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: "your recipes",
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFC83A2D),
                    fontFamily: 'Larken',
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "Turning your ingredients into meals you’ll love.",
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF4B5563),
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildIngredientsChoreography(
    BoxConstraints constraints,
    double potTopLine,
  ) {
    if (widget.detectedIngredients == null || _currentStep < 1) {
      return const SizedBox();
    }

    final int totalCount = widget.detectedIngredients!.length;

    // Falling Ingredients (Images/Icons)
    return AnimatedBuilder(
      animation: _fallingController,
      builder: (context, child) {
        List<Widget> fallingWidgets = [];

        if (_fallingController.value > 0.0) {
          final double fallDuration = 0.5;

          for (int i = 0; i < totalCount; i++) {
            final ing = widget.detectedIngredients![i];
            double startTime = (0.5 / totalCount) * i;

            double progress = 0.0;
            if (_fallingController.value >= startTime) {
              progress = ((_fallingController.value - startTime) / fallDuration)
                  .clamp(0.0, 1.0);
            }

            if (progress == 0.0 || progress == 1.0) continue;

            List<double> horizontalPositions = [
              0.38,
              0.62,
              0.45,
              0.55,
              0.5,
              0.4,
              0.6,
            ];
            double hFactor =
                horizontalPositions[i % horizontalPositions.length];
            double leftPos = constraints.maxWidth * hFactor - 32.5.w;

            // Start from high above the screen top
            double topStart = -300.h;
            double topEnd = potTopLine + 60.h;

            double currentTop =
                topStart +
                (topEnd - topStart) * Curves.easeIn.transform(progress);
            double rotation = progress * pi * 2 * (i % 2 == 0 ? 1 : -1);
            final double size = 65.sp;
            final double iconSize = 48.sp;

            fallingWidgets.add(
              Positioned(
                top: currentTop,
                left: leftPos,
                child: Transform.rotate(
                  angle: rotation,
                  child: (ing.image != null && ing.image!.isNotEmpty)
                      ? Image.asset(
                          ing.image!,
                          width: size,
                          height: size,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Text(
                            ing.icon ?? "🥘",
                            style: TextStyle(fontSize: iconSize),
                          ),
                        )
                      : Text(
                          ing.icon ?? "🥘",
                          style: TextStyle(fontSize: iconSize),
                        ),
                ),
              ),
            );
          }
        }

        return ClipPath(
          clipper: PotClipper(potTopLine),
          child: Stack(clipBehavior: Clip.none, children: fallingWidgets),
        );
      },
    );
  }

  Widget _buildPotAndContent(BoxConstraints constraints) {
    final double disappearanceLineHeight = 330.h;

    final double potTopLine = _currentStep >= 1 && _currentStep < 3
        ? constraints.maxHeight - disappearanceLineHeight
        : constraints.maxHeight - 115.h;

    Widget potStack = Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          bottom: _currentStep == 2 ? 175.h : -400.h,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 1000),
            opacity: (_currentStep == 2 && _isShaking) ? 0.6 : 0.0,
            child: Container(
              height: 200.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC83A2D).withOpacity(0.4),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        // 3. The Pot Image
        AnimatedPositioned(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutBack,
          bottom: _currentStep == 0
              ? -400.h
              : (_currentStep >= 1 && _currentStep < 3 ? 185.h : -30.h),
          left: 0,
          right: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _currentStep <= 1
                ? Image.asset(
                    'assets/images/pot2_b.png',
                    key: const ValueKey(1),
                    width: 300.h, // Using width to enforce proportional scale
                    fit: BoxFit.contain,
                  )
                : (_currentStep == 2
                      ? _buildAnimatedPot2()
                      : Image.asset(
                          'assets/images/pot1.png',
                          key: const ValueKey(3),
                          width: 300.h,
                          fit: BoxFit.contain,
                        )),
          ),
        ),

        // 4. Content that goes IN the pot (Ingredients falling or Recipes rising)
        Positioned.fill(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (_currentStep == 1)
                _buildIngredientsChoreography(constraints, potTopLine),
            ],
          ),
        ),

        Positioned.fill(child: CustomPaint(painter: PotRimPainter(potTopLine))),
      ],
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            double offsetX = 0;
            if (_currentStep == 2 && _isShaking) {
              offsetX = sin(_shakeController.value * pi * 2) * 2.w;
            }
            return Transform.translate(
              offset: Offset(offsetX, 0),
              child: child,
            );
          },
          child: potStack,
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuint,
          bottom: _currentStep >= 1 && _currentStep < 3 ? 20.h : -400.h,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _showCreatingContent ? 1.0 : 0.0,
            child: _buildChecklist(),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklist() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Dashed connector line positioned in the center of the indicators (12.w)
          Positioned(
            left: 12.w,
            top: 0,
            bottom: 0,
            child: CustomPaint(
              size: Size(1.5, double.infinity),
              painter: DashedLinePainter(
                count: _checklist.length,
                checkedCount: _checkedCount,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_checklist.length, (index) {
              bool isChecked = index < _checkedCount;
              bool isCurrent = index == _checkedCount;
              bool isLast = index == _checklist.length - 1;

              Widget leading;
              if (isChecked) {
                leading = Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC83A2D),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 16.sp),
                );
              } else if (isCurrent) {
                leading = Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFC83A2D),
                    ),
                    backgroundColor: const Color(0xFFE5E7EB),
                  ),
                );
              } else {
                leading = Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF9CA3AF),
                      width: 1.5,
                    ),
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
                child: Row(
                  children: [
                    leading,
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        _checklist[index],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'SF Pro',
                          fontWeight: isChecked || isCurrent
                              ? FontWeight.w500
                              : FontWeight.w400,
                          color: isChecked || isCurrent
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    if (isChecked)
                      Text(
                        "Done",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        int activeIndex = _currentStep == 0 ? 0 : 1;
        bool isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          height: 8.h,
          width: 8.h,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFC83A2D) : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildAnimatedPot2() {
    final double lidFinalRestingPosition = -25.h;

    return Stack(
      key: const ValueKey(2),
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/images/pot2_b.png',
          width: 300.h,
          fit: BoxFit.contain,
        ),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(
            milliseconds: 300,
          ), // Snappy bouncy closed lid drop
          curve: Curves.bounceOut, // Realistic bouncy drop
          builder: (context, value, child) {
            return Transform.translate(
              // Drops from high up down to the lidFinalRestingPosition
              offset: Offset(
                0,
                lidFinalRestingPosition - 150.h * (1.0 - value),
              ),
              child: Transform.rotate(
                angle: -0.3 * (1.0 - value), // Slight tilt while falling
                child: child,
              ),
            );
          },
          child: Image.asset(
            'assets/images/pot2_l.png',
            width: 300.h,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

class PotRimPainter extends CustomPainter {
  final double clipY;

  PotRimPainter(this.clipY);

  @override
  void paint(Canvas canvas, Size size) {
    final double depth = 20.0;
    final paint = Paint()
      ..color = Colors
          .transparent // Hidden in production/mockup design presentation
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Offset by 40 to match the previous horizontal margins
    path.moveTo(40.0, clipY - depth);
    path.quadraticBezierTo(
      size.width / 2,
      clipY + depth,
      size.width - 40.0,
      clipY - depth,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant PotRimPainter oldDelegate) {
    return oldDelegate.clipY != clipY;
  }
}

class PotClipper extends CustomClipper<Path> {
  final double clipY;

  PotClipper(this.clipY);

  @override
  Path getClip(Size size) {
    Path path = Path();
    // Start way above the top left to prevent clipping falling ingredients early
    path.moveTo(0, -1000);

    // The curve depth (how much the rim bends down)
    final double depth = 20.0;

    // Go down the left side, stopping a bit above the center dip
    path.lineTo(0, clipY - depth);

    // Draw a curved line to the right side
    path.quadraticBezierTo(
      size.width / 2,
      clipY + depth,
      size.width,
      clipY - depth,
    );

    // Go up the right side to way above the top right
    path.lineTo(size.width, -1000);

    // Connect back to top left to close the rectangle properly
    path.lineTo(0, -1000);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant PotClipper oldClipper) =>
      oldClipper.clipY != clipY;
}

class RaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFE0B2)
          .withOpacity(0.4) // Light warm glow
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20.0);

    final centerX = size.width / 2;
    final bottomY = size.height;

    // Draw several rays emanating from the bottom center (pot opening)
    for (int i = 0; i < 5; i++) {
      final path = Path();
      // Start from the pot rim area
      path.moveTo(centerX - 20.w + (i * 10.w), bottomY);

      // Expand outwards and upwards
      double endX = centerX + (i - 2) * 100.w; // spread from -200 to +200
      double endY = 0; // top of the box

      path.lineTo(endX - 30.w, endY);
      path.lineTo(endX + 30.w, endY);
      path.lineTo(centerX + 20.w + (i * 10.w), bottomY);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DashedLinePainter extends CustomPainter {
  final int count;
  final int checkedCount;

  DashedLinePainter({required this.count, required this.checkedCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC83A2D)
          .withOpacity(0.3) // Light red dashed line to match design perfectly
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final double startY = 12.w; // Center of first circle
    final double endY = size.height - 12.w; // Center of last circle

    double y = startY;
    const double dashHeight = 4.0;
    const double dashSpace = 4.0;

    while (y < endY) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dashHeight), paint);
      y += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant DashedLinePainter oldDelegate) =>
      oldDelegate.checkedCount != checkedCount || oldDelegate.count != count;
}
