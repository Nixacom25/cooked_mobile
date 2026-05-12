import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/auth_service.dart';
import '../../../core/widgets/ios_toast.dart';
import '../../../core/utils/error_helper.dart';
import '../../../widgets/red_button.dart';
import '../../../widgets/loading_text.dart';

class OtpStep extends StatefulWidget {
  final String email;
  final VoidCallback onComplete;

  const OtpStep({super.key, required this.email, required this.onComplete});

  @override
  State<OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<OtpStep> {
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
      final text = val.replaceAll(RegExp(r'[^0-9]'), '');
      for (int i = 0; i < text.length && i < _otpLength; i++) {
        _ctrls[i].text = text[i];
      }
      final nextIdx = text.length < _otpLength ? text.length : _otpLength - 1;
      _nodes[nextIdx].requestFocus();
      setState(() {});
      return;
    }

    if (val.isNotEmpty && idx < _otpLength - 1) {
      _nodes[idx + 1].requestFocus();
    } else if (val.isEmpty && idx > 0) {
      _nodes[idx - 1].requestFocus();
    }
    setState(() {});
  }

  String _getOtpCode() {
    return _ctrls.map((c) => c.text).join();
  }

  Future<void> _verifyCode() async {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    final code = _getOtpCode();
    if (code.length < _otpLength) {
      IosToast.show(
        context,
        message: 'Please enter the complete 6-digit code.',
        type: ToastType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.verifyEmail(
        identifier: widget.email,
        otpCode: code,
      );
      if (!mounted) return;
      widget.onComplete();
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

  Future<void> _resendCode() async {
    HapticFeedback.selectionClick();
    setState(() => _isResending = true);
    try {
      await AuthService.instance.resendCode(widget.email);
      if (!mounted) return;
      IosToast.show(
        context,
        message: 'Verification code resent.',
        type: ToastType.success,
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
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verify your account',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              height: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please enter the 6-digit code we sent to\n${widget.email}',
            style: TextStyle(
              fontSize: 15.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
              height: 1.4,
            ),
          ),
          SizedBox(height: 48.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_otpLength, (idx) {
              return Expanded(
                child: Container(
                  height: 60.h,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: _nodes[idx].hasFocus || _ctrls[idx].text.isNotEmpty
                        ? const Color(0xFFC83A2D)
                        : const Color(0xFFE5E7EB),
                    width: _nodes[idx].hasFocus ? 2.w : 1.5.w,
                  ),
                  boxShadow: _nodes[idx].hasFocus
                      ? [
                          BoxShadow(
                            color: const Color(0xFFC83A2D).withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: TextField(
                  controller: _ctrls[idx],
                  focusNode: _nodes[idx],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _onChanged(v, idx),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'SF Pro',
                    color: const Color(0xFF0D1B3E),
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                ),
              );
            }),
          ),

          SizedBox(height: 32.h),

          Center(
            child: Column(
              children: [
                Text(
                  "Didn't receive a code?",
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF7B8190),
                    fontFamily: 'SF Pro',
                  ),
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: _isResending ? null : _resendCode,
                  child: _isResending
                      ? LoadingText(
                          text: 'Resending',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFC83A2D),
                            fontFamily: 'SF Pro',
                          ),
                        )
                      : Text(
                          'Resend Code',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFC83A2D),
                            fontFamily: 'SF Pro',
                          ),
                        ),
                ),
              ],
            ),
          ),

          SizedBox(height: 48.h),

          RedButton(
            label: 'Verify & Continue',
            loadingLabel: 'Verifying',
            isLoading: _isLoading,
            onTap: _verifyCode,
            height: 56.h,
            fontSize: 18.sp,
          ),
          SizedBox(height: 120.h),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
