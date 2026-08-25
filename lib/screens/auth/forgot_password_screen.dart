import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';
import '../../widgets/red_button.dart';

enum _ContactMethod { email, phone }

enum _ForgotStep { select, input }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  _ContactMethod _method = _ContactMethod.email;
  _ForgotStep _step = _ForgotStep.select;
  final _inputCtrl = TextEditingController();
  String _phoneNumber = '';
  bool _isLoading = false;
  String? _inputError;

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    if (_step == _ForgotStep.select) {
      setState(() => _step = _ForgotStep.input);
    } else {
      String identifier = _inputCtrl.text.trim();
      if (_method == _ContactMethod.phone) {
        identifier = _phoneNumber;
      }

      setState(() {
        _inputError = identifier.isEmpty ? 'This field is required' : null;
      });

      if (_inputError != null) {
        return;
      }

      setState(() => _isLoading = true);
      final nav = Navigator.of(context);

      try {
        await AuthService.instance.forgotPassword(identifier);
        if (!mounted) return;
        IosToast.show(context, message: "Code sent!", type: ToastType.success);
        nav.pushNamed(AppRoutes.forgotOtp, arguments: identifier);
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
  }

  @override
  Widget build(BuildContext context) {
    final statusBarH = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image fond_page.png
            Image.asset(
              'assets/images/fond_page.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),

            // Top Header (Back Button & Forgot Password Title)
            Positioned(
              top: statusBarH + 12.h,
              left: 20.w,
              right: 20.w,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (_step == _ForgotStep.input) {
                        setState(() => _step = _ForgotStep.select);
                      } else {
                        Navigator.pop(context);
                      }
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _step == _ForgotStep.select
                        ? _buildSelectStep()
                        : _buildInputStep(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Select Email or Phone ──────────────────────────────────────────
  Widget _buildSelectStep() {
    return Column(
      key: const ValueKey('select'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Select which contact details we should\nuse to reset your password',
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

        _ContactCard(
          icon: Icons.email_outlined,
          title: 'Email',
          subtitle: 'Send to your email',
          selected: _method == _ContactMethod.email,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _method = _ContactMethod.email);
          },
        ),
        SizedBox(height: 14.h),

        _ContactCard(
          icon: Icons.phone_outlined,
          title: 'Phone Number',
          subtitle: 'Send to your phone',
          selected: _method == _ContactMethod.phone,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _method = _ContactMethod.phone);
          },
        ),
        SizedBox(height: 28.h),

        RedButton(
          label: 'Continue',
          color: const Color(0xFFC31E26),
          height: 52.h,
          fontSize: 16.sp,
          onTap: _onContinue,
        ),
      ],
    );
  }

  // ── Step 2: Input (Email or Phone) ─────────────────────────────────────────
  Widget _buildInputStep() {
    final isEmail = _method == _ContactMethod.email;
    return Column(
      key: const ValueKey('input'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            isEmail
                ? 'Please enter the email, we will send a\nverification code to your email'
                : 'Please enter the phone number, \nwe will send a verification code\n to your phone number',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              fontFamily: 'Rubik',
              height: 1.25,
            ),
          ),
        ),
        SizedBox(height: 24.h),

        Text(
          isEmail ? 'Email' : 'Phone Number',
          style: TextStyle(
            color: const Color(0xFF64748B),
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),

        if (isEmail)
          _EmailField(controller: _inputCtrl, errorText: _inputError)
        else
          _PhoneField(
            controller: _inputCtrl,
            errorText: _inputError,
            onChanged: (val) => _phoneNumber = val,
          ),

        SizedBox(height: 28.h),

        RedButton(
          label: 'Send',
          loadingLabel: 'Sending',
          isLoading: _isLoading,
          color: const Color(0xFFC31E26),
          height: 52.h,
          fontSize: 16.sp,
          onTap: _onContinue,
        ),
      ],
    );
  }
}

// ── Selection card ─────────────────────────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F1F3),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? const Color(0xFFC31E26) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              child: Icon(
                icon,
                color: const Color(0xFFC31E26),
                size: 40.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? const Color(0xFFC31E26) : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? const Color(0xFFC31E26)
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Email field ────────────────────────────────────────────────────────────────
class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;

  const _EmailField({required this.controller, this.errorText});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
          fontFamily: 'SF Pro',
          fontSize: 15.sp,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: 'Email',
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

// ── Phone field ────────────────────────────────────────────────────────────────
class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;

  const _PhoneField({
    required this.controller,
    this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'XX XXX XX XX',
        hintStyle: TextStyle(
          color: const Color(0xFF94A3B8),
          fontFamily: 'SF Pro',
          fontSize: 15.sp,
        ),
        filled: true,
        fillColor: const Color(0xFFF0F1F3),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
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
          borderSide: const BorderSide(color: Color(0xFFC31E26), width: 1.5),
        ),
        errorText: errorText,
        errorStyle: TextStyle(
          color: const Color(0xFFDC2626),
          fontSize: 12.sp,
          fontFamily: 'SF Pro',
        ),
      ),
      initialCountryCode: 'US',
      onChanged: (phone) {
        onChanged(phone.completeNumber);
      },
      style: TextStyle(
        fontFamily: 'SF Pro',
        fontSize: 15.sp,
        color: const Color(0xFF0F172A),
      ),
      dropdownIcon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: const Color(0xFF64748B),
        size: 20.sp,
      ),
      flagsButtonPadding: EdgeInsets.only(left: 8.w),
      flagsButtonMargin: EdgeInsets.only(right: 8.w),
      showCountryFlag: true,
      showDropdownIcon: true,
      dropdownIconPosition: IconPosition.trailing,
      disableLengthCheck: true,
      textAlignVertical: TextAlignVertical.center,
      dropdownDecoration: BoxDecoration(
        color: const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(14.r),
      ),
    );
  }
}

