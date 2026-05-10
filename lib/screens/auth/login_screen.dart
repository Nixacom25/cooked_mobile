import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;

  String? _emailError;
  String? _passError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    final identifier = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    setState(() {
      _emailError = identifier.isEmpty ? 'This field is required' : null;
      _passError = password.isEmpty ? 'This field is required' : null;
    });

    if (_emailError != null || _passError != null) {
      return;
    }

    setState(() => _isLoading = true);
    final nav = Navigator.of(context);

    try {
      await AuthService.instance.login(
        identifier: identifier,
        password: password,
      );
      if (!mounted) return;
      IosToast.show(
        context,
        message: "Login successful!",
        type: ToastType.success,
      );
      nav.pushReplacementNamed(AppRoutes.home);
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

  Future<void> _handleSocialLogin(String provider) async {
    _handleSocialLoginActual(provider);
  }

  Future<void> _handleSocialLoginActual(String provider) async {
    setState(() => _isLoading = true);
    final nav = Navigator.of(context);

    try {
      if (provider == 'GOOGLE') {
        await AuthService.instance.signInWithGoogle(isSignup: false);
      } else {
        // APPLE
        await AuthService.instance.signInWithApple();
      }

      if (!mounted) return;

      IosToast.show(
        context,
        message: "Social login successful!",
        type: ToastType.success,
      );
      nav.pushReplacementNamed(AppRoutes.home);
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
    final statusBarH = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          fit: StackFit.expand,
          children: [
          // ── Background Food Pattern ──
            Image.asset('assets/images/fond.png', fit: BoxFit.cover),

            // ── Header (Back Button & Sign In Title) ──
            Positioned(
              top: statusBarH + 20.h,
              left: 20.w,
              right: 20.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.welcome),
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: const Color(0xffF8F5EF),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 24.sp,
                        color: const Color(0xFF0D1B36),
                      ),
                    ),
                  ),
                  Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w800,
                      fontSize: 16.sp,
                      letterSpacing: 0.5,
                      color: const Color(0xFF0D1B36),
                    ),
                  ),
                ],
              ),
            ),

            // ── Logo Section ──
            Positioned(
              top: statusBarH + 80.h,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 100.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // ── Login Card (Red Gradient) ──
            Positioned(
              top: statusBarH + 240.h,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 620.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFC83A2D), Color(0x63C83A2D)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Internal card pattern
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                        child: Opacity(
                          opacity: 0.08,
                          child: Image.asset('assets/images/fond.png', fit: BoxFit.cover),
                        ),
                      ),
                    ),

                    // Form Content
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        24.w,
                        30.h,
                        24.w,
                        30.h + MediaQuery.of(context).padding.bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Sign To Your Account',
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'SF Pro',
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),

                          _Label('Email'),
                          SizedBox(height: 8.h),
                          _Field(
                            controller: _emailCtrl,
                            hint: 'Full Email',
                            type: TextInputType.emailAddress,
                            errorText: _emailError,
                          ),
                          SizedBox(height: 18.h),

                          _Label('Password'),
                          SizedBox(height: 8.h),
                          _Field(
                            controller: _passCtrl,
                            hint: '••••••••',
                            obscure: _obscurePass,
                            errorText: _passError,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: const Color(0xFF7B8190),
                                size: 20.sp,
                              ),
                              onPressed: () => setState(() => _obscurePass = !_obscurePass),
                            ),
                          ),
                          SizedBox(height: 12.h),

                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'SF Pro',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 25.h),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC83A2D),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                                elevation: 4,
                                shadowColor: Colors.black.withOpacity(0.3),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 24.sp,
                                      height: 24.sp,
                                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'SF Pro',
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 20.h),

                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.preferences),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.7),
                                    fontFamily: 'SF Pro',
                                    fontSize: 16.sp,
                                  ),
                                  children: [
                                    const TextSpan(text: "Don't have an account? "),
                                    TextSpan(
                                      text: 'Sign Up',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),

                          Row(
                            children: [
                              const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14.w),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.5),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                            ],
                          ),
                          SizedBox(height: 20.h),

                          _SocialBtn(
                            label: 'Sign in with Google',
                            icon: Image.asset('assets/images/google.png', width: 20.w, fit: BoxFit.contain),
                            onTap: _isLoading ? null : () => _handleSocialLogin('GOOGLE'),
                          ),
                          SizedBox(height: 12.h),
                          _SocialBtn(
                            label: 'Sign in with Apple',
                            icon: Image.asset('assets/images/apple.png', width: 20.w, fit: BoxFit.contain),
                            onTap: _isLoading ? null : () => _handleSocialLogin('APPLE'),
                          ),

                          // Dynamic keyboard spacer
                          SizedBox(height: bottomInset > 0 ? bottomInset : 20.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared field widgets ────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: Colors.white,
      fontFamily: 'SF Pro',
      fontSize: 14.sp,
    ),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? type;
  final bool obscure;
  final Widget? suffix;
  final String? errorText;

  const _Field({
    required this.controller,
    required this.hint,
    this.type,
    this.obscure = false,
    this.suffix,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: TextField(
        controller: controller,
        keyboardType: type,
        obscureText: obscure,
        style: TextStyle(fontFamily: 'SF Pro', fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.textMuted,
            fontFamily: 'SF Pro',
            fontSize: 14.sp,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none,
          ),
          suffixIcon: suffix,
          errorText: errorText,
          errorStyle: TextStyle(
            color: const Color.fromARGB(255, 126, 1, 1),
            fontSize: 12.sp,
            fontFamily: 'SF Pro',
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 10.h,
          ),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback? onTap;
  const _SocialBtn({required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 10.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Circular Std',
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
