import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../core/api_config.dart';
import '../routes/app_routes.dart';

import 'glass_icon_button.dart';

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

  Widget _buildAvatar(String? photoUrl) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Container(
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFCBD5E1),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.6),
            width: 1.5.w,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            photoUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildDefaultUserIcon(),
          ),
        ),
      );
    }
    return _buildDefaultUserIcon();
  }

  Widget _buildDefaultUserIcon() {
    return Container(
      width: 38.r,
      height: 38.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFCBD5E1),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1.5.w,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          color: Colors.white,
          size: 22.sp,
        ),
      ),
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
                  _buildAvatar(photoUrl),
                  SizedBox(width: 10.w),
                  Text(
                    'Hi, $firstName',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                      color: effectiveTextColor,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    icon: GlassIconButton(
                      size: 36.r,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12.r),
                      child: Icon(
                        Icons.more_vert_rounded,
                        color: effectiveTextColor,
                        size: 20.sp,
                      ),
                    ),
                    onSelected: (val) async {
                      if (val == 'settings') {
                        Navigator.of(context).pushNamed(AppRoutes.profile);
                      } else if (val == 'logout') {
                        await AuthService.instance.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.login,
                            (route) => false,
                          );
                        }
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'settings',
                        child: Row(
                          children: [
                            Icon(Icons.person_outline_rounded,
                                size: 18.sp, color: const Color(0xFF0F172A)),
                            SizedBox(width: 8.w),
                            Text('Profile',
                                style: TextStyle(
                                    fontFamily: 'Rubik', fontSize: 13.sp)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded,
                                size: 18.sp, color: const Color(0xFFC31E26)),
                            SizedBox(width: 8.w),
                            Text('Logout',
                                style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 13.sp,
                                    color: const Color(0xFFC31E26))),
                          ],
                        ),
                      ),
                    ],
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
