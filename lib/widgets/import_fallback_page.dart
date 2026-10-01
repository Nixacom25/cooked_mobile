import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/l10n/l10n.dart';
import '../core/motion/motion_widgets.dart';
import '../core/widgets/ios_toast.dart';
import 'cooked_blob_background.dart';

/// Shown when a link couldn't be turned into a recipe ("Recipe not found").
///
/// Follows the two mockups: light (red wave header, white card with a broken
/// chain and an alert badge) and dark (glass sphere with a broken chain).
/// Everything fits on one screen without scrolling: the illustration takes
/// the space left by the copy and actions, and the copy scales down slightly
/// on very short screens.
class ImportFallbackPage extends StatelessWidget {
  final String? failedUrl;
  final String? errorMessage;
  final VoidCallback onTryAnotherLink;
  final VoidCallback onEnterManually;

  const ImportFallbackPage({
    super.key,
    this.failedUrl,
    this.errorMessage,
    required this.onTryAnotherLink,
    required this.onEnterManually,
  });

  static const red = Color(0xFFD7262E);
  static const deepRed = Color(0xFFB3141C);
  static const amber = Color(0xFFF5A524);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CookedBlobBackground(
        child: Stack(
          children: [
            if (!isDark) const Positioned(top: 0, left: 0, right: 0, child: _LightWaveHeader()),
            SafeArea(
              child: Column(
                children: [
                  _Header(title: context.l10n.fallbackTitle, isDark: isDark),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 14.h),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // The copy and actions keep their natural size and
                          // full width; they only shrink (uniformly) if they
                          // can't fit while leaving a minimum for the art.
                          // The illustration takes whatever height is left.
                          final minArt = constraints.maxHeight * 0.14;
                          return Column(
                            children: [
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, box) {
                                    final art = math.min(box.maxHeight * 0.92, 250.0);
                                    if (art < 56) return const SizedBox.shrink();
                                    return Center(
                                      child: _PopIn(
                                        child: isDark
                                            ? _DarkIllustration(size: art)
                                            : _LightIllustration(size: art),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(maxHeight: constraints.maxHeight - minArt),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.bottomCenter,
                                  child: SizedBox(
                                    width: constraints.maxWidth,
                                    child: _Body(
                                      failedUrl: failedUrl,
                                      errorMessage: errorMessage,
                                      isDark: isDark,
                                      onTryAnotherLink: onTryAnotherLink,
                                      onEnterManually: onEnterManually,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ─────────────────────────────────────────────────────────────────

/// Light mockup: coral band behind the title with a soft wavy bottom edge.
class _LightWaveHeader extends StatelessWidget {
  const _LightWaveHeader();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.paddingOf(context).top + 92.h;
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF4877C), Color(0xFFF9C2B8), Color(0xFFFCE3DC)],
          ),
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final h = size.height;
    final w = size.width;
    return Path()
      ..lineTo(0, h * 0.92)
      ..cubicTo(w * 0.28, h * 1.04, w * 0.55, h * 0.70, w * 0.78, h * 0.76)
      ..cubicTo(w * 0.90, h * 0.79, w * 0.96, h * 0.70, w, h * 0.66)
      ..lineTo(w, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _Header extends StatelessWidget {
  final String title;
  final bool isDark;
  const _Header({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Colors.white : const Color(0xFF16161A);
    return SizedBox(
      height: 52.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              icon: Icon(Icons.close_rounded, size: 30.sp, color: color),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 56.w),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 20.sp,
                fontWeight: isDark ? FontWeight.w600 : FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Copy and actions ───────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final String? failedUrl;
  final String? errorMessage;
  final bool isDark;
  final VoidCallback onTryAnotherLink;
  final VoidCallback onEnterManually;

  const _Body({
    required this.failedUrl,
    required this.errorMessage,
    required this.isDark,
    required this.onTryAnotherLink,
    required this.onEnterManually,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Generic extraction failures get the friendly hint; anything more
    // specific (e.g. "website is blocking access") is shown as-is.
    final message = errorMessage?.trim() ?? '';
    final isGeneric = message.isEmpty || message == l10n.importExtractFailed || message == l10n.errExtractFailed;
    final hint = isGeneric ? l10n.fallbackExtractHint : message;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 4.h),
        // Narrow column like the mockup, so the headline breaks
        // "We couldn't import / this recipe."
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 320.w),
          child: Text(
            l10n.fallbackHeadline,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 29.sp,
              height: 1.12,
              letterSpacing: -0.4,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF14141F),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300.w),
          child: Text(
            l10n.fallbackMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 15.5.sp,
              height: 1.45,
              fontWeight: FontWeight.w300,
              color: isDark ? const Color(0xFF9A9AA2) : const Color(0xFF6B6B76),
            ),
          ),
        ),
        SizedBox(height: 18.h),
        if (failedUrl != null && failedUrl!.isNotEmpty) ...[
          _FailedLinkCard(url: failedUrl!, isDark: isDark),
          SizedBox(height: 12.h),
        ],
        _WarningBanner(title: l10n.fallbackExtractTitle, hint: hint, isDark: isDark),
        SizedBox(height: 16.h),
        _ActionTile(
          icon: Icons.link_rounded,
          title: l10n.fallbackTryOther,
          subtitle: l10n.fallbackTryOtherDesc,
          primary: true,
          isDark: isDark,
          onTap: onTryAnotherLink,
        ),
        SizedBox(height: 12.h),
        _ActionTile(
          icon: Icons.edit_rounded,
          title: l10n.fallbackManual,
          subtitle: l10n.fallbackManualDesc,
          primary: false,
          isDark: isDark,
          onTap: onEnterManually,
        ),
      ],
    );
  }
}

class _FailedLinkCard extends StatelessWidget {
  final String url;
  final bool isDark;
  const _FailedLinkCard({required this.url, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151517) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: isDark ? const Color(0xFF2B2B2F) : const Color(0xFFEFEAE3)),
        boxShadow: isDark
            ? null
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Light mockup: small caps label; dark mockup: sentence case.
                Text(
                  isDark ? l10n.fallbackFailedUrl : l10n.fallbackFailedUrl.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: isDark ? 13.5.sp : 12.sp,
                    letterSpacing: isDark ? 0 : 1.1,
                    fontWeight: isDark ? FontWeight.w400 : FontWeight.w600,
                    color: isDark ? const Color(0xFF8E8E96) : const Color(0xFF6F6F7A),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  url,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 15.sp,
                    height: 1.35,
                    color: isDark ? Colors.white : const Color(0xFF16161A),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Semantics(
            button: true,
            label: l10n.fallbackCopyLink,
            child: PressScale(
              onTap: () {
                HapticFeedback.lightImpact();
                Clipboard.setData(ClipboardData(text: url));
                IosToast.show(context, message: l10n.fallbackLinkCopied, type: ToastType.success);
              },
              child: Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF26262A) : const Color(0xFFF3F1EE),
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: Icon(
                  Icons.copy_rounded,
                  size: 21.sp,
                  color: isDark ? Colors.white : const Color(0xFF4A4A55),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final String title;
  final String hint;
  final bool isDark;
  const _WarningBanner({required this.title, required this.hint, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF231A09) : const Color(0xFFFFF9EA),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: isDark ? const Color(0xFF7C5A12) : const Color(0xFFF6E3AE)),
      ),
      child: Row(
        children: [
          // Light: filled pale-amber disc; dark: outlined amber ring.
          Container(
            width: isDark ? 36.r : 46.r,
            height: isDark ? 36.r : 46.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.transparent : const Color(0xFFFBE08F),
              border: isDark ? Border.all(color: ImportFallbackPage.amber, width: 2.2) : null,
            ),
            child: Center(
              child: Text(
                '!',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: isDark ? 18.sp : 22.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark ? ImportFallbackPage.amber : const Color(0xFF9A6200),
                ),
              ),
            ),
          ),
          SizedBox(width: isDark ? 16.w : 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 14.5.sp,
                    height: 1.3,
                    fontWeight: isDark ? FontWeight.w400 : FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF16161A),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  hint,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 14.sp,
                    height: 1.35,
                    color: isDark ? const Color(0xFF9A9AA2) : const Color(0xFF6B6B76),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool primary;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = primary || isDark ? Colors.white : const Color(0xFF16161A);
    final subColor = primary
        ? Colors.white.withValues(alpha: 0.82)
        : (isDark ? const Color(0xFF9A9AA2) : const Color(0xFF6B6B76));

    final BoxDecoration decoration;
    if (primary) {
      decoration = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFFE02A32), Color(0xFFC81C24)]
              : const [Color(0xFFCC1F27), ImportFallbackPage.deepRed],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: isDark
            // Dark mockup: red glow around the button.
            ? [BoxShadow(color: ImportFallbackPage.red.withValues(alpha: 0.45), blurRadius: 22, spreadRadius: 1)]
            // Light mockup: darker red "step" under the button.
            : [
                const BoxShadow(color: Color(0xFF8E0F15), offset: Offset(0, 4)),
                BoxShadow(color: ImportFallbackPage.red.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 8)),
              ],
      );
    } else {
      decoration = BoxDecoration(
        color: isDark ? const Color(0xFF151517) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isDark ? const Color(0xFF2B2B2F) : const Color(0xFFEFEAE3)),
        boxShadow: isDark
            ? null
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 4))],
      );
    }

    return PressScale(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: decoration,
        child: Row(
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: primary
                    ? Colors.white.withValues(alpha: 0.2)
                    : (isDark ? const Color(0xFF26262A) : const Color(0xFFFDE7E7)),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                icon,
                size: 25.sp,
                color: primary || isDark ? Colors.white : ImportFallbackPage.red,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // One line like the mockup; shrinks a little rather than
                  // wrapping on narrow phones.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      style: TextStyle(fontFamily: 'Rubik', fontSize: 14.sp, color: subColor),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.chevron_right_rounded,
              size: 28.sp,
              color: primary || isDark ? Colors.white : const Color(0xFF5A5A66),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Illustrations ──────────────────────────────────────────────────────────

class _PopIn extends StatelessWidget {
  final Widget child;
  const _PopIn({required this.child});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Motion.of(context, Motion.long),
        curve: Curves.easeOutBack,
        builder: (context, t, child) => Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.scale(scale: 0.85 + 0.15 * t, child: child),
        ),
        child: child,
      );
}

/// Positioned helper in fractions of the illustration size.
Widget _at(double s, double left, double top, Widget child) =>
    Positioned(left: left * s, top: top * s, child: child);

Widget _spark(double s, double length, double angle, Color color) => Transform.rotate(
      angle: angle,
      child: Container(
        width: s * 0.026,
        height: s * length,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(s)),
      ),
    );

Widget _leaf(double s, double size, double angle) => Transform.rotate(
      angle: angle,
      child: Container(
        width: s * size,
        height: s * size * 0.55,
        decoration: BoxDecoration(
          color: const Color(0xFF5E9E3A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(s * size),
            bottomRight: Radius.circular(s * size),
            topRight: Radius.circular(s * size * 0.15),
            bottomLeft: Radius.circular(s * size * 0.15),
          ),
        ),
      ),
    );

Widget _dot(double s, double size, Color color) => Container(
      width: s * size,
      height: s * size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

/// Light mockup: white tilted card with a red 3D broken chain, an alert
/// badge, and red/yellow sparks on a soft pink halo.
class _LightIllustration extends StatelessWidget {
  final double size;
  const _LightIllustration({required this.size});

  @override
  Widget build(BuildContext context) {
    final s = size;
    const yellow = Color(0xFFF5B83A);
    const red = ImportFallbackPage.red;

    return SizedBox(
      width: s * 1.25,
      height: s,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Pink halo
          _at(s, 0.17, 0.0, Container(
            width: s * 0.92,
            height: s * 0.92,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Color(0xFFFCDCD6), Color(0xFFFDEBE7), Color(0x00FDEBE7)], stops: [0, 0.7, 1]),
            ),
          )),
          // Card
          _at(s, 0.22, 0.24, Transform.rotate(
            angle: -0.13,
            child: Container(
              width: s * 0.78,
              height: s * 0.54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(s * 0.08),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: s * 0.12, offset: Offset(0, s * 0.05)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: s * 0.34,
                    child: Center(
                      child: CustomPaint(
                        size: Size(s * 0.44, s * 0.26),
                        painter: _BrokenChainPainter(color: red, depthColor: const Color(0xFF8E1016), sparkColor: null),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: s * 0.1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _bar(s, 0.42),
                        SizedBox(height: s * 0.03),
                        _bar(s, 0.30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
          // Sparks above the chain and on the sides
          _at(s, 0.50, 0.02, _spark(s, 0.10, 0, red)),
          _at(s, 0.38, 0.07, _spark(s, 0.09, -0.6, red)),
          _at(s, 0.63, 0.07, _spark(s, 0.09, 0.6, red)),
          _at(s, 0.88, 0.22, _spark(s, 0.09, 1.0, yellow)),
          _at(s, 0.93, 0.36, _spark(s, 0.08, 1.45, yellow)),
          _at(s, 0.12, 0.54, _spark(s, 0.08, -1.15, yellow)),
          _at(s, 0.14, 0.66, _spark(s, 0.07, -1.6, yellow)),
          // Alert badge
          _at(s, 0.80, 0.60, Container(
            width: s * 0.25,
            height: s * 0.25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(center: Alignment(-0.3, -0.4), colors: [Color(0xFFEF3B3F), Color(0xFFC51920)]),
              boxShadow: [BoxShadow(color: red.withValues(alpha: 0.35), blurRadius: s * 0.08, offset: Offset(0, s * 0.03))],
            ),
            child: Center(
              child: Text('!', style: TextStyle(fontFamily: 'Rubik', fontSize: s * 0.15, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
            ),
          )),
        ],
      ),
    );
  }

  static Widget _bar(double s, double width) => Container(
        width: s * width,
        height: s * 0.045,
        decoration: BoxDecoration(color: const Color(0xFFEDE7E0), borderRadius: BorderRadius.circular(s)),
      );
}

/// Dark mockup: glassy dark sphere holding a broken chain with yellow sparks,
/// a document tile behind it, leaves and dots around.
class _DarkIllustration extends StatelessWidget {
  final double size;
  const _DarkIllustration({required this.size});

  @override
  Widget build(BuildContext context) {
    final s = size;
    const yellow = Color(0xFFF5B83A);

    return SizedBox(
      width: s * 1.3,
      height: s,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Soft organic dark blob behind the sphere
          _at(s, 0.16, 0.30, Container(
            width: s * 0.70,
            height: s * 0.56,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1F),
              borderRadius: BorderRadius.all(Radius.elliptical(s * 0.35, s * 0.28)),
            ),
          )),
          _at(s, 0.40, 0.12, Container(
            width: s * 0.66,
            height: s * 0.62,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1F),
              borderRadius: BorderRadius.all(Radius.elliptical(s * 0.33, s * 0.31)),
            ),
          )),
          // Document tile (behind, top-right)
          _at(s, 0.72, 0.02, Transform.rotate(
            angle: 0.2,
            child: Container(
              width: s * 0.30,
              height: s * 0.30,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3F).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(s * 0.07),
              ),
              child: Center(
                child: Container(
                  width: s * 0.15,
                  height: s * 0.17,
                  padding: EdgeInsets.symmetric(horizontal: s * 0.025, vertical: s * 0.035),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7A7A82),
                    borderRadius: BorderRadius.circular(s * 0.025),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      3,
                      (i) => Container(
                        height: s * 0.016,
                        decoration: BoxDecoration(color: const Color(0xFF3A3A3F), borderRadius: BorderRadius.circular(s)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )),
          // Glass sphere
          _at(s, 0.36, 0.17, Container(
            width: s * 0.62,
            height: s * 0.62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.35, -0.45),
                radius: 1.0,
                colors: [Color(0xFF4A4A50), Color(0xFF2A2A2F), Color(0xFF1C1C20)],
                stops: [0, 0.55, 1],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: s * 0.12, offset: Offset(0, s * 0.05)),
                BoxShadow(color: ImportFallbackPage.red.withValues(alpha: 0.16), blurRadius: s * 0.22, spreadRadius: -s * 0.04, offset: Offset(0, s * 0.10)),
              ],
            ),
            child: Center(
              child: CustomPaint(
                size: Size(s * 0.38, s * 0.38),
                painter: _BrokenChainPainter(
                  color: const Color(0xFFE8333B),
                  depthColor: null,
                  sparkColor: yellow,
                  diagonal: true,
                ),
              ),
            ),
          )),
          // Leaves and dots
          _at(s, 0.18, 0.05, _leaf(s, 0.17, 0.9)),
          _at(s, 0.98, 0.70, _leaf(s, 0.17, -0.6)),
          _at(s, 0.12, 0.33, _dot(s, 0.06, yellow)),
          _at(s, 1.06, 0.56, _dot(s, 0.045, ImportFallbackPage.red)),
        ],
      ),
    );
  }
}

