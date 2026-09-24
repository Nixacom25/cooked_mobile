import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../services/user_service.dart';
import '../../widgets/red_header_background.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';

/// Profile > Settings > Notifications. Lets users opt out of push categories
/// that are genuinely optional. Account-security alerts (new sign-in,
/// payment failed) aren't listed here - they only follow the master switch,
/// on purpose, since they're not marketing.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushEnabled = true;
  bool _pushRemindersEnabled = true;
  bool _pushNewsOffersEnabled = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = UserService.instance.currentUserNotifier.value;
    if (user != null) {
      _pushEnabled = user['pushEnabled'] ?? true;
      _pushRemindersEnabled = user['pushRemindersEnabled'] ?? true;
      _pushNewsOffersEnabled = user['pushNewsOffersEnabled'] ?? true;
    }
  }

  Future<void> _apply({
    bool? pushEnabled,
    bool? pushRemindersEnabled,
    bool? pushNewsOffersEnabled,
  }) async {
    final prev = (
      pushEnabled: _pushEnabled,
      pushRemindersEnabled: _pushRemindersEnabled,
      pushNewsOffersEnabled: _pushNewsOffersEnabled,
    );

    setState(() {
      if (pushEnabled != null) _pushEnabled = pushEnabled;
      if (pushRemindersEnabled != null) _pushRemindersEnabled = pushRemindersEnabled;
      if (pushNewsOffersEnabled != null) _pushNewsOffersEnabled = pushNewsOffersEnabled;
      _saving = true;
    });

    try {
      await UserService.instance.updateNotificationPreferences(
        pushEnabled: pushEnabled,
        pushRemindersEnabled: pushRemindersEnabled,
        pushNewsOffersEnabled: pushNewsOffersEnabled,
      );
    } catch (e) {
      if (!mounted) return;
      // Roll back on failure so the switch reflects what's actually saved.
      setState(() {
        _pushEnabled = prev.pushEnabled;
        _pushRemindersEnabled = prev.pushRemindersEnabled;
        _pushNewsOffersEnabled = prev.pushNewsOffersEnabled;
      });
      IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: RedHeaderBackground()),
          SafeArea(
            bottom: false,
            child: Container(
              margin: EdgeInsets.only(top: 25.h),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              ),
              child: Column(
                children: [
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
                            'Notifications',
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
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                      children: [
                        _NotificationToggleRow(
                          title: 'Push Notifications',
                          subtitle: 'Receive notifications on this device',
                          value: _pushEnabled,
                          onChanged: _saving ? null : (v) => _apply(pushEnabled: v),
                        ),
                        Divider(height: 1, thickness: 1, color: context.colors.pageBackground),
                        Opacity(
                          opacity: _pushEnabled ? 1 : 0.4,
                          child: IgnorePointer(
                            ignoring: !_pushEnabled,
                            child: Column(
                              children: [
                                _NotificationToggleRow(
                                  title: 'Reminders',
                                  subtitle: 'Trial ending and subscription reminders',
                                  value: _pushRemindersEnabled,
                                  onChanged: _saving
                                      ? null
                                      : (v) => _apply(pushRemindersEnabled: v),
                                ),
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: context.colors.pageBackground,
                                ),
                                _NotificationToggleRow(
                                  title: 'News, Tips & Offers',
                                  subtitle: 'New features, recipes and special offers',
                                  value: _pushNewsOffersEnabled,
                                  onChanged: _saving
                                      ? null
                                      : (v) => _apply(pushNewsOffersEnabled: v),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'Account and security alerts (like new sign-ins or payment '
                          'issues) are always sent while push notifications are enabled.',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 13.sp,
                            color: context.colors.textSecondary,
                            height: 1.5,
                          ),
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

class _NotificationToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _NotificationToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 12.sp,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              activeTrackColor: context.colors.accent,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
