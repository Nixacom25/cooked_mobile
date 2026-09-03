import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/extensions/string_extensions.dart';
import 'skeleton_loader.dart';

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
        color: const Color(0xFFFAF5E8), // Cream yellow matching mockup
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: SizedBox(width: 80.w, height: 80.h, child: _buildImage(img)),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toTitleCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w800,
                    fontSize: 16.sp,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 6.h),
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
                          fontFamily: 'Rubik',
                          fontWeight: FontWeight.w500,
                          fontSize: 13.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isSuggested)
            GestureDetector(
              onTap: onValidate,
              child: Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    isValidated
                        ? 'assets/icones/coeur.svg'
                        : 'assets/icones/coeur1.svg',
                    width: 18.r,
                    height: 18.r,
                    colorFilter: ColorFilter.mode(
                      isValidated
                          ? const Color(0xFFC83A2D)
                          : const Color(0xFF94A3B8),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
