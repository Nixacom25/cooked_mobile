import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';

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
          // Background
          Image.asset('assets/images/fond.png', fit: BoxFit.cover),

          // Logo centered above card
          Positioned.fill(
            bottom: 220,
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Red card pinned at bottom
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
                    child: Column(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _step == _ForgotStep.select
                              ? _buildSelectStep()
                              : _buildInputStep(),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom,
                        ),
                      ],
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
                    if (_step == _ForgotStep.input) {
                      setState(() => _step = _ForgotStep.select);
                    } else {
                      Navigator.pop(context);
                    }
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
                  'FORGOT PASSWORD',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 0.8,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  // ── Step 1: Select Email or Phone ──────────────────────────────────────────
  Widget _buildSelectStep() {
    final bottomPadding = 24 + MediaQuery.of(context).padding.bottom;
    return Padding(
      key: const ValueKey('select'),
      padding: EdgeInsets.fromLTRB(22, 28, 22, bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select which contact details should\nwe use to reset your password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'SF Pro',
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),

          // Selection cards
          Row(
            children: [
              Expanded(
                child: _ContactCard(
                  icon: Icons.email_rounded,
                  iconColor: const Color(0xFFC83A2D),
                  title: 'Email',
                  subtitle: 'Send to your email',
                  selected: _method == _ContactMethod.email,
                  onTap: () => setState(() => _method = _ContactMethod.email),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ContactCard(
                  icon: Icons.phone_outlined,
                  iconColor: const Color(0xFFC83A2D),
                  title: 'Phone Number',
                  subtitle: 'Send to your phone',
                  selected: _method == _ContactMethod.phone,
                  onTap: () => setState(() => _method = _ContactMethod.phone),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Continue btn
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC83A2D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 2: Input (Email or Phone) ─────────────────────────────────────────
  Widget _buildInputStep() {
    final isEmail = _method == _ContactMethod.email;
    final bottomPadding = 24 + MediaQuery.of(context).padding.bottom;
    return Padding(
      key: const ValueKey('input'),
      padding: EdgeInsets.fromLTRB(22, 28, 22, bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              isEmail
                  ? 'Please enter the email, we  will send a\nverification code to your email'
                  : 'Please enter the phone number,\n we  will send a verification\ncode to your phone number',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'SF Pro',
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            isEmail ? 'Email' : 'Phone Number',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),

          if (isEmail)
            _EmailField(controller: _inputCtrl, errorText: _inputError)
          else
            _PhoneField(
              controller: _inputCtrl,
              errorText: _inputError,
              onChanged: (val) => _phoneNumber = val,
            ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onContinue,
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
        ],
      ),
    );
  }
}

// ── Selection card ─────────────────────────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.iconColor,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFC83A2D) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 12,
                color: AppColors.textMuted,
              ),
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
      borderRadius: BorderRadius.circular(10),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(fontFamily: 'SF Pro', fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Full Email',
          hintStyle: const TextStyle(
            color: AppColors.textMuted,
            fontFamily: 'SF Pro',
            fontSize: 14,
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
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontFamily: 'SF Pro',
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
          borderSide: const BorderSide(color: Color(0xFFC83A2D), width: 1.5),
        ),
        errorText: errorText,
        errorStyle: const TextStyle(
          color: Color.fromARGB(255, 126, 1, 1),
          fontSize: 12,
          fontFamily: 'SF Pro',
        ),
      ),
      initialCountryCode: 'US',
      onChanged: (phone) {
        onChanged(phone.completeNumber);
      },
      style: const TextStyle(
        fontFamily: 'SF Pro',
        fontSize: 14,
        color: Colors.black,
      ),
      dropdownIcon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textMuted,
        size: 20,
      ),
      flagsButtonPadding: const EdgeInsets.only(left: 8),
      flagsButtonMargin: const EdgeInsets.only(right: 8),
      showCountryFlag: true,
      showDropdownIcon: true,
      dropdownIconPosition: IconPosition.trailing,
      disableLengthCheck: true,
      textAlignVertical: TextAlignVertical.center,
    );
  }
}
