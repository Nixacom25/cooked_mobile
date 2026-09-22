import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rive/rive.dart';
import 'package:video_player/video_player.dart';
import '../models/recipe.dart';
import '../core/widgets/ios_toast.dart';
import '../core/theme/app_theme.dart';

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

  void _prepareVideo() {
    // Always use light mode video since dark mode video doesn't work properly
    final assetPath = 'assets/animations/cooked.mp4';

    debugPrint('🎬 Preparing video: $assetPath (isDark: $_isDark)');

    // Always use light mode video since dark mode video doesn't work properly
    // If the controller doesn't exist or points to the wrong asset, reinitialize it
    if (_videoController == null ||
        _videoController!.dataSource != assetPath) {
      _videoController?.dispose();
      _videoController = VideoPlayerController.asset(assetPath);
      _videoInitialization = _videoController!.initialize().then((_) {
        debugPrint('✅ Video initialized successfully: ${_videoController!.value.size}');
        // Configure video to loop for iOS
        _videoController!.setLooping(false);
      }).catchError((error) {
        debugPrint('❌ Video initialization failed: $error');
        throw error;
      });
    }
  }

  Future<void> _showAnimation() async {
    if (_usesVideo) {
      try {
        debugPrint('🎬 Starting video animation (iOS mode)');
        _prepareVideo();
        await _videoInitialization;
        
        if (_videoController != null && _videoController!.value.isInitialized) {
          await _videoController!.seekTo(Duration.zero);
          await _videoController!.play();
          debugPrint('✅ Video playing successfully');
        } else {
          debugPrint('⚠️ Video controller not initialized properly');
          throw Exception('Video controller not initialized');
        }
      } catch (error) {
        debugPrint('❌ Video animation failed, falling back to Rive: $error');
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
    } else if (selectedPlatform == _AnimationPlatform.ios) {
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
              child: _usesVideo
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
      _riveLoadTimeoutTimer = Timer(const Duration(seconds: 5), () {
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
          _riveLoaded = true;
          _riveLoadTimeoutTimer?.cancel();
          final sm = state.controller.stateMachine;

          try {
            // ignore: deprecated_member_use
            final burst = sm.boolean('burstActive');
            burst?.value = true;
          } catch (e) {
            debugPrint('Rive input burstActive notice: $e');
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
          } catch (_) {}
        },
        onFailed: (Object error, StackTrace stackTrace) {
          debugPrint('❌ RIVE LOAD ERROR: $error\n$stackTrace');
          _riveLoadTimeoutTimer?.cancel();
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
              return RepaintBoundary(
                child: RiveWidget(
                  controller: loadedState.controller,
                  fit: Fit.cover,
                ),
              );
            case RiveFailed():
              debugPrint('⚠️ Rive state is RiveFailed, using fallback spinner');
              return _NativeSpinnerFallback(
                skipImageAnalysis: widget.skipImageAnalysis,
              );
            case RiveLoading():
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
    debugPrint('🎬 _VideoAnimation mounted');
    // Ensure video continues playing when widget rebuilds
    if (widget.controller.value.isInitialized && !widget.controller.value.isPlaying) {
      widget.controller.play();
    }
    // Listen for video completion to stay on last frame
    widget.controller.addListener(_onVideoPositionChanged);
  }

  void _onVideoPositionChanged() {
    final value = widget.controller.value;
    if (value.position >= value.duration) {
      debugPrint('🎬 Video completed, staying on last frame');
      widget.controller.pause();
    }
  }

  @override
  void dispose() {
    debugPrint('🎬 _VideoAnimation disposing');
    widget.controller.removeListener(_onVideoPositionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: widget.controller,
        builder: (context, value, child) {
          if (!value.isInitialized) {
            debugPrint('⏳ Video not initialized yet, showing placeholder');
            return const SizedBox.expand();
          }

          debugPrint('🎬 Video playing: ${value.isPlaying}, size: ${value.size}');

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final image = widget.imagePath.startsWith('assets/')
        ? Image.asset(widget.imagePath, fit: BoxFit.cover)
        : Image.file(io.File(widget.imagePath), fit: BoxFit.cover);

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _ScanSweepPainter(progress: _controller.value, isDark: isDark),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ScanSweepPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  const _ScanSweepPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final scanY = size.height * progress;
    // Adapt scan color to theme - lighter for dark mode
    final scanColor = isDark 
        ? const Color(0xFF4CAF50).withValues(alpha: 0.3)  // Green for dark mode
        : const Color(0xFF42D77D).withValues(alpha: 0.18); // Original green for light mode
    
    final tintPaint = Paint()
      ..color = scanColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, scanY), tintPaint);

    final glowPaint = Paint()
      ..color = isDark
          ? const Color(0xFF4CAF50).withValues(alpha: 0.5)
          : const Color(0xFF42D77D).withValues(alpha: 0.35)
      ..strokeWidth = 14;
    canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), glowPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF8CFFB1)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), linePaint);
  }

  @override
  bool shouldRepaint(_ScanSweepPainter oldDelegate) =>
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
