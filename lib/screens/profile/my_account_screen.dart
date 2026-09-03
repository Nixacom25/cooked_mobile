import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../core/extensions/string_extensions.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/red_header_background.dart';
import '../../services/user_service.dart';
import '../../core/api_config.dart';
import '../../core/widgets/ios_toast.dart';
import '../../widgets/glass_icon_button.dart';
import '../../core/utils/error_helper.dart';
import '../../widgets/alphabet_avatar.dart';
import '../../widgets/app_loading_indicator.dart';

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
        _nameCtrl.text = '${user['firstname'] ?? ''} ${user['lastname'] ?? ''}'.trim();
        _emailCtrl.text = user['email'] ?? '';
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

  Future<void> _pickImage() async {
    await AlphabetAvatar.showPhotoPicker(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Red background fond_page.png ──
          const Positioned.fill(
            child: RedHeaderBackground(),
          ),
          SafeArea(
            bottom: false,
            child: Container(
              margin: EdgeInsets.only(top: 25.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32.r),
                ),
              ),
              child: Column(
                children: [
                  // ── Header (Back Button & Title) ──
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                    child: Row(
                      children: [
                        GlassIconButton(
                          onTap: () => Navigator.pop(context),
                          size: 42.r,
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 20.sp,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'My Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 20.sp,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        SizedBox(width: 42.r),
                      ],
                    ),
                  ),

                  // ── Form Content ──
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      child: Column(
                        children: [
                          // Avatar
                          AlphabetAvatar(
                            name: _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Chef',
                            photoUrl: _photoUrl,
                            imageBytes: _selectedImageBytes,
                            size: 100.r,
                            showEditBadge: true,
                            onTap: () => AlphabetAvatar.showPhotoPicker(context),
                          ),
                          SizedBox(height: 12.h),

                          // Change Picture
                          GestureDetector(
                            onTap: () => AlphabetAvatar.showPhotoPicker(context),
                            child: Text(
                              'Change Picture',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontWeight: FontWeight.w600,
                                fontSize: 15.sp,
                                color: const Color(0xFFC83A2D),
                              ),
                            ),
                          ),
                          SizedBox(height: 28.h),

                          if (_isLoading)
                            Column(
                              children: [
                                const SkeletonLoader(height: 52, width: double.infinity),
                                SizedBox(height: 18.h),
                                const SkeletonLoader(height: 52, width: double.infinity),
                                SizedBox(height: 18.h),
                                const SkeletonLoader(height: 52, width: double.infinity),
                              ],
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name field
                                _buildLabel('Name'),
                                SizedBox(height: 8.h),
                                _buildInputField(
                                  child: TextField(
                                    controller: _nameCtrl,
                                    style: _inputTextStyle(),
                                    textCapitalization: TextCapitalization.words,
                                    decoration: _inputDecoration('Name'),
                                  ),
                                ),
                                SizedBox(height: 20.h),

                                // Email field
                                _buildLabel('Email'),
                                SizedBox(height: 8.h),
                                _buildInputField(
                                  child: TextField(
                                    controller: _emailCtrl,
                                    style: _inputTextStyle(),
                                    keyboardType: TextInputType.emailAddress,
                                    readOnly: true,
                                    decoration: _inputDecoration('your-mail@example.com'),
                                  ),
                                ),
                                SizedBox(height: 20.h),

                                // Phone field
                                _buildLabel('Phone Number'),
                                SizedBox(height: 8.h),
                                IntlPhoneField(
                                  initialValue: _phoneNumberStr.isNotEmpty ? _phoneNumberStr : null,
                                  controller: _phoneCtrl,
                                  decoration: InputDecoration(
                                    hintText: '33 321 22 33',
                                    hintStyle: TextStyle(
                                      color: const Color(0xFF94A3B8),
                                      fontFamily: 'Rubik',
                                      fontSize: 14.sp,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF1F5F9),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 16.h,
                                    ),
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
                                      borderSide: const BorderSide(
                                        color: Color(0xFFC83A2D),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  initialCountryCode: 'US',
                                  onChanged: (phone) {
                                    _phoneNumberStr = phone.completeNumber;
                                  },
                                  style: _inputTextStyle(),
                                  dropdownIcon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: const Color(0xFF0F172A),
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

                                // Save Changes Button
                                GestureDetector(
                                  onTap: _isSaving ? null : _saveProfile,
                                  child: Container(
                                    width: double.infinity,
                                    height: 54.h,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC31E26),
                                      borderRadius: BorderRadius.circular(27.r),
                                    ),
                                    child: Center(
                                      child: _isSaving
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: AppLoadingIndicator(
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              'Save Changes',
                                              style: TextStyle(
                                                fontFamily: 'Rubik',
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 30.h),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Rubik',
        fontWeight: FontWeight.w500,
        fontSize: 14.sp,
        color: const Color(0xFF64748B),
      ),
    );
  }

  Widget _buildInputField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFF94A3B8),
        fontFamily: 'Rubik',
        fontSize: 14.sp,
      ),
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    );
  }

  TextStyle _inputTextStyle() {
    return TextStyle(
      fontFamily: 'Rubik',
      fontSize: 15.sp,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF0F172A),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: Icon(
        Icons.person_rounded,
        size: 50.sp,
        color: const Color(0xFF94A3B8),
      ),
    );
  }
}
