import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/red_button.dart';
import '../../widgets/loading_text.dart';
import '../../widgets/red_header_background.dart';

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
    if (val.length > 1) {
      // Robust Paste Handling
      final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
      final toFill = digits.length > _otpLength ? digits.substring(0, _otpLength) : digits;
      
      for (int i = 0; i < toFill.length; i++) {
        _ctrls[i].text = toFill[i];
        _ctrls[i].selection = TextSelection.fromPosition(TextPosition(offset: 1));
      }
      
      // Move focus to the last filled box
      int lastIdx = toFill.length - 1;
      if (lastIdx < 0) lastIdx = 0;
      _nodes[lastIdx].requestFocus();
      return;
    }

    if (val.length == 1 && idx < _otpLength - 1) {
      _nodes[idx + 1].requestFocus();
    } else if (val.isEmpty && idx > 0) {
      _nodes[idx - 1].requestFocus();
    }
  }

  String _getOtpCode() {
    return _ctrls.map((c) => c.text).join();
  }

  Future<void> _verifyCode(String identifier) async {
    HapticFeedback.selectionClick();
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
      FocusManager.instance.primaryFocus?.unfocus();
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
    HapticFeedback.selectionClick();
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
                  GlassIconButton(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(context);
                    },
                    size: 40.r,
                    child: Icon(
                      Icons.arrow_back,
                      size: 20.sp,
                      color: Colors.black,
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
                    children: [
                      Text(
                        'Please enter the code we just sent to\n${identifier ?? 'mail/phone number'}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          fontFamily: 'Rubik',
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // OTP boxes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ..._buildBoxes(0, 3),
                          SizedBox(width: 2.w),
                          ..._buildBoxes(3, 6),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'If you didn’t receive a code? ',
                            style: TextStyle(
                              color: const Color(0xFF64748B),
                              fontFamily: 'SF Pro',
                              fontSize: 14.sp,
                            ),
                          ),
                          GestureDetector(
                            onTap: _isResending
                                ? null
                                : () {
                                    if (identifier != null) {
                                      _resendCode(identifier);
                                    }
                                  },
                            child: _isResending
                                ? const LoadingText(
                                    text: 'Resending',
                                    style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  )
                                : Text(
                                    'Resend Code',
                                    style: TextStyle(
                                      color: const Color(0xFF0F172A),
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      SizedBox(height: 28.h),

                      RedButton(
                        label: 'Continue',
                        loadingLabel: 'Verifying',
                        isLoading: _isLoading,
                        color: const Color(0xFFC31E26),
                        height: 52.h,
                        fontSize: 16.sp,
                        onTap: () {
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

  List<Widget> _buildBoxes(int from, int to) {
    return List.generate(to - from, (i) {
      final idx = from + i;
      return Container(
        width: 44.w,
        height: 52.h,
        margin: EdgeInsets.symmetric(horizontal: 3.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1F3),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: TextField(
            controller: _ctrls[idx],
            focusNode: _nodes[idx],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: null, // Allow more than 1 char for paste detection
            onChanged: (v) => _onChanged(v, idx),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'SF Pro',
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              counterText: '',
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
                borderSide: const BorderSide(
                  color: Color(0xFFC31E26),
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