/// Two separated chain links (a broken link).
///
/// [diagonal] tilts the chain 45° (dark mockup); otherwise it lies flat and
/// slightly tilted (light mockup). [depthColor] adds a darker offset stroke
/// for the 3D look; [sparkColor] draws sparks in the break.
class _BrokenChainPainter extends CustomPainter {
  final Color color;
  final Color? depthColor;
  final Color? sparkColor;
  final bool diagonal;

  _BrokenChainPainter({
    required this.color,
    required this.depthColor,
    required this.sparkColor,
    this.diagonal = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final unit = math.min(size.width, size.height);
    final stroke = unit * (diagonal ? 0.12 : 0.17);
    final linkW = size.width * (diagonal ? 0.44 : 0.42);
    final linkH = unit * (diagonal ? 0.30 : 0.50);
    final gap = size.width * (diagonal ? 0.16 : 0.12);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(diagonal ? -math.pi / 4 : -0.12);

    RRect link(double dx) => RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(dx, 0), width: linkW, height: linkH),
          Radius.circular(linkH / 2),
        );
    final left = link(-(linkW / 2 + gap / 2));
    final right = link(linkW / 2 + gap / 2);

    // Links are drawn in a layer, then each one is cut open on the side
    // facing the break - two open halves, like the mockup's broken chain.
    final bounds = Rect.fromCenter(center: Offset.zero, width: size.width * 2, height: size.height * 2);
    canvas.saveLayer(bounds, Paint());

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final depth = Offset(0, stroke * 0.38);
    if (depthColor != null) {
      paint.color = depthColor!;
      canvas.drawRRect(left.shift(depth), paint);
      canvas.drawRRect(right.shift(depth), paint);
    }
    paint.color = color;
    canvas.drawRRect(left, paint);
    canvas.drawRRect(right, paint);

