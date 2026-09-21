import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'cooked_blob_background.dart';

class ImportLoadingPage extends StatefulWidget {
  final String? url;

  const ImportLoadingPage({super.key, this.url});

  @override
  State<ImportLoadingPage> createState() => _ImportLoadingPageState();
}

class _ImportLoadingPageState extends State<ImportLoadingPage>
    with TickerProviderStateMixin {
  // Animation de flottement du logo
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  // Animation shimmer du squelette
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  // Animation des 3 points (Importing your recipe...)
  Timer? _dotsTimer;
  int _dotCount = 3;

  // Animation Typewriter (écriture lettre par lettre du lien)
  Timer? _typingTimer;
  String _typedUrl = "";
  int _typingIndex = 0;

  @override
  void initState() {
    super.initState();

    // 1. Logo Flottant
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -6.h).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // 2. Animation Shimmer (Balayage)
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOutSine),
    );

    // 3. Animation des 3 points (...)
    _dotsTimer = Timer.periodic(const Duration(milliseconds: 450), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount % 3) + 1;
        });
      }
    });

    // 4. Animation d'écriture lettre par lettre du lien
    _startTypingAnimation();
  }

  void _startTypingAnimation() {
    final targetUrl = _fullUrl;
    _typedUrl = "";
    _typingIndex = 0;

    _typingTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!mounted) return;
      if (_typingIndex < targetUrl.length) {
        _typingIndex++;
        setState(() {
          _typedUrl = targetUrl.substring(0, _typingIndex);
        });
      } else {
        _typingTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _shimmerController.dispose();
    _dotsTimer?.cancel();
    _typingTimer?.cancel();
    super.dispose();
  }

  String get _fullUrl {
    final raw = widget.url?.trim();
    if (raw == null || raw.isEmpty) return 'https://www.delicious.com/recipe';
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotsText = '.' * _dotCount;

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
                  // Inclinaison de la carte et du logo (-3.5 deg)
                  Transform.rotate(
                    angle: -0.06,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        // Carte de prévisualisation
                        _RecipeCardMock(
                          typedUrl: _typedUrl,
                          shimmerAnimation: _shimmerAnimation,
                        ),

                        // Logo C flottant
                        Positioned(
                          top: -44.h,
                          child: AnimatedBuilder(
                            animation: _floatController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _floatAnimation.value),
                                child: child,
                              );
                            },
                            child: const _LogoBadgeWithSparks(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 48.h),

                  // Titre avec les 3 points qui s'animent
                  SizedBox(
                    height: 30.h,
                    child: Text(
                      'Importing your recipe$dotsText',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1E1E1E), // Texte blanc en mode dark
                      ),
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // Sous-titre
                  Text(
                    'Getting it ready for Cooked',
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

class _LogoBadgeWithSparks extends StatelessWidget {
  const _LogoBadgeWithSparks();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 140.w,
      height: 90.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            isDark
                ? 'assets/images/logo_icon_only_dark.png'
                : 'assets/images/logo_icon_only.png',
            width: 80.w,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _RecipeCardMock extends StatelessWidget {
  final String typedUrl;
  final Animation<double> shimmerAnimation;

  const _RecipeCardMock({
    required this.typedUrl,
    required this.shimmerAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final barColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF4F0E8);
    final textColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF6B6B6B);
    final baseSkeletonColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE9E3D8);

    return Container(
      width: 280.w,
      padding: EdgeInsets.fromLTRB(16.w, 42.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF8C7A6B).withOpacity(0.10),
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
          // Barre URL
          Container(
            height: 38.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.link_rounded,
                  size: 16.sp,
                  color: textColor,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    typedUrl,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 12.sp,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // Contenu (Image + Skeletons)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedBuilder(
                animation: shimmerAnimation,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/images/scan.png',
                          width: 82.w,
                          height: 82.w,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 82.w,
                            height: 82.w,
                            color: baseSkeletonColor,
                            child: Icon(
                              Icons.restaurant_rounded,
                              color: isDark ? const Color(0xFF666666) : const Color(0xFFA09A90),
                              size: 28.sp,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: _ShimmerOverlay(
                            progress: shimmerAnimation.value,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(width: 14.w),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AnimatedSkeletonBar(
                        width: 130.w,
                        height: 10.h,
                        baseColor: baseSkeletonColor,
                        shimmerAnimation: shimmerAnimation,
                        isDark: isDark,
                      ),
                      SizedBox(height: 8.h),
                      _AnimatedSkeletonBar(
                        width: 90.w,
                        height: 10.h,
                        baseColor: baseSkeletonColor,
                        shimmerAnimation: shimmerAnimation,
                        isDark: isDark,
                      ),
                      SizedBox(height: 8.h),
                      _AnimatedSkeletonBar(
                        width: 110.w,
                        height: 8.h,
                        baseColor: baseSkeletonColor.withOpacity(0.6),
                        shimmerAnimation: shimmerAnimation,
                        isDark: isDark,
                      ),
                      SizedBox(height: 6.h),
                      _AnimatedSkeletonBar(
                        width: 70.w,
                        height: 8.h,
                        baseColor: baseSkeletonColor.withOpacity(0.6),
                        shimmerAnimation: shimmerAnimation,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedSkeletonBar extends StatelessWidget {
  final double width;
  final double height;
  final Color baseColor;
  final Animation<double> shimmerAnimation;
  final bool isDark;

  const _AnimatedSkeletonBar({
    required this.width,
    required this.height,
    required this.baseColor,
    required this.shimmerAnimation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmerAnimation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: Container(
            width: width,
            height: height,
            color: baseColor,
            child: _ShimmerOverlay(
              progress: shimmerAnimation.value,
              isDark: isDark,
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerOverlay extends StatelessWidget {
  final double progress;
  final bool isDark;

  const _ShimmerOverlay({
    required this.progress,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final shimmerColor = isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.55);

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withOpacity(0.0),
            shimmerColor,
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
          transform: _SlidingGradientTransform(slidePercent: progress),
        ).createShader(bounds);
      },
      child: Container(color: Colors.white.withOpacity(0.1)),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}