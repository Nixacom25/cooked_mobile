import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/recipe.dart';

class ScanAnimationOverlay extends StatefulWidget {
  final List<RecipeIngredient>? detectedIngredients;
  final List<Recipe>? generatedRecipes;
  final VoidCallback onAnimationComplete;

  const ScanAnimationOverlay({
    Key? key,
    required this.detectedIngredients,
    required this.generatedRecipes,
    required this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<ScanAnimationOverlay> createState() => _ScanAnimationOverlayState();
}

class _ScanAnimationOverlayState extends State<ScanAnimationOverlay> with TickerProviderStateMixin {
  int _currentStep = 0; // 0: Detecting, 1: Falling, 2: Cooking, 3: Recipes Ready
  
  // Cooking step checklist
  final List<String> _checklist = [
    "Finding quick meals",
    "Matching your preferences",
    "Checking ingredients",
    "Finalizing your picks"
  ];
  int _checkedCount = 0;
  Timer? _checklistTimer;

  // Animation controllers
  late AnimationController _fallingController;
  late AnimationController _steamController;
  late AnimationController _recipesController;

  @override
  void initState() {
    super.initState();

    _fallingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _steamController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _recipesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

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
        if (mounted) {
          setState(() {
            _currentStep = 1;
          });
          _fallingController.forward().then((_) {
            if (mounted) {
              setState(() {
                _currentStep = 2;
                _startChecklistTimer();
              });
            }
          });
        }
      });
    }

