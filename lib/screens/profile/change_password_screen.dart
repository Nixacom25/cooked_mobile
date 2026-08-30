import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/user_service.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';
import '../../widgets/red_header_background.dart';

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
        message: 'Please fill in all fields.',
        type: ToastType.error,
      );
      return;
    }
    if (newPass != confirmPass) {
      IosToast.show(
        context,
        message: 'New passwords do not match.',
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
        message: 'Password updated successfully.',
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
                            'New Password',
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

                  // ── Form Content ──
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Password'),
                          SizedBox(height: 8.h),
                          _buildPasswordField(
                            controller: _oldPasswordCtrl,
                            obscureText: !_showCurrent,
                            onToggle: () => setState(() => _showCurrent = !_showCurrent),
                          ),
                          SizedBox(height: 20.h),

                          _buildLabel('New Password'),
                          SizedBox(height: 8.h),
                          _buildPasswordField(
                            controller: _newPasswordCtrl,
                            obscureText: !_showNew,
                            onToggle: () => setState(() => _showNew = !_showNew),
                          ),
                          SizedBox(height: 20.h),

                          _buildLabel('Confirm Password'),
                          SizedBox(height: 8.h),
                          _buildPasswordField(
                            controller: _confirmPasswordCtrl,
                            obscureText: !_showConfirm,
                            onToggle: () => setState(() => _showConfirm = !_showConfirm),
                          ),
                          SizedBox(height: 40.h),

                          // Change Password Button
                          GestureDetector(
                            onTap: _isLoading ? null : _savePassword,
                            child: Container(
                              width: double.infinity,
                              height: 54.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFC83A2D),
                                borderRadius: BorderRadius.circular(27.r),
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Change Password',
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
                          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 30.h),
                        ],
                      ),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Rubik',
        fontWeight: FontWeight.w500,
        fontSize: 14.sp,
        color: const Color(0xFF64748B),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          fontFamily: 'Rubik',
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20.sp,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
      ),
    );
  }
}
