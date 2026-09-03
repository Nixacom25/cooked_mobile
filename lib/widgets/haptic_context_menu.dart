import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HapticMenuAction {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  HapticMenuAction({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });
}

class HapticContextMenu {
  static Future<void> show(
    BuildContext context, {
    required List<HapticMenuAction> actions,
    required Offset targetPosition,
    double menuWidth = 220,
  }) async {
    HapticFeedback.mediumImpact();
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent, // No dark overlay on the screen when modal opens
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return _HapticMenuOverlay(
          actions: actions,
          targetPosition: targetPosition,
          menuWidth: menuWidth,
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            alignment: Alignment.center,
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class _HapticMenuOverlay extends StatelessWidget {
  final List<HapticMenuAction> actions;
  final Offset targetPosition;
  final double menuWidth;

  const _HapticMenuOverlay({
    required this.actions,
    required this.targetPosition,
    required this.menuWidth,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Adjust position to stay within screen bounds
    double top = targetPosition.dy;
    double left = targetPosition.dx;

    // Total menu height estimation (approx 52h per item)
    final menuHeight = actions.length * 52.h;

    if (top + menuHeight > screenSize.height - 40.h) {
      top = screenSize.height - menuHeight - 40.h;
    }

    if (left + (menuWidth.w / 2) > screenSize.width - 20.w) {
      left = screenSize.width - menuWidth.w - 20.w;
    } else if (left - (menuWidth.w / 2) < 20.w) {
      left = 20.w;
    } else {
      left = left - (menuWidth.w / 2);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dismiss tap area without dark overlay
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              onPanStart: (_) => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Menu Content with Glassmorphism Overlay background
          Positioned(
            top: top,
            left: left,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  width: menuWidth.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.65), // Translucent frosted glass
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 1.2.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 28,
                        spreadRadius: 1,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: actions.asMap().entries.map((entry) {
                      final i = entry.key;
                      final action = entry.value;
                      final isLast = i == actions.length - 1;

                      return Column(
                        children: [
                          _MenuTile(
                            action: action,
                          ),
                          if (!isLast)
                            Container(
                              height: 0.5,
                              color: Colors.black.withValues(alpha: 0.08),
                            ),
                        ],
                      );
                    }).toList(),
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

class _MenuTile extends StatelessWidget {
  final HapticMenuAction action;

  const _MenuTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          action.onTap();
        },
        highlightColor: Colors.black.withValues(alpha: 0.05),
        splashColor: Colors.black.withValues(alpha: 0.1),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(
                action.icon,
                color: action.isDestructive
                    ? const Color(0xFFFF453A)
                    : const Color(0xFF1A1A1A),
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  action.title,
                  style: TextStyle(
                    color: action.isDestructive
                        ? const Color(0xFFFF453A)
                        : const Color(0xFF1A1A1A),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'SF Pro',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
