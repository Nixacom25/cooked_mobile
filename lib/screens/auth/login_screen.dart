import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../core/widgets/ios_toast.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/red_button.dart';
import '../../widgets/red_header_background.dart';
import '../../core/utils/error_helper.dart';
import '../../services/user_service.dart';
import '../../services/account_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/legal_content_modal.dart';
import '../../core/widgets/terms_validation_modal.dart';
import '../../core/l10n/l10n.dart';

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

  void _showLegalModal(String title, String content) {
    LegalContentModal.show(context, title: title, content: content);
  }

  String _getPrivacyPolicy() {
    return dummyPrivacy;
  }

  String _getTermsOfUse() {
    return dummyTerms;
  }

  Future<void> _handleLogin() async {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    final identifier = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    setState(() {
      _emailError = identifier.isEmpty ? context.l10n.commonFieldRequired : null;
      _passError = password.isEmpty ? context.l10n.commonFieldRequired : null;
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
        message: context.l10n.authLoginSuccess,
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
        message: context.l10n.authSocialLoginSuccess,
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
    } catch (e) {
      // Signed in, but the profile couldn't be loaded (network/server).
      // Say what actually happened and stay here so the user can retry -
      // don't pretend the profile is incomplete.
      if (mounted) {
        IosToast.show(
          context,
          message: ErrorHelper.getFriendlyMessage(e),
          type: ToastType.error,
        );
      }
      return;
    }

    // Complete accounts (subscribed or not) go Home - premium actions open
    // the paywall themselves. Only an account abandoned at the subscription
    // step of onboarding is sent back there.
    await AccountRouter.routeSignedInUser(nav);
  }

  @override
  Widget build(BuildContext context) {
    final statusBarH = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: context.colors.pageBackground,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background gradient ──
            const Positioned.fill(
              child: RedHeaderBackground(),
            ),

            // ── Header (Back Button & Sign In Title) ──
            Positioned(
              top: statusBarH + 12.h,
              left: 20.w,
              right: 20.w,
              child: Row(
                children: [
                  GlassIconButton(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
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
                    context.l10n.commonSignIn,
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
              top: statusBarH + 210.h,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.surface,
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
                          context.l10n.authSignInSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'SF Pro',
                            color: context.colors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      _Label(context.l10n.commonEmail),
                      SizedBox(height: 8.h),
                      _Field(
                        controller: _emailCtrl,
                        hint: context.l10n.commonEmail,
                        type: TextInputType.emailAddress,
                        errorText: _emailError,
                      ),
                      SizedBox(height: 18.h),

                      _Label(context.l10n.commonPassword),
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
                            color: context.colors.textSecondary,
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
                            context.l10n.authForgotPasswordLink,
                            style: TextStyle(
                              color: context.colors.textPrimary,
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
                        label: context.l10n.authLogin,
                        loadingLabel: context.l10n.authLoggingIn,
                        isLoading: _isLoading,
                        color: context.colors.accent,
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
                                color: context.colors.textSecondary,
                                fontFamily: 'SF Pro',
                                fontSize: 14.sp,
                              ),
                              children: [
                                TextSpan(
                                  text: context.l10n.authNoAccount,
                                ),
                                TextSpan(
                                  text: context.l10n.commonSignUp,
                                  style: TextStyle(
                                    color: context.colors.textPrimary,
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
                          Expanded(
                            child: Divider(
                              color: context.colors.border,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14.w),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: context.colors.textMuted,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                                fontFamily: 'SF Pro',
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: context.colors.border,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      _SocialBtn(
                        label: context.l10n.authSignInWithGoogle,
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
                        label: context.l10n.authSignInWithApple,
                        icon: SvgPicture.asset(
                          'assets/icones/apple.svg',
                          width: 20.w,
                          height: 20.w,
                          colorFilter: ColorFilter.mode(
                            context.colors.textPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                        onTap: _isLoading
                            ? null
                            : () => _handleSocialLogin('APPLE'),
                      ),

                      // Dynamic keyboard spacer
                      SizedBox(height: bottomInset > 0 ? bottomInset : 20.h),

                      // Legal links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => _showLegalModal(context.l10n.commonPrivacyPolicy, _getPrivacyPolicy()),
                            child: Text(
                              context.l10n.commonPrivacyPolicy,
                              style: TextStyle(
                                color: context.colors.textSecondary,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 12.sp,
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showLegalModal(context.l10n.commonTermsOfUse, _getTermsOfUse()),
                            child: Text(
                              context.l10n.commonTermsOfUse,
                              style: TextStyle(
                                color: context.colors.textSecondary,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
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
          color: context.colors.textSecondary,
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
          color: context.colors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: context.colors.textMuted,
            fontFamily: 'SF Pro',
            fontSize: 15.sp,
          ),
          filled: true,
          fillColor: context.colors.pageBackground,
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
            color: context.colors.destructive,
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
          color: context.colors.pageBackground,
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
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
