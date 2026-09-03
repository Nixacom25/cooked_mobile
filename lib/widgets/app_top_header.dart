import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../core/api_config.dart';
import '../routes/app_routes.dart';
import 'glass_icon_button.dart';
import 'alphabet_avatar.dart';

class AppTopHeader extends StatefulWidget {
  final double? topPadding;
  final Color? textColor;

  const AppTopHeader({super.key, this.topPadding, this.textColor});

  @override
  State<AppTopHeader> createState() => _AppTopHeaderState();
}

class _AppTopHeaderState extends State<AppTopHeader> {
  @override
  void initState() {
    super.initState();
    _loadUserIfNeeded();
  }

  Future<void> _loadUserIfNeeded() async {
    if (UserService.instance.currentUserNotifier.value == null) {
      try {
        await UserService.instance.getCurrentUser();
      } catch (_) {}
    }
  }

  void _showGlassProfileMenu(BuildContext context) {
    final RenderBox? button = context.findRenderObject() as RenderBox?;
    final RenderBox? overlay = Navigator.of(context).overlay?.context.findRenderObject() as RenderBox?;
    
    double topPos = 50.h;
    if (button != null && overlay != null) {
      final position = RelativeRect.fromRect(
        Rect.fromPoints(
          button.localToGlobal(Offset.zero, ancestor: overlay),
          button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
        ),
        Offset.zero & overlay.size,
      );
      topPos = position.top + button.size.height + 5.h;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              top: topPos,
              right: 16.w,
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      width: 130.w,
                      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 6.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.65),
                          width: 1.5.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(18.r),
                            onTap: () {
                              Navigator.of(ctx).pop();
                              Navigator.of(context).pushNamed(AppRoutes.profile);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_outline_rounded,
                                    size: 20.sp,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Text(
                                      'Profile',
                                      style: TextStyle(
                                        fontFamily: 'Rubik',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          InkWell(
                            borderRadius: BorderRadius.circular(18.r),
                            onTap: () async {
                              Navigator.of(ctx).pop();
                              await AuthService.instance.logout();
                              if (context.mounted) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  AppRoutes.login,
                                  (route) => false,
                                );
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.logout_rounded,
                                    size: 20.sp,
                                    color: const Color(0xFFC31E26),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontFamily: 'Rubik',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp,
                                        color: const Color(0xFFC31E26),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            alignment: Alignment.topRight,
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = widget.textColor ?? Colors.white;

    return Container(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: ValueListenableBuilder<Map<String, dynamic>?>(
            valueListenable: UserService.instance.currentUserNotifier,
            builder: (context, user, _) {
              String rawName = (user?['firstname'] as String?) ??
                  (user?['firstName'] as String?) ??
                  (user?['name'] as String?) ??
                  '';
              String firstName = rawName.trim();
              if (firstName.isEmpty) {
                firstName = 'Chef';
              }

              String? photo = (user?['profilePictureUrl'] as String?) ??
                  (user?['avatarUrl'] as String?) ??
                  (user?['photo'] as String?);
              String? photoUrl;
              if (photo != null && photo.trim().isNotEmpty) {
                photoUrl = photo.startsWith('http')
                    ? photo
                    : '${ApiConfig.baseUrl}$photo';
              }

              return Row(
                children: [
                  AlphabetAvatar(
                    name: firstName,
                    photoUrl: photoUrl,
                    size: 38.r,
                    onTap: () => AlphabetAvatar.showPhotoPicker(context),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
                    child: Text(
                      'Hi, $firstName',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                        color: effectiveTextColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Builder(
                    builder: (btnContext) {
                      return GlassIconButton(
                        size: 36.r,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(12.r),
                        onTap: () => _showGlassProfileMenu(btnContext),
                        child: Icon(
                          Icons.more_vert_rounded,
                          color: effectiveTextColor,
                          size: 20.sp,
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
