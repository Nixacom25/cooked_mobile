import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../core/api_config.dart';
import '../../models/view_all_type.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/red_header_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String _name = '';
  String _phone = '';
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    UserService.instance.currentUserNotifier.addListener(_onUserChanged);
  }

  @override
  void dispose() {
    UserService.instance.currentUserNotifier.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onUserChanged() {
    final user = UserService.instance.currentUserNotifier.value;
    if (user != null && mounted) {
      setState(() {
        _name = '${user['firstname'] ?? ''} ${user['lastname'] ?? ''}'.trim();
        _phone = user['phone'] ?? '';
        String? photo = user['profilePictureUrl'];
        if (photo != null && photo.isNotEmpty && !photo.startsWith('http')) {
          _photoUrl = '${ApiConfig.baseUrl}$photo';
        } else {
          _photoUrl = photo;
        }
      });
    }
  }

  Future<void> _loadProfile() async {
    try {
      final user = await UserService.instance.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _name = '${user['firstname'] ?? ''} ${user['lastname'] ?? ''}'.trim();
        _phone = user['phone'] ?? '';
        String? photo = user['profilePictureUrl'];
        if (photo != null && photo.isNotEmpty && !photo.startsWith('http')) {
          _photoUrl = '${ApiConfig.baseUrl}$photo';
        } else {
          _photoUrl = photo;
        }
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _showLogout() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LogoutSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Red background fond_page.png ──
          const Positioned.fill(
            child: RedHeaderBackground(),
          ),
          SafeArea(
            bottom: false,
            child: Container(
              margin: EdgeInsets.only(top: 25.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32.r),
                ),
              ),
              child: Column(
                children: [
                  // ── Header (Back Button & Title) ──
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 42.r,
                            height: 42.r,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 20.sp,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Profile',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 20.sp,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        SizedBox(width: 42.r),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // ── Avatar ──
                  Center(
                    child: Container(
                      width: 100.r,
                      height: 100.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: _photoUrl != null && _photoUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: _photoUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => _defaultAvatar(),
                              )
                            : _defaultAvatar(),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // ── Name & Phone ──
                  _isLoading
                      ? Column(
                          children: [
                            const SkeletonLoader(width: 140, height: 22),
                            SizedBox(height: 6.h),
                            const SkeletonLoader(width: 110, height: 14),
                          ],
                        )
                      : Column(
                          children: [
                            Text(
                              _name.isNotEmpty ? _name : 'Adeel',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontWeight: FontWeight.w700,
                                fontSize: 22.sp,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _phone.isNotEmpty ? _phone : '(+1) 234 567 890',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 14.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),

                  SizedBox(height: 16.h),

                  // ── Menu Items ──
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      children: [
                        _MenuItem(
                          svgPath: 'assets/icones/people1.svg',
                          label: 'My Account',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.myAccount),
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                        _MenuItem(
                          svgPath: 'assets/icones/password.svg',
                          label: 'Change Password',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.changePassword),
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                        _MenuItem(
                          svgPath: 'assets/icones/eating.svg',
                          label: 'Dietary Preferences',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.editPreferences),
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                        _MenuItem(
                          svgPath: 'assets/icones/billing.svg',
                          label: 'Subscription',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.subscriptionManagement,
                          ),
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                        _MenuItem(
                          svgPath: 'assets/icones/coeur1.svg',
                          label: 'Favorites',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.viewAll,
                            arguments: {
                              'type': ViewAllType.savedRecipes,
                              'title': 'Your Favorites',
                            },
                          ),
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                        _MenuItem(
                          svgPath: 'assets/icones/order.svg',
                          label: 'Order History',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.activityHistory),
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                        _MenuItem(
                          svgPath: 'assets/icones/help.svg',
                          label: 'Help Center',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.helpCenter),
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                        _MenuItem(
                          svgPath: 'assets/icones/delete.svg',
                          label: 'Delete Account',
                          textColor: const Color(0xFFDC2626),
                          iconColor: const Color(0xFFDC2626),
                          chevronColor: const Color(0xFFDC2626),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const _DeleteAccountSheet(),
                            );
                          },
                        ),
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                        _MenuItem(
                          svgPath: 'assets/icones/logout.svg',
                          label: 'Logout',
                          textColor: const Color(0xFFDC2626),
                          iconColor: const Color(0xFFDC2626),
                          chevronColor: const Color(0xFFDC2626),
                          onTap: _showLogout,
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String svgPath;
  final String label;
  final VoidCallback onTap;
  final Color textColor;
  final Color iconColor;
  final Color chevronColor;

  const _MenuItem({
    required this.svgPath,
    required this.label,
    required this.onTap,
    this.textColor = const Color(0xFF0F172A),
    this.iconColor = const Color(0xFF0F172A),
    this.chevronColor = const Color(0xFF64748B),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          children: [
            SizedBox(
              width: 24.r,
              height: 24.r,
              child: Center(
                child: SvgPicture.asset(
                  svgPath,
                  width: 22.r,
                  height: 22.r,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.circle_outlined,
                    size: 20.r,
                    color: iconColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: chevronColor,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _defaultAvatar() {
  return Container(
    color: const Color(0xFFE2E8F0),
    child: Icon(
      Icons.person_rounded,
      size: 50.sp,
      color: const Color(0xFF94A3B8),
    ),
  );
}

// ── Logout confirmation sheet ───────────────────────────────────────────────
class _LogoutSheet extends StatelessWidget {
  const _LogoutSheet();

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Logout',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w800,
                    fontSize: 20.sp,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, size: 24.sp, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to log out of your account? You will need to enter your credentials to log back in.',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 28.h),

                // Logout button
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context); // close sheet
                    await AuthService.instance.logout();
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.welcome,
                      (_) => false,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 54.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Center(
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: bottomPad + 10.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Delete Account confirmation sheet ───────────────────────────────────────
class _DeleteAccountSheet extends StatefulWidget {
  const _DeleteAccountSheet();

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delete Account',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w800,
                    fontSize: 20.sp,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, size: 24.sp, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to permanently delete your account? This action cannot be undone and you will lose all your data (Cookbooks, grocery items, etc.).',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 28.h),

                // Delete button
                GestureDetector(
                  onTap: _isDeleting ? null : () async {
                    setState(() => _isDeleting = true);
                    try {
                      await AuthService.instance.deleteAccount();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.welcome,
                        (_) => false,
                      );
                    } catch (e) {
                      setState(() => _isDeleting = false);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 54.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Center(
                      child: _isDeleting 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : Text(
                            'Delete permanently',
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                    ),
                  ),
                ),
                SizedBox(height: bottomPad + 10.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
