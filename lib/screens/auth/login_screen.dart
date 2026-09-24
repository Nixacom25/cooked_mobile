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
import '../../core/theme/app_theme.dart';
import '../../utils/paywall_helper.dart';
import '../../core/widgets/legal_content_modal.dart';

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
    return '''
PRIVACY POLICY
Effective Date: September 23, 2026

Cooked Technologies, Inc ("Cooked", "we", "our", or "us") operates the Cooked mobile application (the "App").

This Privacy Policy explains how we collect, use, and protect your information.

1. Information We Collect
We may collect:
- Account Information: Name, email address, phone number
- User Content: Photos you upload (e.g., fridge/pantry images), saved recipes and preferences
- Usage Data: App interactions, analytics data (for performance and improvement)

2. How We Use Your Information
We use your data to:
- Provide and improve the App
- Generate recipes and recommendations
- Personalize your experience
- Process subscriptions
- Monitor performance and usage

3. AI Processing
Cooked uses artificial intelligence to power core features. This includes:
- Processing images you upload to detect ingredients
- Generating recipes and recommendations

Your data may be securely processed by third-party AI providers solely to provide these features. We do not sell your personal data.

4. Payments & Storage
Payments: All payments are processed through Apple App Store or Google Play Store. We do not store or process your payment information directly.

Data Storage: We store Account information, Saved recipes, and Preferences.
We do not sell your personal data.

5. Data Sharing & Security
We may share data only with service providers (e.g., AI processing, analytics) or when required by law.
We do not sell or rent user data.
We take reasonable measures to protect your data, but no system is completely secure.

6. Children's Privacy
Cooked is intended for users 13 years and older. We do not knowingly collect data from children under 13.

7. Your Rights & Changes
You may request deletion of your data or contact us for any privacy concerns. We may update this policy, and continued use means acceptance of updates.

Contact Us
For any questions or concerns about your privacy: contact@cookedapp.com
''';
  }

  String _getTermsOfUse() {
    return '''
TERMS OF USE
Effective Date: September 23, 2026

1. Acceptance of Terms
By downloading and using the Cooked mobile application, you agree to be bound by these Terms of Use.

2. Description of Service
Cooked is a mobile application that provides recipe recommendations, meal planning, and grocery list features using artificial intelligence.

3. User Accounts
You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.

4. Intellectual Property
All content, features, and functionality of the App are owned by Cooked Technologies, Inc and are protected by international copyright, trademark, and other intellectual property laws.

5. User Conduct
You agree not to:
- Use the App for any illegal purpose
- Attempt to gain unauthorized access to the App or its related systems
- Interfere with or disrupt the App or servers

6. AI-Generated Content
The App uses artificial intelligence to generate recipes and recommendations. While we strive for accuracy, AI-generated content may not always be perfect.

7. Subscription and Payments
The App offers subscription-based features. All payments are processed through Apple App Store or Google Play Store according to their respective terms and conditions.

8. Privacy
Your use of the App is also governed by our Privacy Policy, which is incorporated into these Terms by reference.

9. Termination
We reserve the right to terminate or suspend your account at any time for violation of these Terms.

10. Disclaimer of Warranties
The App is provided "as is" without warranties of any kind, either express or implied.

11. Limitation of Liability
Cooked Technologies, Inc shall not be liable for any indirect, incidental, special, or consequential damages.

12. Changes to Terms
We reserve the right to modify these Terms at any time. Continued use of the App constitutes acceptance of the updated Terms.

Contact Us
For questions about these Terms: contact@cookedapp.com
''';
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
        // Only redirect to welcome if user data exists and they're definitely not premium
        if (UserService.instance.currentUserNotifier.value != null) {
          // User is not subscribed - show paywall modal
          if (mounted) {
            IosToast.show(
              context,
              message: "Please complete your subscription to continue.",
              type: ToastType.warning,
            );
            // Navigate to welcome screen to restart onboarding
            nav.pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
          }
          return;
        } else {
          // User data not loaded, proceed to home to handle there
          nav.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        }
      }

      // User has active subscription - proceed to home
      nav.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } catch (e) {
      // Instead of showing error and logging out, check if user account exists
      // and redirect accordingly
      try {
        // Try to get user data to determine if account is active
        await UserService.instance.getCurrentUser();
        final user = UserService.instance.currentUserNotifier.value;
        
        if (user != null) {
          // Account exists - show paywall modal
          if (mounted) {
            PaywallHelper.show(context);
          }
        } else {
          // Account doesn't exist or incomplete - redirect to onboarding
          if (mounted) {
            IosToast.show(
              context,
              message: "Please complete your profile to continue.",
              type: ToastType.warning,
            );
            nav.pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
          }
        }
      } catch (secondError) {
        // If we still can't get user data, redirect to onboarding as fallback
        if (mounted) {
          IosToast.show(
            context,
            message: "Please complete your profile to continue.",
            type: ToastType.warning,
          );
          nav.pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
        }
      }
    }
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
                          'Sign in to your account',
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
                            'Forgot password?',
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
                        label: 'Login',
                        loadingLabel: 'Logging in',
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
                                const TextSpan(
                                  text: "Don’t have an account? ",
                                ),
                                TextSpan(
                                  text: 'Sign Up',
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
                            onPressed: () => _showLegalModal('Privacy Policy', _getPrivacyPolicy()),
                            child: Text(
                              'Privacy Policy',
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
                            onPressed: () => _showLegalModal('Terms of Use', _getTermsOfUse()),
                            child: Text(
                              'Terms of Use',
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
