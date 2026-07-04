import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../core/widgets/ios_toast.dart';
import '../../widgets/red_button.dart';
import '../../core/utils/error_helper.dart';
import '../premium/paywall_screen.dart';
import '../../services/paywall_service.dart';
import '../../core/api_config.dart';
import '../../services/user_service.dart';

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
  void initState() {
    super.initState();
    _checkExistingToken();
  }

  Future<void> _checkExistingToken() async {
    final token = await AuthService.instance.getToken();
    if (token != null && token.isNotEmpty) {
      await AuthService.instance.logout();
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    HapticFeedback.selectionClick();
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
      await _verifyPremiumAndNavigate(nav);
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
    HapticFeedback.selectionClick();
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
      await _verifyPremiumAndNavigate(nav);
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

  Future<void> _verifyPremiumAndNavigate(NavigatorState nav) async {
    try {
      await UserService.instance.getCurrentUser();
      final bool isUserPremium = UserService.instance.isPremium;

      if (!isUserPremium) {
        final token = await AuthService.instance.getToken();
        if (token != null) {
          final paywallService = PaywallService(
            baseUrl: ApiConfig.baseUrl,
            authToken: token,
          );
          if (!mounted) return;
          final purchased = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => PaywallScreen(
                paywallService: paywallService,
                flowType: PaywallFlowType.standard,
              ),
              fullscreenDialog: true,
            ),
          );
          if (purchased == true) {
            nav.pushReplacementNamed(AppRoutes.home);
          } else {
            await AuthService.instance.logout();
            if (mounted) {
              IosToast.show(
                context,
                message: "An active subscription is required to log in.",
                type: ToastType.warning,
              );
            }
          }
        } else {
          await AuthService.instance.logout();
          nav.pushReplacementNamed(AppRoutes.welcome);
        }
      } else {
        nav.pushReplacementNamed(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        IosToast.show(
          context,
          message: "Failed to verify subscription status.",
          type: ToastType.error,
        );
      }
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
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
                    },
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
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Larken',
                      height: 1.149,
                      fontSize: 14,
                      letterSpacing: 0.8,
                      color: AppColors.textDark,
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
                              'Sign In To Your Account',
                              style: TextStyle(
                                fontSize: 25.sp,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Larken',
                                height: 1.149,
                                letterSpacing: 0.8,
                                color: Colors.white,
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
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.pushNamed(context, AppRoutes.forgotPassword);
                              },
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
                          RedButton(
                            label: 'Login',
                            loadingLabel: 'Logging in',
                            isLoading: _isLoading,
                            onTap: _handleLogin,
                          ),
                          SizedBox(height: 20.h),

                          Center(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.pushNamed(context, AppRoutes.preferences);
                              },
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
