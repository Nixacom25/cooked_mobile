import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'skeleton_loader.dart';

class CookbookGridSkeleton extends StatelessWidget {
  final int itemCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry padding;

  const CookbookGridSkeleton({
    super.key,
    this.itemCount = 6,
    this.childAspectRatio = 0.72,
    this.crossAxisSpacing = 14,
    this.mainAxisSpacing = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 18),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: mainAxisSpacing.h,
        crossAxisSpacing: crossAxisSpacing.w,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            width: double.infinity,
            height: 155.h,
            borderRadius: 16,
          ),
          SizedBox(height: 10.h),
          SkeletonLoader(width: 140.w, height: 16.h),
          SizedBox(height: 6.h),
          SkeletonLoader(width: 80.w, height: 12.h),
        ],
      ),
    );
  }
}
