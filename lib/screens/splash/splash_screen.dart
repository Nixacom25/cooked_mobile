import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/account_router.dart';
import '../../core/l10n/l10n.dart';
import '../welcome/welcome_screen.dart';
import 'splash_pattern.dart';
import 'splash_to_welcome.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Started right away so the network check runs while the splash plays.
  late final Future<bool> _signedIn = _checkSession();

  /// True when a valid session exists (user data loaded).
  Future<bool> _checkSession() async {
    final token = await AuthService.instance.getToken();
    if (token == null || token.isEmpty) return false;
    try {
      // Verify the token by fetching the user.
      await UserService.instance.getCurrentUser();
      return true;
    } catch (_) {
      // Invalid or expired: sign out, Welcome follows.
      await AuthService.instance.logout();
      return false;
    }
  }

  /// Runs when the splash has played (scan round trip done). Signed-in users
  /// go on as before; everyone else gets the logo → Welcome transition.
  Future<bool> _beforeTransition() async {
    final signedIn = await _signedIn;
    if (!mounted) return false;
    if (!signedIn) return true;
    // Lapsed subscriptions stay signed in and go Home (premium actions open
    // the paywall); only an account abandoned at the onboarding
    // subscription step is sent back to finish it.
    await AccountRouter.routeSignedInUser(Navigator.of(context));
    return false;
  }

  /// End of the transition: the real Welcome replaces it with no animation
  /// (it looks identical, so the switch is invisible).
  void _showWelcome() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        settings: const RouteSettings(name: AppRoutes.welcome),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => const WelcomeScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) => SplashToWelcome(
        variant: SplashVariant.scanFrame,
        beforeTransition: _beforeTransition,
        onFinished: _showWelcome,
      );
}

/// Splash "A · Signature red" (Claude Design): red radial ground with the
/// drifting food pattern, the logo popping in and the tagline rising with
/// three blinking dots.
class SignatureRedSplash extends StatefulWidget {
  /// False hides the logo (the splash → welcome preview flies its own copy).
  final bool showLogo;

  const SignatureRedSplash({super.key, this.showLogo = true});

  @override
  State<SignatureRedSplash> createState() => _SignatureRedSplashState();
}

class _SignatureRedSplashState extends State<SignatureRedSplash> with TickerProviderStateMixin {
  // Logo pop 1.2 s; tagline rises from 0.35 s for 1 s.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1350),
  )..forward();
  late final AnimationController _dots = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  static const _pop = Cubic(0.2, 0.9, 0.2, 1.2);
  static const _rise = Cubic(0.2, 0.8, 0.2, 1);

  @override
  void dispose() {
    _intro.dispose();
    _dots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      _intro.value = 1;
      _dots.stop();
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFC4161C),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.12),
                  radius: 1.33,
                  colors: [Color(0xFFE0353A), Color(0xFFC4161C), Color(0xFF8E0F14)],
                  stops: [0, 0.42, 1],
                ),
              ),
            ),
            const SplashFoodPattern(opacity: 0.09, drift: true),
            // Glow behind the logo.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.12),
                  radius: 0.62,
                  colors: [Color(0xE6C4161C), Color(0x00C4161C)],
                ),
              ),
            ),
            if (widget.showLogo)
            AnimatedBuilder(
              animation: _intro,
              builder: (context, child) {
                final t = (_intro.value * 1350 / 1200).clamp(0.0, 1.0);
                final scale = 0.82 + 0.18 * _pop.transform(t);
                final opacity = (t / 0.6).clamp(0.0, 1.0);
                return Opacity(opacity: opacity, child: Transform.scale(scale: scale, child: child));
              },
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [SplashLogo()],
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
                  final t = _rise.transform(((_intro.value * 1350 - 350) / 1000).clamp(0.0, 1.0));
                  return Opacity(
                    opacity: t,
                    child: Transform.translate(offset: Offset(0, 14 * (1 - t)), child: child),
                  );
                },
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
    );
  }
}

/// Three dots fading in turn (0.2 s apart), like the mockup's loader.
class BlinkingDots extends StatelessWidget {
  final AnimationController controller;
  const BlinkingDots({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final phase = (controller.value - i * 0.2 / 1.2) % 1.0;
          final opacity = 0.35 + 0.65 * (0.5 - 0.5 * math.cos(phase * 2 * math.pi));
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.8 * opacity),
            ),
          );
        }),
      ),
    );
  }
}

/// Splash logo: the same image as the Welcome screen's logo (logo4.png), so
/// nothing changes when the splash hands over to Welcome.
class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  static const String asset = 'assets/images/logo4.png'; // 338×344

  /// Logo size on the splash (it shrinks to the Welcome size, 170.w, after).
  static double get width => 210.w;
  static double get height => width * 344 / 338;

  @override
  Widget build(BuildContext context) =>
      Image.asset(asset, width: width, height: height, semanticLabel: 'Cooked');
}
