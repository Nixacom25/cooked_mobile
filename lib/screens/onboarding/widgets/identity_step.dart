import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/string_extensions.dart';

class IdentityStep extends StatefulWidget {
  final String initialFirstName;
  final String initialLastName;
  final String initialEmail;
  final String initialPhone;
  final Function({
    required String fullName,
    required String lastName,
    required String email,
    required String phone,
  })
  onChanged;

  const IdentityStep({
    super.key,
    required this.initialFirstName,
    required this.initialLastName,
    required this.initialEmail,
    required this.initialPhone,
    required this.onChanged,
  });

  @override
  State<IdentityStep> createState() => _IdentityStepState();
}

class _IdentityStepState extends State<IdentityStep> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late String _phone = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialFirstName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phone = widget.initialPhone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onChanged(
      fullName: _nameController.text.trim().toTitleCase(),
      lastName: '',
      email: _emailController.text.trim(),
      phone: _phone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Just a few details to get started.',
            style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0D1B3E),
            fontFamily: 'SF Pro',
            height: 1.2,
            letterSpacing: -0.5,
          ),
          ),
          SizedBox(height: 6.h),
          Text(
            'We\'ll use this to personalize your experience',
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFF9CA3AF),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 24.h),
          _buildLabel('Full Name', isRequired: true),
          SizedBox(height: 6.h),
          _buildField(
            controller: _nameController,
            hint: 'Enter your full name',
          ),
          SizedBox(height: 16.h),
          _buildLabel('Email', isRequired: true),
          SizedBox(height: 6.h),
          _buildField(
            controller: _emailController,
            hint: 'Your email address',
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 16.h),
          _buildLabel('Phone Number'),
          SizedBox(height: 6.h),
          _buildPhoneField(),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F5EF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lock_rounded,
                  color: Colors.orange.shade400,
                  size: 16.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'We won\'t share this with anyone',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0D1B3E),
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 24.h),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        onChanged: (val) {
          setState(() => _phone = val);
          _notifyChange();
        },
        keyboardType: TextInputType.phone,
        style: TextStyle(
          fontFamily: 'SF Pro',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A1A),
        ),
        decoration: InputDecoration(
          hintText: '00000000',
          hintStyle: TextStyle(
            color: const Color(0xFFBDC3C7),
            fontWeight: FontWeight.w400,
            fontSize: 12.sp,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  'https://flagcdn.com/w40/us.png',
                  width: 24.w,
                  height: 16.h,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.arrow_drop_down,
                  color: const Color(0xFF7B8190),
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Container(
                  height: 24.h,
                  width: 1.w,
                  color: const Color(0xFFE5E7EB),
                ),
              ],
            ),
          ),
          suffixIcon: () {
            final digits = _phone.replaceAll(' ', '');
            if (digits.length >= 6 && digits.length <= 15) {
              return IconButton(
                icon: Icon(
                  Icons.check_circle_rounded,
                  color: const Color(0xFF2ECC71),
                  size: 18.sp,
                ),
                onPressed: () => FocusScope.of(context).unfocus(),
              );
            }
            return null;
          }(),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(14.r),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF111827),
          fontFamily: 'SF Pro',
        ),
        children: isRequired ? [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: const Color(0xFFC83A2D),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ] : null,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      onChanged: (_) => _notifyChange(),
      keyboardType: keyboardType,
      textCapitalization: keyboardType == TextInputType.emailAddress ? TextCapitalization.none : TextCapitalization.words,
      style: TextStyle(
        fontFamily: 'SF Pro',
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFFBDC3C7),
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
        ),
        prefixIcon: icon != null
            ? Icon(icon, color: const Color(0xFFBDC3C7), size: 20.sp)
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
          borderSide: const BorderSide(color: Color(0xFFC83A2D), width: 1.5),
        ),
      ),
    );
  }
}
