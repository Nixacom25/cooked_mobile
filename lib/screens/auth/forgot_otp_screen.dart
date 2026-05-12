import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';
import '../../widgets/red_button.dart';
import '../../widgets/loading_text.dart';

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
                    width: 100,
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
                      padding: EdgeInsets.fromLTRB(
                        24,
                        30,
                        24,
                        24 + MediaQuery.of(context).padding.bottom,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Please enter the code we just sent to\n${identifier ?? 'your contact details'}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
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
                                ? const LoadingText(
                                    text: 'Resending',
                                    style: TextStyle(
                                      color: Color(0xFFFFF6D6),
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  )
                                : const Text(
                                    'Resend code',
                                    style: TextStyle(
                                      color: Color(0xFFFFF6D6),
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 28),

                          RedButton(
                            label: 'Continue',
                            loadingLabel: 'Verifying',
                            isLoading: _isLoading,
                            onTap: () {
                              if (identifier != null) {
                                _verifyCode(identifier);
                              } else {
                                IosToast.show(
                                  context,
                                  message: 'Missing identifier context. Please try again.',
                                  type: ToastType.success,
                                );
                              }
                            },
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
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 42,
                    height: 42,
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
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 24,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const Text(
                  'VERIFICATION CODE',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
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
        width: 40,
        height: 43,
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
            maxLength: null, // Allow more than 1 char for paste detection
            onChanged: (v) => _onChanged(v, idx),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: const TextStyle(
              fontSize: 20,
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
                  color: Color(0xFFC83A2D),
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
