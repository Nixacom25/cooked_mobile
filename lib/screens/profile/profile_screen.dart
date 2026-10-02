import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../core/api_config.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/red_header_background.dart';
import '../../widgets/alphabet_avatar.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';
import 'settings_screen.dart';
import '../../core/motion/motion_widgets.dart';
import '../../core/l10n/l10n.dart';

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
    // Glass sheet: page dims + blurs, sheet rises 30 px while fading in.
    showGlassSheet(
      context,
      builder: (_) => const _LogoutSheet(),
    );
  }

  /// The website home page: the friend picks the App Store or Google Play
  /// there. The big preview card in Messages/WhatsApp comes from the site's
  /// Open Graph tags (image: /images/og-preview.jpg).
  static const String _inviteLink = 'https://www.cookedapp.com';

  // Same approach as ReciMe: a short message + the link, no referral code.
  void _inviteFriends() {
    SharePlus.instance.share(ShareParams(
      text: context.l10n.profileInviteMessage(_inviteLink),
    ));
  }

  Widget _menuDivider(BuildContext context) =>
      Divider(height: 1, thickness: 1, color: context.colors.pageBackground);

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
                color: context.colors.surface,
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
                            decoration: BoxDecoration(
                              color: context.colors.pageBackground,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 20.sp,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            context.l10n.settingsTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 20.sp,
                              color: context.colors.textPrimary,
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
                    child: AlphabetAvatar(
                      name: _name.isNotEmpty ? _name : 'Chef',
                      seed: AlphabetAvatar.currentUserSeed,
                      photoUrl: _photoUrl,
                      size: 96.r,
                      showEditBadge: true,
                      onTap: () => AlphabetAvatar.showPhotoPicker(context),
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
                              _name.isNotEmpty ? _name : 'Chef',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontWeight: FontWeight.w700,
                                fontSize: 22.sp,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            if (_phone.isNotEmpty)
                              Text(
                                _phone,
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 14.sp,
                                  color: context.colors.textSecondary,
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
                        // 1. Profile / account / change password
                        SettingsMenuItem(
                          svgPath: 'assets/icones/people1.svg',
                          label: context.l10n.settingsMyAccount,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.myAccount),
                        ),
                        _menuDivider(context),
                        SettingsMenuItem(
                          svgPath: 'assets/icones/password.svg',
                          label: context.l10n.settingsChangePassword,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.changePassword),
                        ),
                        _menuDivider(context),

                        // 2. Dietary preferences
                        SettingsMenuItem(
                          svgPath: 'assets/icones/eating.svg',
                          label: context.l10n.settingsDietaryPreferences,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.editPreferences),
                        ),
                        _menuDivider(context),

                        // 3. Allergies
                        SettingsMenuItem(
                          svgPath: 'assets/icones/alert.svg',
                          label: context.l10n.settingsAllergies,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.allergies),
                        ),
                        _menuDivider(context),

                        // 4. Cuisine + Flavor DNA
                        SettingsMenuItem(
                          icon: Icons.ramen_dining_rounded,
                          label: context.l10n.settingsCuisineFlavor,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.cuisineFlavor),
                        ),
                        _menuDivider(context),

                        // 5. Kitchen equipment
                        SettingsMenuItem(
                          icon: Icons.kitchen_rounded,
                          label: context.l10n.settingsKitchenEquipment,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.kitchenEquipment),
                        ),
                        _menuDivider(context),

                        // 6. Notifications
                        SettingsMenuItem(
                          svgPath: 'assets/icones/notif.svg',
                          label: context.l10n.settingsNotifications,
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.notificationSettings),
                        ),
                        _menuDivider(context),

                        // 7. Dark mode
                        SettingsMenuItem(
                          icon: Icons.dark_mode_outlined,
                          label: context.l10n.settingsDarkMode,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.darkMode),
                        ),
                        _menuDivider(context),

                        // Language
                        SettingsMenuItem(
                          icon: Icons.translate_rounded,
                          label: context.l10n.settingsLanguage,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.language),
                        ),
                        _menuDivider(context),

                        // 8. Manage subscription & restore purchases
                        SettingsMenuItem(
                          svgPath: 'assets/icones/billing.svg',
                          label: context.l10n.settingsManageSubscription,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.subscriptionManagement,
                          ),
                        ),
                        _menuDivider(context),

                        // Invite friends / Gift Cooked
                        SettingsMenuItem(
                          icon: Icons.person_add_alt_1_outlined,
                          label: context.l10n.settingsInviteFriends,
                          onTap: _inviteFriends,
                        ),
                        _menuDivider(context),
                        // Gifts are sold on the website for now.
                        SettingsMenuItem(
                          icon: Icons.card_giftcard_outlined,
                          label: context.l10n.settingsGiftCooked,
                          onTap: () => launchUrl(
                            Uri.parse('https://cookedapp.com/gift'),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                        _menuDivider(context),

                        // 9. Contact Support / Report Problem / Privacy / Terms
                        SettingsMenuItem(
                          svgPath: 'assets/icones/email1.svg',
                          label: context.l10n.settingsContactSupport,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.helpCenter),
                        ),
                        _menuDivider(context),

                        // 10. Delete Account
                        SettingsMenuItem(
                          svgPath: 'assets/icones/delete.svg',
                          label: context.l10n.settingsDeleteAccount,
                          textColor: context.colors.destructive,
                          iconColor: context.colors.destructive,
                          chevronColor: context.colors.destructive,
                          onTap: () {
                            showGlassSheet(
                              context,
                              builder: (_) => const _DeleteAccountSheet(),
                            );
                          },
                        ),
                        _menuDivider(context),
                        SettingsMenuItem(
                          svgPath: 'assets/icones/logout.svg',
                          label: context.l10n.settingsLogout,
                          textColor: context.colors.destructive,
                          iconColor: context.colors.destructive,
                          chevronColor: context.colors.destructive,
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

// ── Logout confirmation sheet ───────────────────────────────────────────────
class _LogoutSheet extends StatelessWidget {
  const _LogoutSheet();

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
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
              color: context.colors.divider,
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
                  context.l10n.settingsLogout,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w800,
                    fontSize: 20.sp,
                    color: context.colors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, size: 24.sp, color: context.colors.textSecondary),
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
                  context.l10n.settingsLogoutConfirm,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 14.sp,
                    color: context.colors.textSecondary,
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
                      color: context.colors.destructive,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Center(
                      child: Text(
                        context.l10n.settingsLogout,
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
        color: context.colors.surface,
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
              color: context.colors.divider,
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
                  context.l10n.settingsDeleteAccount,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w800,
                    fontSize: 20.sp,
                    color: context.colors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, size: 24.sp, color: context.colors.textSecondary),
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
                  context.l10n.settingsDeleteAccountConfirm,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 14.sp,
                    color: context.colors.textSecondary,
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
                      IosToast.show(
                        context,
                        message: ErrorHelper.getFriendlyMessage(e),
                        type: ToastType.error,
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 54.h,
                    decoration: BoxDecoration(
                      color: context.colors.destructive,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Center(
                      child: _isDeleting 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: AppLoadingIndicator(color: Colors.white)
                          )
                        : Text(
                            context.l10n.settingsDeletePermanently,
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

