import 'dart:ui';
import 'package:flutter/material.dart';

class ScrollBlurHeaderOverlay extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;
  final double fadeThreshold;
  final double maxBlur;
  final Color? primaryGradientColor;
  final Color? secondaryGradientColor;
  final bool isDarkBackground;

  const ScrollBlurHeaderOverlay({
    super.key,
    required this.child,
    this.scrollController,
    this.fadeThreshold = 35.0,
    this.maxBlur = 28.0,
    this.primaryGradientColor,
    this.secondaryGradientColor,
    this.isDarkBackground = false,
  });

  @override
  State<ScrollBlurHeaderOverlay> createState() => _ScrollBlurHeaderOverlayState();
}

class _ScrollBlurHeaderOverlayState extends State<ScrollBlurHeaderOverlay> {
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ScrollBlurHeaderOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController != null && widget.scrollController!.hasClients) {
      final offset = widget.scrollController!.offset;
      if ((offset - _scrollOffset).abs() > 0.5) {
        setState(() {
          _scrollOffset = offset;
        });
      }
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (widget.scrollController == null && notification.metrics.axis == Axis.vertical) {
      final offset = notification.metrics.pixels;
      if ((offset - _scrollOffset).abs() > 0.5) {
        setState(() {
          _scrollOffset = offset;
        });
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_scrollOffset / widget.fadeThreshold).clamp(0.0, 1.0);
    final double blurSigma = progress * widget.maxBlur;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double baseHeight = statusBarHeight > 0 ? statusBarHeight : MediaQuery.of(context).viewPadding.top;
    final double totalOverlayHeight = baseHeight + 25.0;

    // Instagram Translucent Dark Mirror Glass Gradient (Mirrors underlying content with heavy blur without white block)
    final List<Color> gradientColors = [
      (widget.primaryGradientColor ?? Colors.black).withValues(alpha: 0.68 * progress),
      (widget.secondaryGradientColor ?? Colors.black.withValues(alpha: 0.38)).withValues(alpha: 0.38 * progress),
      Colors.black.withValues(alpha: 0.10 * progress),
      Colors.transparent,
    ];

    final List<double> gradientStops = const [0.0, 0.42, 0.75, 1.0];

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,

          // ── Instagram Liquid Frosted Glass Header Overlay ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: totalOverlayHeight,
            child: IgnorePointer(
              ignoring: true,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
                opacity: progress > 0.005 ? 1.0 : 0.0,
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black,
                        Colors.black,
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.35, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstIn,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: blurSigma,
                        sigmaY: blurSigma,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: gradientColors,
                            stops: gradientStops,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