    if (_currentStep == 2 && widget.generatedRecipes != null) {
      // Step 2 -> Step 3 (Wait for recipes, if checklist is done, show recipes)
      // If checklist isn't done, we wait for the checklist timer to finish it quickly.
    }
  }

  void _startChecklistTimer() {
    _checklistTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (_checkedCount < _checklist.length) {
        setState(() {
          _checkedCount++;
        });
      }

      if (_checkedCount == _checklist.length && widget.generatedRecipes != null) {
        timer.cancel();
        // Go to step 3
        setState(() {
          _currentStep = 3;
        });
        _recipesController.forward();
      }
    });
  }

  @override
  void dispose() {
    _checklistTimer?.cancel();
    _fallingController.dispose();
    _steamController.dispose();
    _recipesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            _buildHeaderLogo(),
            SizedBox(height: 20.h),
            _buildTitles(),
            SizedBox(height: 20.h),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_currentStep == 0) _buildStep0List(),
                  if (_currentStep >= 1) _buildPotAndContent(),
                ],
              ),
            ),
            _buildFooterIndicator(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderLogo() {
    // Cooked logo placeholder or real image
    return Image.asset(
      'assets/images/logo.png', // Assuming this exists based on previous code
      height: 40.h,
      errorBuilder: (context, error, stackTrace) => Text(
        "Cooked",
        style: TextStyle(
          color: Colors.redAccent,
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'SF Pro',
        ),
      ),
    );
  }

  Widget _buildTitles() {
    String title = "";
    String subtitle = "";
    // ignore: unused_local_variable
    Color titleColor = Colors.redAccent;

    switch (_currentStep) {
      case 0:
        title = "Detecting\ningredients...";
        subtitle = "We're identifying what you have.";
        titleColor = Colors.redAccent;
        break;
      case 1:
        title = "Matching\nrecipes...";
        subtitle = "Finding meals that fit your taste.";
        titleColor = Colors.redAccent;
        break;
      case 2:
        title = "Building\nyour recipes...";
        subtitle = "Balancing taste, time, and nutrition.";
        titleColor = Colors.redAccent;
        break;
      case 3:
        title = "Recipes ready!";
        subtitle = "Your personalized meals are ready to cook.";
        titleColor = Colors.redAccent;
        break;
    }

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1E293B),
            height: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStep0List() {
    if (widget.detectedIngredients == null) {
      return Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: widget.detectedIngredients!.length,
      itemBuilder: (context, index) {
        final ing = widget.detectedIngredients![index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(ing.icon ?? "🥘", style: TextStyle(fontSize: 24.sp)),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  ing.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              Icon(Icons.check_circle, color: Colors.redAccent, size: 24.sp),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPotAndContent() {
    // The pot will be at the bottom of this stack area.
    return Stack(
      children: [
        // Content that goes IN the pot (Ingredients falling or Recipes rising)
        // We use a ClipRect to mask out the bottom half so they disappear "into" the pot
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double potTopLine = constraints.maxHeight - 180.h; // Adjust this based on pot image height
              
              return ClipRect(
                clipper: PotClipper(potTopLine),
                child: Stack(
                  children: [
                    if (_currentStep == 1) _buildFallingIngredients(constraints),
                    if (_currentStep == 3) _buildRisingRecipes(constraints),
                  ],
                ),
              );
            },
          ),
        ),

        // Steam (Behind pot, but above falling ingredients conceptually if we want, or just behind)
        if (_currentStep == 2 || _currentStep == 3)
          Positioned(
            bottom: 120.h,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _steamController,
              child: Image.asset(
                'assets/images/steam.png', // User should provide this
                height: 150.h,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),

        // The Pot Image (Always at bottom)
        Positioned(
          bottom: 20.h,
          left: 0,
          right: 0,
          child: Image.asset(
            'assets/images/pot.png', // User should provide this
            height: 200.h,
            errorBuilder: (_, __, ___) => Container(
              height: 200.h,
              margin: EdgeInsets.symmetric(horizontal: 40.w),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(80.r),
                  bottomRight: Radius.circular(80.r),
                ),
              ),
              child: Center(
                child: Text(
                  "assets/images/pot.png",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          ),
        ),

        // Checklist for step 2 (Above the pot)
        if (_currentStep == 2)
          Positioned(
            top: 20.h,
            left: 40.w,
            right: 40.w,
            child: _buildChecklist(),
          ),
      ],
    );
  }

  Widget _buildChecklist() {
    return Column(
      children: List.generate(_checklist.length, (index) {
        bool isChecked = index < _checkedCount;
        bool isCurrent = index == _checkedCount;

        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Row(
            children: [
              if (isChecked)
                Icon(Icons.check_circle, color: Colors.redAccent, size: 24.sp)
              else if (isCurrent)
                SizedBox(
                  width: 24.sp,
                  height: 24.sp,
                  child: CircularProgressIndicator(
                    color: Colors.redAccent,
                    strokeWidth: 2.5,
                  ),
                )
              else
                Icon(Icons.circle_outlined, color: Colors.grey.shade400, size: 24.sp),
              SizedBox(width: 16.w),
              Text(
                _checklist[index],
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                  color: isChecked || isCurrent ? const Color(0xFF1E293B) : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFallingIngredients(BoxConstraints constraints) {
    if (widget.detectedIngredients == null) return const SizedBox();

    return AnimatedBuilder(
      animation: _fallingController,
      builder: (context, child) {
        return Stack(
          children: widget.detectedIngredients!.asMap().entries.map((entry) {
            final int i = entry.key;
            final ing = entry.value;

            // Simple physics simulation
            final double startY = -50.h;
            final double endY = constraints.maxHeight - 150.h;
            
            // Stagger falls
            final double delay = i * 0.1;
            double progress = (_fallingController.value - delay) / (1 - delay);
            progress = progress.clamp(0.0, 1.0);

            // Ease in out curve
            final double curvedProgress = Curves.easeInOutCubic.transform(progress);

            final double currentY = startY + (endY - startY) * curvedProgress;
            
            // Scatter horizontally
            final double xOffset = sin(i * 1.5) * 60.w;

            return Positioned(
              top: currentY,
              left: constraints.maxWidth / 2 + xOffset - 20.w,
              child: Opacity(
                opacity: progress > 0 && progress < 0.95 ? 1.0 : 0.0,
                child: Text(
                  ing.icon ?? "🍅",
                  style: TextStyle(fontSize: 40.sp),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRisingRecipes(BoxConstraints constraints) {
    if (widget.generatedRecipes == null || widget.generatedRecipes!.isEmpty) return const SizedBox();

    return AnimatedBuilder(
      animation: _recipesController,
      builder: (context, child) {
        return Stack(
          children: widget.generatedRecipes!.take(3).toList().asMap().entries.map((entry) {
            final int i = entry.key;
            final recipe = entry.value;

            final double startY = constraints.maxHeight - 150.h;
            final double endY = 40.h + (i == 1 ? 0 : 60.h); // Center one is higher
            
            final double progress = Curves.elasticOut.transform(_recipesController.value);
            final double currentY = startY + (endY - startY) * progress;

            double angle = 0.0;
            double leftOffset = constraints.maxWidth / 2 - 70.w;
            
            if (i == 0) {
              angle = -0.2;
              leftOffset -= 80.w;
            } else if (i == 2) {
              angle = 0.2;
              leftOffset += 80.w;
            }

            return Positioned(
              top: currentY,
              left: leftOffset,
              child: Transform.rotate(
                angle: angle * progress,
                child: Container(
                  width: 140.w,
                  height: 180.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    image: (recipe.image != null && recipe.image!.isNotEmpty) ? DecorationImage(
                      image: NetworkImage(recipe.image!),
                      fit: BoxFit.cover,
                    ) : null,
                  ),
                  child: (recipe.image == null || recipe.image!.isEmpty) ? Center(child: Icon(Icons.fastfood, color: Colors.grey, size: 40.sp)) : null,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFooterIndicator() {
    if (_currentStep == 3) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: ElevatedButton(
          onPressed: widget.onAnimationComplete,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE23E3E), // Cooked Red
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
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        // Dot indicator mapping
        int activeIndex = _currentStep == 0 ? 0 : (_currentStep == 1 || _currentStep == 2 ? 1 : 2);
        bool isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          height: 8.h,
          width: isActive ? 8.h : 8.h,
          decoration: BoxDecoration(
            color: isActive ? Colors.redAccent : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}



// Actually, to clip, we should use a ClipPath or ClipRect around the CustomPaint or Stack.
// Let's modify the ClipRect in _buildPotAndContent to use a CustomClipper.

class PotClipper extends CustomClipper<Rect> {
  final double clipY;

  PotClipper(this.clipY);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width, clipY);
  }

  @override
  bool shouldReclip(covariant PotClipper oldClipper) => oldClipper.clipY != clipY;
}

// Modify _buildPotAndContent's LayoutBuilder:
// child: ClipRect(
//   clipper: PotClipper(potTopLine),
//   child: Stack( ... )
// )
