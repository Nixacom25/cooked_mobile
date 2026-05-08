import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/extensions/string_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/red_button.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';
import '../../core/api_config.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';

// ══════════════════════════════════════════════════════════════════════════════
// MY ACCOUNT SCREEN — HelpCenter-style header, avatar inside the form
// ══════════════════════════════════════════════════════════════════════════════
class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});
  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String _phoneNumberStr = '';
  Uint8List? _selectedImageBytes;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await UserService.instance.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _nameCtrl.text = '${user['firstname'] ?? ''} ${user['lastname'] ?? ''}'
            .trim();
        _emailCtrl.text = user['email'] ?? '';
        _phoneCtrl.text = user['phone'] ?? '';
        _phoneNumberStr = user['phone'] ?? '';
        String? photo = user['profilePictureUrl'];
        if (photo != null && photo.isNotEmpty && !photo.startsWith('http')) {
          _photoUrl = '${ApiConfig.baseUrl}$photo';
        } else {
          _photoUrl = photo;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final fullName = _nameCtrl.text.trim().toTitleCase();
      final nameParts = fullName.split(' ');
      final lastname = nameParts.length > 1 ? nameParts.last : 'Doe';
      final firstname = nameParts.length > 1
          ? nameParts.sublist(0, nameParts.length - 1).join(' ')
          : nameParts.first;

      await UserService.instance.updateCurrentUser(
        firstname: firstname,
        lastname: lastname,
        phone: _phoneNumberStr,
      );

      if (_selectedImageBytes != null) {
        await UserService.instance.uploadProfilePhoto(
          _selectedImageBytes!,
          'profile_photo.jpg',
        );
      }

      if (!mounted) return;
      IosToast.show(context, message: 'Profile updated successfully!', type: ToastType.success);
    } catch (e) {
      if (!mounted) return;
      IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    final nav = Navigator.of(context);
    try {
      await AuthService.instance.logout();
      if (!mounted) return;
      nav.pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
    } catch (e) {
      if (!mounted) return;
      IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _selectedImageBytes = bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // ── Red Header Background ────────────────────────────────────
                SizedBox(
                  height: 180.h,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(15.r),
                    ), // Match Profile Screen
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background image
                        Image.asset(
                          'assets/images/fond4.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                        // Gradient overlay
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [0.0, 0.5],
                              colors: [Color(0xFFC83A2D), Color(0x63C83A2D)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ── AppBar Elements ──────────────────────────────────────────
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10.h,
                  left: 10.w,
                  right: 10.w,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'My Account',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w600,
                          fontSize: 22.sp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Overlapping Avatar ───────────────────────────────────────
                Positioned(
                  bottom: -50.h,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 100.w,
                      height: 100.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 4.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _selectedImageBytes != null
                            ? Image.memory(
                                _selectedImageBytes!,
                                fit: BoxFit.cover,
                              )
                            : _photoUrl != null && _photoUrl!.isNotEmpty
                            ? Image.network(
                                _photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _defaultAvatar(),
                              )
                            : _defaultAvatar(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 60.h),

            // ── Change Picture CTA ───────────────────────────────────────
            GestureDetector(
              onTap: _pickImage,
              child: Text(
                'Change Picture',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: const Color(0xFFC83A2D),
                ),
              ),
            ),
            SizedBox(height: 30.h),

            // ── Form Fields ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Name'),
                  SizedBox(height: 8.h),
                  _field(
                    child: TextField(
                      controller: _nameCtrl,
                      style: _textStyle(),
                      textCapitalization: TextCapitalization.words,
                      decoration: _dec('Name'),
                    ),
                  ),
                  SizedBox(height: 18.h),

                  _label('Email'),
                  SizedBox(height: 8.h),
                  _field(
                    child: TextField(
                      controller: _emailCtrl,
                      style: _textStyle(),
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true,
                      decoration: _dec('Email'),
                    ),
                  ),
                  SizedBox(height: 18.h),

                  _label('Phone Number'),
                  SizedBox(height: 8.h),
                  IntlPhoneField(
                    controller: _phoneCtrl,
                    decoration: InputDecoration(
                      hintText: 'XX XXX XX XX',
                      hintStyle: TextStyle(
                        color: const Color(0xFFBBBBBB),
                        fontFamily: 'SF Pro',
                        fontSize: 14.sp,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: Color(0xFFC83A2D),
                          width: 1.5,
                        ),
                      ),
                    ),
                    initialCountryCode: 'FR',
                    onChanged: (phone) {
                      _phoneNumberStr = phone.completeNumber;
                    },
                    style: _textStyle(),
                    dropdownIcon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF333333),
                      size: 20.sp,
                    ),
                    flagsButtonPadding: EdgeInsets.only(left: 8.w),
                    flagsButtonMargin: EdgeInsets.only(right: 8.w),
                    showCountryFlag: true,
                    showDropdownIcon: true,
                    dropdownIconPosition: IconPosition.trailing,
                    disableLengthCheck: true,
                    textAlignVertical: TextAlignVertical.center,
                  ),
                  SizedBox(height: 36.h),

                  _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: const Color(0xFFC83A2D),
                          ),
                        )
                      : RedButton(
                          label: _isSaving ? 'Saving...' : 'Save Changes',
                          onTap: _isSaving ? () {} : _saveProfile,
                        ),
                  SizedBox(height: 20.h),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: OutlinedButton(
                      onPressed: _logout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFC83A2D),
                        side: const BorderSide(
                          color: Color(0xFFC83A2D),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
TextStyle _textStyle() => TextStyle(
  fontFamily: 'SF Pro',
  fontSize: 15.sp,
  color: const Color(0xFF1A1A1A),
);

Widget _label(String t) => Text(
  t,
  style: TextStyle(
    fontFamily: 'SF Pro',
    fontWeight: FontWeight.w500,
    fontSize: 14.sp,
    color: const Color(0xFF333333),
  ),
);

Widget _field({required Widget child}) => Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.r),
    border: Border.all(color: const Color(0xFFE8E8E8)),
  ),
  child: child,
);

InputDecoration _dec(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: TextStyle(color: const Color(0xFFBBBBBB), fontFamily: 'SF Pro', fontSize: 13.sp),
  border: InputBorder.none,
  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
);

Widget _defaultAvatar() {
  return Container(
    color: const Color(0xFFF0F0F0),
    child: Icon(Icons.person_rounded, size: 40.sp, color: const Color(0xFFAAAAAA)),
  );
}
