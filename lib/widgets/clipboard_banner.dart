import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

class ClipboardBanner extends StatefulWidget {
  final String url;
  final double topOffset;
  final VoidCallback onPaste;
  final VoidCallback onClose;

  const ClipboardBanner({
    super.key,
    required this.url,
    required this.topOffset,
    required this.onPaste,
    required this.onClose,
  });

  @override
  State<ClipboardBanner> createState() => _ClipboardBannerState();
}

class _ClipboardBannerState extends State<ClipboardBanner> with SingleTickerProviderStateMixin {
  bool _isPopped = false;
  bool _isDisappearing = false;
  late AnimationController _attentionController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  Timer? _attentionTimer;
  Timer? _autoDismissTimer; // Timer for auto-closing

  @override
  void initState() {
    super.initState();
    
    _attentionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25).chain(CurveTween(curve: Curves.easeOut)), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0).chain(CurveTween(curve: Curves.bounceOut)), weight: 25),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 50),
    ]).animate(_attentionController);

    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 2 * math.pi).chain(CurveTween(curve: Curves.easeInOutBack)), weight: 50),
    ]).animate(_attentionController);

    _playEntryAnimation();
    _startAttentionTimer();
    _startAutoDismissTimer();
  }

  void _startAttentionTimer() {
    _attentionTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && _isPopped && !_isDisappearing) {
        _attentionController.forward(from: 0.0);
      }
    });
  }

  void _startAutoDismissTimer() {
    // Automatically close after 20 seconds if no action taken
    _autoDismissTimer = Timer(const Duration(seconds: 20), () {
      if (mounted && !_isDisappearing) {
        _handleClose();
      }
    });
  }

  @override
  void dispose() {
    _attentionTimer?.cancel();
    _autoDismissTimer?.cancel();
    _attentionController.dispose();
    super.dispose();
  }

  Future<void> _playEntryAnimation() async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (mounted) setState(() => _isPopped = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) _attentionController.forward(from: 0.0);
  }

  Future<void> _handleClose() async {
    if (mounted) setState(() => _isDisappearing = true);
    await Future.delayed(const Duration(milliseconds: 400));
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      top: (!_isPopped || _isDisappearing) ? -140.h : widget.topOffset,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isDisappearing ? 0.0 : (_isPopped ? 1.0 : 0.0),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            scale: _isPopped && !_isDisappearing ? 1.0 : 0.8,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Main Body
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
                    ),
                    child: Row(
                      children: [
                        // Animated Icon section
                        Container(
                          width: 44.w,
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC83A2D).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: AnimatedBuilder(
                            animation: _attentionController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _rotationAnimation.value,
                                child: Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: child,
                                ),
                              );
                            },
                            child: Icon(
                              Icons.link_rounded,
                              color: const Color(0xFFC83A2D),
                              size: 22.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 14.w),
                        // Text section
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recipe detected',
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15.sp,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                              Text(
                                'Link found in clipboard',
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontSize: 12.sp,
                                  color: const Color(0xFF888888),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Paste Button - Aligned to the far right
                        GestureDetector(
                          onTap: () {
                            _autoDismissTimer?.cancel();
                            widget.onPaste();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC83A2D),
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            child: Text(
                              'Paste',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w700,
                                fontSize: 13.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close Button - Hooked to top right
                  Positioned(
                    top: -8.h,
                    right: -4.w,
                    child: GestureDetector(
                      onTap: _handleClose,
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: const Color(0xFF999999),
                          size: 16.sp,
                        ),
                      ),
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
