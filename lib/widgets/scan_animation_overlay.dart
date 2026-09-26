import 'dart:async';
import 'dart:io' as io;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rive/rive.dart';
import 'package:video_player/video_player.dart';
import '../models/recipe.dart';
import '../core/widgets/ios_toast.dart';
import '../core/theme/app_theme.dart';
import '../services/error_monitoring_service.dart';

enum _AnimationPlatform { ios, android }

class ScanAnimationOverlay extends StatefulWidget {
  final List<RecipeIngredient>? detectedIngredients;
  final List<Recipe>? generatedRecipes;
  final VoidCallback onAnimationComplete;
  final String? imagePath;
  final bool showTestControls;
  final bool skipImageAnalysis;

  const ScanAnimationOverlay({
    super.key,
    this.detectedIngredients,
    this.generatedRecipes,
    required this.onAnimationComplete,
    this.imagePath,
    this.showTestControls = false,
    this.skipImageAnalysis = false,
  });

  @override
  State<ScanAnimationOverlay> createState() => _ScanAnimationOverlayState();
}

class _ScanAnimationOverlayState extends State<ScanAnimationOverlay> {
  Timer? _minAnimationTimer;
  Timer? _maxTimeoutTimer;
  Timer? _imageScanTimer;
  bool _minAnimationFinished = false;
  bool _completionRequested = false;
  bool _showRive = false;
  _AnimationPlatform? _testPlatform;
  VideoPlayerController? _videoController;
  Future<void>? _videoInitialization;
  bool _isDark = false;
  bool _dependenciesResolved = false;

  static const _defaultScanImage = 'assets/images/scan.png';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newIsDark = Theme.of(context).brightness == Brightness.dark;
    if (!_dependenciesResolved || _isDark != newIsDark) {
      _isDark = newIsDark;
      _dependenciesResolved = true;

      final isTestEnvironment = WidgetsBinding.instance.runtimeType
          .toString()
          .toLowerCase()
          .contains('test');
      if (!isTestEnvironment &&
          (widget.showTestControls ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        _prepareVideo();
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _showRive = widget.skipImageAnalysis;
    if (widget.skipImageAnalysis) {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showAnimation();
        });
      }
    } else {
      _imageScanTimer = Timer(const Duration(seconds: 3), () {
        _showAnimation();
      });
    }

