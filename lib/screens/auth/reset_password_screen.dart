import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';

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
        AppRoutes.home,
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset('assets/images/fond.png', fit: BoxFit.cover),

          // Logo + Cooked centered above card
          Positioned.fill(
            bottom: 380,
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                        22,
                        28,
                        22,
                        24 + MediaQuery.of(context).padding.bottom,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Create New Password',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontFamily: 'SF Pro',
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // New Password
                          const _Label('New Password'),
                          const SizedBox(height: 7),
                          _PasswordField(
                            controller: _newPassCtrl,
                            obscure: _obscureNew,
                            errorText: _newPassError,
                            onToggle: () =>
                                setState(() => _obscureNew = !_obscureNew),
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password
                          const _Label('Confirm Password'),
                          const SizedBox(height: 7),
                          _PasswordField(
                            controller: _confirmPassCtrl,
                            obscure: _obscureConfirm,
                            errorText: _confirmPassError,
                            onToggle: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Send button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
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
                                  : const Text(
                                      'Send',
                                      style: TextStyle(
                                        fontSize: 16,
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
                  'RESET PASSWORD',
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
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontFamily: 'SF Pro',
      fontSize: 14,
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
      borderRadius: BorderRadius.circular(10),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(fontFamily: 'SF Pro', fontSize: 14),
        decoration: InputDecoration(
          hintText: '• • • • • • • •',
          hintStyle: const TextStyle(
            color: AppColors.textMuted,
            fontFamily: 'SF Pro',
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.textMuted,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textMuted,
              size: 20,
            ),
            onPressed: onToggle,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          errorText: errorText,
          errorStyle: const TextStyle(
            color: Color.fromARGB(255, 126, 1, 1),
            fontSize: 12,
            fontFamily: 'SF Pro',
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}
