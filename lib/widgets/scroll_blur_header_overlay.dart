import 'dart:ui';
import 'package:flutter/material.dart';

/// Instagram & iOS-style liquid frosted glass scroll header overlay.
/// As the user scrolls down, a heavy Gaussian blur and dark translucent gradient
/// smoothly veil the top status bar & header area, creating an authentic Instagram scroll blur effect.
class ScrollBlurHeaderOverlay extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;
  final double fadeThreshold;
  final double maxBlur;
  final Color? primaryGradientColor;
  final Color? secondaryGradientColor;
  final bool isDarkBackground;
  final bool isInstagramStyle;

  const ScrollBlurHeaderOverlay({
    super.key,
    required this.child,
    this.scrollController,
    this.fadeThreshold = 45.0,
    this.maxBlur = 24.0,
    this.primaryGradientColor,
    this.secondaryGradientColor,
    this.isDarkBackground = false,
    this.isInstagramStyle = true,
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
    final double totalOverlayHeight = statusBarHeight > 0 ? statusBarHeight : MediaQuery.of(context).viewPadding.top;

    // Instagram-style multi-stop gradient colors (dark translucent blur at top)
    final List<Color> gradientColors = widget.isInstagramStyle
        ? [
            Colors.black.withValues(alpha: 0.65 * progress),
            Colors.black.withValues(alpha: 0.38 * progress),
            Colors.black.withValues(alpha: 0.12 * progress),
            Colors.transparent,
          ]
        : [
            (widget.primaryGradientColor ?? const Color(0xFFB00812)).withValues(alpha: 0.80 * progress),
            (widget.secondaryGradientColor ?? const Color(0xFFD66F6C)).withValues(alpha: 0.15 * progress),
            Colors.transparent,
          ];

    final List<double> gradientStops = widget.isInstagramStyle
        ? const [0.0, 0.40, 0.75, 1.0]
        : const [0.0, 0.65, 1.0];

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,

          // ── Instagram Frosted Glass Blur & Multi-Stop Dark Translucent Header ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: totalOverlayHeight,
            child: IgnorePointer(
              ignoring: true,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: progress > 0.005 ? 1.0 : 0.0,
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
        ],
      ),
    );
  }
}
