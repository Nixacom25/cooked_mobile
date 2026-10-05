import 'dart:async';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/motion/motion_widgets.dart';
import 'cooked_blob_background.dart';
import '../core/l10n/l10n.dart';

/// Stages of a link import. Driven by the real request where possible:
/// [receiving] as soon as the link is accepted, [finding] once the request
/// is sent, [pulling] while the backend is still extracting, [ready] only
/// when the recipe actually came back.
enum ImportStage { receiving, finding, pulling, ready }

extension ImportStageCopy on ImportStage {
  String title(AppLocalizations l10n) {
    switch (this) {
      case ImportStage.receiving:
        return l10n.importStageReceiving;
      case ImportStage.finding:
        return l10n.importStageFinding;
      case ImportStage.pulling:
        return l10n.importStagePulling;
      case ImportStage.ready:
        return l10n.importStageReady;
    }
  }
}

class ImportLoadingPage extends StatefulWidget {
  final String? url;

  /// Real import progress. When null (debug preview) the page plays a demo
  /// sequence through every stage.
  final ValueListenable<ImportStage>? stage;

  const ImportLoadingPage({super.key, this.url, this.stage});

  @override
  State<ImportLoadingPage> createState() => _ImportLoadingPageState();
}

class _ImportLoadingPageState extends State<ImportLoadingPage>
    with TickerProviderStateMixin {
  // Floating Cooked logo.
  late final AnimationController _floatController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  // Skeleton shimmer on the card.
  late final AnimationController _shimmerController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  // Dashed link line flowing from the source icon to the card.
  late final AnimationController _flowController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  // Ready: card bump 1 → 1.03 → 1.
  late final AnimationController _readyController = AnimationController(
    vsync: this,
    duration: Motion.long,
  );

  // Demo mode only.
  final ValueNotifier<ImportStage> _demoStage = ValueNotifier(ImportStage.receiving);
  final List<Timer> _demoTimers = [];

  // Link typewriter.
  Timer? _typingTimer;
  String _typedUrl = '';

  ValueListenable<ImportStage> get _stage => widget.stage ?? _demoStage;

  @override
  void initState() {
    super.initState();
    _startTyping();
    _stage.addListener(_onStage);
    if (widget.stage == null) {
      _demoTimers.addAll([
        Timer(const Duration(milliseconds: 900), () => _demoStage.value = ImportStage.finding),
        Timer(const Duration(milliseconds: 2200), () => _demoStage.value = ImportStage.pulling),
        Timer(const Duration(milliseconds: 4200), () => _demoStage.value = ImportStage.ready),
      ]);
    }
  }

  void _onStage() {
    if (_stage.value == ImportStage.ready) {
      Motion.lightHaptic();
      if (!Motion.reduced(context)) _readyController.forward(from: 0);
    }
    if (mounted) setState(() {});
  }

  void _startTyping() {
    final target = _fullUrl;
    var i = 0;
    _typingTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!mounted) return;
      if (i < target.length) {
        i++;
        setState(() => _typedUrl = target.substring(0, i));
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _stage.removeListener(_onStage);
    _floatController.dispose();
    _shimmerController.dispose();
    _flowController.dispose();
    _readyController.dispose();
    _typingTimer?.cancel();
    for (final t in _demoTimers) {
      t.cancel();
    }
    _demoStage.dispose();
    super.dispose();
  }

  String get _fullUrl {
    final raw = widget.url?.trim();
    if (raw == null || raw.isEmpty) return 'https://www.delicious.com/recipe';
    return raw;
  }

  String get _sourceAsset {
    final url = _fullUrl.toLowerCase();
    if (url.contains('tiktok.com')) return 'assets/icones/tiktok2.svg';
    if (url.contains('instagram.com')) return 'assets/icones/instagram2.svg';
    if (url.contains('youtube.com') || url.contains('youtu.be')) return 'assets/icones/youtube.svg';
    if (url.contains('facebook.com') || url.contains('fb.watch')) return 'assets/icones/facebook2.svg';
    return 'assets/icones/web.svg';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stage = _stage.value;
    final reached = stage.index;
    final d = Motion.of(context, Motion.medium);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAF7F2),
      body: CookedBlobBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 310.w,
                    // Tall enough for the whole card, so the stage copy
                    // below never overlaps it.
                    height: 392.h,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Dashed line from the source icon to the card
                        // (from "finding" until the recipe is ready).
                        Positioned.fill(
                          child: AnimatedOpacity(
                            duration: d,
                            opacity: reached >= ImportStage.finding.index &&
                                    stage != ImportStage.ready
                                ? 1
                                : 0,
                            child: AnimatedBuilder(
                              animation: _flowController,
                              builder: (context, _) => CustomPaint(
                                painter: _LinkFlowPainter(
                                  phase: _flowController.value,
                                  color: isDark ? Colors.white54 : const Color(0xFFC31E26),
                                  from: Offset(38.w, 30.h),
                                  to: Offset(120.w, 118.h),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // The Cooked recipe card: faint while receiving,
                        // materializes once the recipe is being fetched,
                        // bumps when ready.
                        Positioned(
                          left: 15.w,
                          right: 15.w,
                          top: 96.h,
                          child: AnimatedBuilder(
                            animation: _readyController,
                            builder: (context, child) {
                              final t = _readyController.value;
                              final bump = 1 + 0.03 * (t < 0.5 ? t * 2 : (1 - t) * 2);
                              return Transform.scale(scale: bump, child: child);
                            },
                            child: AnimatedOpacity(
                              duration: d,
                              curve: Motion.enter,
                              opacity: reached >= ImportStage.finding.index ? 1 : 0.35,
                              child: AnimatedScale(
                                duration: d,
                                curve: Motion.enter,
                                scale: reached >= ImportStage.finding.index ? 1 : 0.96,
                                child: Transform.rotate(
                                  angle: -0.06,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.topCenter,
                                    children: [
                                      _RecipeCardMock(
                                        typedUrl: _typedUrl,
                                        shimmer: _shimmerController,
                                        stage: stage,
                                      ),
                                      Positioned(
                                        top: -44.h,
                                        child: AnimatedBuilder(
                                          animation: _floatController,
                                          builder: (context, child) => Transform.translate(
                                            offset: Offset(0, -6.h * Curves.easeInOut.transform(_floatController.value)),
                                            child: child,
                                          ),
                                          child: const _LogoBadge(),
                                        ),
                                      ),
                                      // Ready: check pops in on the card.
                                      if (stage == ImportStage.ready)
                                        Positioned(
                                          top: -12.h,
                                          right: -12.w,
                                          child: Container(
                                            width: 38.r,
                                            height: 38.r,
                                            padding: EdgeInsets.all(7.r),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF16A34A),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF16A34A).withValues(alpha: 0.35),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: AnimatedCheck(
                                              size: 24.r,
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                              showCircle: false,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Source icon: enters while the link is received,
                        // then slides up/left as the link flows to the card.
                        AnimatedPositioned(
                          duration: d,
                          curve: Motion.standard,
                          left: reached >= ImportStage.finding.index ? 8.w : 60.w,
                          top: reached >= ImportStage.finding.index ? 4.h : 22.h,
                          child: AnimatedOpacity(
                            duration: d,
                            opacity: stage == ImportStage.ready ? 0 : 1,
                            child: _SourceBadge(
                              asset: _sourceAsset,
                              small: reached >= ImportStage.finding.index,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Stage copy: crossfades up as the import progresses.
                  SizedBox(
                    height: 30.h,
                    child: AnimatedSwitcher(
                      duration: Motion.of(context, Motion.medium),
                      switchInCurve: Motion.enter,
                      switchOutCurve: Motion.exit,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                              .animate(animation),
                          child: child,
                        ),
                      ),
                      // One line, scaled down if a stage label is long
                      // (e.g. "Pulling ingredients & steps…", translations).
                      child: FittedBox(
                        key: ValueKey(stage),
                        fit: BoxFit.scaleDown,
                        child: Text(
                          stage.title(context.l10n),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    context.l10n.importGettingReady,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final String asset;
  final bool small;

  const _SourceBadge({required this.asset, required this.small});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = small ? 44.r : 58.r;
    // Pops in once on first build.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Motion.of(context, Motion.medium),
      curve: Motion.enter,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(scale: 0.7 + 0.3 * t, child: child),
      ),
      child: AnimatedContainer(
        duration: Motion.of(context, Motion.medium),
        curve: Motion.standard,
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.22),
        decoration: BoxDecoration(
          // Same tone as the page background in light mode (like dark mode).
          color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFAF7F2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SvgPicture.asset(
          asset,
          fit: BoxFit.contain,
          // White glyphs would vanish on the light page: draw them black.
          colorFilter: isDark ? null : const ColorFilter.mode(Colors.black, BlendMode.srcIn),
        ),
      ),
    );
  }
}

/// Dashed curve whose dashes travel from the source icon to the card.
class _LinkFlowPainter extends CustomPainter {
  final double phase;
  final Color color;
  final Offset from;
  final Offset to;

  _LinkFlowPainter({
    required this.phase,
    required this.color,
    required this.from,
    required this.to,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(to.dx - 10, from.dy - 6, to.dx, to.dy);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dash = 6.0, gap = 6.0;
    for (final metric in path.computeMetrics()) {
      var d = -((dash + gap) * (1 - phase));
      while (d < metric.length) {
        final start = d.clamp(0.0, metric.length);
        final end = (d + dash).clamp(0.0, metric.length);
        if (end > start) canvas.drawPath(metric.extractPath(start, end), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_LinkFlowPainter old) => old.phase != phase || old.color != color;
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 140.w,
      height: 90.h,
      child: Center(
        child: Image.asset(
          isDark ? 'assets/images/logo_icon_only_dark.png' : 'assets/images/logo_icon_only.png',
          width: 80.w,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _RecipeCardMock extends StatelessWidget {
  final String typedUrl;
  final Animation<double> shimmer;
  final ImportStage stage;

  const _RecipeCardMock({
    required this.typedUrl,
    required this.shimmer,
    required this.stage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final barColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF4F0E8);
    final textColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF6B6B6B);
    final skeletonColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE9E3D8);
    final populating = stage.index >= ImportStage.pulling.index;

    return Container(
      width: 280.w,
      padding: EdgeInsets.fromLTRB(16.w, 42.h, 16.w, 18.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0xFF8C7A6B).withValues(alpha: 0.10),
            blurRadius: 28,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // URL bar
          Container(
            height: 38.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.link_rounded, size: 16.sp, color: textColor),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    typedUrl,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(fontFamily: 'Rubik', fontSize: 12.sp, color: textColor),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: _Shimmering(
                  shimmer: shimmer,
                  active: !populating,
                  child: Image.asset(
                    'assets/images/scan.webp',
                    width: 82.w,
                    height: 82.w,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 82.w,
                      height: 82.w,
                      color: skeletonColor,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bar(width: 130.w, height: 10.h, color: skeletonColor, shimmer: shimmer, active: !populating),
                      SizedBox(height: 8.h),
                      _Bar(width: 90.w, height: 10.h, color: skeletonColor, shimmer: shimmer, active: !populating),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Ingredient / step lines populate one after another once the
          // backend is extracting them.
          for (int i = 0; i < 4; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 7.h),
              child: populating
                  ? AnimatedCardEntrance(
                      key: ValueKey('line-$i'),
                      index: i,
                      offset: 4,
                      child: _IngredientLine(width: [150.w, 120.w, 170.w, 100.w][i], color: skeletonColor),
                    )
                  : SizedBox(height: 8.h),
            ),
        ],
      ),
    );
  }
}

class _IngredientLine extends StatelessWidget {
  final double width;
  final Color color;

  const _IngredientLine({required this.width, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8.r,
          height: 8.r,
          decoration: const BoxDecoration(color: Color(0xFFC31E26), shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Container(
          width: width,
          height: 8.h,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6.r)),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Animation<double> shimmer;
  final bool active;

  const _Bar({
    required this.width,
    required this.height,
    required this.color,
    required this.shimmer,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.r),
      child: _Shimmering(
        shimmer: shimmer,
        active: active,
        child: Container(width: width, height: height, color: color),
      ),
    );
  }
}

/// Light sweep over [child] while [active].
class _Shimmering extends StatelessWidget {
  final Animation<double> shimmer;
  final bool active;
  final Widget child;

  const _Shimmering({required this.shimmer, required this.active, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!active || Motion.reduced(context)) return child;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlight = isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.55);
    return AnimatedBuilder(
      animation: shimmer,
      child: child,
      builder: (context, child) => Stack(
        children: [
          child!,
          Positioned.fill(
            child: ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.white.withValues(alpha: 0), highlight, Colors.white.withValues(alpha: 0)],
                stops: const [0, 0.5, 1],
                transform: _Slide(-1 + 3 * shimmer.value),
              ).createShader(bounds),
              child: Container(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide extends GradientTransform {
  final double percent;
  const _Slide(this.percent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * percent, 0, 0);
}
