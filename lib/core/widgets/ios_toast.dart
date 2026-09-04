import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ToastType { success, error, warning }

class IosToast {
  static void show(
    BuildContext context, {
    required String message,
    required ToastType type,
  }) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _IosToastWidget(
        message: message,
        type: type,
        onDismiss: () {
          entry.remove();
        },
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(entry);
  }
}

class _IosToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  const _IosToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_IosToastWidget> createState() => _IosToastWidgetState();
}

class _IosToastWidgetState extends State<_IosToastWidget> {
  bool _isPopped = false;
  bool _isExpanded = false;
  bool _isDisappearing = false;

  @override
  void initState() {
    super.initState();
    _playSequence();
  }

  Future<void> _playSequence() async {
    // 1. Pop-in from top
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    setState(() => _isPopped = true);

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    // 2. Expand text pill
    setState(() => _isExpanded = true);

    // 3. Stay visible for 3.5 seconds
    await Future.delayed(const Duration(milliseconds: 3500));
    if (!mounted) return;

    // 4. Shrink
    setState(() => _isExpanded = false);

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    // 5. Slide up away
    setState(() => _isDisappearing = true);

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    widget.onDismiss();
  }

  Color get _glassBackgroundColor {
    switch (widget.type) {
      case ToastType.success:
        return const Color(0xFF16A34A).withValues(alpha: 0.78); // Vibrant green with glass finish
      case ToastType.error:
        return const Color(0xFFDC2626).withValues(alpha: 0.78); // Vibrant red with glass finish
      case ToastType.warning:
        return const Color(0xFFD97706).withValues(alpha: 0.78); // Vibrant amber with glass finish
    }
  }

  Color get _borderColor {
    return Colors.white.withValues(alpha: 0.35);
  }

  Color get _iconColor {
    return Colors.white;
  }

  IconData get _iconData {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.cancel_rounded;
      case ToastType.warning:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              top: (!_isPopped || _isDisappearing)
                  ? (MediaQuery.of(context).padding.top - 100)
                  : (MediaQuery.of(context).padding.top + 16.h),
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isDisappearing ? 0.0 : (_isPopped ? 1.0 : 0.0),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  scale: _isPopped ? 1.0 : 0.8,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                          constraints: BoxConstraints(minHeight: 46.h),
                          decoration: BoxDecoration(
                            color: _glassBackgroundColor,
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(
                              color: _borderColor,
                              width: 1.2.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.16),
                                blurRadius: 24,
                                spreadRadius: 1,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(_iconData, color: _iconColor, size: 20.sp),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOutCubic,
                                alignment: Alignment.centerLeft,
                                child: _isExpanded
                                    ? AnimatedOpacity(
                                        duration: const Duration(milliseconds: 200),
                                        opacity: 1.0,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: 8.w,
                                            right: 4.w,
                                          ),
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                                            ),
                                            child: Text(
                                              widget.message,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'Rubik',
                                                fontSize: 13.sp,
                                                height: 1.2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(width: 0, height: 20.h),
                              ),
                            ],
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
      ),
    );
  }
}

