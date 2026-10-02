import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The splash mockups' background pattern: little food doodles (tomato,
/// leaf, egg, pear, pan, scan corners, bowl) on a 132 px grid, tilted -12°,
/// drawn in white at low opacity. [drift] slowly scrolls it up (splash A).
class SplashFoodPattern extends StatefulWidget {
  final double opacity;
  final bool drift;

  const SplashFoodPattern({super.key, required this.opacity, this.drift = false});

  @override
  State<SplashFoodPattern> createState() => _SplashFoodPatternState();
}

class _SplashFoodPatternState extends State<SplashFoodPattern> with SingleTickerProviderStateMixin {
  static const double _tile = 132;

  /// One tile of the pattern, same paths as the mockup.
  static const String _tileSvg = '''
<circle cx="22" cy="26" r="11"/><path d="M18 15c2 2 6 2 8 0M22 15v-4"/>
<path d="M78 14c8 2 12 10 8 18-6-1-11-8-8-18z"/><path d="M80 18l6 12"/>
<ellipse cx="112" cy="64" rx="8" ry="10"/>
<path d="M30 76c0-6 4-10 9-10s9 4 9 10c0 7-4 12-9 12s-9-5-9-12z"/><path d="M39 66v-5"/>
<path d="M70 92a12 12 0 1 0 12-12"/><path d="M82 80l6-6"/>
<path d="M8 110h6M8 110v6M30 110h-6M30 110v6"/>
<path d="M96 108c4-6 12-6 16 0"/><path d="M100 114h8"/>''';

  late final AnimationController _drift;

  String? _svg;
  Size? _svgSize;

  @override
  void initState() {
    super.initState();
    _drift = AnimationController(vsync: this, duration: const Duration(seconds: 18));
    if (widget.drift) _drift.repeat();
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  /// Tiles enough of the pattern to cover [size] even once rotated.
  String _buildSvg(Size size) {
    final cover = math.sqrt(size.width * size.width + size.height * size.height) + _tile * 2;
    final count = (cover / _tile).ceil() + 1;
    final half = count * _tile / 2;
    final tiles = StringBuffer();
    for (var row = 0; row < count; row++) {
      for (var col = 0; col < count; col++) {
        tiles.write('<g transform="translate(${col * _tile - half} ${row * _tile - half})">$_tileSvg</g>');
      }
    }
    final cx = size.width / 2, cy = size.height / 2;
    return '<svg xmlns="http://www.w3.org/2000/svg" width="${size.width}" height="${size.height}" '
        'viewBox="0 0 ${size.width} ${size.height}">'
        '<g transform="translate($cx $cy) rotate(-12)" fill="none" stroke="#FFFFFF" stroke-width="2.2" '
        'stroke-linecap="round" stroke-linejoin="round">$tiles</g></svg>';
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion && _drift.isAnimating) _drift.stop();
    return LayoutBuilder(
      builder: (context, constraints) {
        // Extra height so the drift never shows an edge.
        final size = Size(constraints.maxWidth, constraints.maxHeight + _tile);
        if (_svg == null || _svgSize != size) {
          _svgSize = size;
          _svg = _buildSvg(size);
        }
        final picture = Opacity(
          opacity: widget.opacity,
          child: SvgPicture.string(_svg!, width: size.width, height: size.height, fit: BoxFit.none),
        );
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topCenter,
            maxHeight: size.height,
            child: widget.drift
                ? AnimatedBuilder(
                    animation: _drift,
                    builder: (context, child) =>
                        Transform.translate(offset: Offset(0, -_tile * _drift.value), child: child),
                    child: picture,
                  )
                : picture,
          ),
        );
      },
    );
  }
}
