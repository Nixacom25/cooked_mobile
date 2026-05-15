import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimatedValidationButton extends StatefulWidget {
  final bool isValidated;
  final VoidCallback? onTap;
  final bool useWhiteBackground;
  final bool autoAnimate;
  final int index;
  final bool disableSlide;
  final Color? activeColor;
  final Color? inactiveColor;

  const AnimatedValidationButton({
    super.key,
    required this.isValidated,
    this.onTap,
    this.useWhiteBackground = true,
    this.autoAnimate = false,
    this.index = 0,
    this.disableSlide = true,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<AnimatedValidationButton> createState() => _AnimatedValidationButtonState();
}

class _AnimatedValidationButtonState extends State<AnimatedValidationButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  Timer? _autoAnimateTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideAnimation = Tween<double>(
      begin: widget.disableSlide ? 0.0 : -1.5, 
      end: 0.0
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    if (widget.autoAnimate && !widget.isValidated) {
      _startAutoAnimation();
    }
    
    if (widget.isValidated) {
      _controller.value = 1.0;
    }
  }

  void _startAutoAnimation() {
    final initialDelay = Duration(seconds: 5 * widget.index);
    Future.delayed(initialDelay, () {
      if (!mounted || widget.isValidated) return;
      _controller.forward(from: 0.0).then((_) {
        if (mounted && !widget.isValidated) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted && !widget.isValidated) _controller.reverse();
          });
        }
      });
      
      _autoAnimateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if (mounted && !widget.isValidated) {
          _controller.forward(from: 0.0).then((_) {
            if (mounted && !widget.isValidated) {
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted && !widget.isValidated) _controller.reverse();
              });
            }
          });
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void didUpdateWidget(AnimatedValidationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isValidated != oldWidget.isValidated) {
      if (widget.isValidated) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _autoAnimateTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      // Small feedback on tap
      _controller.forward(from: 0.0);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) widget.onTap!();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: 32.r,
            height: 32.r,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Background Circle
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.useWhiteBackground 
                          ? Colors.white.withOpacity(0.9) 
                          : const Color(0xFFC83A2D).withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: widget.useWhiteBackground ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ] : null,
                    ),
                  ),
                ),
                // Base outline icon
                Icon(
                  widget.useWhiteBackground ? Icons.add_circle_outline_rounded : Icons.add_rounded,
                  color: const Color(0xFFAAAAAA).withOpacity((1.0 - _opacityAnimation.value).clamp(0.0, 1.0)),
                  size: widget.useWhiteBackground ? 20.sp : 18.sp,
                ),
                // Falling filled icon
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation.value * 45.h), // Slightly increased drop
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _opacityAnimation.value.clamp(0.0, 1.0),
                          child: Icon(
                            widget.isValidated ? Icons.check_circle_rounded : Icons.add_circle_rounded,
                            color: widget.isValidated 
                                ? (widget.activeColor ?? (widget.useWhiteBackground ? Colors.green : Colors.white))
                                : (widget.inactiveColor ?? (widget.useWhiteBackground ? const Color(0xFFC83A2D) : Colors.white)),
                            size: widget.useWhiteBackground ? 20.sp : 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
