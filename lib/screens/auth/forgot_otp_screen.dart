import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';

class ForgotOtpScreen extends StatefulWidget {
  const ForgotOtpScreen({super.key});
  @override
  State<ForgotOtpScreen> createState() => _ForgotOtpScreenState();
}

class _ForgotOtpScreenState extends State<ForgotOtpScreen> {
  static const int _otpLength = 6;
  final List<TextEditingController> _ctrls = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _nodes = List.generate(_otpLength, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _onChanged(String val, int idx) {
    if (val.length == 1 && idx < _otpLength - 1) {
      _nodes[idx + 1].requestFocus();
    } else if (val.isEmpty && idx > 0) {
      _nodes[idx - 1].requestFocus();
    }
    setState(() {});
  }

  String _getOtpCode() {
    return _ctrls.map((c) => c.text).join();
  }

  Future<void> _verifyCode(String identifier) async {
    final code = _getOtpCode();
    if (code.length < _otpLength) {
      IosToast.show(
        context,
        message: 'Please enter the complete 6-digit code.',
        type: ToastType.success,
      );
      return;
    }

    setState(() => _isLoading = true);
    final nav = Navigator.of(context);
    try {
      await AuthService.instance.verifyResetCode(
        identifier: identifier,
        code: code,
      );
      if (!mounted) return;
      nav.pushReplacementNamed(
        AppRoutes.resetPassword,
        arguments: identifier, // passed to ResetPasswordScreen
      );
    } catch (e) {
      IosToast.show(
        context,
        message: ErrorHelper.getFriendlyMessage(e),
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode(String identifier) async {
    setState(() => _isResending = true);
    try {
      await AuthService.instance.forgotPassword(identifier);
      if (!mounted) return;
      IosToast.show(
        context,
        message: 'Verification code resent.',
        type: ToastType.success,
      );
    } catch (e) {
      IosToast.show(
        context,
        message: ErrorHelper.getFriendlyMessage(e),
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/fond.png', fit: BoxFit.cover),

          // Logo centered
          Positioned.fill(
            bottom: 220,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 80.w,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),

          // Red card at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFC83A2D), Color(0x63C83A2D)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      child: Opacity(
                        opacity: 0.12,
                        child: Image.asset(
                          'assets/images/fond.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Please enter the code we just sent to\n${identifier ?? 'your contact details'}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'SF Pro',
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // OTP boxes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ..._buildBoxes(0, 3),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  '-',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              ..._buildBoxes(3, 6),
                            ],
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            "Didn't receive a code?",
                            style: TextStyle(
                              color: Colors.white70,
                              fontFamily: 'SF Pro',
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 3),
                          GestureDetector(
                            onTap: _isResending
                                ? null
                                : () {
                                    if (identifier != null) {
                                      _resendCode(identifier);
                                    }
                                  },
                            child: _isResending
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFFFF6D6),
                                      strokeWidth: 1.5,
                                    ),
                                  )
                                : Text(
                                    'Resend code',
                                    style: TextStyle(
                                      color: Color(0xFFFFF6D6),
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 28),

                          SizedBox(
                            width: double.infinity,
                            height: 42.h,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      if (identifier != null) {
                                        _verifyCode(identifier);
                                      } else {
                                        IosToast.show(
                                          context,
                                          message:
                                              'Missing identifier context. Please try again.',
                                          type: ToastType.success,
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC83A2D),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'SF Pro',
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).viewInsets.bottom,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating AppBar
          Positioned(
            top: statusBarH + 28,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34.w,
                    height: 34.h,
                    decoration: BoxDecoration(
                      color: Color(0xffF8F5EF),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 18.sp,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Text(
                  'VERIFICATION CODE',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w800,
                    fontSize: 13.sp,
                    letterSpacing: 0.8,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBoxes(int from, int to) {
    return List.generate(to - from, (i) {
      final idx = from + i;
      return Container(
        width: 34.w,
        height: 36.h,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: TextField(
            controller: _ctrls[idx],
            focusNode: _nodes[idx],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            onChanged: (v) => _onChanged(v, idx),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              fontFamily: 'SF Pro',
              color: AppColors.textDark,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFCC3333),
                  width: 1.5,
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      );
    });
  }
}
