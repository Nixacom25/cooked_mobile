import 'dart:ui';
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
    if (trimmed.isEmpty) return 'c';
    final char = trimmed.characters.first;
    return RegExp(r'[a-zA-Z0-9]').hasMatch(char) ? char : 'c';
  }

  bool get _hasCustomPhoto {
    if (imageBytes != null && imageBytes!.isNotEmpty) return true;
    if (photoUrl == null) return false;
    final trimmed = photoUrl!.trim();
    if (trimmed.isEmpty) return false;

    final lower = trimmed.toLowerCase();
    // Default avatar generators or placeholder links are NOT custom user-uploaded photos
    if (lower.contains('ui-avatars.com') ||
        lower.contains('gravatar.com') ||
        lower.contains('default_avatar') ||
        lower.contains('default-avatar') ||
        lower.contains('placeholder') ||
        lower.contains('avatar_default') ||
        lower.contains('dicebear') ||
        lower.contains('lh3.googleusercontent.com') ||
        lower.contains('avatars.githubusercontent.com')) {
      return false;
    }
    return true;
  }

  static Future<void> showPhotoPicker(BuildContext context) async {
    final picker = ImagePicker();
    final user = UserService.instance.currentUserNotifier.value;
    final String name = (user?['firstname'] as String? ?? user?['name'] as String? ?? 'User').trim();
    final String? photoUrl = user?['profilePictureUrl'] as String?;

    final action = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: SafeArea(
            child: Stack(
              children: [
                // Tap outside to dismiss
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox.expand(),
                  ),
                ),

                Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Enlarged Profile Photo with sleek white border & shadow
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3.5.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: AlphabetAvatar(
                            name: name,
                            photoUrl: photoUrl,
                            size: 130.r,
                            showEditBadge: false,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Action Menu Card styled like header bottom / bottom nav frosted glass
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22.r),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                            child: Container(
                              width: 290.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22.r),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: const Color(0xFF1E293B).withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(22.r),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 6.h,
                                    horizontal: 8.w,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 2.h,
                                        ),
                                        leading: Icon(
                                          Icons.image_outlined,
                                          color: Colors.white,
                                          size: 22.sp,
                                        ),
                                        title: Text(
                                          'Choose from library',
                                          style: TextStyle(
                                            fontFamily: 'Rubik',
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                        onTap: () => Navigator.pop(ctx, 'gallery'),
                                      ),
                                      Divider(
                                        height: 1,
                                        color: Colors.white.withValues(alpha: 0.12),
                                        indent: 12.w,
                                        endIndent: 12.w,
                                      ),
                                      ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 2.h,
                                        ),
                                        leading: Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.white,
                                          size: 22.sp,
                                        ),
                                        title: Text(
                                          'Take photo',
                                          style: TextStyle(
                                            fontFamily: 'Rubik',
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                        onTap: () => Navigator.pop(ctx, 'camera'),
                                      ),
                                      Divider(
                                        height: 1,
                                        color: Colors.white.withValues(alpha: 0.12),
                                        indent: 12.w,
                                        endIndent: 12.w,
                                      ),
                                      ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 2.h,
                                        ),
                                        leading: Icon(
                                          Icons.delete_outline_rounded,
                                          color: const Color(0xFFF87171),
                                          size: 22.sp,
                                        ),
                                        title: Text(
                                          'Delete',
                                          style: TextStyle(
                                            fontFamily: 'Rubik',
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFFF87171),
                                          ),
                                        ),
                                        onTap: () => Navigator.pop(ctx, 'delete'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );

    if (action == null) return;

    if (action == 'delete') {
      try {
        if (context.mounted) {
          IosToast.show(context, message: 'Deleting profile photo...', type: ToastType.success);
        }
        await UserService.instance.deleteProfilePhoto();
        if (context.mounted) {
          IosToast.show(context, message: 'Profile photo deleted', type: ToastType.success);
        }
      } catch (e) {
        if (context.mounted) {
          IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
        }
      }
      return;
    }

    final ImageSource? source = action == 'camera'
        ? ImageSource.camera
        : (action == 'gallery' ? ImageSource.gallery : null);

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

    if (imageBytes != null && imageBytes!.isNotEmpty) {
      avatarContent = Image.memory(imageBytes!, fit: BoxFit.cover);
    } else if (_hasCustomPhoto) {
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
    final char = letter.toLowerCase();
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glossy background arc highlight top-left
          Positioned(
            top: size * 0.05,
            left: size * 0.08,
            child: Container(
              width: size * 0.4,
              height: size * 0.25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.6),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Layer 1: Thick Black Outer Stroke/Outline (Image 2 style)
          Text(
            char,
            style: GoogleFonts.rubik(
              fontSize: fontSize * 1.15,
              fontWeight: FontWeight.w900,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = (strokeWidth * 1.6).clamp(2.0, 6.0)
                ..strokeJoin = StrokeJoin.round
                ..color = const Color(0xFF1E1E1E),
            ),
          ),

          // Layer 2: Glossy Red Fill (Image 2 style)
          Text(
            char,
            style: GoogleFonts.rubik(
              fontSize: fontSize * 1.15,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFC31E26),
            ),
          ),

          // Layer 3: Specular White Inner Highlight Line (Image 2 style)
          Positioned(
            top: size * 0.22,
            left: size * 0.26,
            child: Text(
              char,
              style: GoogleFonts.rubik(
                fontSize: fontSize * 1.10,
                fontWeight: FontWeight.w900,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = (strokeWidth * 0.35).clamp(0.6, 2.2)
                  ..color = Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
