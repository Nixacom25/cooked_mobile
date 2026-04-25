import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../core/api_config.dart';
import '../home/view_all_screen.dart';

// ══════════════════════════════════════════════════════════════════════════════
// PROFILE SCREEN
// ══════════════════════════════════════════════════════════════════════════════
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Top Header & Avatar ──
          SizedBox(
            height: 230.h,
            child: Stack(
              children: [
                // Red background with pattern overlay
                Container(
                  height: 170.h,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(15.r),
                    ),
                    child: Stack(
                      children: [
                        // Background Image
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/fond4.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Red Gradient Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: [0.0, 0.5],
                                colors: [Color(0xFFC83A2D), Color(0x63C83A2D)],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // AppBar (Back Button & Title)
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Profile',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w600,
                            fontSize: 22.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Avatar
                Positioned(
                  top: 100.h,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 130.w,
                      height: 130.h,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: _photoUrl != null && _photoUrl!.isNotEmpty
                            ? Image.network(
                                _photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _defaultAvatar(),
                              )
                            : _defaultAvatar(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Name & Phone ──
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(color: Color(0xFFC83A2D)),
                )
              : Column(
                  children: [
                    Text(
                      _name.isNotEmpty ? _name : 'User',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w700,
                        fontSize: 24.sp,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _phone.isNotEmpty ? _phone : '...',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 14.sp,
                        color: const Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
          SizedBox(height: 30.h),

          // ── Menu items ──
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              children: [
                _MenuItem(
                  icon: Icons.person,
                  label: 'My Account',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.myAccount),
                ),
                _MenuItem(
                  icon: Icons.book_rounded,
                  label: 'My Albums',
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.viewAll,
                    arguments: {
                      'type': ViewAllType.cookbooks,
                      'title': 'Cookbooks',
                    },
                  ),
                ),
                _MenuItem(
                  icon: Icons.restaurant_menu_rounded,
                  label: 'Dietary Preferences',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.editPreferences),
                ),
                _MenuItem(
                  icon: Icons.password_rounded,
                  label: 'Security',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.changePassword),
                ),
                _MenuItem(
                  icon: Icons.favorite,
                  label: 'Favorites',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.favorites),
                ),
                _MenuItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Activity History',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.activityHistory),
                ),
                _MenuItem(
                  icon: Icons.subscriptions_rounded,
                  label: 'Subscription',
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.subscriptionManagement,
                  ),
                ),
                _MenuItem(
                  icon: Icons.help_rounded,
                  label: 'Help Center',
                  onTap: () =>
                       Navigator.pushNamed(context, AppRoutes.helpCenter),
                ),
                SizedBox(height: 20.h),
                Divider(height: 1.h, color: Color(0xFFEEEEEE)),
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: _showLogout,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: const Color(0xFFC83A2D),
                          size: 24.sp,
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                            color: const Color(0xFFC83A2D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF333333), size: 24.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
                    fontFamily: 'SF Pro',
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
                    fontFamily: 'SF Pro',
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
                      color: const Color(0xFFCC3333),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Center(
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
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

Widget _defaultAvatar() {
  return Container(
    color: const Color(0xFFEEEEEE),
    child: Icon(Icons.person_rounded, size: 40.sp, color: const Color(0xFFAAAAAA)),
  );
}
