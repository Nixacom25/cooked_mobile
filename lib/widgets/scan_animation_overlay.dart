import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rive/rive.dart';
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

  @override
  void initState() {
    super.initState();
    _RiveScanPreloader.preload();

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
          const Positioned.fill(
            child: _FallbackScanAnimation(),
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

/// Remplace l'ancien spinner natif : essaie de jouer assets/cooked.riv,
/// et si le fichier est absent / corrompu / mal déclaré, retombe sur
/// l'animation Flutter native (_NativeSpinnerFallback) pour ne jamais
/// bloquer l'écran.
/// Gestionnaire de pré-chargement en mémoire pour annuler toute latence d'E/S
class _RiveScanPreloader {
  static FileLoader? _cachedLoader;

  static FileLoader? getLoader() {
    final bool isTestEnv = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');

    if (isTestEnv) {
      return null;
    }

    return _cachedLoader ??= FileLoader.fromAsset(
      'assets/cooked.riv',
      riveFactory: Factory.rive,
    )..file(); // Pré-charge les octets en arrière-plan immédiatement
  }

  static void preload() {
    getLoader();
  }
}

class _FallbackScanAnimation extends StatefulWidget {
  const _FallbackScanAnimation();

  @override
  State<_FallbackScanAnimation> createState() => _FallbackScanAnimationState();
}

class _FallbackScanAnimationState extends State<_FallbackScanAnimation> {
  FileLoader? _fileLoader;

  @override
  void initState() {
    super.initState();
    _fileLoader = _RiveScanPreloader.getLoader();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTestEnv = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');

    if (isTestEnv || _fileLoader == null) {
      return const _NativeSpinnerFallback();
    }

    return SizedBox.expand(
      child: RiveWidgetBuilder(
        fileLoader: _fileLoader!,
        artboardSelector: const ArtboardDefault(),
        stateMachineSelector: const StateMachineDefault(),
        onLoaded: (RiveLoaded state) {
          debugPrint('✅ Rive animation cooked.riv loaded with 0-latency!');
          try {
            // ignore: deprecated_member_use
            final burst = state.controller.stateMachine.boolean('burstActive');
            burst?.value = true;
          } catch (e) {
            debugPrint('Rive input burstActive notice: $e');
          }
        },
        onFailed: (Object error, StackTrace stackTrace) {
          debugPrint('❌ RIVE LOAD ERROR: $error\n$stackTrace');
        },
        builder: (context, state) {
          switch (state) {
            case RiveLoaded loadedState:
              return RepaintBoundary(
                child: RiveWidget(
                  controller: loadedState.controller,
                  fit: Fit.cover,
                ),
              );
            case RiveFailed():
              debugPrint('⚠️ Rive state is RiveFailed, using fallback spinner');
              return const _NativeSpinnerFallback();
            case RiveLoading():
              return const _NativeSpinnerFallback();
          }
        },
      ),
    );
  }
}

/// Ancien spinner Flutter natif, conservé tel quel comme filet de sécurité
/// final si ni la vidéo ni le Rive ne peuvent être chargés.
class _NativeSpinnerFallback extends StatefulWidget {
  const _NativeSpinnerFallback();

  @override
  State<_NativeSpinnerFallback> createState() => _NativeSpinnerFallbackState();
}

class _NativeSpinnerFallbackState extends State<_NativeSpinnerFallback>
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