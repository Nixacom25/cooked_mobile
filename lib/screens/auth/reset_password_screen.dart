import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';
import '../../widgets/red_button.dart';
import '../../widgets/red_header_background.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  String? _newPassError;
  String? _confirmPassError;

  @override
  void dispose() {
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleReset(String identifier) async {
    HapticFeedback.selectionClick();
    final newPass = _newPassCtrl.text;
    final confirmPass = _confirmPassCtrl.text;

    setState(() {
      _newPassError = newPass.isEmpty
          ? 'Ce champ est requis'
          : (newPass.length < 6 ? 'Minimum 6 caractères' : null);
      _confirmPassError = confirmPass.isEmpty
          ? 'Ce champ est requis'
          : (newPass != confirmPass
                ? 'Les mots de passe ne correspondent pas'
                : null);
    });

    if (_newPassError != null || _confirmPassError != null) {
      return;
    }

    setState(() => _isLoading = true);
    final nav = Navigator.of(context);

    try {
      await AuthService.instance.resetPassword(
        identifier: identifier,
        password: newPass,
      );
      if (!mounted) return;
      IosToast.show(
        context,
        message: "Reset successful!",
        type: ToastType.success,
      );
      nav.pushNamedAndRemoveUntil(
        AppRoutes.forgotSuccess,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      IosToast.show(
        context,
        message: ErrorHelper.getFriendlyMessage(
          e,
        ).replaceAll('Exception: ', ''),
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarH = MediaQuery.of(context).padding.top;
    final String? identifier =
        ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient
            const Positioned.fill(
              child: RedHeaderBackground(),
            ),

            // Top Header (Back Button & Forgot Password Title)
            Positioned(
              top: statusBarH + 12.h,
              left: 20.w,
              right: 20.w,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 20.sp,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Rubik',
                      fontSize: 24.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // White Card Pinned at Bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32.r),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    24.w,
                    28.h,
                    24.w,
                    24.h +
                        MediaQuery.of(context).padding.bottom +
                        MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Create New Password',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Rubik',
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // New Password
                      const _Label('New Password'),
                      SizedBox(height: 8.h),
                      _PasswordField(
                        controller: _newPassCtrl,
                        obscure: _obscureNew,
                        errorText: _newPassError,
                        onToggle: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                      SizedBox(height: 18.h),

                      // Confirm Password
                      const _Label('Confirm Password'),
                      SizedBox(height: 8.h),
                      _PasswordField(
                        controller: _confirmPassCtrl,
                        obscure: _obscureConfirm,
                        errorText: _confirmPassError,
                        onToggle: () => setState(
                          () => _obscureConfirm = !_obscureConfirm,
                        ),
                      ),
                      SizedBox(height: 28.h),

                      RedButton(
                        label: 'Continue',
                        loadingLabel: 'Updating',
                        isLoading: _isLoading,
                        color: const Color(0xFFC31E26),
                        height: 52.h,
                        fontSize: 16.sp,
                        onTap: () {
                          if (identifier != null) {
                            _handleReset(identifier);
                          } else {
                            IosToast.show(
                              context,
                              message:
                                  'Missing identifier context. Please try again.',
                              type: ToastType.error,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          color: const Color(0xFF64748B),
          fontFamily: 'SF Pro',
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      );
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final String? errorText;

  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(
          fontFamily: 'SF Pro',
          fontSize: 15.sp,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: TextStyle(
            color: const Color(0xFF94A3B8),
            fontFamily: 'SF Pro',
            fontSize: 15.sp,
          ),
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: const Color(0xFF64748B),
            size: 20.sp,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF64748B),
              size: 20.sp,
            ),
            onPressed: onToggle,
          ),
          filled: true,
          fillColor: const Color(0xFFF0F1F3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          errorText: errorText,
          errorStyle: TextStyle(
            color: const Color(0xFFDC2626),
            fontSize: 12.sp,
            fontFamily: 'SF Pro',
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }
}


