import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/red_button.dart';
import '../../../core/widgets/ios_toast.dart';

class AccountStep extends StatefulWidget {
  final String initialEmail;
  final String initialPassword;
  final String initialPhone;
  final bool initialAcceptedTerms;
  final Function({
    required String email,
    required String password,
    required String phone,
    required bool acceptedTerms,
    String? firstname,
    String? lastname,
  })
  onChanged;
  final VoidCallback onContinue;

  const AccountStep({
    super.key,
    required this.initialEmail,
    required this.initialPassword,
    required this.initialPhone,
    required this.initialAcceptedTerms,
    required this.onChanged,
    required this.onContinue,
  });

  @override
  State<AccountStep> createState() => _AccountStepState();
}

class _AccountStepState extends State<AccountStep> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmController;
  late TextEditingController _nameController;
  late String _phone;
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
    _passwordController = TextEditingController(text: widget.initialPassword);
    _confirmController = TextEditingController(text: widget.initialPassword);
    _nameController = TextEditingController();
    _phone = widget.initialPhone;
    _acceptedTerms = widget.initialAcceptedTerms;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    String? firstname;
    String? lastname;

    final fullName = _nameController.text.trim();
    if (fullName.isNotEmpty) {
      if (fullName.contains(' ')) {
        final lastSpaceIndex = fullName.lastIndexOf(' ');
        firstname = fullName.substring(0, lastSpaceIndex).trim();
        lastname = fullName.substring(lastSpaceIndex + 1).trim();
      } else {
        firstname = fullName;
      }
    }

    widget.onChanged(
      email: _emailController.text,
      password: _passwordController.text,
      phone: _phone,
      acceptedTerms: _acceptedTerms,
      firstname: firstname,
      lastname: lastname,
    );
  }

  void _submitForm() {
    HapticFeedback.selectionClick();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmController.text;

    if (email.isEmpty) {
      IosToast.show(
        context,
        message: 'Please enter your email',
        type: ToastType.warning,
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      IosToast.show(
        context,
        message: 'Please enter a valid email address',
        type: ToastType.warning,
      );
      return;
    }

    if (password.isEmpty) {
      IosToast.show(
        context,
        message: 'Please enter a password',
        type: ToastType.warning,
      );
      return;
    }

    if (password.length < 6) {
      IosToast.show(
        context,
        message: 'Password must be at least 6 characters',
        type: ToastType.warning,
      );
      return;
    }

    if (password != confirmPassword) {
      IosToast.show(
        context,
        message: 'Passwords do not match',
        type: ToastType.warning,
      );
      return;
    }

    // Call notify change to ensure parent has latest state
    _notifyChange();
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create your account',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0D1B3E),
                      fontFamily: 'SF Pro',
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Secure your recipes and preferences',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF7B8190),
                      fontFamily: 'SF Pro',
                    ),
                  ),
                  SizedBox(height: 32.h),

                  _buildLabel('Full Name', required: false),
                  const SizedBox(height: 8),
                  _buildField(
                    controller: _nameController,
                    hint: 'John Doe',
                    icon: Icons.person_outline_rounded,
                  ),

                  const SizedBox(height: 20),

                  _buildLabel('Email', required: true),
                  const SizedBox(height: 8),
                  _buildField(
                    controller: _emailController,
                    hint: 'john@example.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  _buildLabel('Password', required: true),
                  const SizedBox(height: 8),
                  _buildField(
                    controller: _passwordController,
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF7B8190),
                        size: 20,
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildLabel('Confirm Password', required: true),
                  const SizedBox(height: 8),
                  _buildField(
                    controller: _confirmController,
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscureConfirm,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF7B8190),
                        size: 20,
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        setState(() => _obscureConfirm = !_obscureConfirm);
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16.h),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
            child: RedButton(
              label: 'Create Account',
              onTap: _submitForm,
              height: 56.h,
              fontSize: 18.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF7B8190),
          fontFamily: 'SF Pro',
        ),
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: const Color(0xFFC83A2D),
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: (_) => _notifyChange(),
      style: TextStyle(
        fontFamily: 'SF Pro',
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFFBDC3C7),
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFFBDC3C7), size: 22.sp),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: const Color(0xFFC83A2D), width: 1.5.w),
        ),
      ),
    );
  }


}
