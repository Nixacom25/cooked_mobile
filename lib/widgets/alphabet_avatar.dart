import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../services/user_service.dart';
import '../core/widgets/ios_toast.dart';
import '../core/utils/error_helper.dart';
import '../core/theme/app_theme.dart';
import '../core/motion/motion_widgets.dart';
import '../core/l10n/l10n.dart';

class AlphabetAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final Uint8List? imageBytes;
  final double size;
  final VoidCallback? onTap;
  final bool showEditBadge;

  final double? borderWidth;

  /// Picks the plate shown when there's no photo. Use the person's id so the
  /// same person gets the same plate on every screen; defaults to [name].
  final String? seed;

  /// Seed for the signed-in user (id, else email, else name).
  static String? get currentUserSeed {
    final user = UserService.instance.currentUserNotifier.value;
    for (final key in ['id', 'email', 'firstname']) {
      final value = user?[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  const AlphabetAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.imageBytes,
    this.size = 40,
    this.onTap,
    this.showEditBadge = false,
    this.borderWidth,
    this.seed,
  });

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

  static Future<void> showPhotoPicker(BuildContext context, {bool compact = false}) async {
    if (compact) {
      await _showCompactPhotoPicker(context);
      return;
    }

    final picker = ImagePicker();
    final user = UserService.instance.currentUserNotifier.value;
    final String name = (user?['firstname'] as String? ?? user?['name'] as String? ?? 'User').trim();
    final String? photoUrl = user?['profilePictureUrl'] as String?;

    final action = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.commonDismiss,
      barrierColor: Colors.black.withValues(alpha: 0.62),
      transitionDuration: Motion.short,
      pageBuilder: (ctx, anim1, anim2) {
        // Blur ramps in with the route instead of snapping on.
        return AnimatedBuilder(
          animation: anim1,
          builder: (context, child) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20 * anim1.value, sigmaY: 20 * anim1.value),
            child: child,
          ),
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
                        // Enlarged Hero Profile Photo
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.45),
                                blurRadius: 32.r,
                                offset: Offset(0, 12.h),
                              ),
                            ],
                          ),
                          child: AlphabetAvatar(
                            name: name,
                            seed: AlphabetAvatar.currentUserSeed,
                            photoUrl: photoUrl,
                            size: 240.r,
                            borderWidth: 0,
                            showEditBadge: false,
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Action Menu Card styled with premium frosted glass finish
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28.r),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                            child: Container(
                              width: 310.w,
                              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.25),
                                    Colors.white.withValues(alpha: 0.10),
                                    // Fixed dark tint (not textPrimary): this glass
                                    // panel sits over the photo viewer's dark scrim
                                    // in both themes, and textPrimary flips to
                                    // near-white in dark mode, which inverted the
                                    // whole gradient instead of darkening it.
                                    Colors.black.withValues(alpha: 0.70),
                                  ],
                                  stops: const [0.0, 0.35, 1.0],
                                ),
                                borderRadius: BorderRadius.circular(28.r),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.38),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    blurRadius: 32.r,
                                    offset: Offset(0, 12.h),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    blurRadius: 10.r,
                                    spreadRadius: -2.r,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 1. Choose from library
                                    _buildPickerItem(
                                      icon: Icons.photo_library_outlined,
                                      title: context.l10n.avatarChooseLibrary,
                                      color: context.colors.surface,
                                      onTap: () => Navigator.pop(ctx, 'gallery'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                                      child: Divider(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        height: 1.h,
                                        thickness: 0.8,
                                      ),
                                    ),

                                    // 2. Take photo
                                    _buildPickerItem(
                                      icon: Icons.camera_alt_outlined,
                                      title: context.l10n.avatarTakePhoto,
                                      color: Colors.white,
                                      onTap: () => Navigator.pop(ctx, 'camera'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                                      child: Divider(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        height: 1.h,
                                        thickness: 0.8,
                                      ),
                                    ),

                                    // 3. Delete
                                    _buildPickerItem(
                                      icon: Icons.delete_outline_rounded,
                                      title: context.l10n.commonDelete,
                                      color: context.colors.destructive,
                                      onTap: () => Navigator.pop(ctx, 'delete'),
                                    ),
                                  ],
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
      transitionBuilder: (ctx, anim1, anim2, child) =>
          GlassPopIn(animation: anim1, alignment: Alignment.center, child: child),
    );

    if (!context.mounted) return;
    await _handlePickerAction(context, action, picker);
  }

  // ── Compact glass dropdown, anchored under the tapped avatar ──
  // (used by the home header; mirrors the "⋮" Profile/Logout menu style)
  static Future<void> _showCompactPhotoPicker(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final picker = ImagePicker();

    final RenderBox? avatarBox = context.findRenderObject() as RenderBox?;
    final RenderBox? overlay = Navigator.of(context).overlay?.context.findRenderObject() as RenderBox?;

    double topPos = 100.h;
    double leftPos = 16.w;
    if (avatarBox != null && overlay != null) {
      final Offset topLeft = avatarBox.localToGlobal(Offset.zero, ancestor: overlay);
      topPos = topLeft.dy + avatarBox.size.height + 8.h;
      leftPos = topLeft.dx;
    }

    final action = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.commonDismiss,
      barrierColor: Colors.black.withValues(alpha: 0.12),
      transitionDuration: Motion.short,
      pageBuilder: (ctx, anim1, anim2) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              top: topPos,
              left: leftPos,
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      width: 210.w,
                      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 6.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? context.colors.elevatedSurface.withValues(alpha: 0.75)
                            : Colors.white.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.16)
                              : Colors.white.withValues(alpha: 0.65),
                          width: 1.5.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildCompactMenuItem(
                            icon: Icons.photo_library_outlined,
                            label: context.l10n.avatarChooseLibrary,
                            color: context.colors.textPrimary,
                            onTap: () => Navigator.pop(ctx, 'gallery'),
                          ),
                          _buildCompactMenuItem(
                            icon: Icons.camera_alt_outlined,
                            label: context.l10n.avatarTakePhoto,
                            color: context.colors.textPrimary,
                            onTap: () => Navigator.pop(ctx, 'camera'),
                          ),
                          _buildCompactMenuItem(
                            icon: Icons.delete_outline_rounded,
                            label: context.l10n.commonDelete,
                            color: context.colors.accent,
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
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) =>
          GlassPopIn(animation: anim1, alignment: Alignment.topLeft, child: child),
    );

    if (!context.mounted) return;
    await _handlePickerAction(context, action, picker);
  }

  static Future<void> _handlePickerAction(BuildContext context, String? action, ImagePicker picker) async {
    if (action == null) return;

    if (action == 'delete') {
      try {
        if (context.mounted) {
          IosToast.show(context, message: context.l10n.avatarDeleting, type: ToastType.success);
        }
        await UserService.instance.deleteProfilePhoto();
        if (context.mounted) {
          IosToast.show(context, message: context.l10n.avatarDeleted, type: ToastType.success);
        }
      } catch (e) {
        if (context.mounted) {
          IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
        }
      }
      return;
    }

    final ImageSource? source = (action == 'camera')
        ? ImageSource.camera
        : (action == 'gallery' || action == 'facebook' ? ImageSource.gallery : null);

    if (source != null) {
      try {
        final picked = await picker.pickImage(source: source);
        if (picked != null) {
          if (context.mounted) {
            IosToast.show(context, message: context.l10n.avatarUpdating, type: ToastType.success);
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
              IosToast.show(context, message: context.l10n.avatarUpdated, type: ToastType.success);
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

  static Widget _buildCompactMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: color),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildPickerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white.withValues(alpha: 0.15),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              SizedBox(width: 14.w),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: color.withValues(alpha: 0.5),
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget avatarContent;

    if (imageBytes != null && imageBytes!.isNotEmpty) {
      avatarContent = Image.memory(imageBytes!, fit: BoxFit.cover);
    } else if (_hasCustomPhoto) {
      avatarContent = CachedNetworkImage(
        imageUrl: photoUrl!,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _buildPlateAvatar(),
      );
    } else {
      avatarContent = _buildPlateAvatar();
    }

    final double effectiveBorderWidth = borderWidth ?? (size * 0.04).clamp(1.5, 3.5);

    Widget mainAvatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.surface,
        border: effectiveBorderWidth > 0
            ? Border.all(
                color: Colors.white,
                width: effectiveBorderWidth,
              )
            : null,
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
                color: context.colors.accent,
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

  /// Users without a photo get one of the 8 Cooked "plate" avatars, picked
  /// from their name so the same person always gets the same plate.
  Widget _buildPlateAvatar() => SvgPicture.asset(
        plateAvatarAsset(seed ?? name),
        width: size,
        height: size,
        fit: BoxFit.cover,
      );

  /// Stable across launches (unlike String.hashCode, which is not guaranteed).
  static String plateAvatarAsset(String seed) {
    final key = seed.trim().toLowerCase();
    var hash = 0;
    for (final unit in key.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    final index = (key.isEmpty ? 0 : hash % 8) + 1;
    return 'assets/images/avatars/plate_0$index.svg';
  }
}
