import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../motion/animated_check.dart';
import '../motion/motion.dart';

enum ToastType { success, error, warning }

/// Glass toast at the top of the screen. Only one is ever on screen: a new
/// call while one is visible updates it in place (content + timer) instead
/// of stacking a second banner.
///
/// Motion: slides down ~12 px + fades in (200 ms), stays ~2.5 s, then fades
/// and moves up (150 ms). Success draws its check; error nudges sideways
/// twice (3 px) with an icon pulse.
class IosToast {
  static OverlayEntry? _entry;
  static final ValueNotifier<_ToastData?> _current = ValueNotifier(null);
  static int _serial = 0;

  static void show(
    BuildContext context, {
    required String message,
    required ToastType type,
  }) {
    _current.value = _ToastData(message: message, type: type, id: ++_serial);
    if (_entry != null) return; // the live toast picks up the new content

    _entry = OverlayEntry(
      builder: (_) => _IosToastWidget(
        data: _current,
        onDismissed: () {
          _entry?.remove();
          _entry = null;
          _current.value = null;
        },
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }
}

class _ToastData {
  final String message;
  final ToastType type;
  final int id;
  const _ToastData({required this.message, required this.type, required this.id});
}

class _IosToastWidget extends StatefulWidget {
  final ValueNotifier<_ToastData?> data;
  final VoidCallback onDismissed;

  const _IosToastWidget({required this.data, required this.onDismissed});

  @override
  State<_IosToastWidget> createState() => _IosToastWidgetState();
}

class _IosToastWidgetState extends State<_IosToastWidget>
    with TickerProviderStateMixin {
  static const _visibleFor = Duration(milliseconds: 2600);

  late final AnimationController _presence = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    reverseDuration: const Duration(milliseconds: 150),
  );
  late final AnimationController _nudge = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  _ToastData? _shown;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    widget.data.addListener(_onData);
    _onData();
  }

  void _onData() {
    final next = widget.data.value;
    if (next == null || next.id == _shown?.id) return;
    setState(() => _shown = next);
    _presence.forward();
    if (next.type == ToastType.error) _nudge.forward(from: 0);
    _scheduleDismiss();
  }

  Future<void> _scheduleDismiss() async {
    final gen = ++_generation;
    await Future<void>.delayed(_visibleFor);
    if (!mounted || gen != _generation) return; // replaced meanwhile
    await _presence.reverse();
    if (mounted && gen == _generation) widget.onDismissed();
  }

  @override
  void dispose() {
    widget.data.removeListener(_onData);
    _presence.dispose();
    _nudge.dispose();
    super.dispose();
  }

  Color get _background {
    switch (_shown!.type) {
      case ToastType.success:
        return const Color(0xFF16A34A).withValues(alpha: 0.78);
      case ToastType.error:
        return const Color(0xFFDC2626).withValues(alpha: 0.78);
      case ToastType.warning:
        return const Color(0xFFD97706).withValues(alpha: 0.78);
    }
  }

  Widget _icon() {
    final size = 20.sp;
    switch (_shown!.type) {
      case ToastType.success:
        // Keyed by id so each new success redraws its check.
        return AnimatedCheck(
          key: ValueKey(_shown!.id),
          size: size,
          color: Colors.white,
          strokeWidth: 2,
        );
      case ToastType.error:
        return AnimatedBuilder(
          animation: _nudge,
          builder: (context, child) {
            final t = _nudge.value;
            return Transform.scale(scale: 1 + 0.15 * math.sin(t * math.pi), child: child);
          },
          child: Icon(Icons.cancel_rounded, color: Colors.white, size: size),
        );
      case ToastType.warning:
        return Icon(Icons.warning_amber_rounded, color: Colors.white, size: size);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_shown == null) return const SizedBox.shrink();
    final reduced = Motion.reduced(context);
    final top = MediaQuery.of(context).padding.top + 16.h;

    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: top, left: 16.w, right: 16.w),
            child: AnimatedBuilder(
              animation: Listenable.merge([_presence, _nudge]),
              builder: (context, child) {
                final p = reduced ? 1.0 : Motion.enter.transform(_presence.value);
                // Error: two quick sideways moves of ±3 px.
                final dx = reduced ? 0.0 : 3 * math.sin(_nudge.value * 4 * math.pi);
                return Opacity(
                  opacity: _presence.value,
                  child: Transform.translate(
                    offset: Offset(dx, -12 * (1 - p)),
                    child: child,
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: AnimatedContainer(
                    duration: Motion.of(context, Motion.micro),
                    constraints: BoxConstraints(
                      minHeight: 46.h,
                      maxWidth: MediaQuery.of(context).size.width * 0.85,
                    ),
                    decoration: BoxDecoration(
                      color: _background,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.2.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.16),
                          blurRadius: 24,
                          spreadRadius: 1,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    child: AnimatedSize(
                      duration: Motion.of(context, Motion.micro),
                      curve: Motion.standard,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 20.sp, height: 20.sp, child: Center(child: _icon())),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              _shown!.message,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Rubik',
                                fontSize: 13.sp,
                                height: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
