import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/l10n/l10n.dart';
import 'splash_pattern.dart';
import 'splash_screen.dart';

/// Splash "B · Scan frame" (Claude Design), dev preview only (Welcome's
/// debug button). Sequence:
///  1. the logo pops in (0 – 1.2 s)
///  2. the four scan corners snap in one after another (1.0 – 1.9 s)
///  3. the scan line appears and sweeps down and up in a loop (from 2 s)
/// The tagline rises at the end. Tap anywhere to close.
class ScanFrameSplash extends StatefulWidget {
  /// False hides the logo (the splash → welcome preview flies its own copy).
  final bool showLogo;

  /// Tap anywhere closes it (standalone preview).
  final bool closeOnTap;

  /// Set (splash → welcome preview): the scan makes ONE round trip, then the
  /// corners and the scan line fade out together, and this is called as
  /// that fade ends so the next transition follows without a pause.
  /// Null: the scan loops forever (standalone preview).
  final VoidCallback? onFrameDone;

  const ScanFrameSplash({super.key, this.showLogo = true, this.closeOnTap = true, this.onFrameDone});

  @override
  State<ScanFrameSplash> createState() => _ScanFrameSplashState();
}

class _ScanFrameSplashState extends State<ScanFrameSplash> with TickerProviderStateMixin {
  static const _introMs = 2600;
  static const _pop = Cubic(0.2, 0.9, 0.2, 1.2);
  static const _enter = Cubic(0.2, 0.8, 0.2, 1);
  static const _sweepCurve = Cubic(0.45, 0, 0.25, 1);

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _introMs),
  );
  // Down and back up in 2.4 s, like the mockup.
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  // Same blinking dots as splash A.
  late final AnimationController _dots = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  // Corners + scan line leaving together (one round trip mode).
  late final AnimationController _frameOut = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  bool _sweepStarted = false;
  bool _doneSent = false;

  @override
  void initState() {
    super.initState();
    _intro.forward();
    _dots.repeat();
    _intro.addListener(() {
      if (_sweepStarted || _intro.value * _introMs < 2000) return;
      _sweepStarted = true;
      if (widget.onFrameDone == null) {
        _sweep.repeat();
      } else {
        _sweep.forward(from: 0); // down then back up, once
      }
    });
    _sweep.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.onFrameDone != null) _frameOut.forward();
    });
    _frameOut.addListener(() {
      // Hand over slightly before the fade ends: the next motion overlaps it.
      if (!_doneSent && _frameOut.value >= 0.8) {
        _doneSent = true;
        widget.onFrameDone?.call();
      }
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _sweep.dispose();
    _frameOut.dispose();
    _dots.dispose();
    super.dispose();
  }

  /// 0→1 progress of a phase that starts at [startMs] and lasts [ms].
  double _phase(int startMs, int ms, [Curve curve = Curves.linear]) =>
      curve.transform(((_intro.value * _introMs - startMs) / ms).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      _intro.value = 1;
      _sweep.stop();
      _dots.stop();
      if (widget.onFrameDone != null && !_doneSent) {
        _doneSent = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => widget.onFrameDone?.call());
      }
    }
    final frameW = 260.w, frameH = 300.w;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF8E0F14),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.closeOnTap ? () => Navigator.maybePop(context) : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFA8131A), Color(0xFF7A0B10)],
                  ),
                ),
              ),
              // Same drifting pattern and glow behind the logo as splash A.
              const SplashFoodPattern(opacity: 0.06, drift: true),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.12),
                    radius: 0.62,
                    colors: [Color(0xE6C4161C), Color(0x00C4161C)],
                  ),
                ),
              ),
              Center(
                child: Transform.translate(
                  // translate(-50%, -56%) in the mockup: 6 % above center.
                  offset: Offset(0, -frameH * 0.06),
                  child: SizedBox(
                    width: frameW,
                    height: frameH,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_intro, _sweep, _frameOut]),
                      builder: (context, _) {
                        // 4. Frame leaving: corners slide in a touch and fade
                        // with the scan line, as one smooth motion.
                        final out = Curves.easeInOutCubic.transform(_frameOut.value);
                        return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 2. Corners: TL, TR, BR, BL, 150 ms apart.
                          for (var i = 0; i < 4; i++)
                            _corner(i, _phase(1000 + i * 150, 450, _enter), out: out),
                          // 1. Logo pop.
                          if (widget.showLogo) Center(child: _logo(_phase(0, 1200))),
                          // 3. Scan line.
                          _scanLine(frameH, out: out),
                        ],
                      );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24.w,
                right: 24.w,
                bottom: 64.h,
                child: AnimatedBuilder(
                  animation: _intro,
                  builder: (context, child) {
                    final t = _phase(2100, 500, _enter);
                    return Opacity(
                      opacity: t,
                      child: Transform.translate(offset: Offset(0, 14 * (1 - t)), child: child),
                    );
                  },
                  // Same tagline and dots as splash A.
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.splashTagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp, color: Colors.white.withValues(alpha: 0.82)),
                      ),
                      SizedBox(height: 14.h),
                      BlinkingDots(controller: _dots),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logo(double t) {
    final scale = 0.82 + 0.18 * _pop.transform(t);
    return Opacity(
      opacity: (t / 0.6).clamp(0.0, 1.0),
      child: Transform.scale(
        scale: scale,
        child: const SplashLogo(),
      ),
    );
  }

  /// Corner [index] (0 TL, 1 TR, 2 BR, 3 BL): fades in and snaps from 18 px
  /// further out into place, with a slight scale-up.
  Widget _corner(int index, double t, {double out = 0}) {
    const size = 44.0;
    final shift = 18 * (1 - t) - 14 * out;
    final dx = (index == 0 || index == 3) ? -shift : shift;
    final dy = (index == 0 || index == 1) ? -shift : shift;
    final corner = Opacity(
      opacity: t * (1 - out),
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: Transform.scale(
          scale: 0.7 + 0.3 * t,
          child: RotatedBox(
            quarterTurns: index,
            child: const CustomPaint(size: Size(size, size), painter: _CornerPainter()),
          ),
        ),
      ),
    );
    return Positioned(
      left: index == 0 || index == 3 ? 0 : null,
      right: index == 1 || index == 2 ? 0 : null,
      top: index == 0 || index == 1 ? 0 : null,
      bottom: index == 2 || index == 3 ? 0 : null,
      child: corner,
    );
  }

  Widget _scanLine(double frameH, {double out = 0}) {
    final visible = _phase(1950, 300);
    if (visible == 0) return const SizedBox.shrink();
    // top: 6 % → 90 % → 6 %
    final v = _sweep.value;
    final leg = v < 0.5 ? v * 2 : (1 - v) * 2;
    final top = frameH * (0.06 + 0.84 * _sweepCurve.transform(leg));
    return Positioned(
      left: 14,
      right: 14,
      top: top,
      child: Opacity(
        opacity: visible * (1 - out),
        child: Container(
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFFFF5A5E),
            borderRadius: BorderRadius.circular(3),
            boxShadow: const [BoxShadow(color: Color(0x8CFF5A5E), blurRadius: 18, spreadRadius: 6)],
          ),
        ),
      ),
    );
  }
}

/// Top-left scan corner: 4 px white stroke with an 18 px rounded elbow.
class _CornerPainter extends CustomPainter {
  const _CornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 4.0, radius = 18.0;
    const h = stroke / 2;
    final path = Path()
      ..moveTo(h, size.height)
      ..lineTo(h, radius)
      ..arcToPoint(const Offset(radius, h), radius: const Radius.circular(radius - h))
      ..lineTo(size.width, h);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
