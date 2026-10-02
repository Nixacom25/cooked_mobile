import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/l10n/l10n.dart';
import '../../widgets/red_button.dart';
import 'scan_frame_splash.dart';
import 'splash_screen.dart';

enum SplashVariant { signatureRed, scanFrame }

/// Splash → Welcome transition (approved: splash B "Scan frame" at launch).
///  1. the splash plays;
///  2. its logo (the Welcome logo image) rises and shrinks into the Welcome
///     logo slot while the welcome photo fades in over the splash background;
///  3. the welcome texts and buttons come in one after another.
/// At launch ([onFinished] set) the real WelcomeScreen then replaces this
/// screen without animation - it looks exactly the same, so nothing jumps.
/// Without [onFinished] it's the dev preview, whose buttons close it.
class SplashToWelcome extends StatefulWidget {
  final SplashVariant variant;

  /// Awaited before the transition: false skips it (the caller has already
  /// navigated elsewhere, e.g. a signed-in user going Home).
  final Future<bool> Function()? beforeTransition;

  /// Called once the transition has fully played (launch mode).
  final VoidCallback? onFinished;

  const SplashToWelcome({
    super.key,
    this.variant = SplashVariant.signatureRed,
    this.beforeTransition,
    this.onFinished,
  });

  @override
  State<SplashToWelcome> createState() => _SplashToWelcomeState();
}

class _SplashToWelcomeState extends State<SplashToWelcome> with TickerProviderStateMixin {
  static const _moveMs = 1100; // logo rise + background crossfade
  static const _totalMs = 2300; // + texts

  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _totalMs),
  );
  late final AnimationController _hold;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    // Splash A plays for 2.6 s. Splash B decides itself: one full scan
    // round trip, frame fades out, then it calls _start (onFrameDone).
    _hold = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _start();
      });
    _exit.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onFinished?.call();
    });
    if (widget.variant == SplashVariant.signatureRed) _hold.forward();
  }

  bool _starting = false;

  Future<void> _start() async {
    if (_started || _starting || !mounted) return;
    _starting = true;
    final go = widget.beforeTransition == null || await widget.beforeTransition!();
    if (!go || !mounted) return;
    setState(() => _started = true);
    _exit.forward();
  }

  @override
  void dispose() {
    _hold.dispose();
    _exit.dispose();
    super.dispose();
  }

  double _phase(int startMs, int ms, [Curve curve = Curves.easeOutCubic]) =>
      curve.transform(((_exit.value * _totalMs - startMs) / ms).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenH = media.size.height;
    final splash = widget.variant == SplashVariant.signatureRed
        ? SignatureRedSplash(showLogo: !_started)
        : ScanFrameSplash(showLogo: !_started, closeOnTap: false, onFrameDone: _start);

    // Logo positions (top edge): splash center → welcome logo slot.
    final logoH = SplashLogo.height;
    final splashOffset = widget.variant == SplashVariant.scanFrame ? -300.w * 0.06 : 0.0;
    final fromTop = (screenH - logoH) / 2 + splashOffset;
    final welcomeLogoW = 170.w; // logo4.png is 338×344
    final toTop = media.padding.top + 16.h + 20.h;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: AnimatedBuilder(
          animation: _exit,
          builder: (context, _) {
            final move = _phase(0, _moveMs, Curves.easeInOutCubic);
            final bg = _phase(0, _moveMs, Curves.easeInOutSine);
            return Stack(
              fit: StackFit.expand,
              children: [
                // Welcome photo under the splash, revealed as the splash fades.
                Image.asset('assets/images/welcome2.png', fit: BoxFit.cover),
                IgnorePointer(ignoring: _started, child: Opacity(opacity: 1 - bg, child: splash)),
                if (_started) ...[
                  // The logo (same image as Welcome's) glides up and shrinks
                  // into the Welcome logo slot - no swap, nothing pops.
                  Positioned(
                    top: fromTop + (toTop - fromTop) * move,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.asset(
                        SplashLogo.asset,
                        width: SplashLogo.width + (welcomeLogoW - SplashLogo.width) * move,
                      ),
                    ),
                  ),
                  // At launch the real Welcome takes over at the end: the copy
                  // is only for looks.
                  IgnorePointer(ignoring: widget.onFinished != null, child: _welcomeTexts(context)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  /// Copy of the welcome screen's bottom section; each block fades and slides
  /// up 90 ms after the previous one, once the logo has arrived.
  Widget _welcomeTexts(BuildContext context) {
    Widget step(int i, Widget child) {
      final t = _phase(_moveMs - 250 + i * 110, 600);
      return Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 24 * (1 - t)), child: child));
    }

    void close() => Navigator.maybePop(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            step(0, Text(
              context.l10n.welcomeTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(fontSize: 32.sp, fontWeight: FontWeight.w500, color: Colors.white),
            )),
            SizedBox(height: 12.h),
            step(1, Text(
              context.l10n.welcomeSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: Colors.white, fontFamily: 'Poppins', height: 1.35),
            )),
            SizedBox(height: 28.h),
            step(2, RedButton(
              label: context.l10n.commonGetStarted,
              color: Colors.white,
              textColor: const Color(0xFF8B1D1D),
              fontSize: 17.sp,
              height: 54.h,
              onTap: close,
            )),
            SizedBox(height: 18.h),
            step(3, GestureDetector(
              onTap: close,
              // Wraps instead of overflowing on narrow screens / long locales.
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(context.l10n.welcomeHaveAccount,
                      style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 14.sp)),
                  Text(
                    context.l10n.commonSignIn,
                    style: GoogleFonts.rubik(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14.sp,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                      decorationThickness: 2,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

