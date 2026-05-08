import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/red_button.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import '../../models/device_session.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';

// ══════════════════════════════════════════════════════════════════════════════
// SECURITY SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isLoading = false;

  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    final oldPass = _oldPasswordCtrl.text.trim();
    final newPass = _newPasswordCtrl.text.trim();
    final confirmPass = _confirmPasswordCtrl.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      IosToast.show(
        context,
        message: 'Veuillez remplir tous les champs.',
        type: ToastType.error,
      );
      return;
    }
    if (newPass != confirmPass) {
      IosToast.show(
        context,
        message: 'Les nouveaux mots de passe ne correspondent pas.',
        type: ToastType.error,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await UserService.instance.updatePassword(
        oldPassword: oldPass,
        newPassword: newPass,
      );
      if (!mounted) return;
      IosToast.show(
        context,
        message: 'Mot de passe modifié avec succès.',
        type: ToastType.success,
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      IosToast.show(
        context,
        message: ErrorHelper.getFriendlyMessage(e).replaceAll('Exception: ', ''),
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFF1A1A1A), size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Security',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
            fontSize: 22.sp,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change Password',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 16.h),

            _label('Current Password'),
            SizedBox(height: 8.h),
            _field(
              child: TextFormField(
                controller: _oldPasswordCtrl,
                obscureText: !_showCurrent,
                style: _textStyle(),
                decoration: _dec('Enter current password').copyWith(
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _showCurrent = !_showCurrent),
                    child: Icon(
                      _showCurrent
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      size: 20,
                      color: const Color(0xFFAAAAAA),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 18.h),

            _label('New Password'),
            SizedBox(height: 8.h),
            _field(
              child: TextFormField(
                controller: _newPasswordCtrl,
                obscureText: !_showNew,
                style: _textStyle(),
                decoration: _dec('Enter new password').copyWith(
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _showNew = !_showNew),
                    child: Icon(
                      _showNew
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      size: 20,
                      color: const Color(0xFFAAAAAA),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 18.h),

            _label('Confirm Password'),
            SizedBox(height: 8.h),
            _field(
              child: TextFormField(
                controller: _confirmPasswordCtrl,
                obscureText: !_showConfirm,
                style: _textStyle(),
                decoration: _dec('Confirm new password').copyWith(
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _showConfirm = !_showConfirm),
                    child: Icon(
                      _showConfirm
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      size: 20,
                      color: const Color(0xFFAAAAAA),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 36.h),

            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFC83A2D)),
                  )
                : RedButton(label: 'Save', onTap: _savePassword),
            SizedBox(height: 50.h),

            _buildActiveSessions(),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessions() {
    return FutureBuilder<List<DeviceSession>>(
      future: AuthService.instance.getSessions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFC83A2D)),
          );
        }

        final sessions = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Sessions',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Here are all the devices that are currently logged in to your account.',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 14.sp,
                height: 1.4,
                color: const Color(0xFF888888),
              ),
            ),
            SizedBox(height: 24.h),
            if (sessions.isEmpty)
              Text(
                'No active sessions found.',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  color: const Color(0xFF888888),
                  fontSize: 14.sp,
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFEEEEEE), width: 1.w),
                ),
                child: Column(
                  children: sessions.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final session = entry.value;
                    return Column(
                      children: [
                        _sessionItem(session),
                        if (idx < sessions.length - 1)
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _sessionItem(DeviceSession session) {
    IconData icon;
    final name = session.deviceName.toLowerCase();
    if (name.contains('iphone') ||
        name.contains('android') ||
        name.contains('mobile')) {
      icon = Icons.phone_iphone_rounded;
    } else if (name.contains('ipad') || name.contains('tablet')) {
      icon = Icons.tablet_mac_rounded;
    } else {
      icon = Icons.laptop_mac_rounded;
    }

    final date =
        "${session.lastActive.day.toString().padLeft(2, '0')}/${session.lastActive.month.toString().padLeft(2, '0')}/${session.lastActive.year}";
    final subtitle = "${session.location} • $date";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: session.isCurrentSession
                  ? const Color(0xFFE8F7F0)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              size: 22.sp,
              color: session.isCurrentSession
                  ? const Color(0xFF00B251)
                  : const Color(0xFF888888),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      session.deviceName,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    if (session.isCurrentSession) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B251),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Current',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 13.sp,
                    color: const Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          if (!session.isCurrentSession)
            IconButton(
              onPressed: () async {
                try {
                  await AuthService.instance.revokeSession(session.id);
                  setState(() {});
                } catch (e) {
                  if (mounted) {
                    IosToast.show(
                      context,
                      message: ErrorHelper.getFriendlyMessage(e).replaceAll('Exception: ', ''),
                      type: ToastType.error,
                    );
                  }
                }
              },
              icon: Icon(Icons.logout_rounded, color: const Color(0xFFCC3333), size: 24.sp),
            ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
TextStyle _textStyle() => TextStyle(
  fontFamily: 'SF Pro',
  fontSize: 15.sp,
  color: const Color(0xFF1A1A1A),
);

Widget _label(String t) => Text(
  t,
  style: TextStyle(
    fontFamily: 'SF Pro',
    fontWeight: FontWeight.w500,
    fontSize: 14.sp,
    color: const Color(0xFF333333),
  ),
);

Widget _field({required Widget child}) => Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.r),
    border: Border.all(color: const Color(0xFFE8E8E8)),
  ),
  child: child,
);

InputDecoration _dec(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: TextStyle(color: const Color(0xFFBBBBBB), fontFamily: 'SF Pro', fontSize: 13.sp),
  border: InputBorder.none,
  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
);