    if (depthColor != null) {
      // Glossy highlight along the top of each link.
      final shine = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 0.26
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.38);
      for (final r in [left, right]) {
        canvas.drawLine(
          Offset(r.left + linkH * 0.55, r.top + stroke * 0.02),
          Offset(r.right - linkH * 0.65, r.top + stroke * 0.02),
          shine,
        );
      }
    }

    // Cut a slit through the inner end of each link (the ends facing the
    // break), slightly offset so the halves look like they snapped apart.
    final clear = Paint()..blendMode = BlendMode.clear;
    final slitH = linkH * 0.36;
    final slitW = stroke * 2.2 + gap;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(left.right - stroke * 0.3, -linkH * 0.08), width: slitW * 0.7, height: slitH),
      clear,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(right.left + stroke * 0.3, linkH * 0.08), width: slitW * 0.7, height: slitH),
      clear,
    );
    canvas.restore(); // layer

    if (sparkColor != null) {
      final spark = Paint()
        ..color = sparkColor!
        ..strokeWidth = stroke * 0.42
        ..strokeCap = StrokeCap.round;
      final len = linkH * 0.34;
      final reach = linkH * 0.62;
      // Sparks fanning out of the break, above and below.
      for (final sign in [-1.0, 1.0]) {
        canvas.drawLine(Offset(-gap * 0.35, sign * reach), Offset(-gap * 0.35 - len * 0.45, sign * (reach + len)), spark);
        canvas.drawLine(Offset(gap * 0.35, sign * reach), Offset(gap * 0.35 + len * 0.45, sign * (reach + len)), spark);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BrokenChainPainter old) =>
      old.color != color || old.depthColor != depthColor || old.sparkColor != sparkColor || old.diagonal != diagonal;
}
