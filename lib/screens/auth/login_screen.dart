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
    // try {
    //   await UserService.instance.getCurrentUser();
    //   final bool isUserPremium = UserService.instance.isPremium;

    //   if (!isUserPremium) {
    //     final token = await AuthService.instance.getToken();
    //     if (token != null) {
    //       final paywallService = PaywallService(
    //         baseUrl: ApiConfig.baseUrl,
    //         authToken: token,
    //       );
    //       if (!mounted) return;
    //       final purchased = await Navigator.push<bool>(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => PaywallScreen(
    //             paywallService: paywallService,
    //             flowType: PaywallFlowType.standard,
    //           ),
    //           fullscreenDialog: true,
    //         ),
    //       );
    //       if (purchased == true) {
    //         nav.pushReplacementNamed(AppRoutes.home);
    //       } else {
    //         await AuthService.instance.logout();
    //         if (mounted) {
    //           IosToast.show(
    //             context,
    //             message: "An active subscription is required to log in.",
    //             type: ToastType.warning,
    //           );
    //         }
    //       }
    //     } else {
    //       await AuthService.instance.logout();
    //       nav.pushReplacementNamed(AppRoutes.welcome);
    //     }
    //   } else {
    //     nav.pushReplacementNamed(AppRoutes.home);
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     IosToast.show(
    //       context,
    //       message: "Failed to verify subscription status.",
    //       type: ToastType.error,
    //     );
    //   }
    // }
    
    // TEMPORAIRE : On contourne la vérification d'abonnement et on va direct vers l'accueil.
    nav.pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final statusBarH = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFEAEAEA),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background image fond_page.png ──
            Image.asset(
              'assets/images/fond_page.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),

            // ── Header (Back Button & Sign In Title) ──
            Positioned(
              top: statusBarH + 12.h,
              left: 20.w,
              right: 20.w,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
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
                    'Sign In',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SF Pro',
                      fontSize: 24.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // ── Main Card (White Rounded Container) ──
            Positioned(
              top: statusBarH + 180.h,
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
                    32.h,
                    24.w,
                    24.h + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Sign in to your account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'SF Pro',
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      _Label('Email'),
                      SizedBox(height: 8.h),
                      _Field(
                        controller: _emailCtrl,
                        hint: 'Email',
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
                            _obscurePass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF64748B),
                            size: 20.sp,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.pushNamed(
                              context,
                              AppRoutes.forgotPassword,
                            );
                          },
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: const Color(0xFF0F172A),
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Login Button
                      RedButton(
                        label: 'Login',
                        loadingLabel: 'Logging in',
                        isLoading: _isLoading,
                        color: const Color(0xFFC31E26),
                        height: 52.h,
                        fontSize: 16.sp,
                        onTap: _handleLogin,
                      ),
                      SizedBox(height: 18.h),

                      Center(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.pushNamed(
                              context,
                              AppRoutes.preferences,
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: const Color(0xFF64748B),
                                fontFamily: 'SF Pro',
                                fontSize: 14.sp,
                              ),
                              children: [
                                const TextSpan(
                                  text: "Don’t have an account? ",
                                ),
                                TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(
                                    color: const Color(0xFF0F172A),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      Row(
                        children: [
                          const Expanded(
                            child: Divider(
                              color: Color(0xFFE2E8F0),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14.w),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: const Color(0xFF94A3B8),
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                                fontFamily: 'SF Pro',
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              color: Color(0xFFE2E8F0),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      _SocialBtn(
                        label: 'Sign in with Google',
                        icon: Image.asset(
                          'assets/images/google.png',
                          width: 20.w,
                          fit: BoxFit.contain,
                        ),
                        onTap: _isLoading
                            ? null
                            : () => _handleSocialLogin('GOOGLE'),
                      ),
                      SizedBox(height: 12.h),
                      _SocialBtn(
                        label: 'Sign in with Apple',
                        icon: Image.asset(
                          'assets/images/apple.png',
                          width: 20.w,
                          fit: BoxFit.contain,
                        ),
                        onTap: _isLoading
                            ? null
                            : () => _handleSocialLogin('APPLE'),
                      ),

                      // Dynamic keyboard spacer
                      SizedBox(height: bottomInset > 0 ? bottomInset : 20.h),
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

// ─── Shared field widgets ────────────────────────────────────────────────────

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
      borderRadius: BorderRadius.circular(14.r),
      child: TextField(
        controller: controller,
        keyboardType: type,
        obscureText: obscure,
        style: TextStyle(
          fontFamily: 'SF Pro',
          fontSize: 15.sp,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: const Color(0xFF94A3B8),
            fontFamily: 'SF Pro',
            fontSize: 15.sp,
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
          suffixIcon: suffix,
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
          color: const Color(0xFFF0F1F3),
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
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
