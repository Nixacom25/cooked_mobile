import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CookedBlobBackground extends StatefulWidget {
  final Widget child;
  const CookedBlobBackground({super.key, required this.child});

  @override
  State<CookedBlobBackground> createState() => _CookedBlobBackgroundState();
}

class _CookedBlobBackgroundState extends State<CookedBlobBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _blobsIn;
  late final Animation<double> _childFade;
  late final Animation<double> _childScale;

  static const _lightBg = Color(0xFFFFFBF2);
  static const _darkBg = Color(0xFF0F0F11);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();
    _blobsIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.68, curve: Curves.easeOutCubic),
    );
    _childFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 1.0, curve: Curves.easeIn),
    );
    _childScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _darkBg : _lightBg;

    return Container(
      color: bg,
      width: double.infinity,
      height: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _blobsIn.value;
          final slide = 30.w * (1 - t);

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Top-Left Green Blob (Accroché en haut à gauche)
              Positioned(
                left: -20.w - slide,
                top: -10.h - slide,
                child: Opacity(
                  opacity: t,
                  child: Image.asset(
                    'assets/anims/topleft.png', // Remplacez par .png transparent si possible
                    width: 150.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // 2. Top-Right Yellow Blob (Accroché en haut à droite)
              Positioned(
                right: -25.w - slide,
                top: -20.h - slide,
                child: Opacity(
                  opacity: t,
                  child: Image.asset(
                    'assets/anims/topright.png',
                    width: 160.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // 3. Bottom-Left Orange Blob (Accroché en bas à gauche)
              Positioned(
                left: -15.w - slide,
                bottom: -15.h - slide,
                child: Opacity(
                  opacity: t,
                  child: Image.asset(
                    'assets/anims/bottomleft.png',
                    width: 210.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // 4. Bottom-Right Green Blob (Accroché en bas à droite)
              Positioned(
                right: -10.w - slide,
                bottom: -10.h - slide,
                child: Opacity(
                  opacity: t,
                  child: Image.asset(
                    'assets/anims/bottomright.png',
                    width: 170.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Élément de décoration superposés
              Opacity(
                opacity: t,
                child: Stack(
                  children: [
                    // Tranche de tomate à gauche
                    Positioned(
                      top: 280.h,
                      left: -12.w,
                      child: Image.asset(
                        'assets/anims/tomate.png',
                        width: 58.w,
                      ),
                    ),

                    // Graines sous le blob jaune (Haut Droite)
                    Positioned(
                      top: 135.h,
                      right: 95.w,
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Image.asset('assets/anims/fruit.png', width: 26.w),
                      ),
                    ),

                  ],
                ),
              ),

              // Contenu principal (Logo / Card)
              FadeTransition(
                opacity: _childFade,
                child: ScaleTransition(
                  scale: _childScale,
                  child: widget.child,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final double size;
  final Color color;
  const _Dot({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}