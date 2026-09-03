import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ── iOS Flower Spoke Loading Indicator in Signature Red (0xFFC31E26) ────────
class AppLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? radius;

  const AppLoadingIndicator({
    super.key,
    this.color,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoActivityIndicator(
      color: color ?? const Color(0xFFC31E26),
      radius: radius ?? 12.r,
    );
  }
}

// ── Premium Pull-To-Refresh Widget with iOS Flower Spinner ───────────────────
class AppRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
  });

  @override
  State<AppRefreshIndicator> createState() => _AppRefreshIndicatorState();
}

class _AppRefreshIndicatorState extends State<AppRefreshIndicator> {
  double _dragOffset = 0.0;
  bool _isRefreshing = false;
  static const double _refreshThreshold = 65.0;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isRefreshing) return false;

    if (notification is OverscrollNotification) {
      if (notification.overscroll < 0) {
        setState(() {
          _dragOffset = (_dragOffset - notification.overscroll * 0.45).clamp(0.0, 110.0);
        });
      }
    } else if (notification is ScrollUpdateNotification) {
      if (notification.scrollDelta != null && notification.scrollDelta! < 0 && notification.metrics.pixels <= 0) {
        setState(() {
          _dragOffset = (_dragOffset - notification.scrollDelta! * 0.45).clamp(0.0, 110.0);
        });
      }
    } else if (notification is ScrollEndNotification) {
      if (_dragOffset >= _refreshThreshold && !_isRefreshing) {
        _startRefresh();
      } else if (_dragOffset > 0) {
        setState(() {
          _dragOffset = 0.0;
        });
      }
    }
    return false;
  }

  Future<void> _startRefresh() async {
    setState(() {
      _isRefreshing = true;
      _dragOffset = _refreshThreshold;
    });
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _dragOffset = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_dragOffset / _refreshThreshold).clamp(0.0, 1.0);

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          widget.child,
          if (_dragOffset > 0 || _isRefreshing)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8.h + (_dragOffset * 0.35),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: progress,
                child: Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: CupertinoActivityIndicator(
                      color: widget.color ?? const Color(0xFFC31E26),
                      radius: 12.r,
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
