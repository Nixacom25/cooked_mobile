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

    _notifyChange();
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    fontFamily: 'Rubik',
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Secure your recipes and preferences',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF475569),
                    fontFamily: 'SF Pro',
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 24.h),

                _buildLabel('Full Name', required: false),
                SizedBox(height: 8.h),
                _buildField(
                  controller: _nameController,
                  hint: 'John Doe',
                  icon: Icons.person_outline_rounded,
                ),

                SizedBox(height: 16.h),

                _buildLabel('Email', required: true),
                SizedBox(height: 8.h),
                _buildField(
                  controller: _emailController,
                  hint: 'john@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: 16.h),

                _buildLabel('Password', required: true),
                SizedBox(height: 8.h),
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
                      color: const Color(0xFF64748B),
                      size: 20.sp,
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),

                SizedBox(height: 16.h),

                _buildLabel('Confirm Password', required: true),
                SizedBox(height: 8.h),
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
                      color: const Color(0xFF64748B),
                      size: 20.sp,
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20.h),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
          child: SafeArea(
            top: false,
            bottom: true,
            child: RedButton(
              label: 'Create Account',
              color: const Color(0xFFC31E26),
              onTap: _submitForm,
              height: 52.h,
              fontSize: 16.sp,
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
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
          fontFamily: 'Rubik',
        ),
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: const Color(0xFFC31E26),
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
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
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFF94A3B8),
          fontWeight: FontWeight.w400,
          fontSize: 15.sp,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20.sp),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: Color(0xFFC31E26), width: 1.5),
        ),
      ),
    );
  }
}