    if (!widget.showTestControls) {
      // The scan image must remain visible for the full 3-second scan.
      final int minDurationMs = widget.skipImageAnalysis ? 500 : 3000;
      _minAnimationTimer = Timer(Duration(milliseconds: minDurationMs), () {
        if (mounted) {
          setState(() {
            _minAnimationFinished = true;
          });
          _tryComplete();
        }
      });
      // Keep the celebration visible until recipes are actually available.
      // The timer only releases its own resources; it must never show an empty
      // results page while the AI request is still running.
      _maxTimeoutTimer = Timer(const Duration(seconds: 12), () {
        _maxTimeoutTimer = null;
        _tryComplete();
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

    // Ingredients can arrive before recipe generation. Keep the animation
    // running until there is real content to show in Scan Results.
    final bool hasRecipes = widget.generatedRecipes?.isNotEmpty == true;

    if (_minAnimationFinished && hasRecipes && !_completionRequested) {
      _completionRequested = true;
      _maxTimeoutTimer?.cancel();
      // Defer to after the current frame: this can be reached synchronously
      // from didUpdateWidget while the framework is still building the
      // widget tree (e.g. ScanScreen rebuilding a Positioned ancestor), and
      // calling onAnimationComplete() there - which triggers setState() on
      // the parent ScanScreen - crashes with "setState() or markNeedsBuild()
      // called during build". Confirmed via a real Crashlytics fatal crash
      // report (Tecno / Android 13 devices).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onAnimationComplete();
        }
      });
    }
  }

  @override
  void dispose() {
    _minAnimationTimer?.cancel();
    _maxTimeoutTimer?.cancel();
    _imageScanTimer?.cancel();
    _videoController?.dispose();
    debugPrint('🎬 ScanAnimationOverlay disposed');
    super.dispose();
  }

  bool get _usesVideo =>
      (_testPlatform ??
          (defaultTargetPlatform == TargetPlatform.iOS
              ? _AnimationPlatform.ios
              : _AnimationPlatform.android)) ==
      _AnimationPlatform.ios;

  // cooked_dark.mp4 can fail to decode (a corrupt export did); on iOS the
  // Rive fallback doesn't render either, so fall back to the light video.
  bool _darkVideoFailed = false;

  void _prepareVideo() {
    final assetPath = _isDark && !_darkVideoFailed
        ? 'assets/animations/cooked_dark.mp4'
        : 'assets/animations/cooked.mp4';

    debugPrint('🎬 Preparing video: $assetPath (isDark: $_isDark)');

    if (_videoController == null ||
        _videoController!.dataSource != assetPath) {
      _videoController?.dispose();
      _videoController = VideoPlayerController.asset(assetPath);
      _videoInitialization = _videoController!.initialize().then((_) {
        debugPrint('✅ Video initialized successfully: ${_videoController!.value.size}');
        _videoController!.setLooping(false);
      }).catchError((error) {
        debugPrint('❌ Video initialization failed for $assetPath: $error');
        throw error;
      });
    }
  }

  Future<void> _playVideo() async {
    _prepareVideo();
    await _videoInitialization;
    if (_videoController == null || !_videoController!.value.isInitialized) {
      throw Exception('Video controller not initialized');
    }
    await _videoController!.seekTo(Duration.zero);
    await _videoController!.play();
    debugPrint('✅ Video playing successfully (isDark: $_isDark)');
  }

  Future<void> _showAnimation() async {
    if (_usesVideo) {
      try {
        try {
          await _playVideo();
        } catch (error) {
          if (!_isDark || _darkVideoFailed) rethrow;
          debugPrint('❌ Dark video failed, using light video: $error');
          ErrorMonitoringService.instance.recordRiveAnimationFailure(
            animationName: 'cooked_dark.mp4',
            reason: error.toString(),
          );
          _darkVideoFailed = true;
          await _playVideo();
        }
      } catch (error) {
        debugPrint('❌ Video animation failed, falling back to Rive: $error');
        ErrorMonitoringService.instance.recordRiveAnimationFailure(
          animationName: 'cooked.mp4',
          reason: error.toString(),
        );
        if (mounted) {
          setState(() {
            _testPlatform = _AnimationPlatform.android;
          });
        }
      }
    }
    if (mounted) {
      setState(() {
        _showRive = true;
      });
    }
  }

  Future<void> _chooseTestPlatform() async {
    final selectedPlatform = await showDialog<_AnimationPlatform>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la plateforme'),
        content: const Text('Quelle animation veux-tu tester ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _AnimationPlatform.ios),
            child: const Text('iOS'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _AnimationPlatform.android),
            child: const Text('Android'),
          ),
        ],
      ),
    );

    if (selectedPlatform == null || !mounted) return;
    _imageScanTimer?.cancel();
    setState(() {
      _testPlatform = selectedPlatform;
      _showRive = widget.skipImageAnalysis;
    });

    if (!widget.skipImageAnalysis) {
      await Future<void>.delayed(const Duration(seconds: 3));
      if (mounted) await _showAnimation();
    } else {
      await _showAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: context.colors.surface,
      child: Stack(
        children: [
          if (!widget.skipImageAnalysis && !_showRive)
            Positioned.fill(
              child: _ImageScanAnimation(
                imagePath: widget.imagePath ?? _defaultScanImage,
              ),
            ),
          if (_showRive)
            Positioned.fill(
              child: _usesVideo && _videoController != null
                  ? _VideoAnimation(controller: _videoController!)
                  : _FallbackScanAnimation(
                      skipImageAnalysis: widget.skipImageAnalysis,
                      isDark: _isDark,
                    ),
            ),
          if (widget.showTestControls)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.h,
              right: 20.w,
              child: GestureDetector(
                onTap: _testPlatform == null
                    ? _chooseTestPlatform
                    : widget.onAnimationComplete,
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
                      Icon(
                        _testPlatform == null ? Icons.play_arrow : Icons.close,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        _testPlatform == null ? "Tester" : "Fermer",
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

/// Joue l'animation commune aux trois parcours. Le scan de l'image est rendu
/// séparément par [_ImageScanAnimation] afin de pouvoir le superposer au Rive.
class _FallbackScanAnimation extends StatefulWidget {
  final bool skipImageAnalysis;
  final bool isDark;
  const _FallbackScanAnimation({
    this.skipImageAnalysis = false,
    this.isDark = false,
  });

  @override
  State<_FallbackScanAnimation> createState() => _FallbackScanAnimationState();
}

class _FallbackScanAnimationState extends State<_FallbackScanAnimation> {
  FileLoader? _fileLoader;
  Timer? _riveLoadTimeoutTimer;
  bool _riveLoaded = false;
  bool _forceFallback = false;

  @override
  void initState() {
    super.initState();
    final bool isTestEnv = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (!isTestEnv) {
      // 1. Utilisation de Factory.flutter pour être compatible avec Impeller (iOS)
      // 2. Suppression de l'appel manuel ..file() qui provoquait une race condition
      // 3. Le même Rive sans scan est utilisé pour Scan, Type Ingredients et Saved.
      // 4. iOS-specific: Use same Rive files but with proper configuration
      _fileLoader = FileLoader.fromAsset(
        widget.isDark
            ? 'assets/animations/cooked_rkdarkm.riv'
            : 'assets/animations/cooked_no_scan.riv',
        riveFactory: Factory.flutter,
      );

      // Safety net: if Rive hasn't finished loading (or failed loudly) within
      // a few seconds - e.g. a native-side failure that never surfaces as a
      // catchable Dart error and leaves RiveWidgetBuilder stuck in its
      // "loading" state - force the native spinner instead of a blank screen.
      _riveLoadTimeoutTimer = Timer(const Duration(seconds: 8), () {
        if (mounted && !_riveLoaded) {
          debugPrint('⏱️ Rive load timed out, falling back to native spinner');
          if (context.mounted) {
            IosToast.show(
              context,
              message:
                  '⏱️ Scan animation timed out (${defaultTargetPlatform.name}), using fallback',
              type: ToastType.warning,
            );
          }
          setState(() {
            _forceFallback = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _riveLoadTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_fileLoader == null || _forceFallback) {
      return _NativeSpinnerFallback(
        skipImageAnalysis: widget.skipImageAnalysis,
      );
    }

    return SizedBox.expand(
      child: RiveWidgetBuilder(
        fileLoader: _fileLoader!,
        artboardSelector: const ArtboardDefault(),
        stateMachineSelector: const StateMachineDefault(),
        onLoaded: (RiveLoaded state) {
          debugPrint(
            '✅ Rive animation cooked_no_scan.riv loaded using Factory.flutter!',
          );
          debugPrint('📱 Platform: ${defaultTargetPlatform.name}');
          debugPrint('🎨 Artboard size: ${state.controller.artboard?.bounds}');
          debugPrint('🔧 State machine inputs: ${state.controller.stateMachine?.inputs}');
          
          _riveLoaded = true;
          _riveLoadTimeoutTimer?.cancel();
          final sm = state.controller.stateMachine;

          try {
            // ignore: deprecated_member_use
            final burst = sm.boolean('burstActive');
            burst?.value = true;
            debugPrint('✅ Set burstActive to true');
          } catch (e) {
            debugPrint('⚠️ Rive input burstActive notice: $e');
          }

          try {
            // ignore: deprecated_member_use
            final skipScan =
                sm.boolean('skipScan') ??
                // ignore: deprecated_member_use
                sm.boolean('directRecipes') ??
                // ignore: deprecated_member_use
                sm.boolean('cookingPhase');
            skipScan?.value = true;
            debugPrint('✅ Set skipScan/directRecipes/cookingPhase to true');
          } catch (e) {
            debugPrint('⚠️ Rive input skipScan notice: $e');
          }

          // iOS-specific: Ensure proper artboard alignment
          if (defaultTargetPlatform == TargetPlatform.iOS) {
            debugPrint('🍎 iOS-specific: Configuring artboard alignment');
            // Note: ArtboardOrigin may not be available in current Rive version
            // This is handled by fit and alignment parameters instead
          }
        },
        onFailed: (Object error, StackTrace stackTrace) {
          debugPrint('❌ RIVE LOAD ERROR on ${defaultTargetPlatform.name}: $error');
          debugPrint('❌ Stack trace: $stackTrace');
          _riveLoadTimeoutTimer?.cancel();
          
          // Record Rive animation failure for monitoring
          if (defaultTargetPlatform == TargetPlatform.iOS) {
            debugPrint('🍎 iOS Rive failure detected - recording error');
            ErrorMonitoringService.instance.recordRiveAnimationFailure(
              animationName: widget.isDark ? 'cooked_rkdarkm.riv' : 'cooked_no_scan.riv',
              reason: error.toString(),
            );
          }
          
          if (context.mounted) {
            IosToast.show(
              context,
              message:
                  '❌ Scan animation failed (${defaultTargetPlatform.name}): $error',
              type: ToastType.error,
            );
          }
        },
        builder: (context, state) {
          switch (state) {
            case RiveLoaded loadedState:
              debugPrint('🎨 Rendering Rive widget with fit: Fit.cover');
              return RepaintBoundary(
                child: RiveWidget(
                  controller: loadedState.controller,
                  fit: Fit.cover,
                  alignment: Alignment.center,
                ),
              );
            case RiveFailed():
              debugPrint('⚠️ Rive state is RiveFailed, using fallback spinner');
              return _NativeSpinnerFallback(
                skipImageAnalysis: widget.skipImageAnalysis,
              );
            case RiveLoading():
              debugPrint('⏳ Rive loading on ${defaultTargetPlatform.name}');
              // Do not display spinner before Rive launches - keep background clean
              return const SizedBox.expand();
          }
        },
      ),
    );
  }
}

class _VideoAnimation extends StatefulWidget {
  final VideoPlayerController controller;

  const _VideoAnimation({required this.controller});

  @override
  State<_VideoAnimation> createState() => _VideoAnimationState();
}

class _VideoAnimationState extends State<_VideoAnimation> {
  @override
  void initState() {
    super.initState();
    if (widget.controller.value.isInitialized && !widget.controller.value.isPlaying) {
      widget.controller.play();
    }
    // Stay on the last frame instead of looping or going blank once done.
    widget.controller.addListener(_onVideoPositionChanged);
  }

  void _onVideoPositionChanged() {
    final value = widget.controller.value;
    if (value.position >= value.duration) {
      widget.controller.pause();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onVideoPositionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.surface,
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: widget.controller,
        builder: (context, value, child) {
          if (!value.isInitialized) return const SizedBox.expand();
          return FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: value.size.width,
              height: value.size.height,
              child: VideoPlayer(widget.controller),
            ),
          );
        },
      ),
    );
  }
}

class _ImageScanAnimation extends StatefulWidget {
  final String imagePath;

  const _ImageScanAnimation({required this.imagePath});

  @override
  State<_ImageScanAnimation> createState() => _ImageScanAnimationState();
}

class _ImageScanAnimationState extends State<_ImageScanAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.imagePath.startsWith('assets/')
        ? Image.asset(widget.imagePath, fit: BoxFit.cover)
        : Image.file(io.File(widget.imagePath), fit: BoxFit.cover);

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          // Dims the photo toward the dark-grid backdrop the dot animation
          // is designed against, while keeping it clearly visible underneath
          // rather than hiding it.
          Container(color: Colors.black.withValues(alpha: 0.38)),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _DotGridScanPainter(progress: _controller.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A regular grid of dots, dim and tiny by default, with a soft glowing
/// horizontal band that descends then ascends slowly over the scan phase -
/// the whole width lights up together at a given row (not a localized
/// spot), with no hard edge (Gaussian falloff by vertical distance only),
/// fading smoothly back down as the band moves past. Rows near the
/// top/bottom edge fade toward black so the grid dissolves into the dark
/// rather than cutting off.
class _DotGridScanPainter extends CustomPainter {
  final double progress;

  const _DotGridScanPainter({required this.progress});

  static const double _spacing = 11;
  static const double _baseRadius = 0.7;
  static const double _maxRadius = 3.0;
  static const double _glowSigma = 150; // px - wide band = slow, gradual feel
  static const double _edgeFadeDistance = 30; // px from top/bottom to fully dim
  static const Color _dimColor = Color(0xFF10281C);
  static const Color _midColor = Color(0xFF3ED67F);
  static const Color _brightColor = Color(0xFFB8FFDD);

  @override
  void paint(Canvas canvas, Size size) {
    // One full down-then-up cycle over the scan phase: sin(0)=sin(pi)=0, so
    // the wave starts near the top, reaches the bottom at the midpoint, and
    // returns to the top by the end - a single smooth bounce rather than a
    // one-way pass that just gets cut off.
    final wave = math.sin(progress * math.pi);
    final waveY = size.height * (0.05 + 0.85 * wave);

    final cols = (size.width / _spacing).ceil() + 1;
    final rows = (size.height / _spacing).ceil() + 1;

    for (int gy = 0; gy <= rows; gy++) {
      final py = gy * _spacing;
      final dy = py - waveY;
      final intensity = math.exp(-(dy * dy) / (2 * _glowSigma * _glowSigma));

      final edgeDist = math.min(py, size.height - py);
      final edgeFactor = (edgeDist / _edgeFadeDistance).clamp(0.0, 1.0);

      final baseOpacity = 0.12 * edgeFactor;
      final glowOpacity = intensity * edgeFactor;
      final opacity = math.max(baseOpacity, glowOpacity).clamp(0.0, 1.0);
      if (opacity <= 0.01) continue;

      final radius = _baseRadius + (_maxRadius - _baseRadius) * intensity;
      final color = intensity < 0.5
          ? Color.lerp(_dimColor, _midColor, intensity / 0.5)!
          : Color.lerp(_midColor, _brightColor, (intensity - 0.5) / 0.5)!;

      // Same value for every dot on this row - one Paint reused across the
      // whole row instead of allocating one per dot.
      final rowPaint = Paint()..color = color.withValues(alpha: opacity);
      final haloPaint = intensity > 0.55
          ? (Paint()
            ..color = _brightColor.withValues(alpha: (intensity - 0.55) * 0.32)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5))
          : null;

      for (int gx = 0; gx <= cols; gx++) {
        final px = gx * _spacing;
        canvas.drawCircle(Offset(px, py), radius, rowPaint);

        // Subtle halo only on the brightest rows near the wave's centre -
        // deliberately small/low-opacity so it stays a thin glow rather
        // than a blurry blob.
        if (haloPaint != null) {
          canvas.drawCircle(Offset(px, py), radius * 2.1, haloPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridScanPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Ancien spinner Flutter natif, conservé tel quel comme filet de sécurité
/// final si ni la vidéo ni le Rive ne peuvent être chargés.
class _NativeSpinnerFallback extends StatefulWidget {
  final bool skipImageAnalysis;
  const _NativeSpinnerFallback({this.skipImageAnalysis = false});

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
                        context.colors.accent.withValues(alpha: 0.0),
                        context.colors.accent.withValues(alpha: 0.8),
                        context.colors.accent,
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
                          color: context.colors.accent,
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
            widget.skipImageAnalysis
                ? 'Generating recipes...'
                : 'Analyzing recipe...',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
