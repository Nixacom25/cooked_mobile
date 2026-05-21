import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/extensions/string_extensions.dart';
import 'skeleton_loader.dart';
import 'animated_validation_button.dart';

class RecentImportTile extends StatelessWidget {
  final String img;
  final String title;
  final String source;
  final String? sourceUrl;
  final IconData srcIcon;
  final Color srcIconColor;
  final String? srcAsset;
  final bool isSuggested;
  final int index;
  final VoidCallback onValidate;
  final bool isValidated;

  const RecentImportTile({
    super.key,
    required this.img,
    required this.title,
    required this.source,
    this.sourceUrl,
    required this.srcIcon,
    required this.srcIconColor,
    this.srcAsset,
    this.isSuggested = false,
    this.index = 0,
    required this.onValidate,
    this.isValidated = false,
  });

  Future<void> _launchUrl() async {
    if (sourceUrl == null || sourceUrl!.isEmpty) return;
    final Uri url = Uri.parse(sourceUrl!);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $sourceUrl');
    }
  }

  Widget _buildImage(String path) {
    if (path.isEmpty) {
      return Image.asset('assets/images/recipes.png', fit: BoxFit.cover);
    }
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: const Color(0xFFF2F1EF),
          child: const Center(
            child: SkeletonLoader(width: 30, height: 30, borderRadius: 15),
          ),
        ),
        errorWidget: (_, __, ___) =>
            Image.asset('assets/images/recipes.png', fit: BoxFit.cover),
      );
    }
    return Image.asset(path, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F8F6),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(width: 56.w, height: 56.h, child: _buildImage(img)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toTitleCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 4.h),
                GestureDetector(
                  onTap: _launchUrl,
                  child: Row(
                    children: [
                      if (srcAsset != null)
                        Image.asset(srcAsset!, width: 14.w, height: 14.h)
                      else
                        Icon(srcIcon, size: 14.sp, color: srcIconColor),
                      SizedBox(width: 6.w),
                      Text(
                        source,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 12.sp,
                          color: const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isSuggested)
            AnimatedValidationButton(
              isValidated: isValidated,
              onTap: onValidate,
              useWhiteBackground: true,
              autoAnimate: false,
              index: index,
              disableSlide: false,
            ),
        ],
      ),
    );
  }
}
