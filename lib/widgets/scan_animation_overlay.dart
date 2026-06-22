import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/recipe.dart';
import 'confetti_animation.dart';


class ScanAnimationOverlay extends StatefulWidget {
  final List<RecipeIngredient>? detectedIngredients;
  final List<Recipe>? generatedRecipes;
  final VoidCallback onAnimationComplete;
  final String? imagePath;

  const ScanAnimationOverlay({
    Key? key,
    required this.detectedIngredients,
    required this.generatedRecipes,
    required this.onAnimationComplete,
    this.imagePath,
  }) : super(key: key);

  @override
  State<ScanAnimationOverlay> createState() => _ScanAnimationOverlayState();
}

class _ScanAnimationOverlayState extends State<ScanAnimationOverlay>
    with TickerProviderStateMixin {
  int _currentStep =
      0; // 0: Detecting, 1: Falling, 2: Cooking, 3: Recipes Ready

  // Cooking step checklist
  final List<String> _checklist = [
    "Finding quick meals",
    "Matching your preferences",
    "Checking ingredients",
    "Finalizing your picks",
  ];
  int _checkedCount = 0;
  Timer? _checklistTimer;



  // Animation controllers
  late AnimationController _fallingController;
  late AnimationController _steamController;
  late AnimationController _recipesController;
  late AnimationController _gatherController;
  late AnimationController _scannerController;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();

    _fallingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000), // Longer for full rotation and drop
    );

    _steamController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _recipesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _gatherController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Gather fly animation
    );

    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat(reverse: true);

    // Initial check to see if we already have ingredients (which we might not at ms 0)
    _checkStateTransitions();
  }

  @override
  void didUpdateWidget(ScanAnimationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkStateTransitions();
  }

  void _checkStateTransitions() {
    if (_currentStep == 0 && widget.detectedIngredients != null) {
      // Step 0 -> Step 1 (Wait 2 seconds to show ingredients, then drop them)
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _currentStep == 0) {
          HapticFeedback.mediumImpact();
          setState(() {
            _currentStep = 1;
          });
          // First, gather ingredients to the center
          _gatherController.forward().then((_) {
            if (mounted && _currentStep == 1) {
              // Automatically drop them after a short delay
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted && _currentStep == 1) {
                  _fallingController.forward().then((_) {
                    if (mounted && _currentStep == 1) {
                      // Automatically transition to Step 2
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted && _currentStep == 1) {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _currentStep = 2; // Move to Cook phase
                          });
                          _startChecklistTimer();
                        }
                      });
                    }
                  });
                }
              });
            }
          });
        }
      });
    }
  }

  void _transitionToStep3() {
    HapticFeedback.heavyImpact();
    setState(() {
      _currentStep = 3;
    });
    _recipesController.forward().then((_) {
      // The automatic transition to home has been disabled for adjustments.
      // The user must click the "View Recipes" button to complete the flow.
      /*
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted && _currentStep == 3) {
          widget.onAnimationComplete();
        }
      });
      */
    });
  }

  void _startChecklistTimer() {
    _checklistTimer?.cancel();
    _checklistTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_checkedCount < _checklist.length) {
        setState(() {
          _checkedCount++;
        });
      }

      if (_checkedCount >= _checklist.length) {
        timer.cancel();
        // Automatically transition to step 3 when checklist is done
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted && _currentStep == 2) {
            _transitionToStep3();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _checklistTimer?.cancel();
    _gatherController.dispose();
    _fallingController.dispose();
    _steamController.dispose();
    _recipesController.dispose();
    _scannerController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isScanning = _currentStep == 0 && widget.detectedIngredients == null;

    Widget mainContent = Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white, // Always white background
      child: isScanning && widget.imagePath != null
          ? _buildScanningFrame()
          : SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(height: 30.h),
                      _buildHeaderLogo(),
                      SizedBox(height: 40.h),
                      _buildTitles(),
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
                ],
              ),
            ),
    );

    if (_currentStep == 3) {
      return ConfettiAnimation(
        ingredients: widget.detectedIngredients,
        child: mainContent,
      );
    }

    return mainContent;
  }

  Widget _buildScanningFrame() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          File(widget.imagePath!),
          fit: BoxFit.cover,
        ),
        AnimatedBuilder(
          animation: _scannerController,
          builder: (context, child) {
            return Align(
              alignment: Alignment(0, -1.0 + (_scannerController.value * 2.0)),
              child: Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFC83A2D).withOpacity(0.9), // Red line
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC83A2D).withOpacity(0.5),
                      blurRadius: 15.r,
                      spreadRadius: 3.r,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10.h,
          left: 10.w,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.white, size: 30.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
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
          SizedBox(height: 12.h),
          Text(
            "We're identifying what you have.",
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

    if (_currentStep == 2) {
      return Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Building\n",
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFC83A2D),
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
                    color: const Color(0xFF1E293B),
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
            "Balancing taste, time, and nutrition.",
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



    if (_currentStep == 3) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Recipes ready!",
                style: TextStyle(
                  fontSize: 34.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B), // Dark blue like the design
                  fontFamily: 'Larken',
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            "Your personalized recipes are ready to enjoy.",
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF6B7280),
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    String titleLine1 = "";
    String titleLine2 = "";
    String subtitle = "";

    switch (_currentStep) {
      case 1:
        titleLine1 = "Matching\n";
        titleLine2 = "recipes";
        subtitle = "Finding meals that fit your taste.";
        break;
    }

    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: titleLine1,
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
                text: titleLine2,
                style: TextStyle(
                  fontSize: 34.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFC83A2D), // Red color
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
          subtitle,
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

  Widget _buildIngredientsChoreography(
    BoxConstraints constraints,
    double potTopLine,
  ) {
    if (widget.detectedIngredients == null) {
      if (_currentStep == 0) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFC83A2D)),
        );
      }
      return const SizedBox();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_gatherController, _fallingController]),
      builder: (context, child) {
        final double gatherProgress = Curves.easeInOutCubic.transform(
          _gatherController.value,
        );
        final double gatherOpacity = 1.0 - gatherProgress.clamp(0.0, 1.0);

        List<Widget> gatheringWidgets = [];
        List<Widget> fallingWidgets = [];

        final int baseCount = widget.detectedIngredients!.length;
        final int copies = 3;
        final int totalCount = baseCount * copies;
        final double delta = 2 * pi / totalCount;

        for (int circleIndex = 0; circleIndex < totalCount; circleIndex++) {
          // Interleave to mix the ingredients evenly around the circle
          int index = circleIndex % baseCount;
          final ing = widget.detectedIngredients![index];

          String formattedName = ing.name;
          if (formattedName.isNotEmpty) {
            formattedName =
                formattedName[0].toUpperCase() +
                formattedName.substring(1).toLowerCase();
          }

          // GATHER PHASE POSITIONS (All copies of the same ingredient start from the same list position)
          final double initialTop = 24.h + index * 76.h;
          final double initialLeft = 24.w;

          // Target circular positions (for 50.sp size)
          final double centerX = (constraints.maxWidth / 2) - 25.sp; 
          final double centerY = 80.h; // Moved down to not touch the text
          final double radius = 70.w; 
          
          final double theta = pi / 2 - circleIndex * delta; 

          double spinProgress = (_fallingController.value / 0.7).clamp(0.0, 1.0);
          double fallProgress = 0.0;
          if (_fallingController.value > 0.7) {
            fallProgress = ((_fallingController.value - 0.7) / 0.3).clamp(0.0, 1.0);
          }

          final double R = spinProgress * 2 * pi;
          double currentAngle = theta + R;

          final double targetTop = centerY + radius * sin(currentAngle);
          final double targetLeft = centerX + radius * cos(currentAngle);

          double currentTop = initialTop + (targetTop - initialTop) * gatherProgress;
          double currentLeft = initialLeft + (targetLeft - initialLeft) * gatherProgress;

          // Decrease size smoothly from 80.sp (list size) down to 50.sp (circle size)
          double size = 80.sp - (30.sp * gatherProgress);

          if (fallProgress > 0) {
            final double releaseTop = targetTop;
            final double releaseLeft = targetLeft;
            final double endY = constraints.maxHeight - 60.h; // Lowered so they fall deeper into the pot

            // RACE EFFECT: staggered fall delay based on circleIndex pseudo-randomly
            double delay = ((circleIndex * 7) % totalCount) / totalCount * 0.4;
            double duration = 0.6; // Quick fall
            
            double itemFallProgress = 0.0;
            if (fallProgress > delay) {
              itemFallProgress = ((fallProgress - delay) / duration).clamp(0.0, 1.0);
            }

            final double curvedFall = Curves.easeInCubic.transform(itemFallProgress);
            double itemCurrentTop = releaseTop + (endY - releaseTop) * curvedFall;
            // Converge slightly to center
            double itemCurrentLeft = releaseLeft + (centerX - releaseLeft) * curvedFall * 0.4;

            double opacity = 1.0;
            if (itemFallProgress > 0.9) {
              opacity = (1.0 - itemFallProgress) / 0.1;
            }

            fallingWidgets.add(
              Positioned(
                top: itemCurrentTop,
                left: itemCurrentLeft,
                child: Opacity(
                  opacity: opacity,
                  child: (ing.image != null && ing.image!.isNotEmpty)
                      ? Image.asset(
                          ing.image!,
                          width: 50.sp, // They are already 50.sp on the circle
                          height: 50.sp,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Text(
                            ing.icon ?? "🥘",
                            style: TextStyle(fontSize: 25.sp),
                          ),
                        )
                      : Text(
                          ing.icon ?? "🥘",
                          style: TextStyle(fontSize: 25.sp),
                        ),
                ),
              ),
            );
          } else {
            // Gathering phase
            if (gatherProgress == 1.0) {
              gatheringWidgets.add(
                Positioned(
                  top: currentTop,
                  left: currentLeft,
                  child: (ing.image != null && ing.image!.isNotEmpty)
                      ? Image.asset(
                          ing.image!,
                          width: 50.sp,
                          height: 50.sp,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Text(
                            ing.icon ?? "🥘",
                            style: TextStyle(fontSize: 25.sp),
                          ),
                        )
                      : Text(
                          ing.icon ?? "🥘",
                          style: TextStyle(fontSize: 25.sp),
                        ),
                ),
              );
            } else {
              // During transition from list to circle
              // Draw the text container ONLY ONCE per ingredient (using circleIndex < baseCount)
              if (circleIndex < baseCount) {
                gatheringWidgets.add(
                  Positioned(
                    top: currentTop,
                    left: currentLeft,
                    right: gatherProgress > 0 ? null : 24.w,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(gatherOpacity),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: Colors.grey.shade100.withOpacity(gatherOpacity),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Transform.scale(
                            scale: 1.0 + ((size / 40.w) - 1.0) * gatherProgress,
                            child: (ing.image != null && ing.image!.isNotEmpty)
                                ? Image.asset(
                                    ing.image!,
                                    width: 40.w,
                                    height: 40.h,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Text(
                                      ing.icon ?? "🥘",
                                      style: TextStyle(fontSize: 28.sp),
                                    ),
                                  )
                                : Text(
                                    ing.icon ?? "🥘",
                                    style: TextStyle(fontSize: 28.sp),
                                  ),
                          ),
                          if (gatherProgress == 0) ...[
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                formattedName,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(
                                    0xFF1E293B,
                                  ).withOpacity(gatherOpacity),
                                  fontFamily: 'SF Pro',
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(4.r),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFC83A2D,
                                ).withOpacity(gatherOpacity),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white.withOpacity(gatherOpacity),
                                size: 14.sp,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                // For copies (circleIndex >= baseCount), just fly the icon!
                // It will fade in as it leaves the list
                // To avoid it snapping to the top left of the text container, we offset it roughly to where the image is
                gatheringWidgets.add(
                  Positioned(
                    top: currentTop + 10.h * (1.0 - gatherProgress),
                    left: currentLeft + 16.w * (1.0 - gatherProgress),
                    child: Opacity(
                      opacity: gatherProgress, // Fades in!
                      child: (ing.image != null && ing.image!.isNotEmpty)
                          ? Image.asset(
                              ing.image!,
                              width: size,
                              height: size,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Text(
                                ing.icon ?? "🥘",
                                style: TextStyle(fontSize: size / 2),
                              ),
                            )
                          : Text(
                              ing.icon ?? "🥘",
                              style: TextStyle(fontSize: size / 2),
                            ),
                    ),
                  ),
                );
              }
            }
          }
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Stack(clipBehavior: Clip.none, children: gatheringWidgets),
            ClipPath(
              clipper: PotClipper(potTopLine),
              child: Stack(clipBehavior: Clip.none, children: fallingWidgets),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPotAndContent(BoxConstraints constraints) {
    // Calculate the front rim position based on current step
    final double potTopLine = constraints.maxHeight - 115.h; // Pot is lowered for all visible steps now

    Widget potStack = Stack(
      clipBehavior: Clip.none,
      children: [
        // Glow Rays from pot

        // (Fire and Steam removed per boss request)

        // 3. The Pot Image (Always at bottom)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutBack,
          bottom: _currentStep == 0
              ? -400.h
              : -30.h, // Lowered in all visible steps
          left: 0,
          right: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Image.asset(
              _currentStep <= 1 
                  ? 'assets/images/pot3.png' 
                  : (_currentStep == 2 ? 'assets/images/pot2.png' : 'assets/images/pot1.png'),
              key: ValueKey(_currentStep),
              height: 300.h,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                key: ValueKey('error_$_currentStep'),
                height: 300.h,
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(80.r),
                    bottomRight: Radius.circular(80.r),
                  ),
                ),
                child: Center(
                  child: Text(
                    "pot${_currentStep <= 1 ? 1 : (_currentStep == 2 ? 2 : 3)}.png",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
            ),
          ),
        ),

        // 4. Content that goes IN the pot (Ingredients falling or Recipes rising)
        Positioned.fill(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (_currentStep <= 1)
                _buildIngredientsChoreography(constraints, potTopLine),
              ClipPath(
                clipper: PotClipper(potTopLine),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (_currentStep == 3) _buildRisingRecipes(constraints),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Debug Line: Limit of falling ingredients (Curved to match pot rim)
        Positioned.fill(
          child: CustomPaint(
            painter: PotRimPainter(potTopLine),
          ),
        ),
      ],
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            double offsetX = 0;
            // Slight side-to-side vibration when check 3 is reached
            if (_currentStep == 2 && _checkedCount >= 3) {
              offsetX = sin(_shakeController.value * pi * 2) * 2.w;
            }
            return Transform.translate(
              offset: Offset(offsetX, 0),
              child: child,
            );
          },
          child: potStack,
        ),

        // Checklist for step 2 (Above the pot, does not shake)
        if (_currentStep == 2)
          Positioned(
            top: 30.h,
            left: 20.w,
            right: 20.w,
            child: _buildChecklist(),
          ),
      ],
    );
  }

  Widget _buildChecklist() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 60.w,
      ), // Center the checklist nicely
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            leading = SizedBox(
              width: 24.w,
              height: 24.w,
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
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF9CA3AF), width: 1.5),
              ),
            );
          }

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left side: Circle and Line
                SizedBox(
                  width: 24.w,
                  child: Column(
                    children: [
                      leading,
                      // Line connecting to next item
                      if (!isLast)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: Container(
                              width: 2.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(1.r),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                // Right side: Text
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 2.h,
                      bottom: !isLast ? 24.h : 0,
                    ),
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
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRisingRecipes(BoxConstraints constraints) {
    if (widget.generatedRecipes == null || widget.generatedRecipes!.isEmpty)
      return const SizedBox();

    return AnimatedBuilder(
      animation: _recipesController,
      builder: (context, child) {
        final int count = widget.generatedRecipes!.length.clamp(0, 3);
        List<Widget> cards = List.generate(count, (i) {
          final recipe = widget.generatedRecipes![i];
          final String imgPath =
              (recipe.image != null && recipe.image!.isNotEmpty)
              ? recipe.image!
              : 'assets/images/plat${i + 1}.png';
          final bool isNetworkImage = imgPath.startsWith('http');

          final double startY = constraints.maxHeight - 150.h;

          // Layout based on count
          double endY = 100.h;
          double angle = 0.0;
          double leftOffset = constraints.maxWidth / 2 - 60.w;

          if (count == 1) {
            // Just one card in center
            endY = 80.h;
            angle = 0.0;
          } else if (count == 2) {
            // Two cards side by side
            endY = 100.h;
            if (i == 0) {
              angle = 0.0;
              leftOffset -= 65.w;
            } else {
              angle = 0.0;
              leftOffset += 65.w;
            }
          } else {
            // Three cards arc
            if (i == 1) {
              endY = 30.h; // Center highest (monté encore plus)
              leftOffset = constraints.maxWidth / 2 - 60.w; // Exactly center
              angle = 0.0;
            } else if (i == 0) {
              endY = 130.h; // Left lower (descendu encore plus)
              leftOffset = constraints.maxWidth / 2 - 140.w; // Adjusted to overlap nicely
              angle = 0.0;
            } else if (i == 2) {
              endY = 130.h; // Right lower (descendu encore plus)
              leftOffset = constraints.maxWidth / 2 + 20.w; // Adjusted to overlap nicely
              angle = 0.0;
            }
          }

          double baseScale = 1.0;

          // Stagger the animation so they pop out rapidly one by one
          final double delay = i * 0.15;
          double localProgress = (_recipesController.value - delay) / 0.7;
          localProgress = localProgress.clamp(0.0, 1.0);

          final double progress = Curves.easeOutBack.transform(localProgress);
          final double scale =
              (0.5 + (0.5 * Curves.easeOutCubic.transform(localProgress))) * baseScale;
          final double opacity = Curves.easeIn.transform(localProgress);

          final double currentY = startY + (endY - startY) * progress;

          return Positioned(
            top: currentY,
            left: leftOffset,
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Transform.rotate(
                  angle: angle * progress,
                  child: Container(
                    width: 110.w,
                    height: 110.w, // Make it a perfect circle
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle, // Circular cards
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: isNetworkImage
                          ? Image.network(
                              imgPath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildFallbackIcon(),
                            )
                          : Image.asset(
                              imgPath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildFallbackIcon(),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });

        // Reorder so that the center one (index 1) is rendered LAST (on top)
        if (cards.length == 3) {
          Widget centerCard = cards[1];
          cards.removeAt(1);
          cards.add(centerCard);
        } else if (cards.length == 2) {
          // Both are equal, rendering order is fine (0 then 1)
        }

        return Stack(children: cards);
      },
    );
  }

  Widget _buildFallbackIcon() {
    return Center(
      child: Icon(Icons.fastfood, color: Colors.grey, size: 40.sp),
    );
  }

  Widget _buildFooterIndicator() {
    if (_currentStep == 3) {
      return Column(
        children: [
          Text(
            "${widget.generatedRecipes?.length ?? 3} recipes ready",
            style: TextStyle(
              color: const Color(0xFFC83A2D),
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: ElevatedButton(
          onPressed: widget.onAnimationComplete,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC83A2D), // Cooked Red
            minimumSize: Size(double.infinity, 56.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.r),
            ),
          ),
          child: Text(
            "View Recipes",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        int activeIndex = _currentStep == 0 ? 0 : (_currentStep == 1 ? 1 : 2);
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
}

class PotRimPainter extends CustomPainter {
  final double clipY;

  PotRimPainter(this.clipY);

  @override
  void paint(Canvas canvas, Size size) {
    final double depth = 20.0;
    final paint = Paint()
      ..color = Colors.transparent
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
      ..color = const Color(0xFFFFE0B2).withOpacity(0.4) // Light warm glow
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
