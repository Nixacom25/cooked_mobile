import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rive/rive.dart' hide LinearGradient, Image;
import 'package:video_player/video_player.dart';
import '../models/recipe.dart';

class ScanAnimationOverlay extends StatefulWidget {
  final List<RecipeIngredient>? detectedIngredients;
  final List<Recipe>? generatedRecipes;
  final VoidCallback onAnimationComplete;
  final String? imagePath;
  final bool showTestControls;

  const ScanAnimationOverlay({
    super.key,
    this.detectedIngredients,
    this.generatedRecipes,
    required this.onAnimationComplete,
    this.imagePath,
    this.showTestControls = false,
  });

  @override
  State<ScanAnimationOverlay> createState() => _ScanAnimationOverlayState();
}

class _ScanAnimationOverlayState extends State<ScanAnimationOverlay> {
  Timer? _minAnimationTimer;
  Timer? _maxTimeoutTimer;
  bool _minAnimationFinished = false;
  Artboard? _artboard;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadAnimationAsset();

    if (!widget.showTestControls) {
      // Allow 1 quick scan loop (2.0s) minimum before dismissing once AI data is ready
      _minAnimationTimer = Timer(const Duration(milliseconds: 2000), () {
        if (mounted) {
          setState(() {
            _minAnimationFinished = true;
          });
          _tryComplete();
        }
      });
      // Safety max timeout (12s) to guarantee screen transition
      _maxTimeoutTimer = Timer(const Duration(seconds: 12), () {
        if (mounted) {
          widget.onAnimationComplete();
        }
      });
    }
  }

  Future<void> _loadAnimationAsset() async {
    // 1. Try loading MOV video asset first
    try {
      final movController = VideoPlayerController.asset('assets/cooked.mov');
      await movController.initialize();
      movController.setLooping(true);
      movController.play();
      if (mounted) {
        setState(() {
          _videoController = movController;
          _isVideoInitialized = true;
        });
        return;
      }
    } catch (_) {
      // Try MP4 if MOV is not present
      try {
        final mp4Controller = VideoPlayerController.asset('assets/cooked.mp4');
        await mp4Controller.initialize();
        mp4Controller.setLooping(true);
        mp4Controller.play();
        if (mounted) {
          setState(() {
            _videoController = mp4Controller;
            _isVideoInitialized = true;
          });
          return;
        }
      } catch (_) {
        // Fallback to Rive
      }
    }

    // 2. Fallback to Rive file
    await _loadRiveAnimation();
  }

  Future<void> _loadRiveAnimation() async {
    try {
      final data = await rootBundle.load('assets/cooked.riv');
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;

      // 1. Activate State Machine controller if present
      if (artboard.stateMachines.isNotEmpty) {
        final smName = artboard.stateMachines.first.name;
        final controller = StateMachineController.fromArtboard(
          artboard,
          smName,
        );
        if (controller != null) {
          controller.isActive = true;
          artboard.addController(controller);
        }
      } else if (artboard.animations.isNotEmpty) {
        // 2. Activate ONLY primary timeline animation if no State Machine
        artboard.addController(
          SimpleAnimation(artboard.animations.first.name, autoplay: true),
        );
      }

      if (mounted) {
        setState(() {
          _artboard = artboard;
        });
      }
    } catch (e) {
      debugPrint('Error loading cooked.riv animation: $e');
    }
  }

  @override
  void didUpdateWidget(ScanAnimationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.showTestControls) {
      _tryComplete();
    }
  }

  void _tryComplete() {
    if (widget.showTestControls) return;

    // Transition as soon as AI response arrives (recipes or ingredients non-null)
    final bool hasData =
        widget.generatedRecipes != null || widget.detectedIngredients != null;

    if (_minAnimationFinished && hasData) {
      _maxTimeoutTimer?.cancel();
      widget.onAnimationComplete();
    }
  }

  @override
  void dispose() {
    _minAnimationTimer?.cancel();
    _maxTimeoutTimer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Stack(
        children: [
          Positioned.fill(
            child: _isVideoInitialized && _videoController != null
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  )
                : (_artboard != null
                    ? Rive(
                        artboard: _artboard!,
                        fit: BoxFit.contain,
                        antialiasing: true,
                      )
                    : const _FallbackScanAnimation()),
          ),
          if (widget.showTestControls)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.h,
              right: 20.w,
              child: GestureDetector(
                onTap: widget.onAnimationComplete,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6.r,
                        offset: Offset(0, 3.h),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, color: Colors.white, size: 16.sp),
                      SizedBox(width: 6.w),
                      Text(
                        "Fermer",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SF Pro',
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

class _FallbackScanAnimation extends StatefulWidget {
  const _FallbackScanAnimation();

  @override
  State<_FallbackScanAnimation> createState() => _FallbackScanAnimationState();
}

class _FallbackScanAnimationState extends State<_FallbackScanAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * 3.14159,
                child: Container(
                  width: 100.r,
                  height: 100.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        const Color(0xFFC83A2D).withValues(alpha: 0.0),
                        const Color(0xFFC83A2D).withValues(alpha: 0.8),
                        const Color(0xFFC83A2D),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(4.r),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.restaurant_menu_rounded,
                          size: 40.sp,
                          color: const Color(0xFFC83A2D),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24.h),
          Text(
            'Analyzing recipe...',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
