import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../services/user_service.dart';
import '../core/widgets/ios_toast.dart';
import '../core/utils/error_helper.dart';

class AlphabetAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final Uint8List? imageBytes;
  final double size;
  final VoidCallback? onTap;
  final bool showEditBadge;

  const AlphabetAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.imageBytes,
    this.size = 40,
    this.onTap,
    this.showEditBadge = false,
  });

  String get _firstLetter {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'C';
    final char = trimmed.characters.first.toUpperCase();
    return RegExp(r'[A-Z0-9]').hasMatch(char) ? char : 'C';
  }

  static Future<void> showPhotoPicker(BuildContext context) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Text(
              'Profile Photo',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(10.r),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library_rounded, color: Color(0xFFC31E26)),
              ),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(fontFamily: 'Rubik', fontSize: 15.sp, fontWeight: FontWeight.w500),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(10.r),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Color(0xFFC31E26)),
              ),
              title: Text(
                'Take a Photo',
                style: TextStyle(fontFamily: 'Rubik', fontSize: 15.sp, fontWeight: FontWeight.w500),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 10.h),
          ],
        ),
      ),
    );

    if (source != null) {
      try {
        final picked = await picker.pickImage(source: source);
        if (picked != null) {
          if (context.mounted) {
            IosToast.show(context, message: 'Updating profile photo...', type: ToastType.success);
          }
          final compressed = await FlutterImageCompress.compressWithFile(
            picked.path,
            minWidth: 500,
            minHeight: 500,
            quality: 75,
          );
          if (compressed != null) {
            await UserService.instance.uploadProfilePhoto(compressed, 'profile_photo.jpg');
            if (context.mounted) {
              IosToast.show(context, message: 'Profile photo updated!', type: ToastType.success);
            }
          }
        }
      } catch (e) {
        if (context.mounted) {
          IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveLetter = _firstLetter;
    final fontSize = size * 0.52;
    final strokeWidth = size * 0.08;

    Widget avatarContent;

    if (imageBytes != null) {
      avatarContent = Image.memory(imageBytes!, fit: BoxFit.cover);
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      avatarContent = CachedNetworkImage(
        imageUrl: photoUrl!,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _buildLetterAvatar(effectiveLetter, fontSize, strokeWidth),
      );
    } else {
      avatarContent = _buildLetterAvatar(effectiveLetter, fontSize, strokeWidth);
    }

    Widget mainAvatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF8FAFC),
        border: Border.all(
          color: Colors.white,
          width: (size * 0.04).clamp(1.5, 3.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(child: avatarContent),
    );

    if (showEditBadge) {
      mainAvatar = Stack(
        clipBehavior: Clip.none,
        children: [
          mainAvatar,
          Positioned(
            right: -2.r,
            bottom: -2.r,
            child: Container(
              width: (size * 0.32).clamp(24.0, 36.0),
              height: (size * 0.32).clamp(24.0, 36.0),
              decoration: BoxDecoration(
                color: const Color(0xFFC31E26),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: (size * 0.16).clamp(12.0, 18.0),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: mainAvatar,
      );
    }

    return mainAvatar;
  }

  Widget _buildLetterAvatar(String letter, double fontSize, double strokeWidth) {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glossy background arc highlight top-left
          Positioned(
            top: size * 0.06,
            left: size * 0.10,
            child: Container(
              width: size * 0.35,
              height: size * 0.20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.5),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Layer 1: Dark Outer Stroke/Outline (Image 2 style)
          Text(
            letter,
            style: GoogleFonts.rubik(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..strokeJoin = StrokeJoin.round
                ..color = const Color(0xFF1E293B),
            ),
          ),

          // Layer 2: Glossy Red Fill (Image 2 style)
          Text(
            letter,
            style: GoogleFonts.rubik(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFC31E26),
            ),
          ),

          // Layer 3: Highlight specular shine line
          Positioned(
            top: size * 0.23,
            child: Text(
              letter,
              style: GoogleFonts.rubik(
                fontSize: fontSize * 0.96,
                fontWeight: FontWeight.w900,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = (strokeWidth * 0.25).clamp(0.5, 2.0)
                  ..color = Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
