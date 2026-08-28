import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../core/api_config.dart';
import '../routes/app_routes.dart';

class AppTopHeader extends StatelessWidget {
  final double? topPadding;

  const AppTopHeader({super.key, this.topPadding});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: ValueListenableBuilder<Map<String, dynamic>?>(
            valueListenable: UserService.instance.currentUserNotifier,
            builder: (context, user, _) {
              String firstName = user?['firstname'] ?? 'Adeel';
              String? photo = user?['profilePictureUrl'];
              String? photoUrl;
              if (photo != null && photo.isNotEmpty) {
                photoUrl = photo.startsWith('http')
                    ? photo
                    : '${ApiConfig.baseUrl}$photo';
              }
              return Row(
                children: [
                  Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFCBD5E1),
                      image: photoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(photoUrl),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage('assets/images/david.png'),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Hi, $firstName',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    icon: Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.more_vert_rounded,
                        color: const Color(0xFFFFFFFF),
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
